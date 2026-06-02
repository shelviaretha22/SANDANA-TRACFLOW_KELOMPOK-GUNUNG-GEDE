import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sandana_trackflow.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // TABEL USERS
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        department TEXT NOT NULL,
        phone TEXT,
        photo_path TEXT,
        created_at TEXT
      )
    ''');

    // TABEL DOCUMENTS
    await db.execute('''
      CREATE TABLE documents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        lead_project TEXT,
        assign_to TEXT,
        start_date TEXT,
        end_date TEXT,
        file_path TEXT,
        status TEXT DEFAULT 'active',
        created_by INTEGER,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (created_by) REFERENCES users(id)
      )
    ''');

    // TABEL DOCUMENT APPROVALS (tanda tangan)
    await db.execute('''
      CREATE TABLE document_approvals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        document_id INTEGER NOT NULL,
        approver_id INTEGER NOT NULL,
        approver_department TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        signature_path TEXT,
        approved_at TEXT,
        FOREIGN KEY (document_id) REFERENCES documents(id),
        FOREIGN KEY (approver_id) REFERENCES users(id)
      )
    ''');

    // TABEL NOTIFICATIONS
    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        document_id INTEGER,
        title TEXT NOT NULL,
        message TEXT,
        from_department TEXT,
        is_read INTEGER DEFAULT 0,
        created_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // INSERT DEFAULT USERS
    await _insertDefaultUsers(db);
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future _insertDefaultUsers(Database db) async {
    final now = DateTime.now().toIso8601String();
    final users = [
      {
        'name': 'Naflisha',
        'email': 'naflishasamator@gmail.com',
        'password': _hashPassword('sales123'),
        'department': 'Sales Department',
        'phone': '+6281234567890',
        'created_at': now,
      },
      {
        'name': 'Nadiaa',
        'email': 'nadiaaCEO@gmail.com',
        'password': _hashPassword('engineering123'),
        'department': 'Engineering Department',
        'phone': '+6281234567891',
        'created_at': now,
      },
      {
        'name': 'Shelvia',
        'email': 'shelvisamator@gmail.com',
        'password': _hashPassword('finance123'),
        'department': 'Finance Department',
        'phone': '+6281234567892',
        'created_at': now,
      },
    ];
    for (final user in users) {
      await db.insert('users', user);
    }
  }

  // ── USER METHODS ──────────────────────────────────────────

  Future<Map<String, dynamic>?> getUserByEmailAndPassword(
      String email, String password) async {
    final db = await database;
    final hashed = _hashPassword(password);
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, hashed],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    final result =
        await db.query('users', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateUser(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('users', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> changePassword(
      int userId, String currentPassword, String newPassword) async {
    final db = await database;
    final hashed = _hashPassword(currentPassword);
    final result = await db.query('users',
        where: 'id = ? AND password = ?', whereArgs: [userId, hashed]);
    if (result.isEmpty) return false;
    final newHashed = _hashPassword(newPassword);
    await db.update('users', {'password': newHashed},
        where: 'id = ?', whereArgs: [userId]);
    return true;
  }

  Future<List<Map<String, dynamic>>> getUsersByDepartment(String dept) async {
    final db = await database;
    return await db
        .query('users', where: 'department = ?', whereArgs: [dept]);
  }

  // ── DOCUMENT METHODS ──────────────────────────────────────

  Future<int> insertDocument(Map<String, dynamic> data) async {
    final db = await database;
    data['created_at'] = DateTime.now().toIso8601String();
    data['updated_at'] = DateTime.now().toIso8601String();
    return await db.insert('documents', data);
  }

  Future<List<Map<String, dynamic>>> getDocumentsByStatus(
      String status) async {
    final db = await database;
    return await db.query('documents',
        where: 'status = ?', whereArgs: [status], orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getAllDocuments() async {
    final db = await database;
    return await db.query('documents', orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getDocumentsByType(String type) async {
    final db = await database;
    return await db.query('documents',
        where: 'type = ?', whereArgs: [type], orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getDocumentsByCreator(
      int userId) async {
    final db = await database;
    return await db.query('documents',
        where: 'created_by = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> getDocumentById(int id) async {
    final db = await database;
    final result =
        await db.query('documents', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateDocument(int id, Map<String, dynamic> data) async {
    final db = await database;
    data['updated_at'] = DateTime.now().toIso8601String();
    return await db
        .update('documents', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteDocument(int id) async {
    final db = await database;
    return await db.delete('documents', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, int>> getStatusSummary() async {
    final db = await database;
    final active = Sqflite.firstIntValue(await db.rawQuery(
        "SELECT COUNT(*) FROM documents WHERE status='active'")) ?? 0;
    final delay = Sqflite.firstIntValue(await db.rawQuery(
        "SELECT COUNT(*) FROM documents WHERE status='delay'")) ?? 0;
    final done = Sqflite.firstIntValue(await db.rawQuery(
        "SELECT COUNT(*) FROM documents WHERE status='done'")) ?? 0;
    final payment = Sqflite.firstIntValue(await db.rawQuery(
        "SELECT COUNT(*) FROM documents WHERE status='payment'")) ?? 0;
    return {'active': active, 'delay': delay, 'done': done, 'payment': payment};
  }

  // ── APPROVAL METHODS ──────────────────────────────────────

  Future<int> insertApproval(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('document_approvals', data);
  }

  Future<List<Map<String, dynamic>>> getApprovalsByDocument(
      int documentId) async {
    final db = await database;
    return await db.query('document_approvals',
        where: 'document_id = ?', whereArgs: [documentId]);
  }

  Future<int> updateApproval(int id, Map<String, dynamic> data) async {
    final db = await database;
    data['approved_at'] = DateTime.now().toIso8601String();
    return await db.update('document_approvals', data,
        where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getPendingApprovals(
      int approverId) async {
    final db = await database;
    return await db.query('document_approvals',
        where: 'approver_id = ? AND status = ?',
        whereArgs: [approverId, 'pending']);
  }

  // ── NOTIFICATION METHODS ──────────────────────────────────

  Future<int> insertNotification(Map<String, dynamic> data) async {
    final db = await database;
    data['created_at'] = DateTime.now().toIso8601String();
    return await db.insert('notifications', data);
  }

  Future<List<Map<String, dynamic>>> getNotificationsByUser(
      int userId) async {
    final db = await database;
    return await db.query('notifications',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC');
  }

  Future<int> markNotificationRead(int id) async {
    final db = await database;
    return await db.update('notifications', {'is_read': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getUnreadCount(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
        "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0",
        [userId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
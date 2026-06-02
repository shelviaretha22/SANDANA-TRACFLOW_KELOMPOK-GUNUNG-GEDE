import 'package:flutter/foundation.dart';
import '../core/database/db_helper.dart';

class ReportViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> _documents = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get documents => _documents;
  bool get isLoading => _isLoading;

  Future<void> loadReports(String department) async {
    _isLoading = true;
    notifyListeners();

    final db  = DBHelper.instance;
    final all = await db.getAllDocuments();

    // Filter sesuai role:
    // Sales    → semua dokumen (BRD milik sendiri + Berita Acara + Invoice)
    // Engineer → BRD (untuk TTD) + Berita Acara (milik sendiri)
    // Finance  → BRD (TTD) + Berita Acara (TTD) + Invoice (milik sendiri)
    if (department == 'Engineering Department') {
      _documents = all
          .where((d) => d['type'] == 'brd' || d['type'] == 'berita_acara')
          .toList();
    } else if (department == 'Finance Department') {
      _documents = all
          .where((d) =>
              d['type'] == 'brd' ||
              d['type'] == 'berita_acara' ||
              d['type'] == 'invoice')
          .toList();
    } else {
      // Sales → semua
      _documents = all;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateDocumentStatus(int docId, String newStatus) async {
    await DBHelper.instance.updateDocument(docId, {'status': newStatus});
    final idx = _documents.indexWhere((d) => d['id'] == docId);
    if (idx != -1) {
      _documents[idx] = Map<String, dynamic>.from(_documents[idx])
        ..['status'] = newStatus;
    }
    notifyListeners();
  }

  Future<void> deleteDocument(int docId) async {
    await DBHelper.instance.deleteDocument(docId);
    _documents.removeWhere((d) => d['id'] == docId);
    notifyListeners();
  }
}
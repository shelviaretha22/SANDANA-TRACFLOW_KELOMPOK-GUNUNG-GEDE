import 'package:flutter/foundation.dart';
import '../core/database/db_helper.dart';

class DocumentViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // ── Submit Dokumen Baru ──────────────────────────────────────────

  Future<bool> submitDocument({
    required String type,
    required String title,
    required String description,
    required String leadProject,
    required String assignTo,
    required String startDate,
    required String endDate,
    required String? filePath,
    required int createdBy,
    required String creatorDepartment,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final db = DBHelper.instance;

      final docId = await db.insertDocument({
        'type': type,
        'title': title,
        'description': description,
        'lead_project': leadProject,
        'assign_to': assignTo,
        'start_date': startDate,
        'end_date': endDate,
        'file_path': filePath,
        'status': 'active',
        'created_by': createdBy,
      });

      await _sendNotificationsAndApprovals(
        docId: docId,
        title: title,
        assignTo: assignTo,
        senderDepartment: creatorDepartment,
      );

      _successMessage = 'Dokumen berhasil dikirim!';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengirim dokumen: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _sendNotificationsAndApprovals({
    required int docId,
    required String title,
    required String assignTo,
    required String senderDepartment,
  }) async {
    final db = DBHelper.instance;
    final targets = assignTo.split(',').map((s) => s.trim()).toList();

    for (final dept in targets) {
      if (dept.isEmpty) continue;
      final users = await db.getUsersByDepartment(dept);
      for (final user in users) {
        await db.insertNotification({
          'user_id': user['id'],
          'document_id': docId,
          'title': 'Dokumen baru perlu ditandatangani',
          'message': '"$title" membutuhkan persetujuan kamu.',
          'from_department': senderDepartment,
          'is_read': 0,
        });
        await db.insertApproval({
          'document_id': docId,
          'approver_id': user['id'],
          'approver_department': user['department'],
          'status': 'pending',
        });
      }
    }
  }

  // ── Approve Dokumen ──────────────────────────────────────────────

  Future<bool> approveDocument(
    int approverId,
    int documentId,
    String? signaturePath,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = DBHelper.instance;

      // Cari approval record milik user ini yang masih pending
      final allApprovals = await db.getApprovalsByDocument(documentId);
      final myPending = allApprovals.where(
        (a) => a['approver_id'] == approverId && a['status'] == 'pending',
      ).toList();

      if (myPending.isNotEmpty) {
        // Update approval milik user ini
        await db.updateApproval(myPending.first['id'] as int, {
          'status': 'approved',
          'signature_path': signaturePath,
        });
      } else {
        // Fallback: update satu pending approval
        final pending = allApprovals.where((a) => a['status'] == 'pending').toList();
        if (pending.isNotEmpty) {
          await db.updateApproval(pending.first['id'] as int, {
            'status': 'approved',
            'signature_path': signaturePath,
          });
        }
      }

      // ── Cek apakah SEMUA approver sudah approve ──────────────────
      // Kalau iya → status dokumen otomatis jadi 'done'
      final updatedApprovals = await db.getApprovalsByDocument(documentId);
      if (updatedApprovals.isNotEmpty &&
          updatedApprovals.every((a) => a['status'] == 'approved')) {
        await db.updateDocument(documentId, {'status': 'done'});
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menyetujui: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateDocumentStatus(int docId, String status) async {
    await DBHelper.instance.updateDocument(docId, {'status': status});
    notifyListeners();
  }

  // ── Cek Alur ─────────────────────────────────────────────────────

  Future<bool> isBrdFullyApproved() async {
    final db   = DBHelper.instance;
    final brds = await db.getDocumentsByType('brd');
    if (brds.isEmpty) return false;
    for (final brd in brds) {
      final approvals = await db.getApprovalsByDocument(brd['id'] as int);
      if (approvals.isNotEmpty &&
          approvals.every((a) => a['status'] == 'approved')) return true;
    }
    return false;
  }

  Future<bool> isBeritaAcaraApproved() async {
    final db  = DBHelper.instance;
    final bas = await db.getDocumentsByType('berita_acara');
    if (bas.isEmpty) return false;
    for (final ba in bas) {
      final approvals = await db.getApprovalsByDocument(ba['id'] as int);
      if (approvals.isEmpty) continue;
      final financeApproval = approvals.where(
        (a) => a['approver_department'] == 'Finance Department',
      ).toList();
      if (financeApproval.isNotEmpty &&
          financeApproval.every((a) => a['status'] == 'approved')) return true;
    }
    return false;
  }
}
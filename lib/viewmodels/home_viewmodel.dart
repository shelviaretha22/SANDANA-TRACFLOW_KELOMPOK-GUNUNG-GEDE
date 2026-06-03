import 'package:flutter/foundation.dart';
import '../core/database/db_helper.dart';

class HomeViewModel extends ChangeNotifier {
  Map<String, int> _statusSummary = {
    'active': 0,
    'delay': 0,
    'done': 0,
    'payment': 0,
  };
  List<Map<String, dynamic>> _recentDocuments = [];

  // Map<docId, progressValue 0.0–1.0>
  // Dihitung dari jumlah TTD nyata di tabel document_approvals
  Map<int, double> _progressMap = {};

  bool _isLoading = false;

  Map<String, int> get statusSummary => _statusSummary;
  List<Map<String, dynamic>> get recentDocuments => _recentDocuments;
  Map<int, double> get progressMap => _progressMap;
  bool get isLoading => _isLoading;

  Future<void> loadHomeData(String department) async {
    _isLoading = true;
    notifyListeners();

    final db = DBHelper.instance;

    // Summary count — sama untuk semua role
    _statusSummary = await db.getStatusSummary();

    // Ambil semua dokumen
    final all = await db.getAllDocuments();

    // Filter recent documents berdasarkan role
    if (department == 'Finance Department') {
      _recentDocuments = all
          .where((d) =>
              d['type'] == 'brd' ||
              d['type'] == 'berita_acara' ||
              d['type'] == 'invoice')
          .take(10)
          .toList();
    } else if (department == 'Engineering Department') {
      _recentDocuments = all
          .where((d) =>
              d['type'] == 'brd' ||
              d['type'] == 'berita_acara')
          .take(10)
          .toList();
    } else {
      // Sales — lihat semua
      _recentDocuments = all.take(10).toList();
    }

    // Hitung progress tiap dokumen dari approval nyata
    await _loadProgressMap(_recentDocuments);

    _isLoading = false;
    notifyListeners();
  }

  /// Hitung progress per dokumen:
  /// progress = approved / total approvers
  /// 0 TTD dari 2  → 0.0  (0%)
  /// 1 TTD dari 2  → 0.5  (50%)
  /// 2 TTD dari 2  → 1.0  (100%)
  Future<void> _loadProgressMap(List<Map<String, dynamic>> docs) async {
    final db = DBHelper.instance;
    final map = <int, double>{};

    for (final doc in docs) {
      final docId = doc['id'] as int;
      final status = doc['status'] as String?;

      // Kalau status done/payment langsung 100%
      if (status == 'done' || status == 'payment') {
        map[docId] = 1.0;
        continue;
      }

      final approvals = await db.getApprovalsByDocument(docId);
      if (approvals.isEmpty) {
        map[docId] = 0.0;
      } else {
        final total    = approvals.length;
        final approved = approvals
            .where((a) => a['status'] == 'approved')
            .length;
        map[docId] = approved / total;
      }
    }

    _progressMap = map;
  }

  Future<void> refresh(String department) async {
    await loadHomeData(department);
  }
}
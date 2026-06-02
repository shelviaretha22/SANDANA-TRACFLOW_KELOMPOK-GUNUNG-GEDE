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
  bool _isLoading = false;

  Map<String, int> get statusSummary => _statusSummary;
  List<Map<String, dynamic>> get recentDocuments => _recentDocuments;
  bool get isLoading => _isLoading;

  Future<void> loadHomeData(String department) async {
    _isLoading = true;
    notifyListeners();

    final db = DBHelper.instance;

    // Summary count — sama untuk semua role
    _statusSummary = await db.getStatusSummary();

    // Ambil semua dokumen
    final all = await db.getAllDocuments();

    // Filter recent documents berdasarkan role:
    // Finance  → BRD + Berita Acara (dokumen yang perlu dia approve / sudah dia approve)
    // Engineer → BRD + Invoice
    // Sales    → semua
    if (department == 'Finance Department') {
      _recentDocuments = all
          .where((d) => d['type'] == 'brd' || d['type'] == 'berita_acara')
          .take(10)
          .toList();
    } else if (department == 'Engineering Department') {
      _recentDocuments = all
          .where((d) => d['type'] == 'brd' || d['type'] == 'invoice')
          .take(10)
          .toList();
    } else {
      // Sales — lihat semua
      _recentDocuments = all.take(10).toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Panggil ini setelah approve/delete supaya home refresh
  Future<void> refresh(String department) async {
    await loadHomeData(department);
  }
}
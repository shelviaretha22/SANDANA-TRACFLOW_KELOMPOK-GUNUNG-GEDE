import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../core/database/db_helper.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/report_viewmodel.dart';
import '../widgets/bottom_navbar.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  Set<int> _myApprovedIds = {};  // doc_id yang sudah di-TTD user ini
  Set<int> _myCreatedIds  = {};  // doc_id yang dibuat user ini
  // doc_id BRD yang sudah ada minimal 1 orang approve
  // → Sales tidak boleh hapus kalau ini berisi docId-nya
  Set<int> _brdPartiallyApproved = {};
  bool _loadingExtra = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final user = context.read<AuthViewModel>().currentUser;
    if (user == null) return;
    context.read<ReportViewModel>().loadReports(user.department);
    await _loadExtraInfo(user.id!);
  }

  Future<void> _loadExtraInfo(int userId) async {
    if (!mounted) return;
    setState(() => _loadingExtra = true);
    try {
      final dbRaw = await DBHelper.instance.database;

      // Dokumen yang sudah di-TTD user ini
      final approvedRows = await dbRaw.rawQuery(
        'SELECT document_id FROM document_approvals '
        'WHERE approver_id = ? AND status = ?',
        [userId, 'approved'],
      );
      final approved = approvedRows
          .map((r) => r['document_id'] as int)
          .toSet();

      // Dokumen yang dibuat user ini
      final createdRows = await dbRaw.rawQuery(
        'SELECT id FROM documents WHERE created_by = ?',
        [userId],
      );
      final created = createdRows.map((r) => r['id'] as int).toSet();

      // BRD yang sudah ada minimal 1 approval (partial/full)
      // → Sales tidak boleh hapus BRD ini
      final partialRows = await dbRaw.rawQuery(
        "SELECT DISTINCT document_id FROM document_approvals "
        "WHERE status = 'approved' "
        "AND document_id IN ("
        "  SELECT id FROM documents WHERE type = 'brd'"
        ")",
      );
      final partialApproved = partialRows
          .map((r) => r['document_id'] as int)
          .toSet();

      if (mounted) setState(() {
        _myApprovedIds        = approved;
        _myCreatedIds         = created;
        _brdPartiallyApproved = partialApproved;
        _loadingExtra         = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingExtra = false);
    }
  }

  /// Aturan TTD yang berlaku:
  ///   BRD          → Finance + Engineering
  ///   Berita Acara → Finance saja
  ///   Invoice      → Sales saja
  ///
  /// Return: 'see_details' | 'waiting' | 'sign' | 'update'
  String _buttonType(Map<String, dynamic> doc, String dept) {
    final type      = doc['type'] as String?;
    final status    = doc['status'] as String?;
    final docId     = doc['id'] as int;
    final isMine    = _myCreatedIds.contains(docId);
    final hasMySign = _myApprovedIds.contains(docId);

    // Status done → selesai semua → SEE DETAILS
    if (status == 'done') return 'see_details';

    // Sudah TTD → SEE DETAILS (tidak bisa TTD lagi)
    if (hasMySign) return 'see_details';

    // Apakah user ini boleh TTD dokumen ini?
    final bool canSign;
    if (type == 'brd') {
      canSign = dept == 'Finance Department' ||
                dept == 'Engineering Department';
    } else if (type == 'berita_acara') {
      canSign = dept == 'Finance Department';
    } else if (type == 'invoice') {
      canSign = dept == 'Sales Department';
    } else {
      canSign = false;
    }

    // Dokumen buatan sendiri → WAITING
    if (isMine) return 'waiting';

    // Boleh TTD → TANDA TANGAN
    if (canSign) return 'sign';

    // Tidak punya aksi (misal Sales lihat Berita Acara orang lain) → SEE DETAILS
    return 'see_details';
  }

  // ── Helpers warna & label ─────────────────────────────────────────

  Color _cardColor(String? type) {
    switch (type) {
      case 'brd':          return const Color(0xFF1A3A6B);
      case 'berita_acara': return const Color(0xFF7B1A1A);
      case 'invoice':      return const Color(0xFF2E3748);
      default:             return AppColors.primary;
    }
  }

  Color _typeBadgeColor(String? type) {
    switch (type) {
      case 'brd':          return const Color(0xFF4A90D9);
      case 'berita_acara': return const Color(0xFFE53935);
      case 'invoice':      return const Color(0xFF78909C);
      default:             return AppColors.grey;
    }
  }

  String _typeLabel(String? type) {
    switch (type) {
      case 'brd':          return 'BRD';
      case 'berita_acara': return 'Berita Acara';
      case 'invoice':      return 'Invoice';
      default:             return type ?? '';
    }
  }

  Color _statusColor(String? s) {
    switch (s) {
      case 'active':  return AppColors.active;
      case 'delay':   return AppColors.delay;
      case 'done':    return AppColors.done;
      case 'payment': return AppColors.payment;
      default:        return AppColors.grey;
    }
  }

  // Progress 100% kalau done
  double _progressValue(String? s) {
    switch (s) {
      case 'active':  return 0.5;
      case 'delay':   return 0.3;
      case 'done':    return 1.0; // 100%
      case 'payment': return 0.8;
      default:        return 0.0;
    }
  }

  String _statusLabel(String? s) {
    switch (s) {
      case 'active':  return 'PROGRESS: 0%';
      case 'delay':   return 'DELAYED';
      case 'done':    return 'COMPLETED ✓';
      case 'payment': return 'PAYMENT: BELUM LUNAS';
      default:        return '';
    }
  }

  String _waitingLabel(String? type) {
    if (type == 'brd')          return 'Menunggu Approve Finance & Engineering';
    if (type == 'berita_acara') return 'Menunggu Approve Finance';
    if (type == 'invoice')      return 'Menunggu TTD Sales';
    return 'Menunggu Approve';
  }

  // ── Dialog UPDATE ─────────────────────────────────────────────────

  Future<void> _showUpdateDialog(Map<String, dynamic> doc) async {
    String? selected = doc['status'];
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Status',
            style: TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.bold)),
        content: StatefulBuilder(
          builder: (_, setD) => Column(
            mainAxisSize: MainAxisSize.min,
            children: ['active', 'delay', 'done', 'payment'].map((s) =>
              RadioListTile<String>(
                value: s,
                groupValue: selected,
                title: Text(s.toUpperCase(),
                    style: const TextStyle(fontSize: 13)),
                activeColor: AppColors.primary,
                onChanged: (v) => setD(() => selected = v),
              ),
            ).toList(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal',
                  style: TextStyle(color: AppColors.grey))),
          ElevatedButton(
            onPressed: () async {
              if (selected != null) {
                await context.read<ReportViewModel>()
                    .updateDocumentStatus(doc['id'] as int, selected!);
                if (mounted) Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            child: const Text('Simpan',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Dialog DELETE ─────────────────────────────────────────────────

  Future<void> _showDeleteDialog(Map<String, dynamic> doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus BRD?',
            style: TextStyle(
                color: AppColors.delay, fontWeight: FontWeight.bold)),
        content: Text(
          '"${doc['title']}" akan dihapus permanen.',
          style: const TextStyle(color: AppColors.grey, fontSize: 13),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal',
                  style: TextStyle(color: AppColors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.delay),
            child: const Text('Hapus',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context
          .read<ReportViewModel>()
          .deleteDocument(doc['id'] as int);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('BRD berhasil dihapus.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth      = context.watch<AuthViewModel>();
    final report    = context.watch<ReportViewModel>();
    final user      = auth.currentUser;
    final dept      = user?.department ?? '';
    final userId    = user?.id ?? 0;
    final deptShort = dept.replaceAll(' Department', '');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
        title: Row(children: [
          CircleAvatar(
            backgroundColor: Colors.white24,
            radius: 16,
            child: Text(
              deptShort.isNotEmpty ? deptShort[0] : '?',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          Text('Hi $deptShort !',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.notification)
                    .then((_) => _loadData()),
          ),
        ],
      ),
      body: report.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text('Recent Projects',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primary)),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Wrap(spacing: 14, children: [
                    _LegendDot(color: Color(0xFF4A90D9), label: 'BRD'),
                    _LegendDot(color: Color(0xFFE53935), label: 'Berita Acara'),
                    _LegendDot(color: Color(0xFF78909C), label: 'Invoice'),
                  ]),
                ),
                Expanded(
                  child: report.documents.isEmpty
                      ? const Center(
                          child: Text('Belum ada dokumen.',
                              style: TextStyle(color: AppColors.grey)))
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.builder(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: report.documents.length,
                            itemBuilder: (_, i) {
                              final doc        = report.documents[i];
                              final type       = doc['type'] as String?;
                              final status     = doc['status'] as String?;
                              final docId      = doc['id'] as int;
                              final sColor     = _statusColor(status);
                              final cardBg     = _cardColor(type);
                              final badgeColor = _typeBadgeColor(type);

                              final btnType = _loadingExtra
                                  ? 'loading'
                                  : _buttonType(doc, dept);

                              // DELETE muncul HANYA kalau:
                              // - User adalah Sales
                              // - Dokumen ini BRD
                              // - Dokumen ini dibuat oleh Sales ini
                              // - Status masih active
                              // - BELUM ADA SATU PUN yang approve
                              final isMine = _myCreatedIds.contains(docId);
                              final hasAnyApproval =
                                  _brdPartiallyApproved.contains(docId);
                              final showDelete =
                                  dept == 'Sales Department' &&
                                  type == 'brd' &&
                                  isMine &&
                                  status == 'active' &&
                                  !hasAnyApproval; // ← kunci utama

                              return Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: cardBg.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [

                                      // Badge tipe
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: badgeColor,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(_typeLabel(type),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight:
                                                    FontWeight.bold)),
                                      ),
                                      const SizedBox(height: 8),

                                      // Judul
                                      Text(doc['title'] ?? '-',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14)),
                                      const SizedBox(height: 2),

                                      // Customer
                                      Text(
                                          'Customer: ${doc['lead_project'] ?? '-'}',
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12)),

                                      // Assign & tanggal
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Assign to: ${doc['assign_to'] ?? '-'}',
                                              style: const TextStyle(
                                                  color: Colors.white60,
                                                  fontSize: 11),
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(doc['end_date'] ?? '',
                                              style: const TextStyle(
                                                  color: Colors.white60,
                                                  fontSize: 11)),
                                        ],
                                      ),
                                      const SizedBox(height: 10),

                                      // Progress bar
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: _progressValue(status),
                                          backgroundColor: Colors.white24,
                                          color: sColor,
                                          minHeight: 6,
                                        ),
                                      ),
                                      const SizedBox(height: 6),

                                      // Status label
                                      Text(_statusLabel(status),
                                          style: TextStyle(
                                              color: sColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11)),
                                      const SizedBox(height: 10),

                                      // ── TOMBOL AKSI ──────────────
                                      if (btnType == 'loading')
                                        const Center(
                                          child: SizedBox(
                                            width: 20, height: 20,
                                            child: CircularProgressIndicator(
                                                color: Colors.white54,
                                                strokeWidth: 2),
                                          ),
                                        )

                                      else if (btnType == 'see_details')
                                        _buildSeeDetails(doc)

                                      else if (btnType == 'sign')
                                        _buildSign(doc)

                                      else if (btnType == 'waiting')
                                        Column(children: [
                                          _buildWaiting(type),
                                          // Tombol DELETE muncul di bawah
                                          // tombol waiting kalau eligible
                                          if (showDelete) ...[
                                            const SizedBox(height: 8),
                                            _buildDelete(doc),
                                          ],
                                        ])

                                      // Sales update status
                                      else
                                        _buildUpdate(doc),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 2),
    );
  }

  // ── Widget tombol ─────────────────────────────────────────────────

  Widget _buildSeeDetails(Map<String, dynamic> doc) => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(
            context, AppRoutes.documentDetail, arguments: doc,
          ).then((_) => _loadData()),
          icon: const Icon(Icons.visibility, size: 16),
          label: const Text('SEE DETAILS',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white24,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 36),
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );

  Widget _buildSign(Map<String, dynamic> doc) => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(
            context, AppRoutes.documentDetail, arguments: doc,
          ).then((_) => _loadData()),
          icon: const Icon(Icons.draw, size: 16),
          label: const Text('TANDA TANGAN',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.done,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 36),
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );

  Widget _buildWaiting(String? type) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_empty,
                color: Colors.white54, size: 14),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                _waitingLabel(type),
                style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );

  Widget _buildDelete(Map<String, dynamic> doc) => SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _showDeleteDialog(doc),
          icon: const Icon(Icons.delete_outline, size: 16),
          label: const Text('DELETE BRD',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.delay,
            side: const BorderSide(color: AppColors.delay),
            minimumSize: const Size(0, 36),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );

  Widget _buildUpdate(Map<String, dynamic> doc) => SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _showUpdateDialog(doc),
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('UPDATE STATUS',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white38),
            minimumSize: const Size(0, 36),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10, height: 10,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: AppColors.grey, fontSize: 11)),
        ],
      );
}
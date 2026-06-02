import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../app/app_colors.dart';
import '../../core/database/db_helper.dart';
import '../../viewmodels/document_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';

class DocumentDetailPage extends StatefulWidget {
  const DocumentDetailPage({super.key});

  @override
  State<DocumentDetailPage> createState() => _DocumentDetailPageState();
}

class _DocumentDetailPageState extends State<DocumentDetailPage> {
  final GlobalKey<SfSignaturePadState> _signKey = GlobalKey();
  bool _showPdf        = false;
  bool _alreadySigned  = false;
  String? _savedSignaturePath;
  // Simpan data dokumen terbaru (supaya status selalu fresh dari DB)
  Map<String, dynamic>? _freshDoc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final doc = ModalRoute.of(context)?.settings.arguments
        as Map<String, dynamic>?;
    if (doc != null) {
      _freshDoc = doc;
      _checkAlreadySigned(doc['id'] as int);
    }
  }

  Future<void> _checkAlreadySigned(int docId) async {
    final userId =
        context.read<AuthViewModel>().currentUser?.id ?? 0;
    final db = DBHelper.instance;

    // Ambil data dokumen terbaru dari DB (supaya status selalu akurat)
    final latestDoc = await db.getDocumentById(docId);
    if (latestDoc != null && mounted) {
      setState(() => _freshDoc = latestDoc);
    }

    // Cek apakah user ini sudah TTD
    final approvals = await db.getApprovalsByDocument(docId);
    final mine = approvals.where(
      (a) => a['approver_id'] == userId && a['status'] == 'approved',
    ).toList();

    if (mine.isNotEmpty && mounted) {
      setState(() {
        _alreadySigned      = true;
        _savedSignaturePath = mine.first['signature_path'] as String?;
      });
    }
  }

  String _pageTitle(String? type) {
    switch (type) {
      case 'brd':          return 'Business Requirement Document';
      case 'berita_acara': return 'Technical Report / Berita Acara';
      default:             return 'Invoice';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pakai _freshDoc supaya status selalu dari DB terbaru
    final doc      = _freshDoc ??
        (ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>);
    final filePath = doc['file_path'] as String?;
    final hasFile  = filePath != null && filePath.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(_pageTitle(doc['type']),
            style: const TextStyle(fontSize: 15)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── FILE PREVIEW ──────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lightGrey),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                    child: Row(children: [
                      const Icon(Icons.insert_drive_file,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 6),
                      const Text('File Dokumen',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                      const Spacer(),
                      if (hasFile)
                        TextButton.icon(
                          onPressed: () =>
                              setState(() => _showPdf = !_showPdf),
                          icon: Icon(
                            _showPdf
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 16),
                          label: Text(
                            _showPdf ? 'Sembunyikan' : 'Lihat PDF',
                            style: const TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary),
                        ),
                    ]),
                  ),
                  const Divider(height: 1, color: AppColors.lightGrey),
                  if (!hasFile)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Column(children: [
                        Icon(Icons.insert_drive_file_outlined,
                            size: 48, color: AppColors.grey),
                        SizedBox(height: 8),
                        Text('Tidak ada file yang diupload',
                            style: TextStyle(color: AppColors.grey)),
                      ])),
                    )
                  else if (!_showPdf)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.picture_as_pdf,
                              color: AppColors.primary, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(filePath!.split('/').last,
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13),
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            const Text('Ketuk "Lihat PDF" untuk membuka',
                                style: TextStyle(
                                    color: AppColors.grey, fontSize: 11)),
                          ],
                        )),
                      ]),
                    )
                  else
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(12)),
                      child: SizedBox(
                          height: 400,
                          child: _buildPdfViewer(filePath!)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── DETAIL DOKUMEN ────────────────────────────────────
            _detailField('Project Title', doc['title']),
            _detailField('Description', doc['description']),
            _detailField('Assign To', doc['assign_to']),
            _detailField('Lead Project', doc['lead_project']),
            Row(children: [
              Expanded(child: _detailField('Start Date', doc['start_date'])),
              const SizedBox(width: 12),
              Expanded(child: _detailField('End Date', doc['end_date'])),
            ]),
            const SizedBox(height: 8),

            // ── AREA TANDA TANGAN ─────────────────────────────────
            const Text('Tanda Tangan',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 14)),
            const SizedBox(height: 4),

            if (_alreadySigned) ...[
              // ── Sudah TTD ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.done.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.done),
                ),
                child: Column(children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle,
                          color: AppColors.done, size: 20),
                      SizedBox(width: 8),
                      Text('Dokumen sudah ditandatangani',
                          style: TextStyle(
                              color: AppColors.done,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_savedSignaturePath != null &&
                      File(_savedSignaturePath!).existsSync())
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_savedSignaturePath!),
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    )
                  else
                    const Text(
                      'Tanda tangan telah tersimpan di sistem.',
                      style: TextStyle(
                          color: AppColors.grey, fontSize: 12),
                    ),
                ]),
              ),
            ] else ...[
              // ── Belum TTD — tampilkan signature pad ───────────────
              const Text(
                'Tanda tangani di kotak bawah ini untuk menyetujui.',
                style: TextStyle(color: AppColors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.lightGrey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SfSignaturePad(
                  key: _signKey,
                  backgroundColor: Colors.white,
                  strokeColor: AppColors.primary,
                  minimumStrokeWidth: 2,
                  maximumStrokeWidth: 4,
                ),
              ),
              const SizedBox(height: 24),

              Consumer<DocumentViewModel>(
                builder: (_, vm, __) => Row(children: [
                  // RETRY
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _signKey.currentState?.clear(),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Retry'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // DONE
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: vm.isLoading
                          ? null
                          : () async {
                              final docId  = doc['id'] as int;
                              final userId = context
                                  .read<AuthViewModel>()
                                  .currentUser!
                                  .id!;

                              // Simpan gambar TTD
                              String? signPath;
                              try {
                                final image = await _signKey.currentState
                                    ?.toImage(pixelRatio: 2.0);
                                if (image != null) {
                                  final byteData =
                                      await image.toByteData(
                                    format: ui.ImageByteFormat.png,
                                  );
                                  if (byteData != null) {
                                    final dir = Directory.systemTemp;
                                    final f = File(
                                        '${dir.path}/sign_${userId}_$docId.png');
                                    await f.writeAsBytes(
                                        byteData.buffer.asUint8List());
                                    signPath = f.path;
                                  }
                                }
                              } catch (_) {}

                              // Approve dokumen
                              await vm.approveDocument(
                                  userId, docId, signPath);

                              // Reload data dokumen terbaru dari DB
                              // supaya status 'done' langsung terbaca
                              final latestDoc = await DBHelper.instance
                                  .getDocumentById(docId);
                              if (mounted && latestDoc != null) {
                                setState(() {
                                  _freshDoc      = latestDoc;
                                  _alreadySigned = true;
                                  _savedSignaturePath = signPath;
                                });
                              }

                              if (mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                      'Dokumen berhasil ditandatangani! ✅'),
                                ));
                                // Pop dengan result true supaya reports_page
                                // tahu harus reload
                                Navigator.pop(context, true);
                              }
                            },
                      icon: vm.isLoading
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.check_circle, size: 18),
                      label: Text(
                          vm.isLoading ? 'Memproses...' : 'Done'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ]),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfViewer(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      return const Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppColors.delay, size: 40),
          SizedBox(height: 8),
          Text('File tidak ditemukan.',
              style: TextStyle(color: AppColors.grey)),
        ],
      ));
    }
    if (path.toLowerCase().endsWith('.pdf')) {
      return SfPdfViewer.file(file);
    }
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.insert_drive_file,
            color: AppColors.primary, size: 48),
        const SizedBox(height: 8),
        Text(path.split('/').last,
            style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600),
            textAlign: TextAlign.center),
        const SizedBox(height: 4),
        const Text('Preview hanya tersedia untuk file PDF.',
            style: TextStyle(color: AppColors.grey, fontSize: 11),
            textAlign: TextAlign.center),
      ],
    ));
  }

  Widget _detailField(String label, dynamic value) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    fontSize: 13)),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.lightGrey),
              ),
              child: Text(value?.toString() ?? '-',
                  style: const TextStyle(
                      color: AppColors.primary, fontSize: 13)),
            ),
          ],
        ),
      );
}
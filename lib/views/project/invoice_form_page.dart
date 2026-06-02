import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../app/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/document_viewmodel.dart';
import '../widgets/bottom_navbar.dart';

class InvoiceFormPage extends StatefulWidget {
  const InvoiceFormPage({super.key});

  @override
  State<InvoiceFormPage> createState() => _InvoiceFormPageState();
}

class _InvoiceFormPageState extends State<InvoiceFormPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _leadCtrl  = TextEditingController();

  String? _startDate, _endDate, _filePath, _fileName;
  bool _assignSales = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _leadCtrl.dispose();
    super.dispose();
  }

  String _monthName(int m) {
    const months = ['','Jan','Feb','Mar','Apr','Mei','Jun',
                    'Jul','Agu','Sep','Okt','Nov','Des'];
    return months[m];
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final f = '${picked.day} ${_monthName(picked.month)} ${picked.year}';
      setState(() {
        if (isStart) _startDate = f;
        else _endDate = f;
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _filePath = result.files.single.path;
        _fileName = result.files.single.name;
      });
    }
  }

  void _clearForm() {
    _titleCtrl.clear();
    _descCtrl.clear();
    _leadCtrl.clear();
    setState(() {
      _startDate   = null;
      _endDate     = null;
      _filePath    = null;
      _fileName    = null;
      _assignSales = false;
    });
  }

  Future<void> _submit() async {
    if (!_assignSales) {
      _snack('Assign ke Sales Department terlebih dahulu!');
      return;
    }
    if (_titleCtrl.text.trim().isEmpty) {
      _snack('Task Title tidak boleh kosong!');
      return;
    }
    if (_startDate == null || _endDate == null) {
      _snack('Pilih Start Date dan End Date!');
      return;
    }

    final user = context.read<AuthViewModel>().currentUser!;
    final vm   = context.read<DocumentViewModel>();

    // Cek apakah Berita Acara sudah di-approve Finance
    final baApproved = await vm.isBeritaAcaraApproved();
    if (!baApproved) {
      _snack('Berita Acara belum disetujui Finance! Tunggu dulu.');
      return;
    }

    final ok = await vm.submitDocument(
      type: 'invoice',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      leadProject: _leadCtrl.text.trim(),
      assignTo: 'Sales Department',
      startDate: _startDate!,
      endDate: _endDate!,
      filePath: _filePath,
      createdBy: user.id!,
      creatorDepartment: user.department,
    );

    if (ok && mounted) {
      _snack('Invoice berhasil dikirim ke Sales! ✅');
      _clearForm();
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(Icons.receipt_long, size: 22),
        ),
        title: const Text(
          'Invoice',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Banner kalau Berita Acara belum approved
            FutureBuilder<bool>(
              future: context.read<DocumentViewModel>().isBeritaAcaraApproved(),
              builder: (ctx, snap) {
                if (snap.data == false) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.delay.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.delay),
                    ),
                    child: const Row(children: [
                      Icon(Icons.warning_amber, color: AppColors.delay, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tunggu Berita Acara disetujui Finance terlebih dahulu.',
                          style: TextStyle(color: AppColors.delay, fontSize: 12),
                        ),
                      ),
                    ]),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // ASSIGN TO
            _label('Assign to'),
            Row(children: [
              Checkbox(
                value: _assignSales,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _assignSales = v!),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              const Text('Sales',
                  style: TextStyle(color: AppColors.primary, fontSize: 12)),
            ]),
            const SizedBox(height: 14),

            // LEAD PROJECT
            _label('Lead Project'),
            _field(_leadCtrl, 'Nama Lead Project', Icons.person),
            const SizedBox(height: 12),

            // TASK TITLE
            _label('Task Title'),
            _field(_titleCtrl, 'Contoh: Instalasi Ventilator Ruang ICU C'),
            const SizedBox(height: 12),

            // DATES
            Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Start Date'),
                    _datePicker(_startDate, () => _pickDate(true)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('End Date'),
                    _datePicker(_endDate, () => _pickDate(false)),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 12),

            // DESCRIPTION
            _label('Description'),
            TextField(
              controller: _descCtrl,
              maxLines: 5,
              decoration: _dec('Deskripsikan detail invoice...'),
            ),
            const SizedBox(height: 12),

            // UPLOAD
            _label('Upload Document'),
            _uploadBox(),
            const SizedBox(height: 24),

            // BUTTONS
            Consumer<DocumentViewModel>(
              builder: (_, vm, __) => Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearForm,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: vm.isLoading ? null : _submit,
                    icon: vm.isLoading
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.send, size: 18),
                    label: Text(vm.isLoading ? 'Mengirim...' : 'Done'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 1),
    );
  }

  // ── Helper widgets ──────────────────────────────────────────────

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: 13)),
      );

  Widget _field(TextEditingController c, String hint, [IconData? icon]) =>
      TextField(controller: c, decoration: _dec(hint, icon));

  InputDecoration _dec(String hint, [IconData? icon]) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.grey, fontSize: 13),
        prefixIcon: icon != null ? Icon(icon, color: AppColors.grey) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.lightGrey)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.lightGrey)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );

  Widget _datePicker(String? val, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.lightGrey),
          ),
          child: Row(children: [
            const Icon(Icons.calendar_today, size: 15, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(val ?? '-- Pilih tanggal',
                  style: TextStyle(
                      color: val != null ? AppColors.primary : AppColors.grey,
                      fontSize: 12)),
            ),
          ]),
        ),
      );

  Widget _uploadBox() => GestureDetector(
        onTap: _pickFile,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.grey),
          ),
          child: Column(children: [
            Icon(
              _filePath != null
                  ? Icons.insert_drive_file
                  : Icons.cloud_upload_outlined,
              size: 42,
              color: _filePath != null ? AppColors.primary : AppColors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              _fileName ??
                  'Choose a file or drag & drop\ntxt, docx, pdf, xlsx – max 100 MB',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _fileName != null ? AppColors.primary : AppColors.grey,
                  fontSize: 12),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _pickFile,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Browse File'),
            ),
          ]),
        ),
      );
}
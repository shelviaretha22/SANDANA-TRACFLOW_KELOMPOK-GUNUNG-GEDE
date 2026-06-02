import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'brd_form_page.dart';
import 'berita_acara_form_page.dart';
import 'invoice_form_page.dart';

/// ProjectPage hanya bertugas sebagai ROUTER.
/// Dia melihat department user yang sedang login,
/// lalu menampilkan form yang sesuai.
///
/// Sales       → BrdFormPage
/// Engineering → BeritaAcaraFormPage
/// Finance     → InvoiceFormPage
class ProjectPage extends StatelessWidget {
  const ProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dept =
        context.watch<AuthViewModel>().currentUser?.department ?? '';

    if (dept == 'Sales Department') {
      return const BrdFormPage();
    } else if (dept == 'Engineering Department') {
      return const BeritaAcaraFormPage();
    } else {
      // Finance Department
      return const InvoiceFormPage();
    }
  }
}
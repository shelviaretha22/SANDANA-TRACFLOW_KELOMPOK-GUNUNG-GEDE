import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../core/database/db_helper.dart';
import '../../models/notification_model.dart';
import '../../viewmodels/auth_viewmodel.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final userId =
        context.read<AuthViewModel>().currentUser?.id ?? 0;
    final data = await DBHelper.instance.getNotificationsByUser(userId);
    setState(() {
      _notifications = data.map(NotificationModel.fromMap).toList();
      _isLoading = false;
    });
  }

  // Warna card notifikasi berdasarkan department pengirim
  Color _cardColor(String? dept) {
    if (dept == 'Sales Department') {
      return AppColors.salesColor.withValues(alpha: 0.12);
    } else if (dept == 'Engineering Department') {
      return Colors.blueGrey.withValues(alpha: 0.12);
    } else {
      return AppColors.financeColor.withValues(alpha: 0.12);
    }
  }

  Color _borderColor(String? dept) {
    if (dept == 'Sales Department') return AppColors.salesColor;
    if (dept == 'Engineering Department') return Colors.blueGrey;
    return AppColors.financeColor;
  }

  Color _btnColor(String? dept) {
    if (dept == 'Sales Department') return AppColors.salesColor;
    if (dept == 'Engineering Department') return AppColors.secondary;
    return AppColors.financeColor;
  }

  // Klik SEE DETAILS → ambil dokumen dari DB → navigate ke DocumentDetailPage
  Future<void> _onSeeDetails(NotificationModel notif) async {
    // Tandai sudah dibaca
    if (notif.id != null) {
      await DBHelper.instance.markNotificationRead(notif.id!);
    }

    // Ambil data dokumen dari database
    if (notif.documentId != null) {
      final doc =
          await DBHelper.instance.getDocumentById(notif.documentId!);
      if (doc != null && mounted) {
        await Navigator.pushNamed(
          context,
          AppRoutes.documentDetail,
          arguments: doc,
        );
        // Setelah kembali, refresh notifikasi
        _load();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dokumen tidak ditemukan.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: const Icon(Icons.notifications),
        title: const Text(
          'Notification !',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Assignment Required',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: _notifications.isEmpty
                      ? const Center(
                          child: Text(
                            'Tidak ada notifikasi.',
                            style: TextStyle(color: AppColors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _notifications.length,
                          itemBuilder: (_, i) {
                            final n = _notifications[i];
                            final cardBg  = _cardColor(n.fromDepartment);
                            final border  = _borderColor(n.fromDepartment);
                            final btnClr  = _btnColor(n.fromDepartment);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: border.withValues(alpha: 0.5)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Judul + badge unread
                                  Row(children: [
                                    Expanded(
                                      child: Text(
                                        n.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: border,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    if (!n.isRead)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: border,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'BARU',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                  ]),
                                  const SizedBox(height: 4),

                                  // Pesan
                                  if (n.message != null)
                                    Text(
                                      n.message!,
                                      style: const TextStyle(
                                          color: AppColors.grey,
                                          fontSize: 12),
                                    ),
                                  const SizedBox(height: 4),

                                  // Dept pengirim
                                  if (n.fromDepartment != null)
                                    Text(
                                      'Dari: ${n.fromDepartment}',
                                      style: TextStyle(
                                          color: border,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  const SizedBox(height: 10),

                                  // Tombol SEE DETAILS
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => _onSeeDetails(n),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: btnClr,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        'SEE DETAILS',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                // Tombol BACK
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'BACK',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
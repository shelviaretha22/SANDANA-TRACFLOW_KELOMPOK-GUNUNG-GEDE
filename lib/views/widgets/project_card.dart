import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_routes.dart';

class ProjectCard extends StatelessWidget {
  final Map<String, dynamic> document;

  const ProjectCard({super.key, required this.document});

  // Seberapa penuh progress bar berdasarkan status
  double _progressValue(String? status) {
    switch (status) {
      case 'active':  return 0.5;
      case 'delay':   return 0.3;
      case 'done':    return 1.0;
      case 'payment': return 0.8;
      default:        return 0.0;
    }
  }

  // Warna progress bar
  Color _progressColor(String? status) {
    switch (status) {
      case 'active':  return AppColors.active;
      case 'delay':   return AppColors.delay;
      case 'done':    return AppColors.done;
      case 'payment': return AppColors.payment;
      default:        return AppColors.grey;
    }
  }

  // Teks label status
  String _statusLabel(String? status) {
    switch (status) {
      case 'active':  return 'PROGRESS INSTALLATION: 50%';
      case 'delay':   return 'DELAYED';
      case 'done':    return 'COMPLETED';
      case 'payment': return 'PAYMENT STATUS: DP 60%';
      default:        return 'STATUS: -';
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = document['status'] as String?;
    final color = _progressColor(status);

    final type = document['type']?.toString().toLowerCase();

Color cardColor;
switch (type) {
  case 'brd':
    cardColor = const Color(0xFF1E4580); // biru
    break;

  case 'berita_acara':
    cardColor = const Color(0xFF9B111E); // merah
    break;

  case 'invoice':
    cardColor = const Color(0xFF2F3B52); // abu gelap
    break;

  default:
    cardColor = Colors.white;
}

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul dokumen
            Text(
              document['title'] ?? '-',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color:  Colors.white,
              ),
            ),
            const SizedBox(height: 2),

            // Lead project / customer
            Text(
              'Customer: ${document['lead_project'] ?? '-'}',
              style: const TextStyle(color: AppColors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _progressValue(status),
                backgroundColor: AppColors.lightGrey,
                color: color,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),

            // Status label + tombol DETAIL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _statusLabel(status),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.documentDetail,
                      arguments: document,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'DETAIL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
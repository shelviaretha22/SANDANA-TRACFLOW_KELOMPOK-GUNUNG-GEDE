import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_routes.dart';

/// Widget kartu dokumen di Recent Projects (Home).
/// Menerima [progressValue] dari HomeViewModel — nilai 0.0 s/d 1.0
/// hasil hitungan nyata dari tabel document_approvals.
class ProjectCard extends StatelessWidget {
  final Map<String, dynamic> document;

  /// Progress nyata dari HomeViewModel.progressMap
  /// Kalau null → fallback ke 0.0
  final double? progressValue;

  const ProjectCard({
    super.key,
    required this.document,
    this.progressValue,
  });

  // ── Warna card sama persis dengan Reports ─────────────────────────
  Color _cardColor(String? type) {
    switch (type) {
      case 'brd':          return const Color(0xFF1A3A6B); // biru tua
      case 'berita_acara': return const Color(0xFF7B1A1A); // merah tua
      case 'invoice':      return const Color(0xFF2E3748); // abu gelap
      default:             return AppColors.primary;
    }
  }

  Color _typeBadgeColor(String? type) {
    switch (type) {
      case 'brd':          return const Color(0xFF4A90D9); // biru terang
      case 'berita_acara': return const Color(0xFFE53935); // merah terang
      case 'invoice':      return const Color(0xFF78909C); // abu
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

  // ── Warna progress bar berdasarkan status ────────────────────────
  Color _progressColor(String? status) {
    switch (status) {
      case 'active':  return AppColors.active;
      case 'delay':   return AppColors.delay;
      case 'done':    return AppColors.done;
      case 'payment': return AppColors.payment;
      default:        return AppColors.grey;
    }
  }

  // ── Label status + persentase nyata ──────────────────────────────
  String _statusLabel(String? status, double progress) {
    final pct = (progress * 100).round();
    switch (status) {
      case 'active':
        return 'PROGRESS: $pct%';
      case 'delay':
        return 'DELAYED — $pct%';
      case 'done':
        return 'COMPLETED ✓ — 100%';
      case 'payment':
        return 'PAYMENT: BELUM LUNAS — 100%';
      default:
        return 'STATUS: $pct%';
    }
  }

  @override
  Widget build(BuildContext context) {
    final type   = document['type'] as String?;
    final status = document['status'] as String?;

    // Gunakan progressValue dari parent kalau ada,
    // fallback ke 0.0 kalau belum dimuat
    final double progress = progressValue ?? 0.0;
    final progressColor   = _progressColor(status);
    final cardBg          = _cardColor(type);
    final badgeColor      = _typeBadgeColor(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: cardBg.withValues(alpha: 0.45),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Badge tipe dokumen
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _typeLabel(type),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Judul dokumen
            Text(
              document['title'] ?? '-',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),

            // Customer / lead project
            Text(
              'Customer: ${document['lead_project'] ?? '-'}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 10),

            // Progress bar — nilai NYATA dari approval
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white24,
                color: progressColor,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),

            // Baris bawah: label status + persentase + tombol DETAIL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _statusLabel(status, progress),
                    style: TextStyle(
                      fontSize: 11,
                      color: progressColor,
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
                      backgroundColor: Colors.white24,
                      foregroundColor: Colors.white,
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
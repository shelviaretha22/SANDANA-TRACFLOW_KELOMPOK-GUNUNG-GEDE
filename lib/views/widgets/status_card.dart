import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final String label;   // teks label (ACTIVE / DELAY / DONE / PAYMENT)
  final int count;      // angka yang ditampilkan
  final Color color;    // warna background kartu
  final IconData icon;  // icon di tengah kartu

  const StatusCard({
    super.key,
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          // Shadow berwarna sama dengan kartu supaya keliatan melayang
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label kecil di atas (ACTIVE / DELAY / dst)
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),

            // Icon
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 2),

            // Angka besar
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
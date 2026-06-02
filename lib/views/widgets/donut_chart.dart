import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../app/app_colors.dart';

class DonutChart extends StatelessWidget {
  // Menerima data summary dari HomeViewModel
  // Contoh: {'active': 7, 'delay': 3, 'done': 8, 'payment': 5}
  final Map<String, int> summary;

  const DonutChart({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final total = (summary['active'] ?? 0) +
        (summary['delay'] ?? 0) +
        (summary['done'] ?? 0) +
        (summary['payment'] ?? 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Judul
          const Text(
            'PROJECT STATUS',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              // Donut chart kiri
              SizedBox(
                width: 140,
                height: 140,
                child: total == 0
                    ? _emptyChart()   // tampilkan abu-abu kalau belum ada data
                    : PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 42,
                          startDegreeOffset: -90,
                          sections: _buildSections(),
                        ),
                      ),
              ),
              const SizedBox(width: 20),

              // Legend kanan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegendItem(
                      color: AppColors.active,
                      label: 'ACTIVE',
                      count: summary['active'] ?? 0,
                    ),
                    _LegendItem(
                      color: AppColors.delay,
                      label: 'DELAY',
                      count: summary['delay'] ?? 0,
                    ),
                    _LegendItem(
                      color: AppColors.done,
                      label: 'DONE',
                      count: summary['done'] ?? 0,
                    ),
                    _LegendItem(
                      color: AppColors.payment,
                      label: 'PAYMENT',
                      count: summary['payment'] ?? 0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final data = [
      {'value': summary['active'] ?? 0,  'color': AppColors.active},
      {'value': summary['delay'] ?? 0,   'color': AppColors.delay},
      {'value': summary['done'] ?? 0,    'color': AppColors.done},
      {'value': summary['payment'] ?? 0, 'color': AppColors.payment},
    ];

    // Hanya tampilkan section yang nilainya > 0
    return data
        .where((d) => (d['value'] as int) > 0)
        .map((d) => PieChartSectionData(
              value: (d['value'] as int).toDouble(),
              color: d['color'] as Color,
              radius: 28,
              showTitle: false,
            ))
        .toList();
  }

  // Chart abu-abu saat belum ada data
  Widget _emptyChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 42,
        sections: [
          PieChartSectionData(
            value: 1,
            color: AppColors.lightGrey,
            radius: 28,
            showTitle: false,
          ),
        ],
      ),
    );
  }
}

// Widget satu baris legend (kotak warna + label + angka)
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Kotak warna kecil
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          // Label teks
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Angka count
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
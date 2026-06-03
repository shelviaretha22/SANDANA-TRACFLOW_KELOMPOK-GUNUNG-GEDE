import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/status_card.dart';
import '../widgets/project_card.dart';
import '../widgets/donut_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dept =
          context.read<AuthViewModel>().currentUser?.department ?? '';
      context.read<HomeViewModel>().loadHomeData(dept);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth      = context.watch<AuthViewModel>();
    final home      = context.watch<HomeViewModel>();
    final user      = auth.currentUser;
    final deptShort =
        user?.department.replaceAll(' Department', '') ?? '';

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [

            // ── Header ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: Text(
                      deptShort.isNotEmpty ? deptShort[0] : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Hi $deptShort !',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications,
                        color: Colors.white),
                    onPressed: () => Navigator.pushNamed(
                        context, AppRoutes.notification),
                  ),
                ],
              ),
            ),

            // ── Status Cards ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  StatusCard(
                    label: 'ACTIVE',
                    count: home.statusSummary['active'] ?? 0,
                    color: AppColors.active,
                    icon: Icons.work,
                  ),
                  StatusCard(
                    label: 'DELAY',
                    count: home.statusSummary['delay'] ?? 0,
                    color: AppColors.delay,
                    icon: Icons.timer,
                  ),
                  StatusCard(
                    label: 'DONE',
                    count: home.statusSummary['done'] ?? 0,
                    color: AppColors.done,
                    icon: Icons.check_circle,
                  ),
                  StatusCard(
                    label: 'PAYMENT',
                    count: home.statusSummary['payment'] ?? 0,
                    color: AppColors.payment,
                    icon: Icons.payment,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Content area ──────────────────────────────────────
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: home.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // Donut Chart
                            DonutChart(summary: home.statusSummary),
                            const SizedBox(height: 16),

                            // Label Recent Projects
                            const Text(
                              'Recent Projects',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Daftar kartu dokumen
                            // progressValue diambil dari progressMap
                            // supaya progress bar nyata sesuai TTD
                            if (home.recentDocuments.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Text(
                                    'Belum ada dokumen.',
                                    style:
                                        TextStyle(color: AppColors.grey),
                                  ),
                                ),
                              )
                            else
                              ...home.recentDocuments.map((doc) {
                                final docId = doc['id'] as int;
                                final progress =
                                    home.progressMap[docId] ?? 0.0;
                                return ProjectCard(
                                  document: doc,
                                  progressValue: progress,
                                );
                              }),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 0),
    );
  }
}
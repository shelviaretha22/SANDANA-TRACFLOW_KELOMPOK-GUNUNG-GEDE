import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    final auth = context.read<AuthViewModel>();
    await auth.loadCurrentUser();
    if (auth.isLoggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.landing);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // Menggunakan background warna biru tua dasar
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              // 1. Ikon Jalur Utama (Menggunakan file aset asli langsung tanpa bingkai lingkaran)
              Image.asset(
                'assets/images/logo_sandana.png',
                height: 120, // Ketinggian disesuaikan agar proporsional di tengah layar
                fit: BoxFit.contain,
              ),
              
              const SizedBox(height: 28), // Jarak proporsional antara logo dan teks utama
              
              // 2. Tulisan "SANDANA" manual
              const Text(
                'SANDANA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8, // Spasi huruf diperlebar agar seimbang dan estetik
                ),
              ),
              
              const SizedBox(height: 6),
              
              // 3. Tulisan "TRACKFLOW" manual
              const Text(
                'TRACKFLOW',
                style: TextStyle(
                  color: Colors.white, // Diubah menjadi putih terang mengikuti mock-up asli
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
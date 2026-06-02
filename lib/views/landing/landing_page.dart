import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_routes.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          
          // 1. Background Putih Melengkung
          ClipPath(
            clipper: BackgroundClipper(),
            child: Container(
              color: Colors.white,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // 2. Header Brand (Logo Samator)
          Positioned(
            top: 60,
            right: 24,
            child: Image.asset(
              'assets/images/logo_samator.png',
              height: 38,
              fit: BoxFit.contain,
            ),
          ),

          // 3. Logo Lingkaran Center + Teks Custom (SANDANA TRACKFLOW)
          Positioned.fill(
            top: -40,
            child: Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withOpacity(0.85),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 25,
                      spreadRadius: 1,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ikon Ombak/Jalur dari Asset kamu
                    Image.asset(
                      'assets/images/logo_sandana.png',
                      height: 100, // Atur tinggi ikon agar proporsional
                      fit: BoxFit.contain,
                    ),
                    
                    const SizedBox(height: 16), // Jarak antara ikon dan teks
                    
                    // Tulisan "SANDANA"
                    const Text(
                      'SANDANA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6, // Memberi jarak antar huruf (kerning) biar estetik
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Tulisan "TRACKFLOW"
                    const Text(
                      'TRACKFLOW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Tombol Login & Register
          Positioned(
            bottom: 40,
            left: 32,
            right: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // TOMBOL LOGIN
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.login),
                    icon: const Icon(Icons.login),
                    label: const Text('Login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: Colors.black38,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // TOMBOL REGISTER
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.register),
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Clipper untuk lengkungan background putih
class BackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.width * 0.25, 0); 
    path.cubicTo(
      size.width * 0.20, size.height * 0.25,  
      size.width * 0.95, size.height * 0.45,  
      size.width * 0.40, size.height * 0.85,  
    );
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.95,
      0, size.height * 0.92,
    );
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
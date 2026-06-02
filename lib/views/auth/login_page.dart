import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _selectedDept;
  bool _obscurePass = true;

  final List<String> departments = [
    'Sales Department',
    'Engineering Department',
    'Finance Department',
  ];

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_selectedDept == null ||
        _emailCtrl.text.isEmpty ||
        _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lengkapi semua field!')));
      return;
    }

    final auth = context.read<AuthViewModel>();
    final success =
        await auth.login(_emailCtrl.text.trim(), _passCtrl.text, _selectedDept!);

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(auth.errorMessage ?? 'Login gagal')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      resizeToAvoidBottomInset: false, // Kunci layout biar posisi background dan logo TETAP DIEM saat keyboard muncul
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

          // 2. Top SAMATOR Brand
          Positioned(
            top: 60,
            right: 24,
            child: Image.asset(
              'assets/images/logo_samator.png',
              height: 38,
              fit: BoxFit.contain,
            ),
          ),

          // 3. Logo Lingkaran Center + Teks (Ukuran 280 pas, posisi diam terkunci)
          Positioned(
            top: 110, 
            left: 0,
            right: 0,
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
                    Image.asset(
                      'assets/images/logo_sandana.png',
                      height: 100, 
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'SANDANA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24, 
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
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

          // 4. Login Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Login',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                  const SizedBox(height: 20),

                  // Dropdown Department
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedDept,
                      hint: Row(children: const [
                        Icon(Icons.group, color: AppColors.grey, size: 20),
                        SizedBox(width: 8), // FIXED: Sudah diganti dari Snumsbox ke SizedBox
                        Text('Department', style: TextStyle(color: AppColors.grey)),
                      ]),
                      items: departments
                          .map((d) => DropdownMenuItem(
                              value: d,
                              child: Text(d,
                                  style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500))))
                          .toList(),
                      dropdownColor: Colors.white,
                      onChanged: (v) => setState(() => _selectedDept = v),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Email
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person, color: AppColors.grey),
                      hintText: 'Username / Email',
                      filled: true,
                      fillColor: AppColors.lightGrey,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Password
                  TextField(
                    controller: _passCtrl,
                    obscureText: _obscurePass,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock, color: AppColors.grey),
                      hintText: '••••••••••',
                      filled: true,
                      fillColor: AppColors.lightGrey,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePass
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => _obscurePass = !_obscurePass),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Consumer<AuthViewModel>(
                    builder: (_, auth, __) => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: auth.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Login',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
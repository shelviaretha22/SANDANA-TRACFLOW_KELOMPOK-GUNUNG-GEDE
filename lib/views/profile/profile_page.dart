import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../widgets/bottom_navbar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header banner
          Container(
            height: 220,
            width: double.infinity,
            color: AppColors.lightGrey,
            child: Stack(
              children: [
                // Background image placeholder
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.secondary, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
               
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: AppColors.primary,
                            backgroundImage: user?.photoPath != null
                                ? AssetImage(user!.photoPath!)
                                : null,
                            child: user?.photoPath == null
                                ? const Icon(Icons.person,
                                    size: 44, color: Colors.white)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt,
                                  size: 18, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(user?.name ?? '',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Text(user?.department ?? '',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 20),
                    ],
                  ),
                ),
                // Title
                const Positioned(
                  top: 44,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text('Profile',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _menuItem(context, Icons.person, 'User Information',
                    AppRoutes.userInfo),
                _menuItem(context, Icons.edit, 'Edit Profile',
                    AppRoutes.editProfile),
                _menuItem(context, Icons.lock, 'Change Password',
                    AppRoutes.changePassword),
                _menuItem(context, Icons.logout, 'Logout', null,
                    onTap: () async {
                  await context.read<AuthViewModel>().logout();
                  Navigator.pushReplacementNamed(context, AppRoutes.landing);
                }),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 3),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title,
      String? route,
      {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w500, color: AppColors.primary)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
        onTap: onTap ??
            () {
              if (route != null) Navigator.pushNamed(context, route);
            },
      ),
    );
  }
}
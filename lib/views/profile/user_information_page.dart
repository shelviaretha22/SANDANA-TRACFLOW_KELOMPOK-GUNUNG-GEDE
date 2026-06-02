import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';

class UserInformationPage extends StatelessWidget {
  const UserInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('User Information'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with photo
            Container(
              height: 160,
              width: double.infinity,
              color: AppColors.secondary,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.person,
                        size: 44, color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _infoField('Full Name', user?.name),
                  _infoField('Department', user?.department),
                  _infoField('Email', user?.email),
                  _infoField('Phone Number', user?.phone),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  fontSize: 13)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: Text(value ?? '-',
                style: const TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
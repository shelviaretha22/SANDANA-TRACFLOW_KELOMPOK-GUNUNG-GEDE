import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;

  Future<void> _save() async {
    if (_newCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password baru tidak cocok!')));
      return;
    }
    final userId = context.read<AuthViewModel>().currentUser!.id!;
    final vm = context.read<ProfileViewModel>();
    final ok =
        await vm.changePassword(userId, _currentCtrl.text, _newCtrl.text);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(vm.message ?? '')));
      if (ok) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            _passField(_currentCtrl, 'Current Password'),
            const SizedBox(height: 12),
            _passField(_newCtrl, 'New Password'),
            const SizedBox(height: 12),
            _passField(_confirmCtrl, 'Confirm New Password'),
            const SizedBox(height: 28),
            Consumer<ProfileViewModel>(
              builder: (_, vm, __) => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: vm.isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: vm.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('SAVE',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      obscureText: _obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock, color: AppColors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.lightGrey)),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}
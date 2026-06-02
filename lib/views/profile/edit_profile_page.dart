import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthViewModel>().currentUser;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
    _photoPath = user?.photoPath;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _photoPath = img.path);
  }

  Future<void> _save() async {
    final user = context.read<AuthViewModel>().currentUser!;
    final vm = context.read<ProfileViewModel>();
    await vm.updateProfile(
        user.id!, _nameCtrl.text.trim(), _phoneCtrl.text.trim(), _photoPath);
    await context.read<AuthViewModel>().loadCurrentUser();
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(vm.message ?? 'Tersimpan!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Photo
            Container(
              height: 160,
              color: AppColors.secondary,
              child: Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.primary,
                        child: const Icon(Icons.person,
                            size: 44, color: Colors.white),
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
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Full Name'),
                  _field(_nameCtrl),
                  _label('Department'),
                  _readOnly(user?.department ?? ''),
                  _label('Email'),
                  _readOnly(user?.email ?? ''),
                  _label('Phone Number'),
                  _field(_phoneCtrl, type: TextInputType.phone),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('SAVE',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 12),
      child: Text(t,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              fontSize: 13)));

  Widget _field(TextEditingController c,
      {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: c,
      keyboardType: type,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.lightGrey)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.lightGrey)),
      ),
    );
  }

  Widget _readOnly(String val) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(val,
          style: const TextStyle(color: AppColors.grey, fontSize: 13)),
    );
  }
}
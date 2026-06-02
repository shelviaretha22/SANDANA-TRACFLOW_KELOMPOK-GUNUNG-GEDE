import 'package:flutter/foundation.dart';
import '../core/database/db_helper.dart';
import '../models/user_model.dart';

class ProfileViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _message;

  bool get isLoading => _isLoading;
  String? get message => _message;

  Future<bool> updateProfile(int userId, String name, String phone,
      String? photoPath) async {
    _isLoading = true;
    notifyListeners();

    await DBHelper.instance.updateUser(userId, {
      'name': name,
      'phone': phone,
      if (photoPath != null) 'photo_path': photoPath,
    });

    _message = 'Profil berhasil diperbarui!';
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> changePassword(
      int userId, String current, String newPass) async {
    _isLoading = true;
    notifyListeners();

    final result =
        await DBHelper.instance.changePassword(userId, current, newPass);
    _message = result ? 'Password berhasil diubah!' : 'Password lama salah.';

    _isLoading = false;
    notifyListeners();
    return result;
  }
}
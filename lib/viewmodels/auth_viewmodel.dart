import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/database/db_helper.dart';
import '../models/user_model.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthViewModel extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<bool> login(String email, String password, String department) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final db = DBHelper.instance;
    final userMap = await db.getUserByEmailAndPassword(email, password);

    if (userMap == null) {
      _errorMessage = 'Email atau password salah.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final user = UserModel.fromMap(userMap);
    if (user.department != department) {
      _errorMessage = 'Department tidak sesuai.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', user.id!);
    await prefs.setString('user_department', user.department);

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> register(String name, String email, String password,
      String department, String phone) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final db = DBHelper.instance;
      final hashedPw = _hashPassword(password);
      await (await db.database).insert('users', {
        'name': name,
        'email': email,
        'password': hashedPw,
        'department': department,
        'phone': phone,
        'created_at': DateTime.now().toIso8601String(),
      });
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Email sudah terdaftar.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId != null) {
      final userMap = await DBHelper.instance.getUserById(userId);
      if (userMap != null) {
        _currentUser = UserModel.fromMap(userMap);
        notifyListeners();
      }
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _currentUser = null;
    notifyListeners();
  }

  bool get isLoggedIn => _currentUser != null;
}
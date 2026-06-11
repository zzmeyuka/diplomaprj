import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._auth);
  final AuthService _auth;

  User? user;
  bool loading = true;
  String? error;

  bool get isLoggedIn => user != null;

  Future<void> init() async {
    loading = true;
    notifyListeners();
    try {
      final token = await _auth.loadToken();
      if (token != null) {
        user = await _auth.me();
      }
    } catch (_) {
      await _auth.logout();
      user = null;
    }
    loading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    error = null;
    try {
      user = await _auth.login(email, password);
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    error = null;
    try {
      user = await _auth.register(
        fullName: fullName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      );
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.logout();
    user = null;
    notifyListeners();
  }
}

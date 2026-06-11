import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  AuthService(this._client);
  final ApiClient _client;
  static const _tokenKey = 'smartfly_token';

  Future<String?> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    _client.setToken(token);
    return token;
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    _client.setToken(token);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _client.setToken(null);
  }

  Future<User> register({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
    String preferredLanguage = 'ru',
  }) async {
    final data = await _client.post('/auth/register', {
      'fullName': fullName,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'preferredLanguage': preferredLanguage,
    });
    await saveToken(data['token'] as String);
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<User> login(String email, String password) async {
    final data = await _client.post('/auth/login', {
      'email': email,
      'password': password,
    });
    await saveToken(data['token'] as String);
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<User> me() async {
    final data = await _client.get('/auth/me');
    return User.fromJson(data as Map<String, dynamic>);
  }
}

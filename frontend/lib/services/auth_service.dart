import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _storage = const FlutterSecureStorage();

  // Keys
  static const _tokenKey = "jwt_token";

  // Register new user
  Future<Map<String, dynamic>?> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await apiClient.dio.post("/auth/register", data: {
        "email": email,
        "password": password,
        if (fullName != null && fullName.isNotEmpty) "full_name": fullName,
      });

      return response.data;
    } catch (e) {
      return null;
    }
  }

  // Login
  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post("/auth/login", data: {
        "username": email,
        "password": password,
      });

      final token = response.data["access_token"] as String;
      await _storage.write(key: _tokenKey, value: token);

      return response.data;
    } catch (e) {
      return null;
    }
  }

  // Get stored token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Logout
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

// Global instance
final authService = AuthService();

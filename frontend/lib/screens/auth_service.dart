import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final storage = FlutterSecureStorage();

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await apiClient.dio.post("/auth/token", data: {
        "username": email,
        "password": password,
      });
      final token = response.data["access_token"];
      await storage.write(key: "jwt_token", value: token);
      return response.data;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> register(String email, String password, String fullName) async {
    try {
      final response = await apiClient.dio.post("/auth/register", data: {
        "email": email,
        "password": password,
        "full_name": fullName,
      });
      return response.data;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getToken() async {
    return await storage.read(key: "jwt_token");
  }

  Future<void> logout() async {
    await storage.delete(key: "jwt_token");
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}

final authService = AuthService();

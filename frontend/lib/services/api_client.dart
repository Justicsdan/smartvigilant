import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'auth_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio dio;

  void init() {
    dio = Dio(BaseOptions(
      baseUrl: "http://10.0.2.2:8000/api/v1",  // Android emulator → localhost
      // For real phone on same WiFi: replace with your PC IP
      // e.g. "http://192.168.1.100:8000/api/v1"
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      contentType: "application/json",
    ));

    // Pretty logger (remove in production if needed)
    dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      compact: false,
    ));

    // Automatic JWT injection
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await AuthService().getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await AuthService().logout();
          // You can trigger navigation to login here if needed
        }
        handler.next(error);
      },
    ));
  }
}

// Global instance
final apiClient = ApiClient();

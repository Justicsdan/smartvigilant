// vigilant_api.dart - Central API service for backend communication
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class VigilantApi {
  static final VigilantApi _instance = VigilantApi._internal();
  factory VigilantApi() => _instance;
  VigilantApi._internal();

  static const String baseUrl = 'https://api.smartvigilant.com/v1'; // Or your backend URL
  static const String wsUrl = 'wss://api.smartvigilant.com/ws/alerts';

  final FlutterSecureStorage _storage = FlutterSecureStorage();
  IOWebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _alertController;

  // Initialize WebSocket for real-time alerts
  Future<void> initialize() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) return;

    _channel = IOWebSocketChannel.connect(
      Uri.parse('$wsUrl?token=$token'),
    );

    _alertController = StreamController.broadcast();
    _channel!.stream.listen(
      (data) {
        final alert = jsonDecode(data) as Map<String, dynamic>;
        _alertController!.add(alert);
      },
      onError: (error) => print('WebSocket error: $error'),
      onDone: () => print('WebSocket closed'),
    );
  }

  // Subscribe to real-time alerts
  static void subscribeToAlerts(Function(Map<String, dynamic>) onAlert) {
    VigilantApi()._alertController?.stream.listen(onAlert);
  }

  // GET: System status
  static Future<Map<String, dynamic>> getSystemStatus() async {
    final response = await http.get(Uri.parse('$baseUrl/status'));
    return jsonDecode(response.body);
  }

  // GET: Alert history
  static Future<List<Map<String, dynamic>>> getAlertHistory() async {
    final response = await http.get(Uri.parse('$baseUrl/alerts/history'));
    return List<Map<String, dynamic>>.from(jsonDecode(response.body)['alerts']);
  }

  // GET: AI Insights
  static Future<Map<String, dynamic>> getAIInsights() async {
    final response = await http.get(Uri.parse('$baseUrl/insights'));
    return jsonDecode(response.body);
  }

  // POST: Trigger emergency panic
  static Future<void> triggerPanicButton() async {
    await http.post(Uri.parse('$baseUrl/emergency/panic'));
  }

  // Generic authenticated request helper
  static Future<http.Response> _authRequest(String method, String endpoint, [Map<String, dynamic>? body]) async {
    final token = await VigilantApi()._storage.read(key: 'auth_token');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    switch (method) {
      case 'POST':
        return http.post(Uri.parse('$baseUrl$endpoint'), headers: headers, body: jsonEncode(body));
      case 'GET':
      default:
        return http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
    }
  }

  void dispose() {
    _channel?.sink.close();
    _alertController?.close();
  }
}

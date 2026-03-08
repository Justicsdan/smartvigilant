import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  String apiBase = 'http://127.0.0.1:8000/api'; // adjust to your backend
  String? authToken; // JWT or API token

  bool scanning = false;
  String lastScanResult = 'No scans yet';

  bool cameraChecking = false;
  String cameraStatus = 'Unknown';

  // Logs & summary (populated from backend)
  List<Map<String, dynamic>> logs = [];
  Map<String, int> summary = {
    'total': 0,
    'safe': 0,
    'warning': 0,
    'critical': 0,
  };

  void setApiBase(String url) {
    apiBase = url;
    notifyListeners();
  }

  void setAuthToken(String? token) {
    authToken = token;
    notifyListeners();
  }

  void setScanning(bool v) {
    scanning = v;
    notifyListeners();
  }

  void setLastScanResult(String s) {
    lastScanResult = s;
    notifyListeners();
  }

  void setCameraChecking(bool v) {
    cameraChecking = v;
    notifyListeners();
  }

  void setCameraStatus(String s) {
    cameraStatus = s;
    notifyListeners();
  }

  void setLogs(List<Map<String, dynamic>> l) {
    logs = l;
    _computeSummary();
    notifyListeners();
  }

  void _computeSummary() {
    summary = {'total': 0, 'safe': 0, 'warning': 0, 'critical': 0};
    for (var item in logs) {
      summary['total'] = (summary['total'] ?? 0) + 1;
      final level = (item['level'] ?? '').toString().toLowerCase();
      if (level.contains('crit') || level.contains('critical')) {
        summary['critical'] = (summary['critical'] ?? 0) + 1;
      } else if (level.contains('warn')) {
        summary['warning'] = (summary['warning'] ?? 0) + 1;
      } else {
        summary['safe'] = (summary['safe'] ?? 0) + 1;
      }
    }
  }
}


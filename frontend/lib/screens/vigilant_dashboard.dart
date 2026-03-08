// vigilant_dashboard.dart - Central hub showing system status and quick actions
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/vigilant_status.dart';
import '../widgets/vigilant_quick_actions.dart';
import '../widgets/vigilant_threat_summary.dart';
import '../services/vigilant_api.dart';
import '../utils/vigilant_theme.dart';

class VigilantDashboard extends StatefulWidget {
  @override
  _VigilantDashboardState createState() => _VigilantDashboardState();
}

class _VigilantDashboardState extends State<VigilantDashboard> {
  String systemStatus = "Scanning...";
  List<Map<String, dynamic>> recentAlerts = [];

  @override
  void initState() {
    super.initState();
    _startRealTimeMonitoring();
  }

  void _startRealTimeMonitoring() async {
    VigilantApi.subscribeToAlerts((alert) {
      setState(() {
        recentAlerts.insert(0, alert);
        if (alert['severity'] == 'critical') {
          systemStatus = "Threat Detected!";
        }
      });
    });

    // Initial status poll
    final status = await VigilantApi.getSystemStatus();
    setState(() => systemStatus = status['message']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SmartVigilant', style: TextStyle(fontFamily: 'VigilantFont')),
        backgroundColor: vigilantPrimary,
        actions: [
          IconButton(icon: Icon(Icons.settings), onPressed: () => Navigator.pushNamed(context, '/setup')),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _startRealTimeMonitoring(),
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            VigilantStatus(status: systemStatus),
            SizedBox(height: 24),
            VigilantThreatSummary(alerts: recentAlerts.take(5).toList()),
            SizedBox(height: 32),
            VigilantQuickActions(
              onCameraPressed: () => Navigator.pushNamed(context, '/camera'),
              onAlertsPressed: () => Navigator.pushNamed(context, '/alerts'),
              onInsightsPressed: () => Navigator.pushNamed(context, '/insights'),
            ),
            SizedBox(height: 20),
            Text(
              "Protected since January 2026",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}

// vigilant_alerts.dart - Full alert log with AI explanations
import 'package:flutter/material.dart';
import '../widgets/vigilant_alert_card.dart';
import '../services/vigilant_api.dart';

class VigilantAlerts extends StatefulWidget {
  @override
  _VigilantAlertsState createState() => _VigilantAlertsState();
}

class _VigilantAlertsState extends State<VigilantAlerts> {
  List<Map<String, dynamic>> alerts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    final data = await VigilantApi.getAlertHistory();
    setState(() {
      alerts = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Alert History")),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : alerts.isEmpty
              ? Center(child: Text("All clear! No threats detected.", style: TextStyle(fontSize: 18)))
              : ListView.builder(
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    return VigilantAlertCard(
                      title: alert['title'],
                      description: alert['ai_explanation'],
                      timestamp: alert['timestamp'],
                      severity: alert['severity'],
                      icon: _getIconForType(alert['type']),
                      onTap: () => _showAlertDetails(alert),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: Icon(Icons.warning_amber_rounded, size: 32),
        onPressed: () => VigilantApi.triggerPanicButton(),
        tooltip: "Emergency Panic",
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'deepfake': return Icons.record_voice_over;
      case 'intruder': return Icons.person_outline;
      case 'disaster': return Icons.warning;
      case 'malware': return Icons.bug_report;
      default: return Icons.security;
    }
  }

  void _showAlertDetails(Map<String, dynamic> alert) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(alert['title']),
        content: Text(alert['ai_explanation'] + "\n\nResolved: ${alert['resolved'] ? 'Yes' : 'Pending'}"),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("Close"))],
      ),
    );
  }
}

// vigilant_threat_summary.dart - Mini recent alerts on dashboard
import 'package:flutter/material.dart';

class VigilantThreatSummary extends StatelessWidget {
  final List<Map<String, dynamic>> alerts;

  const VigilantThreatSummary({required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text("No recent activity — Everything is secure", textAlign: TextAlign.center),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Recent Activity", style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: 12),
        ...alerts.map((a) => ListTile(
              leading: Icon(Icons.security, color: Colors.orange),
              title: Text(a['title']),
              subtitle: Text(a['timestamp']),
            )),
      ],
    );
  }
}

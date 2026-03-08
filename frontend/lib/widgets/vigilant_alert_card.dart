// vigilant_alert_card.dart - Reusable card for alerts in history and dashboard
import 'package:flutter/material.dart';
import '../../utils/vigilant_theme.dart';

class VigilantAlertCard extends StatelessWidget {
  final String title;
  final String description;
  final String timestamp;
  final String severity; // 'low', 'medium', 'high', 'critical'
  final IconData icon;
  final VoidCallback? onTap;

  const VigilantAlertCard({
    Key? key,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.severity,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  Color _getSeverityColor() {
    switch (severity) {
      case 'critical': return Colors.red;
      case 'high': return Colors.orange;
      case 'medium': return Colors.amber;
      default: return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getSeverityColor().withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: _getSeverityColor(), size: 32),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[700], height: 1.4),
                    ),
                    SizedBox(height: 8),
                    Text(
                      timestamp,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// vigilant_insights.dart - AI explanations and trend analysis
import 'package:flutter/material.dart';
import '../services/vigilant_api.dart';

class VigilantInsights extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AI Security Insights")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: VigilantApi.getAIInsights(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final insights = snapshot.data!;
          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              _buildInsightCard("Top Threat This Week", insights['top_threat'], Icons.trending_up),
              _buildInsightCard("AI-vs-AI Wins", "${insights['ai_neutralized']} threats blocked autonomously", Icons.shield),
              _buildInsightCard("Disaster Risk", insights['disaster_risk'], Icons.cloud_queue),
              _buildInsightCard("System Health", "99.9% uptime • Models updated daily", Icons.health_and_safety),
              SizedBox(height: 20),
              Text(
                "SmartVigilant uses advanced AI to predict, detect, and neutralize threats — before they reach you.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInsightCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, size: 40, color: vigilantPrimary),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

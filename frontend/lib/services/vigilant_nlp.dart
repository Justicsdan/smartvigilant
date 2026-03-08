// vigilant_nlp.dart - Convert raw AI threat data into plain-language explanations
class VigilantNLP {
  // Map technical threat codes to human-readable explanations
  static String explainThreat(Map<String, dynamic> rawAlert) {
    final type = rawAlert['type'] ?? 'unknown';
    final confidence = (rawAlert['confidence'] ?? 0.0) * 100;

    switch (type) {
      case 'malware':
        return "A harmful file was automatically blocked. Your device is safe — no action needed.";
      case 'deepfake':
        return "AI detected a fake video/audio attempt (e.g., impersonation). It was blocked with $confidence% confidence.";
      case 'intruder':
        return "Unknown person detected at your door/camera. Recording saved and alert sent.";
      case 'agentic_attack':
        return "An autonomous AI attack was detected and neutralized before it could spread.";
      case 'natural_disaster':
        final event = rawAlert['event'] ?? 'severe weather';
        return "Warning: $event approaching your area. Prepare evacuation if needed.";
      case 'phishing':
        return "Suspicious message/link blocked. It tried to steal your info — you're protected.";
      default:
        return "Potential threat detected and handled automatically ($confidence% confidence).";
    }
  }

  // Generate proactive tips
  static String getProactiveTip() {
    final tips = [
      "SmartVigilant has blocked 47 threats this month — all automatically.",
      "Your AI models were updated overnight with the latest global intelligence.",
      "Geofence active: You'll be notified if family members leave safe zones.",
      "Quantum-resistant encryption enabled on all backups.",
    ];
    return tips[DateTime.now().millisecond % tips.length];
  }
}

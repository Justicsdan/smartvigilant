// vigilant_alert.dart - Model for all threat alerts (cyber + human + disaster)
import 'package:flutter/material.dart';

enum AlertSeverity { low, medium, high, critical }

enum AlertType {
  malware,
  phishing,
  deepfake,
  agentic_attack,
  anomaly,
  intruder,
  unknown_person,
  suspicious_behavior,
  natural_disaster,
  health_emergency,
  panic,
  system
}

class VigilantAlert {
  final String id;
  final String title;
  final String description;
  final String aiExplanation; // User-friendly NLP version
  final DateTime timestamp;
  final AlertSeverity severity;
  final AlertType type;
  final bool resolved;
  final Map<String, dynamic>? metadata; // e.g., video clip URL, location, confidence

  VigilantAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.aiExplanation,
    required this.timestamp,
    required this.severity,
    required this.type,
    this.resolved = false,
    this.metadata,
  });

  // Factory to parse from backend JSON
  factory VigilantAlert.fromJson(Map<String, dynamic> json) {
    return VigilantAlert(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      aiExplanation: json['ai_explanation'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      severity: _parseSeverity(json['severity'] as String),
      type: _parseType(json['type'] as String),
      resolved: json['resolved'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Convert back to JSON (e.g., for local caching)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'ai_explanation': aiExplanation,
      'timestamp': timestamp.toIso8601String(),
      'severity': severity.name,
      'type': type.name,
      'resolved': resolved,
      'metadata': metadata,
    };
  }

  static AlertSeverity _parseSeverity(String value) {
    switch (value.toLowerCase()) {
      case 'critical':
        return AlertSeverity.critical;
      case 'high':
        return AlertSeverity.high;
      case 'medium':
        return AlertSeverity.medium;
      default:
        return AlertSeverity.low;
    }
  }

  static AlertType _parseType(String value) {
    return AlertType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AlertType.system,
    );
  }

  // Helper: Get color for UI
  Color get color {
    switch (severity) {
      case AlertSeverity.critical:
        return Colors.red;
      case AlertSeverity.high:
        return Colors.orange;
      case AlertSeverity.medium:
        return Colors.amber;
      default:
        return Colors.green;
    }
  }

  // Helper: Get icon
  IconData get icon {
    switch (type) {
      case AlertType.malware:
        return Icons.bug_report;
      case AlertType.deepfake:
        return Icons.record_voice_over;
      case AlertType.intruder:
      case AlertType.unknown_person:
        return Icons.person_off;
      case AlertType.natural_disaster:
        return Icons.warning_amber_rounded;
      case AlertType.panic:
        return Icons.emergency;
      default:
        return Icons.security;
    }
  }
}

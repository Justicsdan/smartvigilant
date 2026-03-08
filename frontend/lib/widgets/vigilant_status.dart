// vigilant_status.dart - Large, animated central status display
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../utils/vigilant_theme.dart';

class VigilantStatus extends StatelessWidget {
  final String status; // e.g., "All Systems Secure", "Threat Detected!"

  const VigilantStatus({Key? key, required this.status}) : super(key: key);

  bool get isSecure => status.toLowerCase().contains('secure') || status.toLowerCase().contains('clear');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSecure
              ? [vigilantPrimary, vigilantPrimaryDark]
              : [Colors.red.shade700, Colors.red.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            isSecure ? Icons.shield : Icons.warning_amber_rounded,
            color: Colors.white,
            size: 80,
          ),
          SizedBox(height: 20),
          AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                status,
                textStyle: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                speed: Duration(milliseconds: 100),
              ),
            ],
            totalRepeatCount: 1,
          ),
          SizedBox(height: 12),
          Text(
            isSecure ? "Your home and devices are protected" : "AI is actively responding",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

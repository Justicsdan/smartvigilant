// vigilant_panic.dart - Large, accessible emergency button (used in multiple screens)
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../../services/vigilant_api.dart';

class VigilantPanicButton extends StatelessWidget {
  final double size;
  final String label;

  const VigilantPanicButton({
    Key? key,
    this.size = 80,
    this.label = "PANIC",
  }) : super(key: key);

  Future<void> _triggerPanic(BuildContext context) async {
    // Haptic feedback
    if (await Vibration.hasCustomVibrationsSupport() ?? false) {
      Vibration.vibrate(pattern: [0, 200, 100, 300]);
    }

    // Call backend emergency endpoint
    await VigilantApi.triggerPanicButton();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("EMERGENCY ALERT SENT — Help is on the way"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTapDown: (_) => _showConfirmDialog(context),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.red.shade600, Colors.red.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: size * 0.6,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red.shade700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.red.shade50,
        title: Text("Confirm Emergency?", style: TextStyle(color: Colors.red.shade900)),
        content: Text("This will alert authorities and trusted contacts immediately."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _triggerPanic(context);
            },
            child: Text("SEND ALERT", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

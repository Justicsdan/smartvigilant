// vigilant_quick_actions.dart - Grid of action buttons on dashboard
import 'package:flutter/material.dart';
import '../../utils/vigilant_theme.dart'; // Make sure this path is correct

class VigilantQuickActions extends StatelessWidget {
  final VoidCallback onCameraPressed;
  final VoidCallback onAlertsPressed;
  final VoidCallback onInsightsPressed;

  const VigilantQuickActions({
    required this.onCameraPressed,
    required this.onAlertsPressed,
    required this.onInsightsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      children: [
        _ActionButton(icon: Icons.camera_alt, label: "Live View", onTap: onCameraPressed),
        _ActionButton(icon: Icons.notifications_active, label: "Alerts", onTap: onAlertsPressed),
        _ActionButton(icon: Icons.insights, label: "AI Insights", onTap: onInsightsPressed),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: vigilantPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: vigilantPrimary),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

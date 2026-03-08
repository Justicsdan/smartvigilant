// onboarding_zones.dart
import 'package:flutter/material.dart';
import '../utils/vigilant_theme.dart';

class OnboardingZones extends StatelessWidget {
  const OnboardingZones({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on_rounded, size: 100, color: vigilantAccent),
            const SizedBox(height: 40),
            Text("Set Safe Zones", style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            Text(
              "Define home, school, or custom zones. Get notified if someone enters or leaves.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 60),
            ElevatedButton.icon(
              icon: const Icon(Icons.map),
              label: const Text("Define Home Zone"),
              onPressed: () => Navigator.pushNamed(context, '/onboarding_complete'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/onboarding_complete'),
              child: const Text("Skip"),
            ),
          ],
        ),
      ),
    );
  }
}

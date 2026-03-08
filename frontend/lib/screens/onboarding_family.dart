import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onboarding_complete.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingFamily extends StatelessWidget {
  const OnboardingFamily({super.key});

  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: vigilantBackground,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const LinearProgressIndicator(value: 0.8, color: vigilantAccent),
            const SizedBox(height: 40),
            const Icon(Icons.people, size: 100, color: vigilantAccent),
            const SizedBox(height: 40),
            Text(
              "Add Trusted Family",
              style: GoogleFonts.orbitron(fontSize: 28, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              "Invite family members to receive alerts and access shared cameras.",
              style: TextStyle(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => _completeOnboarding(context),
                child: const Text("Complete Setup"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onboarding_family.dart';

class OnboardingCamera extends StatelessWidget {
  const OnboardingCamera({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: vigilantBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
            child: const Text("Skip", style: TextStyle(color: vigilantAccent)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const LinearProgressIndicator(value: 0.2, color: vigilantAccent),
            const SizedBox(height: 40),
            const Icon(Icons.camera_alt, size: 100, color: vigilantAccent),
            const SizedBox(height: 40),
            Text(
              "Connect Your Cameras",
              style: GoogleFonts.orbitron(fontSize: 28, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              "SmartVigilant works with any RTSP/ONVIF camera.\nAdd your home cameras to start 24/7 protection.",
              style: TextStyle(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OnboardingFamily()),
                  );
                },
                child: const Text("Continue"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

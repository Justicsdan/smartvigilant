import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/vigilant_constants.dart';
import '../utils/vigilant_theme.dart';
import 'onboarding_camera.dart';

class OnboardingWelcome extends StatelessWidget {
  const OnboardingWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: vigilantBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Spacer(),
              Image.asset("assets/images/smartvigilant_logo.png", height: 180),
              const SizedBox(height: 40),
              Text(
                "Welcome to SmartVigilant",
                style: GoogleFonts.orbitron(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                "Your AI guardian for home and digital life.\nProtect what matters most.",
                style: const TextStyle(fontSize: 18, color: Colors.white70),
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
                      MaterialPageRoute(builder: (context) => const OnboardingCamera()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: vigilantAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Get Started", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// vigilant_setup.dart - First-run wizard and advanced settings
import 'package:flutter/material.dart';
import '../services/vigilant_api.dart';

class VigilantSetup extends StatefulWidget {
  @override
  _VigilantSetupState createState() => _VigilantSetupState();
}

class _VigilantSetupState extends State<VigilantSetup> {
  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Setup & Settings")),
      body: Stepper(
        currentStep: currentStep,
        onStepContinue: () {
          if (currentStep < 3) setState(() => currentStep++);
        },
        onStepCancel: () {
          if (currentStep > 0) setState(() => currentStep--);
        },
        steps: [
          Step(title: Text("Connect Devices"), content: Text("Link cameras, smart locks, and sensors")),
          Step(title: Text("Set Safe Zones"), content: Text("Define home boundaries and trusted faces")),
          Step(title: Text("Enable AI Shield"), content: Text("Activate AI-vs-AI defense and disaster monitoring")),
          Step(title: Text("Complete!"), content: Text("SmartVigilant is now protecting you 24/7"), isActive: true),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/onboarding_welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  apiClient.init();

  runApp(const SmartVigilantApp());
}

class SmartVigilantApp extends StatelessWidget {
  const SmartVigilantApp({super.key});

  Future<Widget> _getStartingScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    final isLoggedIn = await authService.isLoggedIn();

    if (!onboardingComplete) {
      return const OnboardingWelcome();
    }

    if (!isLoggedIn) {
      return const LoginScreen();
    }

    return const DashboardScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "SmartVigilant",
      debugShowCheckedModeBanner: false,
      theme: vigilantTheme.copyWith(
        textTheme: GoogleFonts.orbitronTextTheme(vigilantTheme.textTheme),
      ),
      home: FutureBuilder<Widget>(
        future: _getStartingScreen(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data!;
          }
          return const Scaffold(
            backgroundColor: vigilantBackground,
            body: Center(
              child: CircularProgressIndicator(color: vigilantAccent),
            ),
          );
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/onboarding_welcome': (context) => const OnboardingWelcome(),
        // Other onboarding screens will be pushed manually
      },
    );
  }
}

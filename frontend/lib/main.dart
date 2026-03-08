import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/vigilant_dashboard.dart';
import 'screens/vigilant_alerts.dart';
import 'screens/vigilant_camera.dart';
import 'screens/vigilant_insights.dart';
import 'screens/vigilant_setup.dart';
import 'screens/vigilant_verify_email.dart';
import 'screens/vigilant_forgot_password.dart';
import 'screens/onboarding_welcome.dart';
import 'screens/onboarding_camera.dart';
import 'screens/onboarding_family.dart';
import 'screens/onboarding_zones.dart';
import 'screens/onboarding_complete.dart';

import 'services/vigilant_api.dart';
import 'utils/vigilant_theme.dart';
import 'utils/vigilant_constants.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize cameras
  try {
    cameras = await availableCameras();
  } catch (e) {
    cameras = [];
  }

  // Initialize API client
  vigilantApi.initialize();

  runApp(const SmartVigilantApp());
}

class SmartVigilantApp extends StatelessWidget {
  const SmartVigilantApp({super.key});

  Future<String> _determineInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    // Future: add auth check here
    return onboardingComplete ? '/dashboard' : '/onboarding_welcome';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: VigilantConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: vigilantTheme.copyWith(
        textTheme: GoogleFonts.robotoTextTheme(vigilantTheme.textTheme),
      ),
      home: FutureBuilder<String>(
        future: _determineInitialRoute(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          final route = snapshot.data ?? '/onboarding_welcome';
          return Navigator(
            onGenerateRoute: (settings) {
              Widget page;
              switch (route) {
                case '/dashboard':
                  page = const VigilantDashboard();
                  break;
                default:
                  page = const OnboardingWelcome();
              }
              return MaterialPageRoute(builder: (_) => page);
            },
          );
        },
      ),
      routes: {
        '/dashboard': (context) => const VigilantDashboard(),
        '/alerts': (context) => const VigilantAlerts(),
        '/camera': (context) => const VigilantCamera(),
        '/insights': (context) => const VigilantInsights(),
        '/setup': (context) => const VigilantSetup(),
        '/verify-email': (context) => const VigilantVerifyEmail(email: ""),
        '/forgot-password': (context) => const VigilantForgotPassword(),
        '/onboarding_welcome': (context) => const OnboardingWelcome(),
        '/onboarding_camera': (context) => const OnboardingCamera(),
        '/onboarding_family': (context) => const OnboardingFamily(),
        '/onboarding_zones': (context) => const OnboardingZones(),
        '/onboarding_complete': (context) => const OnboardingComplete(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: vigilantPrimaryDark,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/smartvigilant_logo.png',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 40),
                Text(
                  VigilantConstants.appName,
                  style: GoogleFonts.orbitron(
                    fontSize: 42,
                    color: vigilantAccent,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "by Dutycall",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  VigilantConstants.tagline,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 100),
                const CircularProgressIndicator(
                  color: vigilantAccent,
                  strokeWidth: 6,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

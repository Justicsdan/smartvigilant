class VigilantConstants {
  // === API & WebSocket ===
  static const String apiBaseUrl = 'http://10.0.2.2:8000/api/v1';  // Android emulator localhost
  // For real device: replace with your PC IP, e.g. 'http://192.168.1.100:8000/api/v1'
  // Production: 'https://api.smartvigilant.com/api/v1'
  static const String wsBaseUrl = 'wss://api.smartvigilant.com/ws';

  // === App Info ===
  static const String appName = 'SmartVigilant';
  static const String appVersion = '1.0.0';
  static const String appBuild = '20260107';  // January 07, 2026
  static const String developer = 'Danladi Heman Shagatpo';
  static const String business = 'Dutycall';
  static const String tagline = 'AI-Powered Protection for Home & Digital Life';

  // === Security & Performance ===
  static const Duration alertRefreshInterval = Duration(seconds: 30);
  static const Duration cameraStreamInterval = Duration(milliseconds: 500);
  static const int maxAlertHistory = 200;
  static const int maxDevices = 10;  // Free tier limit

  // === Threat Confidence Thresholds ===
  static const double lowConfidenceThreshold = 0.5;
  static const double mediumConfidenceThreshold = 0.7;
  static const double highConfidenceThreshold = 0.85;
  static const double criticalConfidenceThreshold = 0.95;

  // === UI Constants ===
  static const double defaultPadding = 16.0;
  static const double largePadding = 32.0;
  static const double cardRadius = 16.0;
  static const double buttonHeight = 56.0;
  static const double iconSizeSmall = 24.0;
  static const double iconSizeMedium = 36.0;
  static const double iconSizeLarge = 48.0;

  // === Colors (for easy theming) ===
  static const Color primaryColor = Color(0xFF6A1B9A);  // Deep Purple
  static const Color accentColor = Color(0xFF00D4FF);   // Cyan
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);

  // === Supported Languages ===
  static const List<String> supportedLocales = ['en', 'es', 'fr', 'pt', 'ha', 'yo', 'ig'];  // Added Nigerian languages

  // === Emergency ===
  static const String defaultEmergencyNumber = '+2347080304822';  // Your number as default
  static const String emergencyMessage = "EMERGENCY: SmartVigilant panic button activated! Immediate help needed.";

  // === Onboarding ===
  static const int onboardingSteps = 5;
}

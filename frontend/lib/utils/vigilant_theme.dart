import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// === SmartVigilant Color Palette ===
const Color vigilantPrimary = Color(0xFF0A3D62);        // Deep Navy Blue - Trust & Authority
const Color vigilantPrimaryDark = Color(0xFF061F3A);   // Darker variant
const Color vigilantAccent = Color(0xFF00D4FF);         // Electric Cyan - Energy & Alerts
const Color vigilantSuccess = Color(0xFF2ECC71);       // Emerald Green
const Color vigilantWarning = Color(0xFFF39C12);       // Amber Orange
const Color vigilantDanger = Color(0xFFE74C3C);         // Crimson Red
const Color vigilantBackground = Color(0xFF0B1626);    // Deep Space Blue
const Color vigilantCard = Color(0xFF152238);          // Card background
const Color vigilantSurface = Color(0xFF1E2A44);        // Elevated surfaces

// === Dark Theme - Primary for SmartVigilant ===
final ThemeData vigilantTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: vigilantPrimary,
  scaffoldBackgroundColor: vigilantBackground,
  canvasColor: vigilantBackground,

  // AppBar
  appBarTheme: AppBarTheme(
    backgroundColor: vigilantPrimaryDark,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.orbitron(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      letterSpacing: 1.5,
    ),
    iconTheme: const IconThemeData(color: vigilantAccent),
  ),

  // Text Theme
  textTheme: GoogleFonts.robotoTextTheme(const TextTheme(
    displayLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
    headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
    headlineMedium: TextStyle(fontSize: 24, color: vigilantAccent),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.white60),
    labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
  )),

  // Cards
  cardTheme: CardTheme(
    color: vigilantCard,
    elevation: 8,
    shadowColor: Colors.black.withOpacity(0.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
  ),

  // Buttons
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: vigilantAccent,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
    ),
  ),

  // Floating Action Button (Panic Button)
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: vigilantDanger,
    foregroundColor: Colors.white,
    elevation: 12,
    sizeConstraints: BoxConstraints(minWidth: 72, minHeight: 72),
  ),

  // Icons
  iconTheme: const IconThemeData(color: vigilantAccent, size: 28),
  primaryIconTheme: const IconThemeData(color: Colors.white),

  // Color Scheme
  colorScheme: ColorScheme.dark(
    primary: vigilantPrimary,
    secondary: vigilantAccent,
    surface: vigilantSurface,
    error: vigilantDanger,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: Colors.white70,
    onError: Colors.white,
  ),

  // Material 3
  useMaterial3: true,

  // Divider
  dividerColor: Colors.white10,

  // Input Decoration
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: vigilantCard,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: vigilantAccent, width: 2),
    ),
    labelStyle: const TextStyle(color: Colors.grey),
    hintStyle: const TextStyle(color: Colors.grey),
  ),
);

// === Light Theme Variant (Future Toggle) ===
final ThemeData vigilantLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: vigilantPrimary,
  scaffoldBackgroundColor: Colors.grey[50],
  appBarTheme: AppBarTheme(
    backgroundColor: vigilantPrimary,
    foregroundColor: Colors.white,
    elevation: 0,
    titleTextStyle: GoogleFonts.orbitron(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  cardColor: Colors.white,
  textTheme: GoogleFonts.robotoTextTheme(),
  useMaterial3: true,
);

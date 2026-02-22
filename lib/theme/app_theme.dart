import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF05070D);
  static const Color surface = Color(0xFF0B1220);
  static const Color surfaceAlt = Color(0xFF101B2D);
  static const Color card = surface;
  static const Color cardBorder = Color(0xFF1A2B46);
  static const Color primaryBlue = Color(0xFF1E4BFF);
  static const Color accentBlue = Color(0xFF3BA4FF);
  static const Color blueGlow = Color(0xFF0A84FF);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF90A4C8);
  static const Color textMuted = Color(0xFF6C7DA0);
  static const Color danger = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);

  static const LinearGradient appGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF05070D), Color(0xFF0A1221), Color(0xFF0E1A2F)],
    stops: [0.0, 0.55, 1.0],
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: accentBlue,
      surface: surface,
      error: danger,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(
        bodyMedium: TextStyle(color: textPrimary),
        bodySmall: TextStyle(color: textSecondary),
      ),
    ).apply(bodyColor: textPrimary, displayColor: textPrimary),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: accentBlue,
      inactiveTrackColor: Color(0xFF1D2A45),
      thumbColor: primaryBlue,
      overlayColor: Color(0x332563EB),
      trackHeight: 6,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
    cardTheme: const CardThemeData(
      color: surface,
      margin: EdgeInsets.zero,
      elevation: 0,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: accentBlue),
    dividerTheme: const DividerThemeData(color: cardBorder),
    useMaterial3: true,
  );
}

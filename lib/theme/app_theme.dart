import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/language_controller.dart';

class AppTheme {
  // Sudan Flag Colors
  static const Color sudanRed = Color(0xFFDC143C); // Determination and rescue
  static const Color sudanBlack = Color(0xFF000000); // Resilience
  static const Color sudanWhite = Color(0xFFFFFFFF); // Purity and transparency
  static const Color sudanGreen = Color(0xFF228B22); // Hope and life

  // App Colors (using Sudan flag colors)
  static const Color primaryColor = sudanRed;
  static const Color secondaryColor = sudanGreen;
  static const Color backgroundColor = sudanWhite;
  static const Color surfaceColor = sudanWhite;
  static const Color errorColor = sudanRed;
  static const Color textPrimaryColor = sudanBlack;
  static const Color textSecondaryColor = Color(0xFF757575);

  // Get font family based on current language
  static String get fontFamily {
    try {
      final languageController = Get.find<LanguageController>();
      return languageController.isArabic ? 'Tajawal' : 'Roboto';
    } catch (e) {
      // Fallback to Tajawal if language controller is not available
      return 'Tajawal';
    }
  }

  // Light Theme
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    fontFamily: fontFamily, // Dynamic font based on language
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryColor,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: surfaceColor,
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: textPrimaryColor,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        fontFamily: fontFamily,
      ),
      headlineMedium: TextStyle(
        color: textPrimaryColor,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        fontFamily: fontFamily,
      ),
      headlineSmall: TextStyle(
        color: textPrimaryColor,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        fontFamily: fontFamily,
      ),
      titleLarge: TextStyle(
        color: textPrimaryColor,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        fontFamily: fontFamily,
      ),
      titleMedium: TextStyle(
        color: textPrimaryColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamily,
      ),
      titleSmall: TextStyle(
        color: textPrimaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamily,
      ),
      bodyLarge: TextStyle(
        color: textPrimaryColor,
        fontSize: 16,
        fontWeight: FontWeight.normal,
        fontFamily: fontFamily,
      ),
      bodyMedium: TextStyle(
        color: textPrimaryColor,
        fontSize: 14,
        fontWeight: FontWeight.normal,
        fontFamily: fontFamily,
      ),
      bodySmall: TextStyle(
        color: textSecondaryColor,
        fontSize: 12,
        fontWeight: FontWeight.normal,
        fontFamily: fontFamily,
      ),
    ),
  );
}

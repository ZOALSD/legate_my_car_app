import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UtilsHelper {
  // Get translation with fallback
  static String tr(String key, {String? fallback}) {
    try {
      return key.tr;
    } catch (e) {
      return fallback ?? key;
    }
  }

  // Get translation with parameters
  static String trParams(String key, Map<String, String> params) {
    try {
      String translation = key.tr;
      params.forEach((key, value) {
        translation = translation.replaceAll('{$key}', value);
      });
      return translation;
    } catch (e) {
      return key;
    }
  }

  // Check if translation exists
  static bool hasTranslation(String key) {
    try {
      final translation = key.tr;
      return translation != key;
    } catch (e) {
      return false;
    }
  }

  // Get all available languages
  static List<String> getAvailableLanguages() {
    return ['en', 'ar'];
  }

  // Get language name
  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      default:
        return languageCode;
    }
  }

  // Get current language
  static String getCurrentLanguage() {
    return Get.locale?.languageCode ?? 'en';
  }

  // Check if current language is RTL
  static bool isRTL() {
    return Get.locale?.languageCode == 'ar';
  }

  // Show Material SnackBar
  static void showSnackBar(
    BuildContext context, {
    required String message,
    String? title,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: title != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor ?? Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    message,
                    style: TextStyle(
                      color: textColor ?? Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            : Text(
                message,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: 14,
                ),
              ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Show success SnackBar
  static void showSuccessSnackBar(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    showSnackBar(
      context,
      message: message,
      title: title,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      duration: duration,
    );
  }

  // Show error SnackBar
  static void showErrorSnackBar(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 4),
  }) {
    showSnackBar(
      context,
      message: message,
      title: title,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      duration: duration,
    );
  }

  // Show info SnackBar
  static void showInfoSnackBar(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    showSnackBar(
      context,
      message: message,
      title: title,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      duration: duration,
    );
  }
}

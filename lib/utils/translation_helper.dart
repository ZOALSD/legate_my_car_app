import 'package:get/get.dart';

class TranslationHelper {
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
}

import 'package:get/get.dart';
import 'package:flutter/material.dart';

class LanguageController extends GetxController {
  // Current locale - Default to Arabic
  final Rx<Locale> _currentLocale = const Locale('ar', 'SA').obs;

  // Available locales
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('ar', 'SA'), // Arabic
  ];

  // Getters
  Locale get currentLocale => _currentLocale.value;
  String get currentLanguageCode => _currentLocale.value.languageCode;
  bool get isArabic => currentLanguageCode == 'ar';
  bool get isEnglish => currentLanguageCode == 'en';

  @override
  void onInit() {
    super.onInit();
    // Initialize with saved locale or default to English
    _loadSavedLocale();
  }

  // Load saved locale from storage
  void _loadSavedLocale() {
    // In a real app, you would load this from SharedPreferences
    // For now, we'll use Arabic as default
    _currentLocale.value = const Locale('ar', 'SA');
  }

  // Change language
  void changeLanguage(String languageCode) {
    Locale newLocale;

    switch (languageCode) {
      case 'ar':
        newLocale = const Locale('ar', 'SA');
        break;
      case 'en':
      default:
        newLocale = const Locale('en', 'US');
        break;
    }

    if (_currentLocale.value != newLocale) {
      _currentLocale.value = newLocale;
      Get.updateLocale(newLocale);

      // In a real app, you would save this to SharedPreferences
      _saveLocale(newLocale);
    }
  }

  // Save locale to storage
  void _saveLocale(Locale locale) {
    // In a real app, you would save this to SharedPreferences
    // SharedPreferences.getInstance().then((prefs) {
    //   prefs.setString('language_code', locale.languageCode);
    // });
  }

  // Toggle between Arabic and English
  void toggleLanguage() {
    if (isArabic) {
      changeLanguage('en');
    } else {
      changeLanguage('ar');
    }
  }

  // Get language name
  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return 'العربية';
      case 'en':
      default:
        return 'English';
    }
  }

  // Get current language name
  String get currentLanguageName => getLanguageName(currentLanguageCode);
}

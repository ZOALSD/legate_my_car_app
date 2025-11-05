import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:legate_my_car/intro_view.dart';
import 'theme/app_theme.dart';
import 'translations/app_translations.dart';
import 'controllers/language_controller.dart';
import 'config/env_config.dart';
import 'config/app_flavor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize app flavor detection
  await AppFlavorConfig.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize language controller
    Get.put(LanguageController());

    return GetMaterialApp(
      title: 'لقيت عربيتي',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: EnvConfig.showDebugBanner,
      translations: AppTranslations(),
      locale: Get.find<LanguageController>().currentLocale,
      fallbackLocale: const Locale("ar", "SA"),
      supportedLocales: LanguageController.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: const IntroView(),
    );
  }
}

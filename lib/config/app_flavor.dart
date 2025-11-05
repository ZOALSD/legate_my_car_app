import 'package:flutter/services.dart';
import 'dart:io';

enum AppFlavor { managers, clients }

class AppFlavorConfig {
  static AppFlavor? _flavor;
  static const MethodChannel _channel = MethodChannel(
    'com.laqeetarabeety.app/flavor',
  );

  // Initialize flavor based on platform
  static Future<void> init() async {
    if (Platform.isAndroid) {
      // On Android, get flavor from native side via MethodChannel
      try {
        final String? flavorString = await _channel.invokeMethod(
          'getAppFlavor',
        );
        print('🔥 Flavor: $flavorString');
        _flavor = _parseFlavor(flavorString);
      } catch (e) {
        // If MethodChannel fails, try to detect from package name
        _flavor = _detectFlavorFromPackage();
      }
    }
    if (Platform.isIOS) {
      _flavor = AppFlavor.managers; // Default for iOS
    }
  }

  static AppFlavor _parseFlavor(String? flavorString) {
    if (flavorString == null) return AppFlavor.managers;
    return switch (flavorString.toLowerCase()) {
      'clients' => AppFlavor.clients,
      'managers' => AppFlavor.managers,
      _ => AppFlavor.managers,
    };
  }

  static AppFlavor _detectFlavorFromPackage() {
    // Fallback: detect from environment or defaults
    // In production, this should come from native side
    return AppFlavor.managers;
  }

  // Get current flavor
  static AppFlavor get flavor {
    return _flavor ?? AppFlavor.managers;
  }

  // Check if current flavor is managers
  static bool get isManagers => flavor == AppFlavor.managers;

  // Check if current flavor is clients
  static bool get isClients => flavor == AppFlavor.clients;

  // Get application ID based on flavor
  static String get applicationId {
    switch (flavor) {
      case AppFlavor.managers:
        return 'com.laqeetarabeety.managers';
      case AppFlavor.clients:
        return 'com.laqeetarabeety.clinets';
    }
  }

  // Get app name based on flavor
  static String get appName {
    switch (flavor) {
      case AppFlavor.managers:
        return 'لقيت عربيتي - Managers';
      case AppFlavor.clients:
        return 'لقيت عربيتي - Clients';
    }
  }

  // Get logo path based on flavor
  static String get logoPath {
    final currentFlavor = flavor;
    switch (currentFlavor) {
      case AppFlavor.managers:
        return 'assets/images/managers.svg';
      case AppFlavor.clients:
        return 'assets/images/clients.svg';
    }
  }

  // Set flavor manually (for testing or when native detection isn't available)
  static void setFlavor(AppFlavor flavor) {
    _flavor = flavor;
  }
}

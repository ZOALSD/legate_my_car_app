# Flavor Setup Guide

This app supports two product flavors:
- **managers**: For manager users (default)
- **clients**: For client users with package name `com.laqeetarabeety.clinets`

## Building with Flavors

### Android

#### Managers Flavor
```bash
flutter build apk --flavor managers --release
flutter build appbundle --flavor managers --release
flutter run --flavor managers
```

#### Clients Flavor
```bash
flutter build apk --flavor clients --release
flutter build appbundle --flavor clients --release
flutter run --flavor clients
```

### iOS (requires Xcode configuration)

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the Runner target
3. Duplicate scheme: "managers" and "clients"
4. Configure Build Settings for each scheme with different Bundle Identifiers

## Adding Different Icons

### Android

1. **For Managers flavor:**
   - Place icons in: `android/app/src/managers/res/mipmap-*/`
   - Copy the icon files from `android/app/src/main/res/mipmap-*/` and replace with manager-specific icons

2. **For Clients flavor:**
   - Place icons in: `android/app/src/clients/res/mipmap-*/`
   - Copy the icon files from `android/app/src/main/res/mipmap-*/` and replace with client-specific icons

**Required icon sizes:**
- `mipmap-mdpi`: 48x48
- `mipmap-hdpi`: 72x72
- `mipmap-xhdpi`: 96x96
- `mipmap-xxhdpi`: 144x144
- `mipmap-xxxhdpi`: 192x192
- `mipmap-anydpi-v26`: Adaptive icon configuration

### iOS

1. Create separate asset catalogs for each flavor
2. Configure in Xcode scheme settings

## Flavor Detection in Code

Use the `AppFlavorConfig` class to detect the current flavor:

```dart
import 'package:legate_my_car/config/app_flavor.dart';

// Check current flavor
if (AppFlavorConfig.isManagers) {
  // Manager-specific code
}

if (AppFlavorConfig.isClients) {
  // Client-specific code
}

// Get application ID
String appId = AppFlavorConfig.applicationId;

// Get app name
String appName = AppFlavorConfig.appName;
```

## Package Names

- **Managers**: `com.laqeetarabeety.managers`
- **Clients**: `com.laqeetarabeety.clinets`

## Notes

- The flavor is automatically detected at app startup via native code (Android MethodChannel)
- Default flavor if detection fails: `managers`
- Different flavors can have different app names, icons, and configurations


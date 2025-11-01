# Launcher Icon Setup for Flavors

## Overview

The app uses different launcher icons for each flavor:
- **Managers flavor**: `android/app/src/managers/res/`
- **Clients flavor**: `android/app/src/clients/res/`

Android automatically uses flavor-specific resources when building with a specific flavor.

## Launcher Configuration Files

### Adaptive Icon XML (Android 8.0+)

Both flavors have their adaptive icon configuration:

1. **Managers**: `android/app/src/managers/res/mipmap-anydpi-v26/ic_launcher.xml`
2. **Clients**: `android/app/src/clients/res/mipmap-anydpi-v26/ic_launcher.xml`

These XML files reference the adaptive icon layers:
```xml
<adaptive-icon>
  <background android:drawable="@mipmap/ic_launcher_adaptive_back"/>
  <foreground android:drawable="@mipmap/ic_launcher_adaptive_fore"/>
</adaptive-icon>
```

## How It Works

1. **Resource Resolution**:
   - When building with `--flavor managers`, Android uses resources from `android/app/src/managers/res/`
   - When building with `--flavor clients`, Android uses resources from `android/app/src/clients/res/`
   - If a resource is missing in flavor directory, it falls back to `android/app/src/main/res/`

2. **Launcher Icon Reference**:
   - The `AndroidManifest.xml` references `@mipmap/ic_launcher`
   - Android automatically resolves to the flavor-specific `ic_launcher.png` or `ic_launcher.xml`

## Current Status

✅ Launcher XML files created for both flavors
✅ Icon placeholders copied from main (use as base)
✅ Directory structure ready for flavor-specific icons

## Next Steps

1. **Design flavor-specific icons**:
   - Create manager-specific icons
   - Create client-specific icons

2. **Replace placeholder icons**:
   - Replace icons in `android/app/src/managers/res/mipmap-*/`
   - Replace icons in `android/app/src/clients/res/mipmap-*/`

3. **Generate all required sizes**:
   - Use Android Asset Studio or similar tool
   - Generate icons for all density folders (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)

4. **Test launcher icons**:
   ```bash
   # Test managers launcher
   flutter run --flavor managers
   
   # Test clients launcher
   flutter run --flavor clients
   ```

## Icon Files Needed

For each flavor, you need icons in these directories:

```
mipmap-mdpi/       (48x48 px)
  - ic_launcher.png
  - ic_launcher_adaptive_back.png
  - ic_launcher_adaptive_fore.png

mipmap-hdpi/       (72x72 px)
  - ic_launcher.png
  - ic_launcher_adaptive_back.png
  - ic_launcher_adaptive_fore.png

mipmap-xhdpi/      (96x96 px)
  - ic_launcher.png
  - ic_launcher_adaptive_back.png
  - ic_launcher_adaptive_fore.png

mipmap-xxhdpi/     (144x144 px)
  - ic_launcher.png
  - ic_launcher_adaptive_back.png
  - ic_launcher_adaptive_fore.png

mipmap-xxxhdpi/    (192x192 px)
  - ic_launcher.png
  - ic_launcher_adaptive_back.png
  - ic_launcher_adaptive_fore.png

mipmap-anydpi-v26/
  - ic_launcher.xml (already configured)
```

## Notes

- The launcher XML files are already set up and don't need modification unless you change the icon structure
- Android will automatically use the correct icons when building with the specified flavor
- The `ic_launcher.png` files are used for devices running Android 7.1 and below
- Adaptive icons (`ic_launcher_adaptive_*.png`) are used for Android 8.0+
- Both icon types should be present for full compatibility


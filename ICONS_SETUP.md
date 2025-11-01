# App Icons Setup for Flavors

## Current Icon Locations

### Default Icons (Main)

- Location: `android/app/src/main/res/mipmap-*/`
- These are used as fallback if flavor-specific icons are not found

### Managers Flavor Icons

- Location: `android/app/src/managers/res/mipmap-*/`
- Launcher XML: `android/app/src/managers/res/mipmap-anydpi-v26/ic_launcher.xml`
- Icons copied from main (as placeholder) - replace with manager-specific icons

### Clients Flavor Icons

- Location: `android/app/src/clients/res/mipmap-*/`
- Launcher XML: `android/app/src/clients/res/mipmap-anydpi-v26/ic_launcher.xml`
- Icons copied from main (as placeholder) - replace with client-specific icons

## Icon File Structure

Each flavor needs icons in these directories:

```
mipmap-mdpi/       (48x48 px)
mipmap-hdpi/       (72x72 px)
mipmap-xhdpi/      (96x96 px)
mipmap-xxhdpi/     (144x144 px)
mipmap-xxxhdpi/    (192x192 px)
mipmap-anydpi-v26/ (adaptive icon configuration)
```

## Required Files per Directory

Each `mipmap-*` directory (except `mipmap-anydpi-v26`) should contain:

- `ic_launcher.png` - Main launcher icon
- `ic_launcher_adaptive_back.png` - Adaptive icon background (for Android 8.0+)
- `ic_launcher_adaptive_fore.png` - Adaptive icon foreground (for Android 8.0+)

The `mipmap-anydpi-v26` directory should contain:

- `ic_launcher.xml` - Adaptive icon configuration (already set up for both flavors)

## Steps to Add Custom Icons

1. **Copy existing icons as base:**

   ```bash
   # For managers flavor
   cp -r android/app/src/main/res/mipmap-* android/app/src/managers/res/

   # For clients flavor
   cp -r android/app/src/main/res/mipmap-* android/app/src/clients/res/
   ```

2. **Replace icons with flavor-specific versions:**

   - Design your manager icon
   - Design your client icon
   - Generate all required sizes using Android Asset Studio or similar tool
   - Replace the files in respective flavor directories

3. **Update adaptive icon config** (if using adaptive icons):
   - Edit `android/app/src/[flavor]/res/mipmap-anydpi-v26/ic_launcher.xml`
   - Update paths if needed

## Testing Icons

After adding icons, rebuild the app with the specific flavor:

```bash
# Test managers flavor icons
flutter run --flavor managers

# Test clients flavor icons
flutter run --flavor clients
```

## Tools for Icon Generation

- **Android Asset Studio**: https://romannurik.github.io/AndroidAssetStudio/icons-launcher.html
- **Flutter Icon**: https://fluttericon.com/
- **App Icon Generator**: Various online tools available

## Notes

- Icons must be PNG format
- Ensure icons are properly sized for each density
- Test on multiple devices to ensure icons display correctly
- Adaptive icons (Android 8.0+) require both foreground and background layers

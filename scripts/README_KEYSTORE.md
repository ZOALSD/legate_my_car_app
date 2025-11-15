# Android Release Keystore Setup

This project uses separate keystores for signing release builds of the Android app.

## Current Keystores

- **Clients**: `android/app/clients-release-key.jks` (already exists)
- **Managers**: `android/app/managers-release-key.jks` (create if needed)

## Creating Keystores

### Quick Setup

Run the keystore creation script:

```bash
# Create keystores for both flavors
./scripts/create_keystore.sh

# Or create for a specific flavor
./scripts/create_keystore.sh -f managers
./scripts/create_keystore.sh -f clients
```

### Manual Creation

If you prefer to create keystores manually:

```bash
# For managers flavor
keytool -genkey -v \
  -keystore android/app/managers-release-key.jks \
  -alias managers \
  -keyalg RSA \
  -keysize 2048 \
  -validity 9125 \
  -storepass <your-password> \
  -keypass <your-password> \
  -dname "CN=Legate My Car, OU=Mobile, O=Legate My Car, L=Khartoum, ST=Khartoum, C=SD"

# For clients flavor
keytool -genkey -v \
  -keystore android/app/clients-release-key.jks \
  -alias clients \
  -keyalg RSA \
  -keysize 2048 \
  -validity 9125 \
  -storepass <your-password> \
  -keypass <your-password> \
  -dname "CN=Legate My Car, OU=Mobile, O=Legate My Car, L=Khartoum, ST=Khartoum, C=SD"
```

## Configuration

### Option 1: Single Keystore (Current Setup)

Both flavors use the same keystore. Update `android/key.release.properties`:

```properties
storePassword=<your-password>
keyPassword=<your-password>
keyAlias=clients
storeFile=app/clients-release-key.jks
```

### Option 2: Separate Keystores (Recommended)

If you create separate keystores, you can:
1. Update `build_release.sh` to use different properties files per flavor
2. Or modify `build.gradle.kts` to support flavor-specific signing configs

## Building Release APKs

After keystores are configured, build release APKs:

```bash
# Build app bundle for managers
./scripts/build_release.sh -t appbundle -f managers

# Build APK for clients
./scripts/build_release.sh -t apk -f clients
```

## Security Notes

⚠️ **IMPORTANT**:
- Never commit keystore files (`.jks`, `.keystore`) to version control
- Never commit passwords in property files
- Store keystore passwords securely
- Keep backups of your keystore files in a secure location
- If you lose your keystore, you won't be able to update your app on Google Play

## Keystore Properties File Structure

The `android/key.release.properties` file should contain:

```properties
storePassword=<keystore-password>
keyPassword=<key-password>
keyAlias=<key-alias>
storeFile=<relative-path-to-keystore>
```

Example:
```properties
storePassword=MySecurePassword123!
keyPassword=MySecurePassword123!
keyAlias=clients
storeFile=app/clients-release-key.jks
```


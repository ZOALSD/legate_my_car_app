#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_DIR="$PROJECT_ROOT/android"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"
SWITCH_KEYSTORE="$SCRIPTS_DIR/switch_keystore.sh"
BUILD_TYPE="appbundle"  # default to appbundle
FLAVOR=""
SWITCH_BACK=false

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Build a release app bundle or APK for the Flutter app.

Options:
  -t, --type TYPE          Build type: 'appbundle' or 'apk' (default: appbundle)
  -f, --flavor FLAVOR      Build flavor: 'managers' or 'clients' (required)
  -k, --keep-release       Keep release keystore after build (default: switch back to debug)
  -h, --help               Show this help message

Examples:
  $(basename "$0") -t appbundle -f managers
  $(basename "$0") -t apk -f clients
  $(basename "$0") -t appbundle -f managers -k
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -t|--type)
      BUILD_TYPE="$2"
      shift 2
      ;;
    -f|--flavor)
      FLAVOR="$2"
      shift 2
      ;;
    -k|--keep-release)
      SWITCH_BACK=false
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

# Validate flavor
if [[ -z "$FLAVOR" ]]; then
  echo "❌ Error: Flavor is required"
  usage
  exit 1
fi

if [[ "$FLAVOR" != "managers" && "$FLAVOR" != "clients" ]]; then
  echo "❌ Error: Invalid flavor '$FLAVOR'. Must be 'managers' or 'clients'"
  exit 1
fi

# Validate build type
if [[ "$BUILD_TYPE" != "appbundle" && "$BUILD_TYPE" != "apk" ]]; then
  echo "❌ Error: Invalid build type '$BUILD_TYPE'. Must be 'appbundle' or 'apk'"
  exit 1
fi

echo "🚀 Starting release build..."
echo "   Flavor: $FLAVOR"
echo "   Type: $BUILD_TYPE"
echo ""

# Switch to release keystore
echo "📝 Switching to release keystore..."
if [[ -f "$SWITCH_KEYSTORE" ]]; then
  bash "$SWITCH_KEYSTORE" release
else
  echo "⚠️  Warning: switch_keystore.sh not found. Continuing without switching..."
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
cd "$PROJECT_ROOT"
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build based on type
echo "🔨 Building release $BUILD_TYPE for $FLAVOR..."
if [[ "$BUILD_TYPE" == "appbundle" ]]; then
  flutter build appbundle --release --flavor "$FLAVOR"
  OUTPUT_FILE="$PROJECT_ROOT/build/app/outputs/bundle/${FLAVOR}Release/app-release.aab"
  echo ""
  echo "✅ App bundle built successfully!"
  echo "   Location: $OUTPUT_FILE"
else
  flutter build apk --release --flavor "$FLAVOR"
  OUTPUT_FILE="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-${FLAVOR}-release.apk"
  echo ""
  echo "✅ APK built successfully!"
  echo "   Location: $OUTPUT_FILE"
fi

# Switch back to debug keystore if requested
if [[ "$SWITCH_BACK" == false ]]; then
  echo ""
  echo "📝 Switching back to debug keystore..."
  if [[ -f "$SWITCH_KEYSTORE" ]]; then
    bash "$SWITCH_KEYSTORE" debug
  fi
fi

echo ""
echo "🎉 Build completed successfully!"


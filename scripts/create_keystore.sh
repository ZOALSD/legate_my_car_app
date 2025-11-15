#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_DIR="$PROJECT_ROOT/android"
KEYSTORE_DIR="$ANDROID_DIR/app"

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Create release keystores for Android app flavors.

Options:
  -f, --flavor FLAVOR      Flavor to create keystore for: 'managers', 'clients', or 'all' (default: all)
  -a, --alias ALIAS        Key alias (default: based on flavor)
  -p, --password PASSWORD  Keystore password (default: prompted)
  -v, --validity YEARS     Validity period in years (default: 25)
  -h, --help               Show this help message

Examples:
  $(basename "$0")                          # Create keystores for both flavors (prompts for passwords)
  $(basename "$0") -f managers              # Create keystore for managers only
  $(basename "$0") -f clients -p mypass123  # Create keystore for clients with password
  $(basename "$0") -f all -v 30             # Create both keystores with 30-year validity
EOF
}

FLAVOR="all"
ALIAS=""
PASSWORD=""
VALIDITY=25

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -f|--flavor)
      FLAVOR="$2"
      shift 2
      ;;
    -a|--alias)
      ALIAS="$2"
      shift 2
      ;;
    -p|--password)
      PASSWORD="$2"
      shift 2
      ;;
    -v|--validity)
      VALIDITY="$2"
      shift 2
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
if [[ "$FLAVOR" != "managers" && "$FLAVOR" != "clients" && "$FLAVOR" != "all" ]]; then
  echo "❌ Error: Invalid flavor '$FLAVOR'. Must be 'managers', 'clients', or 'all'"
  exit 1
fi

create_keystore() {
  local flavor=$1
  local keystore_name="${flavor}-release-key.jks"
  local keystore_path="$KEYSTORE_DIR/$keystore_name"
  local alias_name="${ALIAS:-$flavor}"
  local password="${PASSWORD:-}"
  
  # Check if keystore already exists
  if [[ -f "$keystore_path" ]]; then
    echo "⚠️  Warning: Keystore '$keystore_name' already exists at:"
    echo "   $keystore_path"
    read -p "   Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "   Skipping $flavor keystore creation."
      return
    fi
    echo "   Removing existing keystore..."
    rm -f "$keystore_path"
  fi
  
  echo "🔑 Creating release keystore for $flavor..."
  echo "   Keystore: $keystore_name"
  echo "   Alias: $alias_name"
  echo "   Validity: $VALIDITY years"
  
  # Prompt for password if not provided
  if [[ -z "$password" ]]; then
    read -sp "   Enter keystore password: " password
    echo
    read -sp "   Re-enter password: " password_confirm
    echo
    if [[ "$password" != "$password_confirm" ]]; then
      echo "❌ Error: Passwords do not match!"
      exit 1
    fi
  fi
  
  # Create keystore using keytool
  keytool -genkey -v \
    -keystore "$keystore_path" \
    -alias "$alias_name" \
    -keyalg RSA \
    -keysize 2048 \
    -validity $((VALIDITY * 365)) \
    -storepass "$password" \
    -keypass "$password" \
    -dname "CN=Legate My Car, OU=Mobile, O=Legate My Car, L=Khartoum, ST=Khartoum, C=SD" \
    || {
      echo "❌ Error: Failed to create keystore"
      exit 1
    }
  
  echo "✅ Keystore created successfully!"
  echo "   Location: $keystore_path"
  echo "   Alias: $alias_name"
  echo ""
  
  # Save password for later use (optional - user can update properties manually)
  echo "   📝 Remember to update key.release.properties with:"
  echo "      storeFile=app/$keystore_name"
  echo "      keyAlias=$alias_name"
  echo "      storePassword=<your-password>"
  echo "      keyPassword=<your-password>"
  echo ""
}

# Check if keytool is available
if ! command -v keytool &> /dev/null; then
  echo "❌ Error: keytool not found. Please install Java JDK."
  exit 1
fi

# Create keystore(s)
if [[ "$FLAVOR" == "all" ]]; then
  create_keystore "managers"
  # Reset password for next keystore
  PASSWORD=""
  create_keystore "clients"
else
  create_keystore "$FLAVOR"
fi

echo "🎉 Keystore creation completed!"


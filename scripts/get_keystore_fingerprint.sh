#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_DIR="$PROJECT_ROOT/android"
KEYSTORE_DIR="$ANDROID_DIR/app"

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Get SHA-1, SHA-256, and MD5 fingerprints from release keystores.

Options:
  -f, --flavor FLAVOR      Flavor to get fingerprint for: 'managers', 'clients', or 'all' (default: all)
  -h, --help               Show this help message

Examples:
  $(basename "$0")                    # Get fingerprints for both flavors
  $(basename "$0") -f managers        # Get fingerprint for managers only
  $(basename "$0") -f clients         # Get fingerprint for clients only
EOF
}

FLAVOR="all"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -f|--flavor)
      FLAVOR="$2"
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

get_fingerprint() {
  local flavor=$1
  local keystore_name="${flavor}-release-key.jks"
  local keystore_path="$KEYSTORE_DIR/$keystore_name"
  local alias_name="$flavor"
  local password=""
  
  # Set password based on flavor
  case "$flavor" in
    managers)
      password="LegateManagersStorePass!23"
      ;;
    clients)
      password="LegateClientsStorePass!23"
      ;;
    *)
      echo "❌ Error: Unknown flavor"
      exit 1
      ;;
  esac
  
  # Check if keystore exists
  if [[ ! -f "$keystore_path" ]]; then
    echo "⚠️  Warning: Keystore '$keystore_name' not found at:"
    echo "   $keystore_path"
    echo "   Skipping $flavor fingerprint."
    return
  fi
  
  echo "🔑 Release Keystore Fingerprints - $flavor"
  echo "   Keystore: $keystore_name"
  echo "   Alias: $alias_name"
  echo ""
  
  # Get all fingerprints using keytool
  keytool -list -v -keystore "$keystore_path" -alias "$alias_name" -storepass "$password" 2>/dev/null | \
    grep -E "(SHA256|SHA1|MD5)" | while IFS= read -r line; do
      echo "   $line"
    done
  
  echo ""
  
  # Extract SHA-256 for easy copy-paste
  local sha256=$(keytool -list -v -keystore "$keystore_path" -alias "$alias_name" -storepass "$password" 2>/dev/null | \
    grep "SHA256:" | sed 's/.*SHA256: //' | sed 's/ //g' | tr -d ':')
  
  if [[ -n "$sha256" ]]; then
    echo "   📋 SHA-256 (no colons): $sha256"
    echo ""
  fi
}

# Check if keytool is available
if ! command -v keytool &> /dev/null; then
  echo "❌ Error: keytool not found. Please install Java JDK."
  exit 1
fi

# Get fingerprint(s)
if [[ "$FLAVOR" == "all" ]]; then
  get_fingerprint "clients"
  get_fingerprint "managers"
else
  get_fingerprint "$FLAVOR"
fi

echo "💡 Tip: Use these fingerprints for Firebase, Google Sign-In, and other services."


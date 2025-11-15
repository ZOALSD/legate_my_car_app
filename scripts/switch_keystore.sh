#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_DIR="$PROJECT_ROOT/android"
KEY_FILE="$ANDROID_DIR/key.properties"
DEBUG_TEMPLATE="$ANDROID_DIR/key.debug.properties"
RELEASE_TEMPLATE="$ANDROID_DIR/key.release.properties"

usage() {
  cat <<EOF
Usage: $(basename "$0") [debug|release]

Copies the corresponding template keystore properties file into
android/key.properties. Run with 'release' before building a signed
app bundle and 'debug' afterwards to revert to the default state.
EOF
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

mode="$1"

case "$mode" in
  debug)
    cp "$DEBUG_TEMPLATE" "$KEY_FILE"
    echo "✔ Switched key.properties to debug configuration."
    ;;
  release)
    cp "$RELEASE_TEMPLATE" "$KEY_FILE"
    echo "✔ Switched key.properties to release configuration."
    ;;
  *)
    usage
    exit 1
    ;;
esac


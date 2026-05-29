#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-stable}"
FLUTTER_DIR="${FLUTTER_DIR:-/tmp/flutter}"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Installing Flutter (${FLUTTER_VERSION})..."
  git clone https://github.com/flutter/flutter.git -b "$FLUTTER_VERSION" --depth 1 "$FLUTTER_DIR"
  export PATH="${FLUTTER_DIR}/bin:${PATH}"
fi

export PATH="${FLUTTER_DIR}/bin:${PATH}"

flutter config --enable-web --no-analytics
flutter --version
flutter pub get

API_URL="${API_BASE_URL:-http://localhost:3000}"
echo "Building web release with API_BASE_URL=${API_URL}"

flutter build web --release --dart-define=API_BASE_URL="${API_URL}"

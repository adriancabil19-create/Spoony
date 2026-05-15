#!/bin/bash
set -e

FLUTTER_VERSION="3.41.9"
FLUTTER_DIR="$HOME/flutter"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

export PATH="$PATH:$FLUTTER_DIR/bin"

if [ ! -f "$FLUTTER_DIR/bin/flutter" ]; then
  echo "Downloading Flutter $FLUTTER_VERSION..."
  curl -fsSLo /tmp/flutter.tar.xz "$FLUTTER_URL"
  echo "Extracting Flutter..."
  tar xf /tmp/flutter.tar.xz -C "$HOME"
  rm /tmp/flutter.tar.xz
  flutter config --no-analytics
  echo "Flutter installed: $(flutter --version 2>&1 | head -1)"
fi

echo "Getting dependencies..."
flutter pub get

echo "Building Flutter web..."
flutter build web --release

echo "Build complete."

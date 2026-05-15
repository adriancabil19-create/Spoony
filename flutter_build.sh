#!/bin/bash
set -e

FLUTTER_DIR="$HOME/flutter"
export PATH="$PATH:$FLUTTER_DIR/bin"

if [ ! -d "$FLUTTER_DIR" ]; then
  echo "Cloning Flutter stable..."
  git clone --depth 1 -b stable https://github.com/flutter/flutter.git "$FLUTTER_DIR"
  flutter config --no-analytics
  echo "Flutter ready: $(flutter --version 2>&1 | head -1)"
fi

flutter pub get
flutter build web --release
echo "Build complete."

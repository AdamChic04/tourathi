#!/usr/bin/env bash
set -euo pipefail

# Vercel does not include Flutter. Install the same stable channel used
# by our GitHub Actions Flutter CI, then compile the Flutter web frontend.
FLUTTER_SDK_DIR="${FLUTTER_SDK_DIR:-$PWD/.vercel-flutter-sdk}"
if [ ! -x "$FLUTTER_SDK_DIR/bin/flutter" ]; then
  git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "$FLUTTER_SDK_DIR"
fi
export PATH="$FLUTTER_SDK_DIR/bin:$PATH"
export CI=true

flutter --version
flutter config --no-analytics
flutter pub get
flutter build web --release --base-href /

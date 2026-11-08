#!/usr/bin/env bash
set -e

FLUTTER_BIN="/home/sutris-remote/development/flutter/bin/flutter"
DART_BIN="/home/sutris-remote/development/flutter/bin/cache/dart-sdk/bin/dart"
DIST_DIR="dist"

mkdir -p "$DIST_DIR"

SCHOOL_KEY="$1"
if [ -z "$SCHOOL_KEY" ]; then
  echo "Usage: ./build_single_school.sh <school_key>"
  exit 1
fi

case "$SCHOOL_KEY" in
  "smpn1majenang")
    APP_NAME="Portal SMPN 1 Majenang"
    BASE_URL="https://smpn1majenang.sch.id/api/v1"
    SCHOOL_CODE="20528991"
    ;;
  "smpn3kedungreja")
    APP_NAME="Portal SMPN3 Kedungreja"
    BASE_URL="https://smpn3kedungreja.sch.id/api/v1"
    SCHOOL_CODE="20331747"
    ;;
  "smpn1sampang")
    APP_NAME="Portal SMPN 1 Sampang"
    BASE_URL="https://smp1sampang.sch.id/api/v1"
    SCHOOL_CODE="20528992"
    ;;
  *)
    echo "Unknown school: $SCHOOL_KEY"
    exit 1
    ;;
esac

LOGO_PATH="assets/schools/$SCHOOL_KEY/logo.png"

echo "----------------------------------------------------------------------"
echo "📦 Building APK for: $APP_NAME"
echo "🌐 Base URL         : $BASE_URL"
echo "🎨 Logo Source      : $LOGO_PATH"
echo "----------------------------------------------------------------------"

if [ -f "$LOGO_PATH" ]; then
  echo ">> Updating assets/images/logo_sekolah.png..."
  cp "$LOGO_PATH" "assets/images/logo_sekolah.png"

  echo ">> Generating launcher icons..."
  cat <<EOF > flutter_launcher_icons.yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "$LOGO_PATH"
  min_sdk_android: 21
EOF
  $DART_BIN run flutter_launcher_icons -f flutter_launcher_icons.yaml
fi

echo ">> Compiling Split APKs..."
$FLUTTER_BIN build apk --release --split-per-abi \
  -PAPP_NAME="$APP_NAME" \
  --dart-define=BASE_URL="$BASE_URL" \
  --dart-define=APP_NAME="$APP_NAME" \
  --dart-define=SCHOOL_CODE="$SCHOOL_CODE"

CLEAN_NAME=$(echo "$APP_NAME" | tr ' ' '-')
cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk "$DIST_DIR/${CLEAN_NAME}-arm64-v8a.apk"
cp build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk "$DIST_DIR/${CLEAN_NAME}-armeabi-v7a.apk"
cp build/app/outputs/flutter-apk/app-x86_64-release.apk "$DIST_DIR/${CLEAN_NAME}-x86_64.apk"

echo ">> Compiling Universal APK..."
$FLUTTER_BIN build apk --release \
  -PAPP_NAME="$APP_NAME" \
  --dart-define=BASE_URL="$BASE_URL" \
  --dart-define=APP_NAME="$APP_NAME" \
  --dart-define=SCHOOL_CODE="$SCHOOL_CODE"

cp build/app/outputs/flutter-apk/app-release.apk "$DIST_DIR/${CLEAN_NAME}-universal.apk"

echo "✅ All APKs built successfully for $APP_NAME!"

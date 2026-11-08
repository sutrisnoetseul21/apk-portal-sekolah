#!/usr/bin/env bash

# ==============================================================================
# Script Otomatisasi Build APK Multi-Sekolah (Opsi 1: 1 Codebase, Beda APK & Logo)
# ==============================================================================
# Menghasilkan APK dengan:
# 1. Logo Launcher Android sesuai sekolah masing-masing (assets/schools/[folder]/logo.png)
# 2. Nama Aplikasi di HP: "Portal [Nama Sekolah]"
# 3. Base URL terkunci ke domain VPS sekolah masing-masing
# ==============================================================================

set -e

FLUTTER_BIN="/home/sutris-remote/development/flutter/bin/flutter"
DIST_DIR="dist"

mkdir -p "$DIST_DIR"

echo "======================================================================"
echo "🚀 MEMULAI BUILD APK MULTI-SEKOLAH DENGAN LOGO & NAMA EKSKLUSIF"
echo "======================================================================"

build_school() {
  local SCHOOL_KEY="$1"
  local APP_NAME="$2"
  local BASE_URL="$3"
  local SCHOOL_CODE="$4"
  local LOGO_PATH="assets/schools/$SCHOOL_KEY/logo.png"

  echo ""
  echo "----------------------------------------------------------------------"
  echo "📦 Membangun APK untuk: $APP_NAME"
  echo "🌐 Server Domain     : $BASE_URL"
  echo "----------------------------------------------------------------------"

  # 1. Update In-App Asset Logo & Icon Launcher jika file logo.png tersedia
  if [ -f "$LOGO_PATH" ]; then
    echo "🎨 Menyalin logo internal aplikasi ke: assets/images/logo_sekolah.png"
    cp "$LOGO_PATH" "assets/images/logo_sekolah.png"

    echo "🎨 Menggenerasi Icon Launcher Aplikasi dari: $LOGO_PATH"
    cat <<EOF > flutter_launcher_icons.yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "$LOGO_PATH"
  min_sdk_android: 21
EOF
    $FLUTTER_BIN pub run flutter_launcher_icons -f flutter_launcher_icons.yaml > /dev/null 2>&1 || true
  else
    echo "⚠️  File $LOGO_PATH belum ada. Menggunakan logo default sebelumnya."
  fi

  # 2. Compile APK Release (Split ABI arm64-v8a & armeabi-v7a)
  echo "🔨 Mengompilasi Release APK..."
  $FLUTTER_BIN build apk --release --split-per-abi \
    -PAPP_NAME="$APP_NAME" \
    --dart-define=BASE_URL="$BASE_URL" \
    --dart-define=APP_NAME="$APP_NAME" \
    --dart-define=SCHOOL_CODE="$SCHOOL_CODE"

  # 3. Pindahkan file APK ke folder dist/ dengan nama yang rapi
  local CLEAN_NAME=$(echo "$APP_NAME" | tr ' ' '-')
  cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk "$DIST_DIR/${CLEAN_NAME}-arm64-v8a.apk"
  cp build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk "$DIST_DIR/${CLEAN_NAME}-armeabi-v7a.apk"

  echo "✅ Berhasil disimpan ke: $DIST_DIR/${CLEAN_NAME}-arm64-v8a.apk"
}

# ==============================================================================
# DAFTAR 4 SEKOLAHAN
# ==============================================================================

# 1. SMP Negeri 3 Kedungreja
build_school "smpn3kedungreja" "Portal SMPN3 Kedungreja" "https://smpn3kedungreja.sch.id/api/v1" "20331747"

# 2. SMP Negeri 1 Majenang
build_school "smpn1majenang" "Portal SMPN 1 Majenang" "https://smpn1majenang.sch.id/api/v1" "20528991"

# 3. SMP Negeri 1 Sampang
build_school "smpn1sampang" "PORTAL SMPN1 Sampang" "https://smp1sampang.sch.id/api/v1" "20528992"

# 4. SMP Negeri 1 Jeruklegi
build_school "smpn1jeruklegi" "Portal SMPN 1 Jeruklegi" "https://smpn1jeruklegi.sch.id/api/v1" "20528993"

# Bersihkan file config sementara
rm -f flutter_launcher_icons.yaml

echo ""
echo "======================================================================"
echo "🎉 SEMUA APK 4 SEKOLAH SELESAI DIBUAT DENGAN LOGO & NAMA MASING-MASING!"
echo "======================================================================"
ls -lh "$DIST_DIR"

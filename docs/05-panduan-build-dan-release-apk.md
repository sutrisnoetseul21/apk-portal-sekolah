# 📦 05. Panduan Build & Rilis File APK

Dokumen ini adalah panduan praktis bagi pengembang untuk mengompilasi kode sumber Flutter menjadi file instalasi Android siap pakai (**APK Release**).

---

## 🛠️ 1. Persiapan Sebelum Build

Pastikan Anda berada di direktori `apk-android-presensi`:
```bash
cd /home/sutris-remote/Documents/projek-laravel/apk-android-presensi
```

Verifikasi dependensi terpasang lengkap:
```bash
flutter pub get
```

---

## 🚀 2. Perintah Kompilasi APK (Rilis Produksi)

### Mengapa Menggunakan Flag `--split-per-abi`?
Secara *default*, file APK universal Flutter berukuran ~55 MB karena menggabungkan pustaka mesin untuk 4 arsitektur prosesor (arm64, armeabi, x86_64).

Dengan menambahkan opsi `--split-per-abi`, Flutter akan menghasilkan file APK terpisah yang sangat hemat ukuran (**hanya ~18 s/d 22 MB**):

```bash
flutter build apk --release --split-per-abi
```

### File Output yang Dihasilkan:
Kompilasi di atas akan menghasilkan berkas di:
```text
build/app/outputs/flutter-apk/
├── app-arm64-v8a-release.apk    <-- INI YANG DIBAGIKAN (Untuk 95% HP Android modern)
├── app-armeabi-v7a-release.apk  <-- Untuk HP Android lawas (32-bit)
└── app-x86_64-release.apk       <-- Untuk emulator Android PC
```

---

## 🏫 3. Kompilasi Khusus / Eksklusif per Sekolah

Untuk menghasilkan file APK bagi sekolah tertentu, tambahkan parameter `--dart-define` sesuai identitas sekolah:

### Contoh 1: SMPN 1 Sampang
```bash
flutter build apk --release --split-per-abi \
  --dart-define=BASE_URL="https://smpn1sampang.sch.id/api/v1" \
  --dart-define=APP_NAME="Portal SMPN 1 Sampang"

# Rename hasil APK agar mudah dibagikan:
cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk ~/Desktop/Portal_SMPN1_Sampang.apk
```

### Contoh 2: SMPN 2 Bangkalan
```bash
flutter build apk --release --split-per-abi \
  --dart-define=BASE_URL="https://smpn2bangkalan.sch.id/api/v1" \
  --dart-define=APP_NAME="Portal SMPN 2 Bangkalan"

# Rename hasil APK:
cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk ~/Desktop/Portal_SMPN2_Bangkalan.apk
```

---

## 💻 4. Menjalankan Langsung via Android Studio (Debugging)

Jika Anda ingin menjalankan aplikasi di HP fisik atau Emulator melalui GUI Android Studio:

1. Buka **Android Studio** ➜ Pilih proyek `apk-android-presensi`.
2. Di toolbar atas, pastikan target perangkat telah terpilih (misal: *Pixel 7 Pro Emulator* atau *Samsung SM-xxx*).
3. Klik tombol **Run (Segitiga Hijau)** atau tekan `Shift + F10`.
4. Saat aplikasi berjalan:
   - Tekan tombol **Hot Reload (Petir Kuning)** untuk menerapkan perubahan kode seketika.
   - Buka tab **Logcat** atau **Run Console** di bagian bawah Android Studio untuk memantau request API secara *real-time*.


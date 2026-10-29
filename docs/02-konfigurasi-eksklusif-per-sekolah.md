# 🏫 02. Konfigurasi Eksklusif per Sekolah (Beda Sekolah Beda APK)

Dokumen ini menjelaskan strategi teknis **Aplikasi Eksklusif per Sekolah**, di mana alamat server (*Base URL*), nama aplikasi, dan identitas visual **langsung di-injek saat build APK**, sehingga setiap sekolah memiliki file APK mandiri tanpa perlu siswa/guru mengetik server secara manual.

---

## 🎯 1. Konsep "Injeksi Langsung"

Ketika siswa atau guru menginstal aplikasi di HP mereka:
1. **Tidak Ada Input Alamat Server**: Pengguna membuka aplikasi dan langsung melihat logo resmi sekolah mereka dan formulir login NISN/NIP.
2. **Koneksi Terkunci Permanen**: Aplikasi hanya berkomunikasi dengan server backend milik sekolah tersebut, menjamin keamanan data dan mencegah salah server.
3. **Identitas Terisolasi**: Nama aplikasi di layar utama HP mencerminkan nama sekolah, misalnya **"Portal SMPN 1 Sampang"**.

---

## ⚙️ 2. Mekanisme Injeksi Kode (`lib/core/config/app_config.dart`)

Alamat server dan profil sekolah di-injek menggunakan fitur bawaan Dart: `String.fromEnvironment()`.

```dart
class AppConfig {
  /// Alamat Base URL Server API yang diinjek saat build
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://coba.haflaitsolution.my.id/api/v1',
  );

  /// Nama Aplikasi yang tampil di layar
  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'Portal SMPN 1 Sampang',
  );

  /// Kode Unik / NPSN Sekolah
  static const String schoolCode = String.fromEnvironment(
    'SCHOOL_CODE',
    defaultValue: 'SMPN1_SAMPANG',
  );

  /// Nilai warna primer HEX (misal: 0xFF1E40AF untuk biru sekolah)
  static const int primaryColorHex = int.fromEnvironment(
    'PRIMARY_COLOR',
    defaultValue: 0xFF1E40AF,
  );
}
```

---

## 🏗️ 3. Daftar Preset Sekolah & Perintah Build APK

Untuk mengompilasi APK bagi sekolah tertentu, cukup jalankan perintah build dengan parameter injeksi:

### A. SMP Negeri 1 Sampang (Produksi)
```bash
flutter build apk --release --split-per-abi \
  --dart-define=BASE_URL="https://smpn1sampang.sch.id/api/v1" \
  --dart-define=APP_NAME="Portal SMPN 1 Sampang" \
  --dart-define=SCHOOL_CODE="20528990" \
  --dart-define=PRIMARY_COLOR=0xFF1E40AF
```
*Hasil Output:* `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`
*(Bisa langsung Anda rename menjadi `Portal-SMPN1-Sampang-v1.0.apk`)*

---

### B. Server Staging / Demo (Hafla IT Solution)
```bash
flutter build apk --release --split-per-abi \
  --dart-define=BASE_URL="https://coba.haflaitsolution.my.id/api/v1" \
  --dart-define=APP_NAME="Portal Smart School (Demo)" \
  --dart-define=SCHOOL_CODE="DEMO" \
  --dart-define=PRIMARY_COLOR=0xFF0D9488
```

---

### C. Server Pengujian Lokal (Localhost / WiFi Kantor)
```bash
flutter build apk --debug \
  --dart-define=BASE_URL="http://192.168.1.50:8001/api/v1" \
  --dart-define=APP_NAME="Portal Dev Local"
```

---

## 📜 4. Otomasi Script Build (`scripts/build_school.sh`)

Untuk mempermudah pembuatan APK massal tanpa mengetik perintah panjang, dibuatkan skrip bantuan:

```bash
# Contoh eksekusi:
bash scripts/build_school.sh smpn1sampang
bash scripts/build_school.sh smpn2bangkalan
```

Skrip ini otomatis membaca profil konfigurasi sekolah dari file konfigurasi dan menghasilkan file APK di folder `dist/` dengan penamaan rapi:
`dist/Portal_SMPN1_Sampang_v1.0.0.apk`.


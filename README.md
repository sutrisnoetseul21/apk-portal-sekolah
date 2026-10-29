# 📱 Portal Smart School Mobile App (Flutter)

Aplikasi mobile resmi untuk ekosistem **Smart School & Presensi Barcode**, dirancang untuk memfasilitasi kebutuhan harian **Siswa/Orang Tua** (Kartu Pelajar Digital, Presensi, Izin Online) dan **Guru/Wali Kelas** (Presensi Harian, Sholat Dhuhur Berjamaah, Approval Izin).

---

## 🏛️ Identitas & Konfigurasi Paket

- **Package Name**: `id.haflaitsolution.apk_portal_smpn1_sampang`
- **Application Label**: `Portal SMPN 1 Sampang` (dapat disesuaikan secara dinamis)
- **Framework**: Flutter 3.47+ (Dart 3)
- **Backend ERP**: Laravel 12 API + Sanctum Bearer Token

---

## 🚀 Tech Stack & Library Kunci

| Komponen | Pustaka / Paket | Kegunaan |
| :--- | :--- | :--- |
| **State Management** | `flutter_riverpod` | State reaktif, bebas memory-leak, dan terstruktur modular |
| **HTTP Client** | `dio` | Networking, interceptor Bearer Token Sanctum otomatis, penanganan timeout |
| **Secure Token Storage** | `flutter_secure_storage` | Penyimpanan token sesi login terenkripsi di Android Keystore |
| **Barcode Generator** | `barcode_widget` | Merender barcode Code 128 kartu pelajar tajam di layar HP |
| **Typography & Theme** | `google_fonts` (Plus Jakarta Sans) | Desain Material 3 modern selaras dengan Portal Web Filament |
| **Device Media** | `image_picker` | Unggah foto surat izin/sakit langsung dari kamera atau galeri |
| **Komunikasi Cepat** | `url_launcher` | Tombol kontak cepat langsung membuka chat WhatsApp orang tua |

---

## 🏫 Arsitektur Multi-Sekolah & Multi-Server

Backend Laravel diaplikasikan pada berbagai sekolah dengan domain/server masing-masing. Aplikasi ini mendukung **3 cara penanganan server**:

1. **Default Preset**: Mengarah ke server sekolah utama (misal `https://smpn1sampang.sch.id` atau staging `https://coba.haflaitsolution.my.id`).
2. **Dynamic Server Switcher**: Pengguna/Guru dapat mengubah alamat server sekolah langsung dari layar login aplikasi tanpa perlu instal ulang.
3. **Compile-Time White-Labeling**: Dapat di-build khusus untuk sekolah tertentu menggunakan perintah:
   ```bash
   flutter build apk --release \
     --dart-define=APP_NAME="Portal SMPN 1 Sampang" \
     --dart-define=BASE_URL="https://smpn1sampang.sch.id/api/v1"
   ```

---

## 📂 Struktur Direktori Kode (`lib/`)

```text
lib/
├── main.dart                      # Titik masuk utama aplikasi (Inisialisasi Riverpod & Theme)
├── core/
│   ├── config/
│   │   ├── app_config.dart        # Konfigurasi Base URL, nama app, timeout
│   │   └── theme.dart             # Palet warna Material 3 & tipografi
│   ├── constants/
│   │   └── api_endpoints.dart     # Daftar URI endpoint backend Laravel
│   ├── network/
│   │   ├── api_client.dart        # Instansiasi Dio + Sanctum Interceptor
│   │   └── api_response.dart      # Standard JSON envelope model
│   └── storage/
│       └── secure_storage.dart    # Wrapper token & preferensi lokal
│
├── features/
│   ├── auth/                      # Modul Otentikasi
│   │   ├── models/                # UserModel, LoginRequest, AuthState
│   │   ├── providers/             # Riverpod AuthNotifier & Controller
│   │   └── screens/               # LoginScreen, ServerSettingsDialog, SplashScreen
│   │
│   ├── siswa/                     # Modul Khusus Siswa / Orang Tua
│   │   ├── models/                # StudentProfile, AttendanceHistory, LeaveRequest
│   │   ├── providers/             # SiswaProviders
│   │   └── screens/               # DigitalCardScreen (Barcode), DashboardSiswaScreen, PengajuanIzinScreen
│   │
│   └── guru/                      # Modul Khusus Guru / Wali Kelas
│       ├── models/                # Classroom, AttendanceToday, SholatDhuhur
│       ├── providers/             # GuruProviders
│       └── screens/               # DashboardGuruScreen, PresensiKelasScreen, PresensiSholatScreen, ApprovalIzinScreen
│
└── shared/
    └── widgets/                   # Komponen UI global (Buttons, Cards, ErrorState, LoadingState)
```

---

## 💻 Panduan Menjalankan di Android Studio

1. Buka aplikasi **Android Studio**.
2. Pilih **Open** ➜ arahkan ke folder ini (`/home/sutris-remote/Documents/projek-laravel/apk-android-presensi`).
3. Tunggu proses Gradle indexing dan sync selesai.
4. Pilih target perangkat di bilah atas:
   - **Android Emulator** (misal Pixel 7 Pro), atau
   - **HP Android Fisik** (hubungkan kabel USB dan aktifkan *USB Debugging* di HP).
5. Klik tombol **Run (Segitiga Hijau)** atau tekan `Shift + F10`.
6. Untuk melihat perubahan tampilan langsung saat coding, gunakan tombol **Hot Reload (Petir Kuning)**.

---

## 📦 Panduan Build File APK

Untuk menghasilkan file APK siap pakai yang hemat ukuran untuk dibagikan ke siswa/guru:

```bash
# Build APK yang dipisah per arsitektur CPU (ukuran hemat ~18MB)
flutter build apk --release --split-per-abi

# Hasil file APK berada di:
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

---

## 🔗 Rujukan Dokumentasi Terkait
- Perencanaan Detail Arsitektur Mobile: [projek-absensi-barcode/docs/07-aplikasi-mobile/](file:///home/sutris-remote/Documents/projek-laravel/projek-absensi-barcode/docs/07-aplikasi-mobile)
- Desain Endpoint REST API Sanctum: [projek-absensi-barcode/docs/07-aplikasi-mobile/03-desain-rest-api-laravel-sanctum.md](file:///home/sutris-remote/Documents/projek-laravel/projek-absensi-barcode/docs/07-aplikasi-mobile/03-desain-rest-api-laravel-sanctum.md)
- Struktur Basis Data & Token: [projek-absensi-barcode/docs/02-database/09-autentikasi-api-dan-tokens.md](file:///home/sutris-remote/Documents/projek-laravel/projek-absensi-barcode/docs/02-database/09-autentikasi-api-dan-tokens.md)

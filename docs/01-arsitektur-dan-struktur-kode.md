# 🏗️ 01. Arsitektur & Struktur Kode Aplikasi

Dokumen ini menjelaskan fondasi teknis, pola arsitektur, dan struktur direktori kode Dart pada aplikasi mobile Flutter.

---

## 1. Pola Arsitektur (Feature-First MVVM)

Aplikasi dibangun menggunakan pola **Feature-First** yang dikombinasikan dengan pemisahan lapisan tanggung jawab (Separation of Concerns):

```text
┌────────────────────────────────────────────────────────┐
│                   Presentation Layer                   │
│   (Screens, Custom Widgets, Modals, Form Inputs)       │
└───────────────────────────┬────────────────────────────┘
                            │ Membaca State & Memicu Aksi
                            ▼
┌────────────────────────────────────────────────────────┐
│                   Logic / State Layer                  │
│       (Riverpod Notifiers, StateProviders, AsyncValue) │
└───────────────────────────┬────────────────────────────┘
                            │ Memanggil Service
                            ▼
┌────────────────────────────────────────────────────────┐
│                   Data & Network Layer                 │
│   - Dio HTTP Client (Sanctum Interceptor)              │
│   - Flutter Secure Storage (Simpan Token Enkripsi)     │
│   - Repositories & Data Models (fromJson / toJson)     │
└────────────────────────────────────────────────────────┘
```

---

## 2. Peta Direktori Kode (`lib/`)

```text
lib/
├── main.dart                      # Titik awal aplikasi (ProviderScope & Theme Setup)
│
├── core/                          # Modul inti lintas fitur
│   ├── config/
│   │   ├── app_config.dart        # Injeksi BASE_URL, nama aplikasi, & identitas sekolah
│   │   └── app_theme.dart         # Konfigurasi ThemeData (Material 3 + Plus Jakarta Sans)
│   ├── constants/
│   │   ├── api_endpoints.dart     # Konstanta path URL (/api/v1/...)
│   │   └── app_colors.dart        # Palet warna primer, sukses, peringatan, alpa
│   ├── network/
│   │   ├── api_client.dart        # Instansiasi Dio + interceptor otomatis token Sanctum
│   │   └── api_response.dart      # Standard JSON envelope model
│   └── storage/
│       └── secure_storage.dart    # Wrapper flutter_secure_storage (token & profil)
│
├── features/                      # Fitur modular aplikasi
│   ├── auth/                      # Modul Otentikasi
│   │   ├── models/                # UserModel, LoginRequest, AuthState
│   │   ├── providers/             # AuthNotifier (login, logout, checkAuth)
│   │   └── screens/               # SplashScreen, LoginScreen
│   │
│   ├── siswa/                     # Modul Siswa / Orang Tua
│   │   ├── models/                # StudentModel, AttendanceSummary, LeaveModel
│   │   ├── providers/             # SiswaDashboardNotifier, IzinNotifier
│   │   └── screens/               # DashboardSiswaScreen, DigitalCardScreen, IzinScreen
│   │
│   └── guru/                      # Modul Guru / Wali Kelas
│       ├── models/                # ClassModel, StudentAttendanceItem, SholatItem
│       ├── providers/             # PresensiKelasNotifier, SholatNotifier
│       └── screens/               # DashboardGuruScreen, PresensiKelasScreen, SholatScreen, ApprovalIzinScreen
│
└── shared/                        # Komponen UI bersama
    └── widgets/                   # LoadingIndicator, PrimaryButton, StatusBadge, CustomCard
```

---

## 3. Komponen Utama

### A. HTTP Networking (Dio + Sanctum Interceptor)
Semua komunikasi HTTP dikelola oleh class terpusat `ApiClient`. Interceptor otomatis menambahkan header:
```http
Authorization: Bearer <token_dari_secure_storage>
Accept: application/json
```
Jika backend mengembalikan HTTP 401 (token kedaluwarsa atau dicabut), interceptor otomatis mengosongkan secure storage dan me-*redirect* user kembali ke layar login.

### B. State Management (Flutter Riverpod 2.x)
- Digunakan untuk reaktivitas UI yang konsisten dan mudah dites.
- Menggunakan `AsyncValue` untuk menangani status `data`, `loading`, dan `error` secara elegan tanpa boilerplate.

### C. Barcode Renderer (`barcode_widget`)
- Merender barcode fisik tipe **Code 128** langsung dari nilai string NISN siswa.
- Menggunakan vector rendering sehingga tidak pecah pada resolusi layar HP apa pun dan sangat mudah dipindai oleh barcode scanner sekolah.


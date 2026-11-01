# 📱 Rencana Kerja Bertahap (Action Plan) Push Notification FCM + Database (Flutter Android)

> **Dokumen Master Sumber Utama Lengkap**:  
> Seluruh analisis backend Laravel, alur presensi, penanganan WhatsApp yang tetap utuh, dan arsitektur queue worker PM2 terdapat pada file master:  
> [`projek-absensi-barcode/docs/plans/fcm-notifikasi.md`](file:///home/sutris-remote/Documents/projek-laravel/projek-absensi-barcode/docs/plans/fcm-notifikasi.md)

---

## 📌 Ringkasan Prinsip & Alur Bisnis Sisi Mobile
1. **Tidak Mengganggu WhatsApp**: Pengiriman WhatsApp gateway (baik ke ortu, siswa, maupun grup rekap) tetap berjalan utuh dan normal. Push notification dan penyimpanan database berjalan secara berdampingan (*parallel companion*).
2. **Push Notifikasi Disimpan di Database (`notifications`)**: Setiap notifikasi yang dikirimkan ke pengguna juga tersimpan di tabel database agar tersimpan aman dan dapat dibuka kembali melalui layar **Pusat Notifikasi (Inbox)**.
3. **Alur Notifikasi Utama**:
   - **Terlambat di Gerbang**: Siswa menerima push notifikasi *"Status Presensi: Terlambat"* saat scan barcode di `/portal-presensi/scan`.
   - **Siswa Ajukan Izin/Sakit**: Guru Wali Kelas menerima push notifikasi *"Pengajuan Izin Siswa Baru"* untuk segera ditinjau.
   - **Guru Setujui / Tolak Izin**: Siswa menerima push notifikasi *"Izin Disetujui / Ditolak"*.
   - **Input Manual Guru**: Siswa menerima push notifikasi saat guru menetapkan presensi manual.
   - **Alpa Otomatis Scheduler**: Siswa menerima push notifikasi saat jam batas kehadiran telah terlewati dan ditandai alpa.

---

## 📋 Kontrak API Bersama (Shared API Contract)

### A. Endpoint Manajemen Token FCM & Inbox Notifikasi
1. **Registrasi Token**:
   - `POST /api/v1/auth/fcm-token` [Headers: `Authorization: Bearer <SanctumToken>`]
   - Body:
     ```json
     {
       "token": "eXample_FCM_Token_String...",
       "device_type": "android",
       "app_version": "1.0.8"
     }
     ```
2. **Pencabutan Token Saat Logout**:
   - `DELETE /api/v1/auth/fcm-token` [Headers: `Authorization: Bearer <SanctumToken>`]
   - Body:
     ```json
     {
       "token": "eXample_FCM_Token_String..."
     }
     ```
   - **Urutan Logout**: Panggil `DELETE /api/v1/auth/fcm-token` terlebih dahulu selagi Sanctum token aktif &rarr; panggil `POST /api/v1/auth/logout` &rarr; bersihkan cache lokal.
3. **Inbox Notifikasi In-App**:
   - `GET /api/v1/notifications`: Mengambil daftar riwayat notifikasi user login (paginasi).
   - `POST /api/v1/notifications/{id}/read`: Menandai notifikasi telah dibaca.
   - `POST /api/v1/notifications/read-all`: Menandai seluruh notifikasi telah dibaca.

---

### B. Format Payload FCM Push (HTTP v1)
Semua nilai di dalam atribut `data` bertipe **STRING**:
```json
{
  "message": {
    "token": "eXample_FCM_Token_String...",
    "notification": {
      "title": "Pemberitahuan Presensi",
      "body": "Status kehadiran Anda hari ini tercatat: Terlambat (15 menit)"
    },
    "android": {
      "priority": "HIGH",
      "notification": {
        "channel_id": "high_importance_channel",
        "sound": "default",
        "default_vibrate_timings": true
      }
    },
    "data": {
      "type": "attendance_status",
      "id": "2026-11-01:e5b8d2b0-8e12-4c28-bf34-7a1b4d2e9f01"
    }
  }
}
```

### C. Pemetaan Nilai `type`, Format `id`, & Navigasi Mobile

| Penerima | Nilai `type` | Format Pasti `id` (String) | Pemicu Kejadian | Layar Tujuan di Flutter |
| :--- | :--- | :--- | :--- | :--- |
| **Siswa** | `attendance_status` | String gabungan `YYYY-MM-DD:<student_id>` | Status Alpa/Ijin/Sakit/Telat resmi ditetapkan | `PresensiSiswaScreen` |
| **Guru (Wali Kelas)** | `leave_approval` | UUID String (`leave_requests.id`) | Siswa mengajukan izin/sakit baru status pending | `IjinKehadiranDetailScreen` |
| **Siswa** | `leave_result` | UUID String (`leave_requests.id`) | Surat izin resmi disetujui / ditolak wali kelas | `IjinKehadiranSiswaScreen` |
| **Guru Wali / Siswa** | `consultation` | UUID String (`konsultasi_guru_wali.id`) | Pengajuan bimbingan baru atau status diubah | `DetailKonsultasiScreen` |
| **Guru (BK, WK, KS)** | `spikap` | UUID String (`spikap_laporans.id`) | Laporan SPIKAP baru *(Layar kunci selalu generik)* | `SpikapDetailScreen` |
| **Siswa** | `spikap` | UUID String (`spikap_laporans.id`) | Konfirmasi terkirim / tindak lanjut laporan | `SpikapDetailSiswaScreen` |

---

## 🛠️ Roadmap Kerja Tahap Flutter (Tahap 4) - ✅ COMPLETED

1. [x] **Setup Native Android & Kredensial**:
   - Pasang file `google-services.json` ke folder `android/app/`.
   - Setup Gradle plugin `id("com.google.gms.google-services")` di `settings.gradle.kts` & `app/build.gradle.kts`.
   - Tambahkan izin `POST_NOTIFICATIONS`, `VIBRATE`, `RECEIVE_BOOT_COMPLETED` pada `AndroidManifest.xml`.
   - Daftarkan metadata default notification channel `high_importance_channel`.
2. [x] **Service Notifikasi & Background Messaging**:
   - Dependensi `firebase_core`, `firebase_messaging`, `flutter_local_notifications` terpasang di `pubspec.yaml`.
   - Buat `lib/core/services/fcm_service.dart` (registrasi channel, permission request Android 13+, local notification foreground heads-up banner).
   - Daftarkan `@pragma('vm:entry-point')` background handler dan inisialisasi di `main.dart`.
3. [x] **Manajemen Token & Auth Lifecycle**:
   - Pendaftaran token otomatis ke `POST /api/v1/auth/fcm-token` saat login dan token refresh.
   - Pencabutan token aman `DELETE /api/v1/auth/fcm-token` saat logout sebelum sesi lokal dibersihkan.
4. [x] **Deep Linking & Cold Start Navigation**:
   - Buat `lib/core/utils/notification_router.dart` dengan `NotificationRouter.navigatorKey`.
   - Menangani routing tap notifikasi sesuai kontrak `type` dan `id` ke layar terkait (`PresensiSiswaScreen`, `IjinKehadiranScreen`, `IjinKehadiranSiswaScreen`, `SpikapScreen`, `GuruWaliScreen`).
   - Penanganan cold start melalui `FcmService.checkInitialMessage()`.
5. [x] **Layar Inbox Notifikasi (Pusat Notifikasi)**:
   - Buat model `NotificationItemModel` dan service `NotificationService`.
   - Buat `NotificationInboxScreen` dengan filter status, indikator belum dibaca, pull-to-refresh, dan tombol tandai semua dibaca.
   - Tambahkan icon lonceng notifikasi di AppBar `DashboardGuruScreen` dan `DashboardSiswaScreen`.
6. [x] **Pengujian & Validasi**:
   - `flutter analyze`: **No issues found (0 errors, 0 warnings)**.
   - `flutter test`: **16 passed (100% HIJAU)**.

---

## 🚦 Status Integrasi Proyek
- **Tahap 1 (Fondasi Backend, DB, Security Sanctum Token)**: ✅ **SELESAI & ACCEPTED**
- **Tahap 2 (Worker PM2, FcmChannel, Inbox API)**: ✅ **SELESAI & ACCEPTED**
- **Tahap 3 (Pemicu Presensi Gerbang, Izin Siswa, Auto-Alpa Guard)**: ✅ **SELESAI (18 tests passed)**
- **Tahap 4 (Implementasi Flutter Android FCM, Router, & Inbox UI)**: ✅ **SELESAI (16 tests passed)**
- **Tahap 5 (End-to-End Testing & Build APK Siap Pasang)**: ✅ **SELESAI & VERIFIED LIVE**
  - **Firebase Credentials Asli**: `google-services.json` dan `firebase-service-account.json` project `notif-android-testing` terhubung.
  - **Verifikasi Pengiriman HP**: Push notifikasi live berhasil dikirim dan diterima oleh HP siswa Nada Arava (NISN `3126336940`).
  - **Autentikasi Dual-Token**: Middleware `AuthenticateMobileToken` mendukung Sanctum token dan token fallback lama tanpa memaksa re-login.
  - **Pembatasan Karakter Alasan Izin**: Validasi alasan ijin/sakit dibatasi maksimal 200 karakter secara konsisten di Form Flutter (`maxLength: 200`), API Backend (`max:200`), dan Form Web Livewire.
  - **Build APK Release Split-ABI**: `app-arm64-v8a-release.apk` (22.7 MB) dan `app-armeabi-v7a-release.apk` (20.6 MB) siap pakai di root direktori.

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


---

## 🚀 Tahap 6: Standardisasi Direct FCM HTTP v1, WhatsApp Multi-Kanal (SPIKAP & SI-WALI), dan Manajemen Terpusat Notifikasi WA Admin

> **Status Tahap 6: SELESAI & FULLY TESTED**  
> Diterapkan per 01 November 2026. Mencakup pembaruan backend Laravel (`projek-absensi-barcode`), modul Filament Admin, dan routing aplikasi mobile Flutter (`apk-android-presensi`).

### 6.1 Perbaikan Input Presensi Kelas Manual (Durasi Keterlambatan Menitan)
- **Masalah Sebelumnya**: Pada modal input presensi kelas manual portal guru (`modal-input.blade.php`) dan aplikasi mobile (`presensi_kelas_screen.dart`), input menit keterlambatan sempat mengalami kendala bouncing/reset saat status diubah ke terlambat.
- **Solusi & Perbaikan**:
  - `modal-input.blade.php`: Memperbaiki `wire:model.defer="terlambat_menit"`, tipe input numerik bertahap, dan penanganan default nilai `0` saat status bukan terlambat.
  - `PresensiKelasController.php` & `presensi_kelas_screen.dart`: Standarisasi parsing data durasi keterlambatan ke tipe integer murni sebelum dikirim ke database.

### 6.2 Standardisasi Direct FCM HTTP v1 (`FcmPushService`) & Deep-Linking
- **Arsitektur Baru**:
  - Menggantikan legacy FCM library dengan pemanggilan langsung API resmi Google **Firebase Cloud Messaging HTTP v1** (`https://fcm.googleapis.com/v1/projects/{projectId}/messages:send`).
  - Autentikasi aman menggunakan token OAuth2 Bearer yang digenerate dari `firebase-service-account.json`.
- **Jobs Terstandardisasi**:
  - [`SendLeaveRequestFcmNotificationJob.php`](file:///home/sutris-remote/Documents/projek-laravel/projek-absensi-barcode/app/Jobs/SendLeaveRequestFcmNotificationJob.php): Notifikasi pengajuan izin siswa ke wali kelas & notifikasi hasil persetujuan ke siswa.
  - [`SendSpikapFcmNotificationJob.php`](file:///home/sutris-remote/Documents/projek-laravel/projek-absensi-barcode/app/Jobs/SendSpikapFcmNotificationJob.php): Notifikasi aduan darurat/biasa ke wali kelas, guru BK, dan kepala sekolah, serta notifikasi perubahan status/tindak lanjut ke siswa.
  - [`SendKonsultasiGuruWaliFcmNotificationJob.php`](file:///home/sutris-remote/Documents/projek-laravel/projek-absensi-barcode/app/Jobs/SendKonsultasiGuruWaliFcmNotificationJob.php): Notifikasi curhat siswa ke guru wali, balasan guru ke siswa, dan penetapan jadwal temu tatap muka.
- **Deep Linking Status Bar di Flutter (`notification_router.dart`)**:
  - Payload notifikasi menyertakan `click_action: FLUTTER_NOTIFICATION_CLICK`, `type`, `id`, dan `action_url`.
  - Ketika notifikasi di-tap dari sistem Android, aplikasi langsung melompat (*auto-route*) ke:
    - `type: leave_request` -> `PersetujuanIjinScreen` (Wali Kelas) atau `PengajuanIjinScreen` (Siswa).
    - `type: spikap` -> `SpikapDetailScreen` (Guru/BK/Kepsek) atau `SpikapDetailSiswaScreen` (Siswa).
    - `type: guru_wali_konsultasi` -> `GuruWaliScreen` tab konsultasi (Guru Wali) atau `SiWaliSiswaScreen` (Siswa).

### 6.3 Aktivasi Notifikasi WhatsApp Fisik SPIKAP
- **Konfigurasi Environment**:
  - `.env`: `SPIKAP_WA_TEST_MODE=false`.
- **Eksekusi Pengiriman**:
  - [`SpikapNotificationService.php`](file:///home/sutris-remote/Documents/projek-laravel/projek-absensi-barcode/app/Services/SpikapNotificationService.php) terhubung langsung dengan gateway WhatsApp fisik sekolah.
  - Mendukung pengiriman pesan real-time untuk:
    1. Aduan Darurat (ke Wali Kelas, Guru BK, dan Kepala Sekolah).
    2. Aduan Biasa (ke Wali Kelas dan Guru BK).
    3. Apresiasi Pengirim (ke nomor WhatsApp siswa dan nomor WhatsApp orang tua/wali).
    4. Pembaruan Status Penanganan Aduan (ke siswa dan orang tua).

### 6.4 Integrasi WhatsApp Gateway untuk SI-WALI (Guru Wali Siswa Bercerita)
- **Service Baru**:
  - [`GuruWaliNotificationService.php`](file:///home/sutris-remote/Documents/projek-laravel/projek-absensi-barcode/app/Services/GuruWaliNotificationService.php) mengelola notifikasi WhatsApp untuk fitur konsultasi guru-wali.
- **Pemicu Pengiriman**:
  - `SiswaGuruWaliController@store`: Mengirim pesan WA ke Guru Wali saat siswa mengajukan cerita/bimbingan baru.
  - `GuruWaliKonsultasiController@kirimPesan` & `@balas`: Mengirim pesan WA ke nomor siswa (dan opsi salinan ke orang tua) saat guru memberikan tanggapan.
  - `GuruWaliKonsultasiController@jadwalkan`: Mengirim pesan WA berisi tanggal, jam, dan lokasi tatap muka ke siswa.

### 6.5 Panel Manajemen Notifikasi WhatsApp Terpusat di Filament Admin
- **Halaman Admin**: `http://localhost:8001/admin/manajemen-notifikasi-wa` (`ManajemenNotifikasiWaPage.php`).
- **Trait Tambahan**: [`HasSpikapDanGuruWaliWaNotifications.php`](file:///home/sutris-remote/Documents/projek-laravel/projek-absensi-barcode/app/Filament/Traits/HasSpikapDanGuruWaliWaNotifications.php).
- **Fitur Antarmuka**:
  - **Tab Notifikasi SPIKAP**: Toggle aktif/nonaktif dan textarea kustomisasi template pesan (Darurat, Biasa, Apresiasi Siswa & Ortu, Update Status Siswa & Ortu) dilengkapi daftar placeholder dinamis (`{nama_siswa}`, `{nisn}`, `{kelas}`, `{kode_tiket}`, `{kategori}`, `{deskripsi}`, dll).
  - **Tab Notifikasi Guru Wali (SI-WALI)**: Toggle aktif/nonaktif dan textarea kustomisasi template pesan (Pengajuan Cerita Siswa, Balasan Guru, Salinan ke Orang Tua, Jadwal Temu Bimbingan) dilengkapi daftar placeholder dinamis (`{nama_siswa}`, `{nama_guru}`, `{kategori}`, `{pesan}`, `{tanggal_temu}`, dll).
- **Penyimpanan**:
  - Data tersimpan persisten di tabel `presensi_notification_settings`.
  - Tersinkronisasi otomatis dengan model singleton `SpikapNotifSetting` untuk kompatibilitas service eksisting.

### 6.6 Otomasi Antrean (Queue Worker) & Kesiapan Reboot Server/PC
- **Antrean**: Worker membaca antrean `default` dan `notifications`:
  ```bash
  php artisan queue:work --queue=default,notifications --tries=3
  ```
- **Cron Scheduler**: Berjalan setiap menit (`* * * * * cd /home/sutris-remote/Documents/projek-laravel/projek-absensi-barcode && php artisan schedule:run >> /dev/null 2>&1`).
- **Heartbeat Monitoring**: Perintah `php artisan scheduler:heartbeat` dijalankan otomatis oleh scheduler setiap 5 menit untuk mencatat stempel waktu aktif di database.

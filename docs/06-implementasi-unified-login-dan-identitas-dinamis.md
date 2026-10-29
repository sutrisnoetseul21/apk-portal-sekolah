# 🔐 06. Implementasi Splash Screen, Unified Login Minimalis & Identitas Sekolah Dinamis

Dokumen ini mencatat detail teknis dan alur implementasi **Splash Screen**, **Layar Login Terpadu Minimalis (*Unified Login*)**, optimasi pemuatan logo sekolah untuk Web/Android, serta pemisahan navigasi otomatis ke **Portal Siswa** dan **Portal Guru**.

---

## 🏛️ 1. Identitas Sekolah Dinamis dari Database (`SchoolInfoController`)

Aplikasi mobile memuat nama dan logo sekolah secara dinamis dari basis data backend Laravel setiap kali dibuka, sembari menyimpan aset lokal terkompresi sebagai *fallback* instan:

* **Endpoint Publik**: `GET /api/v1/school-info` dan `GET /api/v1/school-logo`
* **Controller Backend**: [`app/Http/Controllers/Api/Mobile/SchoolInfoController.php`](file:///home/sutris-remote/Documents/projek-laravel/projek-absensi-barcode/app/Http/Controllers/Api/Mobile/SchoolInfoController.php)
* **Sumber Data**: `\App\Models\PengaturanSekolah::current()` (Tabel `school_settings`)
* **Data JSON yang Dikirim**:
  1. `nama_sekolah`: Nama resmi sekolah (contoh: `SMP Negeri 3 Kedungreja`).
  2. `logo_base64`: String *Data URI Base64* yang sudah dioptimasi ukurannya menjadi *thumbnail* lebar **240px (~50 KB)** oleh fungsi `getOptimizedBase64Logo()` menggunakan ekstensi GD PHP.
  3. `logo_url`: URL endpoint `/api/v1/school-logo` yang dilengkapi header `Access-Control-Allow-Origin: *`.
  4. `theme_primary`: Warna tema utama sekolah.

### Mengapa Logo Dioptimasi Menjadi Thumbnail 240px + Pre-cache?
* File logo asli di `storage/app/public/settings/` berukuran **1189 × 1600 piksel (1,2 MB)**.
* Pada pengujian Flutter Web di Chrome yang berjalan dengan mode *CPU-only rendering* (`webGLVersion is -1`), mendekode gambar 1,2 MB memakan waktu ~1,5 detik sehingga kotak logo sempat terlihat putih polos saat *Splash Screen*.
* Dengan mengecilkan resolusi ke **240px (~50–77 KB)** baik di backend (`thumb_240_...`) maupun aset lokal (`assets/images/logo_sekolah.png`), serta memanggil `await precacheImage(MemoryImage(decodedBytes), context)` dan `gaplessPlayback: true`, logo langsung tampil tajam tanpa jeda putih.

---

## ✨ 2. Struktur Tampilan Splash Screen & Login Screen

### A. Tampilan Awal (`SplashScreen`)
* **File**: [`lib/features/auth/screens/splash_screen.dart`](file:///home/sutris-remote/Documents/projek-laravel/apk-android-presensi/lib/features/auth/screens/splash_screen.dart)
* **Elemen Tengah**:
  1. **Logo Sekolah** (Di dalam kotak putih membulat dengan bayangan halus)
  2. **Nama Sekolah** (Tepat di bawah logo, contoh: `SMP Negeri 3 Kedungreja`)
* **Alur Kerja**:
  - Memuat `/api/v1/school-info`, mendekode `Uint8List` gambar satu kali, melakukan `precacheImage`, lalu meneruskan byte gambar (`initialLogoBytes`) dan nama sekolah langsung ke `LoginScreen` agar tidak terjadi kedipan (*flicker*) saat berpindah halaman.

### B. Tampilan Login Minimalis (`LoginScreen`)
* **File**: [`lib/features/auth/screens/login_screen.dart`](file:///home/sutris-remote/Documents/projek-laravel/apk-android-presensi/lib/features/auth/screens/login_screen.dart)
* **Susunan Header**:
  1. **Logo Sekolah**
  2. **Portal Digital** (Judul Utama)
  3. **Nama Sekolahan** (Sub-judul dinamis dari database, contoh: `SMP Negeri 3 Kedungreja`)
* **Kartu Form Login Minimalis**:
  1. **`Username`**: Satu kolom input terpadu (menerima NISN, NIS, NIP, atau Email).
  2. **`Password`**: Kolom kata sandi dengan tombol mata (*show/hide password*).
  3. **`Login Portal`**: Tombol aksi utama untuk masuk ke portal.
* **Konfigurasi Server Paten**:
  - Bagian "Server Terhubung" di bawah halaman login telah dihapus agar antarmuka bersih bagi pengguna akhir.
  - Alamat server diatur secara paten melalui kode di [`lib/core/config/app_config.dart`](file:///home/sutris-remote/Documents/projek-laravel/apk-android-presensi/lib/core/config/app_config.dart) (`AppConfig.baseUrl`).

---

## 🔄 3. Pemisahan Alur Portal Otomatis (Siswa vs Guru)

Setelah pengguna menekan tombol **Login Portal**, aplikasi mengirim kredensial ke backend dan mengarahkan pengguna ke halaman portal sesuai perannya:

1. **Request Autentikasi**:
   * **Endpoint**: `POST /api/v1/auth/login`
   * **Controller**: [`app/Http/Controllers/Api/Mobile/AuthController.php`](file:///home/sutris-remote/Documents/projek-laravel/projek-absensi-barcode/app/Http/Controllers/Api/Mobile/AuthController.php)
   * **Payload**:
     ```json
     {
       "identifier": "username_atau_nisn_nip",
       "password": "password_akun",
       "device_name": "Flutter Mobile App"
     }
     ```
2. **Deteksi Peran (*Role Resolution*) di Backend**:
   * Backend mencari kecocokan `identifier` pada kolom `email`, `Students.nisn`, `Students.nis`, atau `Teachers.nip`.
   * Jika akun terhubung ke data siswa (`student()->exists()` atau role `siswa`) ➜ `role: "siswa"`.
   * Jika akun terhubung ke data guru (`teacher()->exists()` atau role `guru`/`wali_kelas`) ➜ `role: "guru"`.
   * Jika akun adalah administrator (`isSuperAdmin()`) ➜ `role: "admin"`.
3. **Routing Otomatis di Flutter**:
   * **Role `siswa`** ➜ Diarahkan ke [`DashboardSiswaScreen`](file:///home/sutris-remote/Documents/projek-laravel/apk-android-presensi/lib/features/siswa/screens/dashboard_siswa_screen.dart) (**Portal Siswa**: Kartu Pelajar Digital, Barcode ID, Status Kehadiran).
   * **Role `guru` / `admin`** ➜ Diarahkan ke [`DashboardGuruScreen`](file:///home/sutris-remote/Documents/projek-laravel/apk-android-presensi/lib/features/guru/screens/dashboard_guru_screen.dart) (**Portal Guru**: Presensi Kelas, Sholat Dhuhur, Approval Izin, Jurnal Mengajar).

---

## 🛡️ 4. Catatan Pengujian Web (Chrome) & Database Sanctum

1. **Menjalankan Ulang Setelah Penambahan Aset**:
   - Jika menambahkan file gambar baru pada `assets/images/` di `pubspec.yaml`, lakukan **Stop (⏹)** lalu **Run (▶)** ulang di Android Studio agar server dev Chrome memuat bundel aset terbaru.
2. **Penanganan Tabel Token Sanctum (`personal_access_tokens`)**:
   - `AuthController::login()` dilengkapi blok *try-catch* saat memanggil `$user->createToken()` sehingga tidak gagal dengan HTTP 500 apabila tabel `personal_access_tokens` belum dimigrasi.
   - Untuk mengaktifkan penyimpanan token penuh di database, jalankan `php artisan migrate` pada folder backend `projek-absensi-barcode`.

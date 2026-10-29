# 📅 08. Analisa & Rencana Matang Menu 1: Presensi (Mengikuti `/portal-guru/akademik`)

Dokumen ini menyajikan hasil bedah kode (*code analysis*) dari tampilan web Laravel `/portal-guru/akademik` (`WaliKelasDashboard`) beserta rencana implementasi persisnya ke dalam tampilan mobile Flutter (`PresensiKelasScreen`).

---

## 🔍 1. Hasil Analisa Blade `/portal-guru/akademik`

Berdasarkan bedah kode pada [`WaliKelasDashboard.php`](file:///home/sutris-remote/Documents/projek-laravel/projek-absensi-barcode/app/Livewire/WaliKelasDashboard.php) dan 6 *partial view* di [`resources/views/livewire/wali-kelas/`](file:///home/sutris-remote/Documents/projek-laravel/projek-absensi-barcode/resources/views/livewire/wali-kelas-dashboard.blade.php), halaman `/portal-guru/akademik` terdiri dari **7 Komponen Utama**:

### 1. Header Banner & Aksi Utama (`header.blade.php`)
* **Judul**: **Presensi Kelas** (diambil dari konsep *Dashboard Portal Guru - Kelola data presensi, pantau keterlambatan harian, dan lakukan presensi manual*).
* **Indikator Live Hari Ini**:
  - 🟢 **Sudah Absen Hari Ini**: `total - belum`
  - 🔴 **Belum Absen**: `belum`
* **2 Tombol Aksi Utama di Header**:
  - 🖨️ **Cetak Laporan** (Membuka Modal Cetak Excel / PDF).
  - ✏️ **Input Manual** (Membuka Modal Input Presensi Manual).

### 2. Kartu Filter 3 Dropdown (`filters.blade.php`)
* **Tahun Ajaran** (`selectedAcademicYearId` — default tahun ajaran aktif).
* **Pilih Kelas** (`selectedClassId` — otomatis memuat kelas binaan Wali Kelas, Kelas Pantau BK, atau seluruh kelas bagi Admin/Bypass).
* **Bulan Kehadiran** (`selectedMonthYear` — daftar bulan Juli s/d Desember `start_year` dan Januari s/d Juni `end_year`).

### 3. Toggle Mode & 4 Kartu Statistik Interaktif (`stats-monthly.blade.php`)
* **Saklar Mode Rekap (`rekapMode`)**: **Rekap Harian** vs **Rekap Bulanan**.
* **Sub-info Ringkas**:
  - Saat *Rekap Harian*: Menampilkan Hari/Tanggal, Total Siswa, dan `% Kehadiran`.
  - Saat *Rekap Bulanan*: Menampilkan Potensi Maksimal (`Total Siswa × Hari Efektif`).
* **Grid 4 Kartu Statistik (2×2 di layar HP)**:
  - **Mode Harian** *(Bisa diklik untuk memfilter daftar siswa di bawahnya)*:
    1. 🟢 **Hadir Tepat Waktu**: `hadir / total` + badge `%`.
    2. 🟠 **Terlambat**: `telat / total` + badge `Telat / Nihil`.
    3. 🌸 **Sakit / Izin**: `(sakit + izin) / total` + badge rincian `XS • YI`.
    4. 🟣/⚫ **Belum Absen**: `belum / total` + badge `Tuntas` (jika 0) atau `Perlu Tindakan` (jika $>0$) + info jumlah Alpa.
  - **Mode Bulanan**:
    1. 🟢 **Total Hadir**: `hadir / max_possible` + `%`.
    2. 🟠 **Total Telat**: `telat / max_possible`.
    3. 🌸 **Total Sakit/Izin**: `(sakit + izin) / max_possible`.
    4. ⚫ **Total Alpa**: `alpa / max_possible`.

### 4. Pencarian, Filter Chips & Daftar Siswa (`table.blade.php`)
* **Kolom Cari Cepat**: Cari nama siswa atau NISN secara *real-time*.
* **View 1: Presensi Hari Ini (Tampilan Kartu Mobile)**:
  - **Baris Filter Chips Horizontal**: `Semua (N)`, `Belum Absen (N)`, `Hadir (N)`, `Telat (N)`, `Sakit / Izin (N)`, dan `Alpa (N)` + tombol pintas `Input Presensi`.
  - **Banner Apresiasi**: Muncul otomatis jika filter `Belum Absen` dipilih dan nilainya `0` (*"Luar Biasa! Semua Siswa Sudah Presensi 🎉"*).
  - **Kartu Siswa Ringkas (Mobile Card)**:
    - Avatar Inisial 2 Huruf berwarna sesuai status.
    - Nama Siswa & NISN.
    - Badge Status: `Hadir (06:45)`, `Telat (15m)`, `Izin`, `Sakit`, `Alpa`, atau `Belum Absen` (berdenyut).
    - Box `Catatan` (jika ada) dan info `Scan Pulang: HH:mm WIB` (jika ada).
    - **Footer Kartu Siswa**:
      - Link **Detail Siswa >** (Menuju rekam jejak kalender individual siswa).
      - Tombol **WA Ortu** (hijau, jika status `belum` & fitur aktif) atau **WA Telat** (kuning, jika status `telat` & fitur aktif).
      - Tombol **Input Presensi / Ubah** (membuka modal input manual).
* **View 2: Tabel Matriks Bulanan (1 s/d 31 Hari)**:
  - Legenda kode warna: `H` (Hadir - Hijau), `T` (Telat - Kuning), `I` (Izin - Biru), `S` (Sakit - Ungu), `A` (Alpa - Merah), `L` (Libur - Abu).
  - Tabel *scrollable* horizontal dengan kolom **Nama Siswa** yang *sticky* di sebelah kiri (dilengkapi badge peringatan `⚠️ ≥3 Alpa` atau `⚠️ ≥100mnt Telat`), kolom tanggal `1..31`, serta kolom rekap `H | T | I | S | A` di ujung kanan.

### 5. Modal Input Presensi Manual (`modal-input.blade.php`)
* **Pemilih Tanggal Input (`inputDate`)**: Otomatis mendeteksi apakah tanggal tersebut **Hari Libur Sekolah** (`KalenderSekolahService::isHariSekolah`). Jika hari libur, tombol simpan dikunci dengan peringatan merah.
* **Fitur Set Massal (Bulk Action)**:
  - Dropdown **Set Massal Datang**: `⚡ Hadir Semua`, `Terlambat Semua`, `Izin Semua`, `Sakit Semua`, `Alpa Semua`.
  - Dropdown **Set Massal Pulang** (jika `enable_checkout` aktif): `⚡ Pulang Semua`, `Izin Semua`, `Sakit Semua`, `Alpa Semua`.
* **Daftar Input Per Siswa**:
  - **Proteksi Scan Kiosk (`🔒 Terkunci`)**: Jika siswa sudah scan langsung di mesin kiosk (`is_manual_input == false` dan status `hadir`/`telat`), status datang dikunci agar guru tidak salah timpa, namun status pulang tetap boleh diisi.
  - Input **Telat (Menit)**: Muncul otomatis hanya jika status datang dipilih `Terlambat`.
  - Sinkronisasi otomatis: Jika status datang dipilih `Izin`, `Sakit`, atau `Alpa`, maka status pulang otomatis mengikuti.

### 6. Modal Kirim WhatsApp Ortu via Sistem Gateway (`wali-kelas-dashboard.blade.php`)
* Menampilkan Nama Siswa, Kelas, NISN, dan Status (`Belum Presensi` / `Terlambat`).
* Input **Nomor WhatsApp Orang Tua** (otomatis diformat dari `08...` ke `628...`, dan bisa diedit langsung).
* Textarea **Isi Pesan WhatsApp** yang terisi otomatis dari template `PresensiNotificationSetting::renderTemplate()` + tombol **Reset Format Asli**.
* Tombol **Kirim Sekarang (via Sistem)**: Mengirim pesan langsung melalui `WhatsAppGatewayService` di server tanpa perlu membuka WhatsApp Web.

### 7. Modal Cetak Laporan Presensi (`modal-cetak.blade.php`)
* Pilihan Jenis Laporan: **Bulanan** (pilih bulan), **Semester** (Ganjil/Genap), atau **Tahunan**.
* 2 Tombol Unduh: **Excel (`.xlsx`)** dan **PDF (`.pdf`)**.

---

## 🛠️ 2. Rencana Implementasi Teknis (Backend API & Flutter UI)

### A. Pembuatan Controller API Backend (`GuruPresensiController.php`)
Kita akan membuat [`app/Http/Controllers/Api/Mobile/GuruPresensiController.php`](file:///home/sutris-remote/Documents/projek-laravel/projek-absensi-barcode/app/Http/Controllers/Api/Mobile/GuruPresensiController.php) yang memanfaatkan *service* resmi yang sama dengan Livewire (`PresensiRekapService`, `KalenderSekolahService`, `WhatsAppGatewayService`):

| No | Method & Endpoint | Fungsi (Setara Method di `WaliKelasDashboard`) |
| :-: | :--- | :--- |
| **1** | `GET /api/v1/guru/dashboard-summary` | Mengambil angka badge untuk **9 Kotak Menu** di beranda Portal Guru (`kelasAmpuCount`, `jurnalHariIniCount`, `pendingLeaveRequestsCount`, `activeBooksCount`, dll.). |
| **2** | `GET /api/v1/guru/presensi/dashboard` | Memuat daftar Tahun Ajaran, Kelas Binaan, Bulan, `todayStats`, `classMonthlyStats`, daftar `students` + `todayAttendances` (lengkap dengan template teks WA), `monthlyStats` (matriks 1–31), dan `alerts`. |
| **3** | `GET /api/v1/guru/presensi/manual-input` | Memuat daftar siswa pada tanggal tertentu (`?class_id=&date=`) beserta status `is_holiday`, `enable_checkout`, dan flag `is_locked` (proteksi hasil scan kiosk). |
| **4** | `POST /api/v1/guru/presensi/manual-input` | Menyimpan presensi manual satuan/massal dengan validasi hari libur, proteksi scan kiosk, dan pencatatan histori `note` otomatis. |
| **5** | `POST /api/v1/guru/presensi/send-wa` | Mengirim pesan WhatsApp ke orang tua siswa langsung melalui `WhatsAppGatewayService`. |
| **6** | `GET /api/v1/guru/presensi/export` | Mengunduh/membuka file laporan presensi **PDF** atau **Excel** (Bulanan, Semester, Tahunan). |
| **7** | `GET /api/v1/guru/presensi/student/{id}` | Memuat halaman **Detail Siswa** (kalender absensi bulanan per siswa, persentase hadir, dan aktivitas terakhir sesuai `WaliKelasStudentDetail`). |

---

### B. Pembuatan Layar Flutter (`apk-android-presensi`)

1. **[`lib/features/guru/screens/dashboard_guru_screen.dart`](file:///home/sutris-remote/Documents/projek-laravel/apk-android-presensi/lib/features/guru/screens/dashboard_guru_screen.dart)**:
   - Menampilkan **Banner Sambutan Guru** dan **Grid 9 Kotak Menu** (tanpa sidebar kiri):
     1. **Presensi** *(aktif penuh & membuka `PresensiKelasScreen`)*
     2. **Presensi Sholat Dhuhur**
     3. **Jurnal Mengajar**
     4. **Persetujuan Ijin**
     5. **Guru Wali**
     6. **Data Siswa**
     7. **SPIKAP (Anti-Perundungan & Pengaduan Siswa)**
     8. **Perpustakaan**
     9. **Profil Saya**

2. **[`lib/features/guru/screens/presensi_kelas_screen.dart`](file:///home/sutris-remote/Documents/projek-laravel/apk-android-presensi/lib/features/guru/screens/presensi_kelas_screen.dart)**:
   - Mengikuti persis struktur visual `/portal-guru/akademik`:
     - **Header Banner Gradien**: Badge *Sudah Absen Hari Ini* & *Belum Absen*, tombol **Cetak Laporan**, dan tombol **Input Manual**.
     - **Kartu Filter**: Dropdown *Tahun Ajaran*, *Pilih Kelas*, dan *Bulan Kehadiran*.
     - **Toggle Rekap Harian / Rekap Bulanan** + **Grid 2×2 Kartu Statistik Berwarna** (klik kartu untuk menyaring daftar siswa).
     - **Baris Filter Chips** (`Semua`, `Belum Absen`, `Hadir`, `Telat`, `Sakit/Izin`, `Alpa`) + **Kolom Pencarian Nama/NISN**.
     - **Mode Harian**: Daftar Kartu Siswa Mobile lengkap dengan inisial, badge jam scan/menit telat, catatan, tombol **WA Ortu / WA Telat**, tombol **Input/Ubah**, dan tombol **Detail Siswa >**.
     - **Mode Bulanan**: Tabel Matriks Bulanan (1 s/d 31) dengan kolom Nama Siswa *sticky* di kiri, badge peringatan `⚠️ ≥3 Alpa` / `⚠️ ≥100mnt Telat`, kode warna `H/T/I/S/A/L`, dan total di kanan.
   - **3 Modal BottomSheet / Dialog Interaktif**:
     - **Modal Input Presensi Manual**: Pilih tanggal, peringatan hari libur, tombol **⚡ Set Massal Datang & Pulang**, indikator `🔒 Terkunci` untuk siswa yang sudah scan kiosk, input menit terlambat, dan tombol **Simpan Presensi**.
     - **Modal Kirim WhatsApp Ortu**: Info siswa, edit nomor WA tujuan, edit isi pesan template, tombol *Reset Format Asli*, dan tombol **Kirim Sekarang (via Sistem)**.
     - **Modal Cetak Laporan**: Pilih Bulanan / Semester / Tahunan lalu unduh **Excel** atau **PDF**.

3. **[`lib/features/guru/screens/detail_presensi_siswa_screen.dart`](file:///home/sutris-remote/Documents/projek-laravel/apk-android-presensi/lib/features/guru/screens/detail_presensi_siswa_screen.dart)**:
   - Halaman detail saat guru mengetuk nama siswa atau tombol **Detail Siswa >** pada kartu presensi.


# Dokumentasi Teknis: Fitur Presensi Sholat Dhuhur & Presensi KBM (Jurnal Mengajar) Siswa

Dokumen ini menjelaskan arsitektur, konfigurasi saklar admin, alur data backend Laravel, serta implementasi antarmuka pada aplikasi Flutter (`apk-android-presensi`) untuk dua fitur integrasi akademik siswa:
1. **Tab 2: Presensi Sholat Dhuhur Berjamaah**
2. **Tab 3: Presensi KBM (per Mata Pelajaran dari Jurnal Mengajar Guru)**

---

## 1. Latar Belakang & Masalah Lapangan

Sebelumnya, **Menu 1 (Presensi & Akademik Siswa)** hanya memiliki riwayat presensi harian masuk dan pulang (gerbang sekolah). Terdapat dua kebutuhan integrasi baru:

1. **Presensi Sholat Dhuhur**:
   - Sekolah menyelenggarakan ibadah sholat dhuhur berjamaah yang dipindai oleh guru pembina.
   - Tidak semua siswa beragama Islam, sehingga sistem harus memberikan dispensasi/pengecualian otomatis (*Non-Muslim Exemption*) agar siswa non-muslim tidak dirugikan atau dicatat alpa ibadah.
   - Tidak semua sekolah memberlakukan sholat dhuhur di sistem, sehingga wajib ada saklar toggle aktif/non-aktif dari admin.

2. **Presensi KBM / Mengajar (per Mata Pelajaran)**:
   - Siswa mengikuti 11–12 mata pelajaran sesuai rombongan belajarnya.
   - **Tantangan Lapangan**: Guru di kelas tidak selalu menginput jurnal pembelajaran secara tertib setiap hari/jam pelajaran. Jika sistem menghitung kehadiran dengan kuota target kaku (misal 16 pertemuan per semester), siswa yang selalu masuk akan dirugikan (dicap alpa pada pertemuan yang belum diisi oleh gurunya).
   - **Solusi**: Menggunakan **Model Pertemuan Terdata / Terlaksana (Log-Based)**. Persentase kehadiran hanya dihitung dari pertemuan yang jurnalnya sudah diinput oleh guru. Jika guru belum menginput jurnal pada mapel tersebut, kartu mapel menampilkan status *"Belum Ada Jurnal"*, bukan Alpa.
   - **Saklar Fleksibel**: Sekolah dapat mengaktifkan/menonaktifkan fitur ini sewaktu-waktu melalui tombol toggle langsung di menu admin Jurnal Mengajar (`localhost:8001/admin/jurnal-mengajar`).

---

## 2. Arsitektur Saklar & Konfigurasi Admin (Laravel Backend)

### 2.1 Skema Database & Migrasi
Dua kolom flag boolean ditambahkan pada tabel `school_settings`:
- `enable_sholat_dhuhur` (boolean, default: `true` / `1`)
- `enable_presensi_kbm` (boolean, default: `true` / `1`)

Migrasi Presensi KBM:
- Path: `database/migrations/2026_11_05_120600_add_enable_presensi_kbm_to_school_settings_table.php`
- Model: `app/Models/PengaturanSekolah.php` telah didaftarkan pada properti `$fillable` dan di-cast ke `'boolean'`.

### 2.2 Penempatan Tombol Saklar Toggle di Admin Filament

1. **Header Action di Jurnal Mengajar** (`localhost:8001/admin/jurnal-mengajar`):
   - File: `app/Filament/Akademik/Resources/JurnalPembelajaranResource/Pages/ListJurnalPembelajarans.php`
   - Dilengkapi tombol header action cepat:
     - Badge warna: **Hijau (Aktif)** atau **Abu-abu (Non-aktif)**.
     - Modal konfirmasi yang menampilkan status saat ini serta tombol ubah saklar secara instan tanpa harus membuka menu pengaturan umum.

2. **Halaman Pengaturan Presensi Terpusat**:
   - File: `app/Filament/Presensi/Pages/PengaturanPresensiPage.php`
   - Menyediakan `Toggle::make('enable_presensi_kbm')` dan `Toggle::make('enable_sholat_dhuhur')`.

3. **Penyiapan Informasi Sekolah ke API**:
   - File: `app/Http/Controllers/Api/Mobile/SchoolInfoController.php`
   - File: `app/Http/Controllers/Api/Mobile/Siswa/SiswaDashboardController.php`
   - Mengembalikan `enable_sholat_dhuhur` dan `enable_presensi_kbm` pada payload response profil/dashboard sekolah.

---

## 3. Spesifikasi API Endpoint Mobile

### 3.1 Endpoint 1: Presensi Sholat Dhuhur
- **Method & URI**: `GET /api/v1/siswa/presensi-sholat/dashboard`
- **Query Params**:
  - `month_year` (opsional, format `MM-YYYY`, default: bulan kalender saat ini).
  - `identifier` (opsional jika menggunakan token Bearer siswa).
- **Logika Bisnis**:
  - Memeriksa agama siswa dari biodata. Jika non-muslim (`is_non_muslim: true`), banner dispensasi dimunculkan dan kehadiran tidak diwajibkan.
  - Membangun matriks kalender 1..31 (`berjamaah`, `masbuk`, `tidak_hadir`, `ijin`, `halangan`/`haid`).
  - Menghitung statistik bulanan (total berjamaah, masbuk, tidak hadir, dispensasi).
  - Mengembalikan daftar catatan ibadah terbaru.

### 3.2 Endpoint 2: Presensi KBM (Jurnal Mengajar per Mapel)
- **Method & URI**: `GET /api/v1/siswa/presensi-kbm/dashboard`
- **Query Params**:
  - `month_year` (opsional: `'all'` untuk seluruh semester, atau `MM-YYYY` untuk bulan tertentu).
  - `identifier` (opsional jika menggunakan token Bearer siswa).
- **Logika Bisnis**:
  1. Mengambil rombongan belajar aktif siswa (`AnggotaKelas` -> `KelasAjaran`).
  2. Mengambil seluruh penugasan guru (`Pengajaran`) untuk rombel tersebut (biasanya 11–12 mata pelajaran).
  3. Mengambil seluruh `JurnalPembelajaran` yang telah dibuat guru untuk kelas dan mata pelajaran tersebut pada semester/tahun ajaran aktif.
  4. Mengambil rekaman status kehadiran siswa pada `JurnalPembelajaranPresensi`.
  5. Menghitung persentase kehadiran:
     $$\text{Persentase} = \left(\frac{\text{Pertemuan Hadir}}{\text{Pertemuan Terdata}}\right) \times 100\%$$
     *(Jika pertemuan terdata = 0, persentase default 100% dan status ditandai "Belum Ada Jurnal")*.
  6. Mengurutkan riwayat pertemuan secara kronologis lengkap dengan jam pelajaran, nama guru pengampu, materi pembelajaran, uraian kegiatan, dan status kehadiran siswa.

---

## 4. Implementasi Aplikasi Flutter (`apk-android-presensi`)

### 4.1 Struktur File Fitur

```
lib/features/siswa/
├── models/
│   ├── siswa_akademik_model.dart             # Penambahan field enablePresensiKbm
│   ├── siswa_sholat_model.dart               # Model dashboard Sholat Dhuhur
│   └── siswa_presensi_kbm_model.dart         # Model lengkap KBM (Mapel, Pertemuan, Ringkasan)
├── services/
│   └── siswa_dashboard_service.dart          # Integrasi Dio getPresensiKbmDashboard & getSholatDhuhurDashboard
└── screens/
    ├── presensi_siswa_screen.dart            # Layar Utama Menu 1 dengan Dynamic TabBar (1, 2, atau 3 Tab)
    └── widgets/presensi_siswa/
        ├── sections/
        │   ├── presensi_siswa_month_selector.dart   # Dropdown pemilih periode/bulan kalender
        │   ├── presensi_siswa_stats_card.dart       # Statistik Tab 1 Harian
        │   ├── presensi_siswa_calendar_card.dart    # Matriks kalender Tab 1 Harian
        │   ├── sholat_siswa_stats_card.dart         # Statistik Tab 2 Sholat
        │   ├── sholat_siswa_calendar_card.dart      # Matriks kalender Tab 2 Sholat
        │   ├── kbm_siswa_summary_card.dart          # Kartu Ringkasan Tab 3 KBM (Indigo gradient)
        │   └── kbm_siswa_subject_list.dart          # Daftar kartu 11-12 mapel siswa
        └── modals/
            ├── sheet_presensi_siswa_day_detail.dart # Bottom sheet detail harian
            ├── sheet_sholat_siswa_day_detail.dart   # Bottom sheet detail ibadah sholat
            └── sheet_kbm_siswa_subject_detail.dart  # Bottom sheet kronologi pertemuan per mapel
```

### 4.2 Dynamic TabController
Layar [`PresensiSiswaScreen`](file:///home/sutris-remote/Documents/projek-laravel/apk-android-presensi/lib/features/siswa/screens/presensi_siswa_screen.dart) menggunakan daftar tab dinamis berdasarkan status saklar:

```dart
enum SiswaPresensiTabType {
  harian,
  sholat,
  kbm,
}

List<SiswaPresensiTabType> get _activeTabs {
  final tabs = <SiswaPresensiTabType>[SiswaPresensiTabType.harian];
  if (_enableSholatDhuhur) tabs.add(SiswaPresensiTabType.sholat);
  if (_enablePresensiKbm) tabs.add(SiswaPresensiTabType.kbm);
  return tabs;
}
```

- Jika kedua saklar aktif: menampilkan **3 Tab** (*Presensi Harian*, *Sholat Dhuhur*, *Presensi Mapel*).
- Jika saklar sholat dimatikan: hanya menampilkan **2 Tab** (*Presensi Harian* & *Presensi Mapel*).
- Jika saklar KBM dimatikan: hanya menampilkan **2 Tab** (*Presensi Harian* & *Sholat Dhuhur*).
- Jika keduanya dimatikan: hanya menampilkan **1 Tab** (*Presensi Harian* tanpa header TabBar).
- Menggunakan `isScrollable: _activeTabs.length > 2` untuk menjamin tata letak tidak berdesakan (*overflow*) pada layar HP dengan lebar terbatas.

---

## 5. Tampilan Antarmuka (UI/UX)

### 5.1 Tab 1: Presensi Harian
- Dropdown bulan kalender akademik.
- Kartu statistik kehadiran (Hadir, Telat, Izin, Sakit, Alpa, % Kehadiran).
- Matriks kalender 1..31 interaktif dengan kode warna (Hijau = Hadir, Oranye = Terlambat, Biru = Izin, Merah = Alpa, Abu-abu = Libur/Minggu).
- Rincian aktivitas jam masuk & pulang terbaru.

### 5.2 Tab 2: Sholat Dhuhur Berjamaah
- Banner khusus siswa non-muslim jika tercatat di biodata.
- Dropdown bulan kalender akademik.
- Kartu statistik ibadah (Berjamaah, Masbuk, Halangan/Haid, Sakit/Izin, Tidak Hadir).
- Matriks kalender sholat 1..31 dengan interaksi *tap* untuk melihat jam sholat dan catatan guru pemantau.

### 5.3 Tab 3: Presensi Mapel (KBM)
- **Pemilih Periode**: Pilihan *"Semua Bulan (Semester Ini)"* atau filter per bulan tertentu.
- **Kartu Ringkasan KBM (`KbmSiswaSummaryCard`)**:
  - Desain *Gradient Indigo* (`#4338CA` $\rightarrow$ `#4F46E5`).
  - Badge persentase total kehadiran KBM siswa.
  - Statistik ringkas: Terdata, Hadir, Izin, Sakit, Alpa.
- **Daftar Mata Pelajaran (`KbmSiswaSubjectList`)**:
  - Menampilkan seluruh mata pelajaran siswa (11–12 mapel).
  - Ikon tematik cerdas (Matematika = Kalkulator, Bahasa = Terjemahan, Informatika = Komputer, IPA = Tabung reaksi, dsb).
  - Nama guru pengampu dan badge *"X Pertemuan"* atau *"Belum Ada Jurnal"*.
  - Badge persentase kehadiran dan rasio hadir (contoh: `2/2 Hadir`, `100%`).
- **Modal Detail Pertemuan (`SheetKbmSiswaSubjectDetail`)**:
  - Dibuka ketika kartu mapel diklik.
  - Kartu ringkasan mini kehadiran untuk mapel yang dipilih.
  - Daftar kronologis pertemuan terlaksana (Pertemuan Ke-1, Ke-2, dst).
  - Menampilkan jam pelajaran, hari, tanggal, judul materi guru, dan status kehadiran siswa.

---

## 6. Pengujian dan Verifikasi Mutu

1. **Flutter Code Analysis**:
   - Perintah: `flutter analyze lib/features/siswa`
   - Hasil: `No issues found! (0 error, 0 warning)`
2. **Widget & Unit Testing**:
   - File test: [`portal_siswa_presensi_kbm_test.dart`](file:///home/sutris-remote/Documents/projek-laravel/apk-android-presensi/test/portal_siswa_presensi_kbm_test.dart)
   - Menguji:
     - Rendering `KbmSiswaSummaryCard` dan `KbmSiswaSubjectList` tanpa terjadi *RenderFlex overflow*.
     - Rendering modal `SheetKbmSiswaSubjectDetail` beserta materi pelajaran dan riwayat pertemuan.
   - Hasil: Lulus `100%` (Semua 18 pengujian dalam proyek berstatus lolos).
3. **Uji Coba API Tinker**:
   - Menguji data siswa nyata kelas 8A (`identifier: 0138109237`).
   - Berhasil mengembalikan 12 mata pelajaran (PAI, PKn, Bhs Indonesia, Matematika, IPA, IPS, Bhs Inggris, Seni Budaya, PJOK, Informatika, Prakarya, Bhs Jawa) lengkap dengan pertemuan terdata dari guru.

---

## 5. Integrasi Web Portal Siswa (`localhost:8001/portal-siswa`)

Selain aplikasi mobile Flutter, fitur **Jurnal KBM** dan **Sholat Dhuhur** juga telah diintegrasikan secara penuh pada portal web siswa berbasis Laravel Livewire & Tailwind CSS:

### 5.1 Route & Komponen Livewire
1. **Route Jurnal KBM**:
   - `GET /portal-siswa/jurnal-kbm` -> `App\Livewire\PortalSiswa\SiswaJurnalKbm::class` (Name: `portal-siswa.jurnal-kbm`)
   - Komponen Livewire: `app/Livewire/PortalSiswa/SiswaJurnalKbm.php`
   - Blade Template: `resources/views/livewire/portal-siswa/siswa-jurnal-kbm.blade.php`
2. **Fitur Antarmuka Jurnal KBM**:
   - Filter Periode: Seluruh Semester atau per Bulan.
   - Kartu Ringkasan Total KBM Terdata (Indigo Gradient) menampilkan persentase akumulasi dan statistik (Hadir, Sakit, Izin, Alpa, Belum Ada Jurnal).
   - Grid Kartu 11–12 Mata Pelajaran sesuai rombel aktif siswa.
   - Modal Rincian Mata Pelajaran (Pop-up Livewire) menampilkan daftar kronologis pertemuan, jam ke-, topik/bab, uraian materi, dan status kehadiran siswa.
3. **Route Sholat Dhuhur**:
   - `GET /portal-siswa/sholat-dhuhur` -> `App\Livewire\PortalSiswa\SiswaSholatDhuhur::class` (Name: `portal-siswa.sholat-dhuhur`)

### 5.2 Navigasi Sidebar & Dashboard Pintasan
1. **Sidebar Siswa (`resources/views/components/layouts/portal.blade.php`)**:
   - Menu **Sholat Dhuhur**: Ditampilkan secara otomatis jika saklar `enable_sholat_dhuhur == true`.
   - Menu **Jurnal KBM**: Ditampilkan secara otomatis jika saklar `enable_presensi_kbm == true`.
   - Kedua menu otomatis disembunyikan (*hidden*) jika fitur dinonaktifkan oleh admin sekolah.
2. **Kartu Pintasan Dashboard Utama (`resources/views/livewire/siswa-main-dashboard.blade.php`)**:
   - Ditambahkan 2 kartu pintasan cepat pada grid menu utama siswa:
     - Kartu **Sholat Dhuhur** (Teal Theme) dengan link ke `portal-siswa.sholat-dhuhur`.
     - Kartu **Jurnal KBM** (Indigo Theme) dengan link ke `portal-siswa.jurnal-kbm`.
   - Kedua kartu dibungkus dengan kondisi `@if($enableSholatDhuhur)` dan `@if($enablePresensiKbm)`.
3. **Pengamanan Akses (Route Guarding)**:
   - Jika siswa mengakses URL langsung saat fitur dinonaktifkan di admin, kedua komponen Livewire melempar `abort(403, 'Fitur ... sedang dinonaktifkan.')`.


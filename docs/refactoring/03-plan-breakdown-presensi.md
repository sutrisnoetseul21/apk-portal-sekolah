# 🎯 03. Plan Breakdown: Modul Presensi Guru (9.261 Baris)

> **File Sasaran:**  
> 1. `lib/features/guru/screens/presensi_kelas_screen.dart` (**4.939 baris**)  
> 2. `lib/features/guru/screens/presensi_sholat_dhuhur_screen.dart` (**4.322 baris**)

Kedua berkas ini adalah komponen terbesar dalam seluruh aplikasi. Berita baiknya: kedua file ini memiliki **struktur arsitektural yang hampir 100% simetris**. Memecah satu file akan langsung memvalidasi pola pemecahan untuk file kedua.

---

## 1. Analisa Dekomposisi: `presensi_kelas_screen.dart` (4.939 Baris)

### Peta Baris Kode Eksisting
```text
Baris 1 - 111    : Import, Deklarasi Screen, State variabel
Baris 112 - 417  : Data Fetching Dio, fallback dummy data (305 baris)
Baris 418 - 551  : Method build() utama & empty state (133 baris)
Baris 552 - 805  : _buildHeaderBanner() (253 baris)
Baris 806 - 1065 : _buildFiltersCard() & dropdown fields (259 baris)
Baris 1066 - 1477: _buildStatsSection() & gradient cards (411 baris)
Baris 1478 - 1617: _buildViewSwitcherAndSearch() (139 baris)
Baris 1618 - 2177: _buildDailyAttendanceSection() & StudentCard (559 baris)
Baris 2178 - 2554: _buildMonthlyMatrixSection() & MatrixCell (376 baris)
Baris 2572 - 3408: _openSingleStudentInputModal() (836 baris) -> Modal 1 Siswa!
Baris 3409 - 4294: _openInputManualModal() (885 baris) -> Modal Massal!
Baris 4295 - 4646: _openWaModal() (351 baris) -> Modal WhatsApp Ortu!
Baris 4647 - 4939: _openCetakModal() (292 baris) -> Modal Cetak Rekap!
```

### Rencana Pemecahan Menjadi Modul-Modul Baru

```text
lib/features/guru/
├── screens/
│   └── presensi_kelas_screen.dart               # Dikecilkan dari 4.939 -> ~200 baris
│
└── screens/widgets/presensi_kelas/
    ├── sections/
    │   ├── presensi_header_banner.dart          # Ekstraksi banner status & persentase (~200 baris)
    │   ├── presensi_filter_card.dart            # Dropdown tahun ajaran, kelas, bulan (~220 baris)
    │   └── presensi_stats_section.dart          # Kartu KPI (Hadir, Telat, Izin, Alpa) (~250 baris)
    │
    ├── views/
    │   ├── presensi_daily_list_view.dart        # Switcher harian, search bar, & list card (~250 baris)
    │   └── presensi_monthly_matrix_view.dart    # Grid matriks tanggal 1 - 31 & legenda (~280 baris)
    │
    ├── cards/
    │   └── presensi_student_card.dart           # Card siswa harian dengan chip status (~180 baris)
    │
    └── modals/
        ├── modal_presensi_single_student.dart   # Input status, jam, foto, alasan (1 siswa) (~320 baris)
        ├── modal_presensi_bulk_manual.dart      # Input massal seluruh kelas checklist (~350 baris)
        ├── modal_presensi_wa_reminder.dart      # Template chat WA ortu siswa alpa/telat (~200 baris)
        └── modal_presensi_cetak_dialog.dart     # Pilihan filter cetak PDF / Excel (~180 baris)
```

---

## 2. Analisa Dekomposisi: `presensi_sholat_dhuhur_screen.dart` (4.322 Baris)

### Peta Baris Kode Eksisting
```text
Baris 1 - 126    : Import, Deklarasi Screen, State variabel
Baris 127 - 448  : Data Fetching Dio, fallback dummy data (321 baris)
Baris 449 - 622  : Method build() & state kelas kosong (173 baris)
Baris 623 - 913  : _buildHeaderBanner() tema hijau emerald (290 baris)
Baris 914 - 1286 : _buildFiltersCard() & sinkronisasi pagi (372 baris)
Baris 1287 - 1848: _buildStatsSection() (Jamaah, Munfarid, Haid, dll) (561 baris)
Baris 1849 - 2428: _buildDailyAttendanceSection() & StudentCard (579 baris)
Baris 2429 - 2641: _buildMonthlyMatrixSection() (212 baris)
Baris 2642 - 3099: _openSingleStudentInputModal() (457 baris)
Baris 3100 - 3886: _openBulkInputModal() (786 baris)
Baris 3887 - 4105: _openWaModal() (218 baris)
Baris 4130 - 4322: _openCetakModal() (192 baris)
```

### Rencana Pemecahan Menjadi Modul-Modul Baru

```text
lib/features/guru/
├── screens/
│   └── presensi_sholat_dhuhur_screen.dart       # Dikecilkan dari 4.322 -> ~210 baris
│
└── screens/widgets/presensi_sholat/
    ├── sections/
    │   ├── sholat_header_banner.dart            # Banner nuansa islami emerald (~200 baris)
    │   ├── sholat_filter_card.dart              # Filter kelas, tanggal, sinkron pagi (~240 baris)
    │   └── sholat_stats_section.dart            # Metrik Jamaah, Munfarid, Halangan (~250 baris)
    │
    ├── views/
    │   ├── sholat_daily_list_view.dart          # List siswa sholat harian & filter chips (~220 baris)
    │   └── sholat_monthly_matrix_view.dart      # Matriks kode sholat bulanan (~200 baris)
    │
    ├── cards/
    │   └── sholat_student_card.dart             # Card per siswa + chip status sholat (~180 baris)
    │
    └── modals/
        ├── modal_sholat_single_student.dart     # Input sholat 1 siswa (jamaah/halangan/dll) (~260 baris)
        ├── modal_sholat_bulk_input.dart         # Input massal presensi mushola (~320 baris)
        ├── modal_sholat_wa_reminder.dart        # Notifikasi WA ortu siswa belum sholat (~180 baris)
        └── modal_sholat_cetak_dialog.dart       # Dialog download rekap sholat (~170 baris)
```

---

## 3. Komponen Bersama yang Dapat Di-sharing Antar Presensi

Untuk efisiensi jangka panjang, kedua modul presensi dapat memanfaatkan komponen utilitas di `lib/shared/`:
1. **`MatrixDayCell`**: Kotak kalender 1–31 untuk menampilkan kode `H`, `T`, `I`, `S`, `A`, `J`, `M`.
2. **`PresensiStatusBadge`**: Badge warna standar (Hijau: Hadir/Jamaah, Kuning: Telat, Biru: Izin, Merah: Alpa, Ungu: Haid).
3. **`WhatsAppDirectLauncher`**: Utility untuk validasi nomor HP (`08` -> `628`) dan membuka aplikasi WhatsApp via `url_launcher`.

---

## 4. Hasil Akhir yang Dicapai

- **Sebelum:** 2 file raksasa total **9.261 baris**.
- **Sesudah:** 
  - 2 file screen utama masing-masing hanya **~200 baris**.
  - 16 sub-widget modular dengan ukuran masing-masing rata-rata **180–320 baris**.
  - Kode menjadi sangat mudah dibaca, di-*review*, dan dimodifikasi tanpa saling mengganggu.


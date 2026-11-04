# 📚 04. Plan Breakdown: Perpustakaan & Jurnal Mengajar (9.955 Baris)

> **File Sasaran:**  
> 1. `lib/features/guru/screens/perpustakaan_screen.dart` (**3.502 baris**)  
> 2. `lib/features/guru/screens/form_jurnal_mengajar_screen.dart` (**2.689 baris**)  
> 3. `lib/features/guru/screens/jurnal_mengajar_screen.dart` (**2.508 baris**)  
> 4. `lib/features/siswa/screens/perpustakaan_siswa_screen.dart` (**1.256 baris**)

Modul ini memiliki karakteristik:
- **Perpustakaan:** Layar multi-tab besar (5 tab independen dalam satu layar).
- **Form Jurnal:** Formulir interaktif 3 tahap (*Stepper KBM Parameter -> Materi & Refleksi -> Presensi Siswa*).
- **List Jurnal:** Pencarian, pagination, sheet detail, dan modal ekspor periode.

---

## 1. Analisa Dekomposisi: `perpustakaan_screen.dart` (3.502 Baris)

### Peta Baris Kode Eksisting
```text
Baris 1 - 205    : Import, State 5 scroll controller, & inisialisasi (205 baris)
Baris 206 - 612  : Pagination handler & method fetch untuk 5 tab (406 baris)
Baris 613 - 711  : Method build() & layout scaffolding (98 baris)
Baris 712 - 889  : _buildHeaderBanner() & _buildKpiCard() (177 baris)
Baris 890 - 971  : _buildTabBarPill() (81 baris)
Baris 972 - 1708 : TAB 1: _buildKatalogTab() & BukuCard (736 baris)
Baris 1709 - 2213: TAB 2: _buildPinjamanSayaTab() & Card (504 baris)
Baris 2214 - 2614: TAB 3: _buildRiwayatPinjamanTab() & Card (400 baris)
Baris 2615 - 2923: TAB 4: _buildKunjunganSayaTab() & Card (308 baris)
Baris 2924 - 3502: TAB 5: _buildPinjamanSiswaTab() & Card (578 baris)
```

### Rencana Pemecahan Menjadi Modul-Modul Baru

```text
lib/features/guru/
├── screens/
│   └── perpustakaan_screen.dart                 # Dikecilkan dari 3.502 -> ~180 baris
│
└── screens/widgets/perpustakaan/
    ├── sections/
    │   ├── perpustakaan_header_banner.dart      # Hero banner selamat datang & metrik baca (~160 baris)
    │   └── perpustakaan_tab_selector.dart       # Pill switch 5 tab responsif (~100 baris)
    │
    ├── tabs/                                    # SETIAP TAB MENJADI FILE TERPISAH
    │   ├── tab_katalog_buku.dart                # Pencarian, chip kategori, grid buku (~280 baris)
    │   ├── tab_pinjaman_saya.dart               # Daftar pinjaman aktif guru & jatuh tempo (~220 baris)
    │   ├── tab_riwayat_pinjaman.dart            # Histori peminjaman yang sudah kembali (~200 baris)
    │   ├── tab_kunjungan_fisik.dart             # Histori tap/kunjungan ke perpustakaan (~180 baris)
    │   └── tab_pinjaman_siswa_binaan.dart       # Monitoring literasi siswa kelas ampu & WA (~260 baris)
    │
    └── cards/
        ├── perpustakaan_buku_card.dart          # Card buku + placeholder cover jika null (~160 baris)
        ├── pinjaman_guru_card.dart              # Card pinjaman guru + badge status (~150 baris)
        └── pinjaman_siswa_card.dart             # Card siswa pinjam buku + tombol WA ortu (~160 baris)
```

> **Keuntungan:**  
> Ketika ada perubahan pada fitur pinjaman siswa, developer hanya membuka `tab_pinjaman_siswa_binaan.dart` (260 baris), bukan lagi menggulir 3.500 baris kode!

---

## 2. Analisa Dekomposisi: `form_jurnal_mengajar_screen.dart` (2.689 Baris)

### Peta Baris Kode Eksisting
```text
Baris 1 - 124    : State form, text controller, sinkronisasi (124 baris)
Baris 125 - 539  : Data loading, auto-select kelas, gate presensi, _saveJurnal() (414 baris)
Baris 540 - 592  : Method build() & form scaffolding (52 baris)
Baris 593 - 696  : _buildHeroHeaderCard() (103 baris)
Baris 697 - 1439 : LANGKAH 1: _buildStep1ParameterCard() (742 baris)
Baris 1440 - 1691: LANGKAH 2: _buildStep2MateriRefleksiCard() (251 baris)
Baris 1692 - 2017: LANGKAH 3: _buildStep3StudentAttendanceCard() (325 baris)
Baris 2018 - 2611: Sub-item presensi siswa, chip status, catatan individu (593 baris)
Baris 2612 - 2689: _buildStickyBottomBar() (77 baris)
```

### Rencana Pemecahan Menjadi Modul-Modul Baru

```text
lib/features/guru/
├── screens/
│   └── form_jurnal_mengajar_screen.dart         # Dikecilkan dari 2.689 -> ~180 baris
│
└── screens/widgets/form_jurnal/
    ├── steps/
    │   ├── step1_parameter_kbm_card.dart       # Pilihan mapel, kelas, tanggal, jam JP (~280 baris)
    │   ├── step2_materi_refleksi_card.dart      # Input materi, capaian, refleksi belajar (~180 baris)
    │   └── step3_presensi_siswa_card.dart       # Gate sync presensi, tombol 'Semua Hadir' (~220 baris)
    │
    ├── items/
    │   └── student_jurnal_attendance_tile.dart  # Baris checklist status siswa (H/T/I/S/A) (~240 baris)
    │
    └── sections/
        ├── form_jurnal_header.dart              # Header ringkasan edit / buat baru (~100 baris)
        └── form_jurnal_sticky_bottom_bar.dart   # Tombol submit 'Simpan Jurnal KBM' (~90 baris)
```

---

## 3. Analisa Dekomposisi: `jurnal_mengajar_screen.dart` (2.508 Baris)

### Rencana Pemecahan Menjadi Modul-Modul Baru

```text
lib/features/guru/
├── screens/
│   └── jurnal_mengajar_screen.dart              # Dikecilkan dari 2.508 -> ~190 baris
│
└── screens/widgets/jurnal_mengajar/
    ├── sections/
    │   ├── jurnal_hero_banner.dart              # Banner sambutan + tombol Buat Jurnal Baru (~150 baris)
    │   ├── jurnal_summary_kpi_row.dart          # Total JP mengajar, total sesi KBM (~140 baris)
    │   └── jurnal_filter_card.dart              # Filter tanggal, mapel, & kelas ampu (~220 baris)
    │
    ├── cards/
    │   └── jurnal_item_card.dart                # Card riwayat KBM + tombol Edit/Hapus/Cetak (~220 baris)
    │
    └── modals/
        ├── sheet_detail_jurnal_kbm.dart         # BottomSheet detail materi & absensi sesi (~260 baris)
        └── dialog_cetak_jurnal_periode.dart     # Pilihan cetak PDF KBM mingguan/bulanan (~220 baris)
```

---

## 4. Analisa Dekomposisi: `perpustakaan_siswa_screen.dart` (1.256 Baris)

Untuk sisi siswa, modul memiliki ukuran 1.256 baris yang menampung katalog buku dan pinjaman aktif siswa:
- **`tab_katalog_siswa.dart`** (~250 baris): Menampilkan rekomendasi bacaan & kategori.
- **`tab_pinjaman_aktif_siswa.dart`** (~200 baris): Menampilkan buku yang sedang dipinjam siswa & tanggal jatuh tempo.
- **`perpustakaan_siswa_screen.dart`** (~120 baris): Layar utama sebagai host TabBar.


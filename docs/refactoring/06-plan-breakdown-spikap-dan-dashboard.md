# 🛡️ 06. Plan Breakdown: SPIKAP & Dashboard Utama (6.212 Baris)

> **File Sasaran:**  
> 1. `lib/features/siswa/screens/spikap_siswa_screen.dart` (**1.357 baris**)  
> 2. `lib/features/siswa/screens/dashboard_siswa_screen.dart` (**1.304 baris**)  
> 3. `lib/features/guru/screens/spikap_detail_screen.dart` (**1.299 baris**)  
> 4. `lib/features/guru/screens/dashboard_guru_screen.dart` (**1.135 baris**)  
> 5. `lib/features/guru/screens/spikap_screen.dart` (**1.117 baris**)

---

## 1. Analisa Dekomposisi: Dashboard Utama (Guru & Siswa)

Kedua dashboard saat ini menampung seluruh rendering hero banner, grid menu 9-kotak (Guru) / 7-kotak (Siswa), barcode popup, dan ringkasan presensi harian.

### A. Siswa: `dashboard_siswa_screen.dart` (1.304 Baris)
- **Rencana Pemecahan:**
  ```text
  lib/features/siswa/screens/widgets/dashboard/
  ├── sections/
  │   ├── dashboard_siswa_hero_banner.dart    # Sambutan nama siswa, logo sekolah, NISN (~160 baris)
  │   └── dashboard_today_attendance_card.dart# Kartu status presensi hari ini + jam masuk/pulang (~220 baris)
  ├── grid/
  │   ├── dashboard_siswa_menu_grid.dart      # Grid adaptif (2 kolom HP / 3-4 kolom Tablet) (~150 baris)
  │   └── siswa_menu_box_card.dart            # Komponen kotak menu warna-warni bersudut melengkung (~140 baris)
  └── modals/
      └── dialog_quick_barcode.dart           # Popup cepat kartu barcode NISN (~120 baris)
  ```
  *Layar `dashboard_siswa_screen.dart` menyusut menjadi **~150 baris**.*

### B. Guru: `dashboard_guru_screen.dart` (1.135 Baris)
- **Rencana Pemecahan:**
  ```text
  lib/features/guru/screens/widgets/dashboard/
  ├── sections/
  │   ├── dashboard_guru_hero_banner.dart     # Sambutan bapak/ibu guru, badge NIP & peran wali (~180 baris)
  │   └── dashboard_guru_quick_stats.dart     # Indikator cepat rekap hadir kelas hari ini (~160 baris)
  └── grid/
      ├── dashboard_guru_menu_grid.dart       # Grid 9 Menu Utama Portal Guru (~160 baris)
      └── guru_menu_box_card.dart             # Card menu dengan badge notifikasi merah (~150 baris)
  ```
  *Layar `dashboard_guru_screen.dart` menyusut menjadi **~140 baris**.*

---

## 2. Analisa Dekomposisi: Modul SPIKAP (Anti-Perundungan)

### A. Guru: `spikap_screen.dart` (1.117 Baris) & `spikap_detail_screen.dart` (1.299 Baris)
- **Rencana Pemecahan `spikap_screen.dart`:**
  ```text
  lib/features/guru/screens/widgets/spikap/
  ├── sections/
  │   ├── spikap_header_banner.dart           # Banner perlindungan ramah anak (~120 baris)
  │   └── spikap_filter_status_bar.dart       # Filter investigasi / selesai / verifikasi (~140 baris)
  └── cards/
      └── spikap_kasus_item_card.dart         # Card kasus: tingkat keparahan, tanggal, status (~200 baris)
  ```
- **Rencana Pemecahan `spikap_detail_screen.dart`:**
  ```text
  lib/features/guru/screens/widgets/spikap/detail/
  ├── sections/
  │   ├── spikap_kronologi_card.dart          # Lembar detail kronologi & saksi (~220 baris)
  │   ├── spikap_bukti_viewer_card.dart       # Galeri foto / dokumen bukti kejadian (~160 baris)
  │   └── spikap_tindakan_form_card.dart      # Form update status kasus & rekomendasi BK (~240 baris)
  └── modals/
      └── sheet_hubungi_ortu_spikap.dart      # Template chat WA khusus orang tua terlapor (~180 baris)
  ```
  *Layar `spikap_screen.dart` menyusut menjadi **~160 baris** dan `spikap_detail_screen.dart` menjadi **~220 baris**.*

### B. Siswa: `spikap_siswa_screen.dart` (1.357 Baris)
- **Rencana Pemecahan:**
  ```text
  lib/features/siswa/screens/widgets/spikap/
  ├── sections/
  │   ├── spikap_siswa_hero_banner.dart       # Banner jaminan kerahasiaan pelapor 100% aman (~120 baris)
  │   └── spikap_lapor_cepat_action.dart      # Tombol ajakan buat aduan baru (~100 baris)
  ├── forms/
  │   └── form_aduan_spikap_section.dart      # Form rahasia: terlapor, saksi, waktu, lampiran (~260 baris)
  └── cards/
      └── riwayat_laporan_siswa_card.dart     # Card status penanganan aduan saya (~180 baris)
  ```
  *Layar `spikap_siswa_screen.dart` menyusut menjadi **~150 baris**.*

---

## 3. Ringkasan Perubahan Ukuran Berkas

| Berkas Asal | Ukuran Asal | Target Ukuran Baru | Pengurangan |
| :--- | :-: | :-: | :-: |
| `dashboard_siswa_screen.dart` | 1.304 baris | **~150 baris** | **-88%** |
| `dashboard_guru_screen.dart` | 1.135 baris | **~140 baris** | **-87%** |
| `spikap_siswa_screen.dart` | 1.357 baris | **~150 baris** | **-89%** |
| `spikap_detail_screen.dart` | 1.299 baris | **~220 baris** | **-83%** |
| `spikap_screen.dart` | 1.117 baris | **~160 baris** | **-85%** |


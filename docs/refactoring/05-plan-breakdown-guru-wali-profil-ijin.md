# 👥 05. Plan Breakdown: SI-WALI, Profil, Kartu & Izin (13.810 Baris)

> **File Sasaran:**  
> 1. `lib/features/siswa/screens/guru_wali_siswa_screen.dart` (**2.782 baris**)  
> 2. `lib/features/guru/screens/profil_guru_screen.dart` (**2.557 baris**)  
> 3. `lib/features/guru/screens/ijin_kehadiran_screen.dart` (**2.015 baris**)  
> 4. `lib/features/guru/screens/guru_wali_screen.dart` (**1.922 baris**)  
> 5. `lib/features/siswa/screens/profil_siswa_screen.dart` (**1.626 baris**)  
> 6. `lib/features/siswa/screens/kartu_siswa_screen.dart` (**1.596 baris**)  
> 7. `lib/features/siswa/screens/ijin_kehadiran_siswa_screen.dart` (**1.312 baris**)

---

## 1. Analisa Dekomposisi: Modul Guru Wali SI-WALI

### A. Siswa: `guru_wali_siswa_screen.dart` (2.782 Baris)
- **Titik Obesitas Utama:**  
  Widget `_ModalCurhatForm` (form pengajuan curhat/bimbingan privat) berukuran **845 baris** (baris 1937–2782) tertanam langsung di dalam file layar!
- **Rencana Pemecahan:**
  ```text
  lib/features/siswa/screens/widgets/guru_wali/
  ├── sections/
  │   ├── siwali_guru_profile_card.dart     # Kartu identitas guru wali & tombol WA (~180 baris)
  │   └── siwali_metrics_summary.dart       # Ringkasan sesi curhat & bimbingan (~120 baris)
  ├── tabs/
  │   ├── tab_konsultasi_privat.dart        # Daftar riwayat chat curhat & status (~240 baris)
  │   └── tab_bimbingan_klasikal.dart       # Materi bimbingan kelas & presensi (~250 baris)
  ├── cards/
  │   ├── siwali_konsultasi_item_card.dart  # Card status curhat (~150 baris)
  │   └── siwali_klasikal_item_card.dart    # Card materi klasikal (~160 baris)
  └── modals/
      └── modal_curhat_siswa_form.dart      # Form pengajuan sesi curhat mandiri (~280 baris)
  ```
  *Layar `guru_wali_siswa_screen.dart` menyusut menjadi **~180 baris**.*

### B. Guru: `guru_wali_screen.dart` (1.922 Baris)
- **Titik Obesitas Utama:**  
  Menampung 3 tab besar: Tab Siswa Asuh (grid siswa + list arsip), Tab Riwayat Jurnal (filter pilar + card jurnal), Tab Ruang Aman Cerita (filter topik + card konsultasi).
- **Rencana Pemecahan:**
  ```text
  lib/features/guru/screens/widgets/guru_wali/
  ├── sections/
  │   ├── guru_wali_header_banner.dart      # Banner pengantar & aksi cepat (~150 baris)
  │   └── guru_wali_action_bar.dart         # Tombol Cetak PDF, Tambah Klasikal (~100 baris)
  ├── tabs/
  │   ├── tab_siswa_asuh.dart               # Grid siswa binaan & tab arsip (~260 baris)
  │   ├── tab_riwayat_jurnal.dart           # Filter pilar & list jurnal bimbingan (~220 baris)
  │   └── tab_ruang_aman_cerita.dart        # Chat bimbingan & filter status (~240 baris)
  └── cards/
      ├── siswa_asuh_card.dart              # Card siswa binaan + badge status (~160 baris)
      └── konsultasi_cerita_card.dart       # Card cerita konsultasi siswa (~170 baris)
  ```
  *Layar `guru_wali_screen.dart` menyusut menjadi **~190 baris**.*

---

## 2. Analisa Dekomposisi: Modul Profil & Kartu Siswa

### A. Guru: `profil_guru_screen.dart` (2.557 Baris)
- **Titik Obesitas Utama:**
  Pencampuran 3 tab besar (Biodata & Kontak, Penugasan Akademik, Keamanan Akun) ditambah manajemen foto profil (`ImagePicker`, upload kamera/galeri, crop, kompresi).
- **Rencana Pemecahan:**
  ```text
  lib/features/guru/screens/widgets/profil/
  ├── sections/
  │   └── profil_hero_avatar_section.dart   # Avatar besar, badge NIP, tombol edit foto (~220 baris)
  ├── tabs/
  │   ├── tab_profil_kontak_biodata.dart    # Form email, WA, alamat, microsite (~280 baris)
  │   ├── tab_profil_akademik.dart          # Kelas ampu, mata pelajaran aktif (~200 baris)
  │   └── tab_profil_keamanan.dart          # Form ganti password & tombol logout (~220 baris)
  └── sheets/
      └── sheet_ganti_foto_profil.dart      # BottomSheet kamera / galeri / hapus foto (~180 baris)
  ```
  *Layar `profil_guru_screen.dart` menyusut menjadi **~160 baris**.*

### B. Siswa: `kartu_siswa_screen.dart` (1.596 Baris)
- **Titik Obesitas Utama:**
  Animasi rotasi flip kartu (depan/belakang), CustomPainter ornamen kartu, modal pembesar barcode Code 128, dan utilitas ekspor tangkapan layar kartu.
- **Rencana Pemecahan:**
  ```text
  lib/features/siswa/screens/widgets/kartu/
  ├── card/
  │   ├── kartu_pelajar_front_view.dart     # Sisi depan: Foto, NISN, barcode Code 128 (~260 baris)
  │   ├── kartu_pelajar_back_view.dart      # Sisi belakang: Tata tertib & ketentuan (~180 baris)
  │   └── kartu_background_painter.dart     # CustomPainter garis grafis kartu (~80 baris)
  ├── modals/
  │   └── modal_barcode_fullscreen.dart     # Tampilan barcode layar penuh untuk scanner (~150 baris)
  └── sections/
      ├── kartu_action_panel.dart           # Tombol Simpan Gambar, Cetak PDF, Flip (~140 baris)
      └── kartu_panduan_penggunaan.dart     # Panduan scan & penggunaan kartu (~100 baris)
  ```
  *Layar `kartu_siswa_screen.dart` menyusut menjadi **~170 baris**.*

---

## 3. Analisa Dekomposisi: Modul Ijin Kehadiran

### A. Guru: `ijin_kehadiran_screen.dart` (2.015 Baris)
- **Titik Obesitas Utama:**
  Widget modal `_DetailIjinModal` memakan **886 baris** (baris 1129–2015), berisi form persetujuan izin, alasan penolakan, penampil lampiran surat/foto dokter, dan integrasi WhatsApp wali murid.
- **Rencana Pemecahan:**
  ```text
  lib/features/guru/screens/widgets/ijin/
  ├── sections/
  │   ├── ijin_hero_banner.dart             # Banner ringkasan izin masuk (~120 baris)
  │   ├── ijin_metric_cards.dart            # Metrik Menunggu, Disetujui, Ditolak (~140 baris)
  │   └── ijin_filter_bar.dart              # Filter tanggal, kelas ampu, status (~180 baris)
  ├── cards/
  │   └── leave_request_card.dart           # Card daftar permohonan izin siswa (~220 baris)
  └── modals/
      ├── modal_detail_approval_ijin.dart   # Detail izin, tombol Setujui / Tolak (~280 baris)
      └── dialog_attachment_preview.dart    # Viewer lampiran foto surat dokter/PDF (~150 baris)
  ```
  *Layar `ijin_kehadiran_screen.dart` menyusut menjadi **~180 baris**.*

### B. Siswa: `ijin_kehadiran_siswa_screen.dart` (1.312 Baris)
- **Rencana Pemecahan:**
  - `form_pengajuan_ijin_section.dart` (~240 baris): Form tanggal mulai–selesai, jenis izin, alasan, upload surat.
  - `riwayat_ijin_siswa_card.dart` (~180 baris): Card status izin (Pending/Approved/Rejected).
  - Layar utama menyusut menjadi **~150 baris**.


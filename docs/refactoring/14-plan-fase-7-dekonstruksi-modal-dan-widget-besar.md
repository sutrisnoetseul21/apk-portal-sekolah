# 📋 Plan Fase 7: Dekonstruksi Berkas Besar (>500 Baris) & Optimalisasi Komponen Modular

> **Status Dokumen:** DRAF RENCANA KERJA (Menunggu Review & Persetujuan Pengembang)  
> **Target:** Mengurangi beban baris kode pada modal raksasa, card kompleks, dan screen controller berukuran di atas 500 baris menjadi modul-modul kecil mandiri berukuran <250–300 baris.

---

## 1. 📊 Latar Belakang & Hasil Audit Kode

Setelah penyelesaian Fase 1 s.d. 6 dan pembaruan rilis **v1.0.1** (di mana 18 berkas "God-Widget" di atas 1.000–4.900 baris berhasil didekonstruksi), dilakukan audit lanjutan terhadap seluruh berkas Dart di direktori `lib/`.

Hasil audit menemukan **36 berkas** yang masih memiliki panjang **di atas 500 baris kode**:

```text
               ┌─────────────────────────────────────────────────────────┐
               │    DISTRIBUSI 36 BERKAS > 500 BARIS (TOTAL 23.411 BARIS) │
               └────────────────────────────┬────────────────────────────┘
                                            │
       ┌──────────────────────┬─────────────┴────────────┬─────────────────────┐
       ▼                      ▼                          ▼                     ▼
┌───────────────┐      ┌───────────────┐          ┌──────────────┐      ┌──────────────┐
│  Kategori 1   │      │  Kategori 2   │          │  Kategori 3  │      │  Kategori 4  │
│ Modal/Sheet   │      │ Screen Level  │          │ Card/Section │      │ Data Models  │
│   Raksasa     │      │ Controller    │          │   Kompleks   │      │   & Service  │
│  (12 Berkas)  │      │  (16 Berkas)  │          │  (6 Berkas)  │      │  (2 Berkas)  │
│ 7.828 baris   │      │ 10.428 baris  │          │ 3.561 baris  │      │ 1.141 baris  │
└───────────────┘      └───────────────┘          └──────────────┘      └──────────────┘
```

---

## 2. 📑 Inventaris Lengkap 36 Berkas (> 500 Baris)

| No | Lokasi Berkas | Baris | Kategori | Prioritas Refactor |
| :-: | :--- | :-: | :--- | :-: |
| 1 | `lib/features/guru/screens/widgets/guru_wali/chat_konsultasi_sheet.dart` | **961** | Modal Sheet | 🚨 Kritis (Batch A) |
| 2 | `lib/features/guru/screens/widgets/ijin/modals/modal_detail_ijin.dart` | **920** | Modal Detail | 🚨 Kritis (Batch A) |
| 3 | `lib/features/guru/screens/widgets/presensi_kelas/modals/modal_presensi_manual_bulk.dart` | **896** | Modal Input Massal | 🚨 Kritis (Batch A) |
| 4 | `lib/features/guru/screens/widgets/presensi_kelas/modals/modal_presensi_single_student.dart` | **868** | Modal Input Tunggal | 🚨 Kritis (Batch A) |
| 5 | `lib/features/guru/screens/widgets/data_siswa/modal_edit_biodata.dart` | **861** | Form Biodata | 🚨 Kritis (Batch A) |
| 6 | `lib/features/guru/screens/profil_guru_screen.dart` | **848** | Screen Controller | 🟠 Tinggi (Batch C) |
| 7 | `lib/features/guru/screens/perpustakaan_screen.dart` | **828** | Screen Controller | 🟠 Tinggi (Batch C) |
| 8 | `lib/features/guru/screens/widgets/detail_buku_bottom_sheet.dart` | **783** | Modal Detail/Pinjam | 🚨 Kritis (Batch A) |
| 9 | `lib/features/guru/screens/widgets/form_jurnal/steps/step1_parameter_kbm_card.dart` | **777** | Form Stepper Card | 🚨 Kritis (Batch A) |
| 10 | `lib/features/guru/screens/widgets/presensi_sholat/modals/modal_sholat_bulk_input.dart` | **766** | Modal Input Massal | 🚨 Kritis (Batch A) |
| 11 | `lib/features/guru/screens/presensi_sholat_dhuhur_screen.dart` | **715** | Screen Controller | 🟠 Tinggi (Batch C) |
| 12 | `lib/features/guru/screens/widgets/guru_wali/modal_jurnal_individu.dart` | **710** | Form Konseling | 🟡 Menengah (Batch B) |
| 13 | `lib/features/siswa/screens/profil_siswa_screen.dart` | **696** | Screen Controller | 🟠 Tinggi (Batch C) |
| 14 | `lib/features/guru/screens/detail_presensi_siswa_screen.dart` | **680** | Screen Controller | 🟠 Tinggi (Batch C) |
| 15 | `lib/features/guru/screens/form_jurnal_mengajar_screen.dart` | **642** | Screen Controller | 🟠 Tinggi (Batch C) |
| 16 | `lib/features/guru/screens/widgets/jurnal_mengajar/modals/dialog_cetak_jurnal_periode.dart` | **634** | Dialog Export/Cetak | 🟡 Menengah (Batch B) |
| 17 | `lib/features/guru/screens/widgets/presensi_sholat/sections/sholat_daily_attendance.dart` | **616** | Section Widget | 🟡 Menengah (Batch D) |
| 18 | `lib/features/guru/screens/widgets/data_siswa/student_card_widget.dart` | **596** | Item Card | 🟡 Menengah (Batch D) |
| 19 | `lib/features/guru/screens/widgets/form_jurnal/items/student_jurnal_attendance_tile.dart` | **595** | Item Tile | 🟡 Menengah (Batch D) |
| 20 | `lib/features/guru/models/perpustakaan_models.dart` | **592** | Data Model DTO | ⚪ Tetap (Data Model) |
| 21 | `lib/features/siswa/screens/widgets/guru_wali/modals/modal_detail_konsultasi.dart` | **591** | Modal Siswa | 🟡 Menengah (Batch B) |
| 22 | `lib/features/guru/screens/widgets/presensi_sholat/sections/sholat_stats_section.dart` | **590** | Section Widget | 🟡 Menengah (Batch D) |
| 23 | `lib/features/guru/screens/widgets/presensi_kelas/sections/presensi_daily_attendance.dart` | **588** | Section Widget | 🟡 Menengah (Batch D) |
| 24 | `lib/features/auth/screens/login_screen.dart` | **579** | Screen Controller | 🟠 Tinggi (Batch C) |
| 25 | `lib/features/guru/screens/widgets/presensi_kelas/sections/presensi_stats_section.dart` | **576** | Section Widget | 🟡 Menengah (Batch D) |
| 26 | `lib/features/guru/services/guru_wali_service.dart` | **549** | Service API | ⚪ Tetap (Service Layer) |
| 27 | `lib/features/siswa/screens/guru_wali_siswa_screen.dart` | **534** | Screen Controller | 🟢 Ringan (Batch C) |
| 28 | `lib/features/guru/screens/jurnal_mengajar_screen.dart` | **534** | Screen Controller | 🟢 Ringan (Batch C) |
| 29 | `lib/features/siswa/screens/form_spikap_siswa_screen.dart` | **519** | Screen Controller | 🟢 Ringan (Batch C) |
| 30 | `lib/features/siswa/screens/dashboard_siswa_screen.dart` | **517** | Screen Controller | 🟢 Ringan (Batch C) |
| 31 | `lib/features/guru/screens/presensi_kelas_screen.dart` | **514** | Screen Controller | 🟢 Ringan (Batch C) |
| 32 | `lib/features/guru/screens/guru_wali_screen.dart` | **514** | Screen Controller | 🟢 Ringan (Batch C) |
| 33 | `lib/features/siswa/screens/kartu_siswa_screen.dart` | **507** | Screen Controller | 🟢 Ringan (Batch C) |
| 34 | `lib/features/guru/screens/widgets/guru_wali/modal_jurnal_klasikal.dart` | **507** | Form Klasikal | 🟡 Menengah (Batch B) |
| 35 | `lib/features/guru/screens/dashboard_guru_screen.dart` | **502** | Screen Controller | 🟢 Ringan (Batch C) |
| 36 | `lib/features/guru/screens/spikap_detail_screen.dart` | **501** | Screen Controller | 🟢 Ringan (Batch C) |

---

## 3. 🎯 Rencana Strategis Dekonstruksi Bertahap (Batching Plan)

Untuk menghindari risiko regresi dan memastikan kompilasi tetap stabil di setiap langkah, pengerjaan dibagi ke dalam 4 Batch terarah:

```text
┌────────────────────────────────────────────────────────────────────────┐
│                   TAHAPAN EKSEKUSI FASE 7                              │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
    ┌───────────────────────────────┼───────────────────────────────┐
    ▼                               ▼                               ▼
┌────────────────────────┐      ┌────────────────────────┐      ┌────────────────────────┐
│ BATCH A:               │      │ BATCH B:               │      │ BATCH C:               │
│ Modal/Sheet Raksasa    │ ───► │ Modal Menengah &       │ ───► │ Screen Controllers     │
│ (8 Berkas, 750-960 baris)     │ Dialog Cetak           │      │ (> 600 Baris)          │
│ Target: < 250 baris    │      │ (4 Berkas, 500-710 baris)     │ Target: < 250 baris    │
└────────────────────────┘      └────────────────────────┘      └────────────────────────┘
```

---

### 🔹 BATCH A: Dekonstruksi Modal & Bottom Sheet Raksasa (Prioritas Utama)

Berkas-berkas ini saat ini bertindak sebagai "mini-screen" tersendiri karena memuat form, validasi, dan rendering visual rumit:

#### 1. `chat_konsultasi_sheet.dart` (961 baris)
*Lokasi:* `lib/features/guru/screens/widgets/guru_wali/`
- **Permasalahan:** Menggabungkan header riwayat kasus, daftar bubble chat, status resolution picker, form balasan, dan image viewer.
- **Rencana Pemecahan:**
  - `chat/chat_bubble_item.dart` (~150 baris): Rendering bubble pesan guru & siswa (termasuk timestamp & status terbaca).
  - `chat/chat_input_action_bar.dart` (~180 baris): Text field pengiriman pesan, tombol lampiran, dan shortcut jawaban cepat.
  - `chat/chat_status_resolution_card.dart` (~160 baris): Selector status penanganan (Dalam Bimbingan, Dialihkan ke BK, Selesai).
  - `chat_konsultasi_sheet.dart` (Induk tersisa ~220 baris).

#### 2. `modal_detail_ijin.dart` (920 baris)
*Lokasi:* `lib/features/guru/screens/widgets/ijin/modals/`
- **Permasalahan:** Berisi card identitas pemohon, timeline persetujuan, dialog konfirmasi persetujuan/penolakan dengan alasan, serta full-screen attachment viewer.
- **Rencana Pemecahan:**
  - `modal_detail/ijin_timeline_audit_view.dart` (~180 baris): Visual tracker persetujuan (Wali Kelas -> BK -> Approved).
  - `modal_detail/ijin_surat_attachment_preview.dart` (~170 baris): Viewer gambar surat dokter / dokumen bukti izin.
  - `modal_detail/ijin_approval_action_panel.dart` (~200 baris): Form catatan persetujuan dan tombol aksi Setuju/Tolak.
  - `modal_detail_ijin.dart` (Induk tersisa ~230 baris).

#### 3. `modal_presensi_manual_bulk.dart` (896 baris) & `modal_presensi_single_student.dart` (868 baris)
*Lokasi:* `lib/features/guru/screens/widgets/presensi_kelas/modals/`
- **Permasalahan:** Modal massal memuat search box, checklist filter status massal (H/S/I/A), dan daftar puluhan siswa lengkap dengan status tile. Modal single memuat riwayat kehadiran siswa 30 hari terakhir.
- **Rencana Pemecahan:**
  - `bulk/presensi_bulk_student_tile.dart` (~180 baris): Tile baris per siswa dengan 4 radio chip status.
  - `bulk/presensi_bulk_quick_setter_bar.dart` (~140 baris): Tombol pintas "Hadirkan Semua", "Set Sakit Semua".
  - `single/presensi_single_history_strip.dart` (~190 baris): Strip matriks riwayat kehadiran siswa bulan aktif.
  - File modal induk masing-masing berkurang menjadi <260 baris.

#### 4. `modal_edit_biodata.dart` (861 baris)
*Lokasi:* `lib/features/guru/screens/widgets/data_siswa/`
- **Permasalahan:** Form panjang mencakup identitas siswa, NISN, NIK, alamat lengkap, kontak ortu, pekerjaan ayah/ibu.
- **Rencana Pemecahan:**
  - `edit_biodata/tab_biodata_identitas.dart` (~220 baris): NIS, NISN, Nama, Tempat Tanggal Lahir, Agama, Jenis Kelamin.
  - `edit_biodata/tab_biodata_alamat_kontak.dart` (~200 baris): Alamat rumah, RT/RW, Desa, Nomor HP/WhatsApp Siswa.
  - `edit_biodata/tab_biodata_orang_tua.dart` (~240 baris): Nama Ayah, Nama Ibu, Nama Wali, No HP Ortu, Pekerjaan.
  - `modal_edit_biodata.dart` (Induk tab controller tersisa ~180 baris).

#### 5. `detail_buku_bottom_sheet.dart` (783 baris)
*Lokasi:* `lib/features/guru/screens/widgets/`
- **Permasalahan:** Detail buku + daftar eksemplar/salinan buku fisik + form peminjaman langsung.
- **Rencana Pemecahan:**
  - `detail_buku/buku_metadata_header.dart` (~180 baris): Cover buku, judul, pengarang, penerbit, nomor rak.
  - `detail_buku/buku_eksemplar_status_list.dart` (~210 baris): Status barcode eksemplar (Tersedia / Sedang Dipinjam).
  - `detail_buku/buku_action_pinjam_panel.dart` (~190 baris): Pemilihan durasi peminjaman dan tombol konfirmasi.
  - `detail_buku_bottom_sheet.dart` (Induk tersisa ~200 baris).

#### 6. `step1_parameter_kbm_card.dart` (777 baris)
*Lokasi:* `lib/features/guru/screens/widgets/form_jurnal/steps/`
- **Permasalahan:** Memuat banyak dropdown berantai (Tahun Ajaran, Rombel, Mata Pelajaran, Jam Ke-, Kompetensi Dasar).
- **Rencana Pemecahan:**
  - `steps/step1/jurnal_rombel_mapel_selector.dart` (~230 baris).
  - `steps/step1/jurnal_jam_pelajaran_picker.dart` (~200 baris).
  - `steps/step1/jurnal_materi_kompetensi_field.dart` (~180 baris).
  - `step1_parameter_kbm_card.dart` (Induk tersisa ~170 baris).

#### 7. `modal_sholat_bulk_input.dart` (766 baris)
*Lokasi:* `lib/features/guru/screens/widgets/presensi_sholat/modals/`
- **Permasalahan:** Mirip presensi manual, tetapi memiliki logika khusus sholat (Halangan/Haid, Non-Muslim, Ibadah Alternatif).
- **Rencana Pemecahan:**
  - `bulk/sholat_bulk_student_item.dart` (~190 baris): Tile siswa dengan status Jamaah, Munfarid, Halangan, Non-Muslim.
  - `bulk/sholat_bulk_summary_footer.dart` (~150 baris): Counter real-time per kategori status.
  - `modal_sholat_bulk_input.dart` (Induk tersisa ~210 baris).

---

### 🔹 BATCH B: Dekonstruksi Modal Menengah & Dialog Cetak (500–710 Baris)

1. **`modal_jurnal_individu.dart` (710 baris)**:
   - Ekstrak form RTL & rujukan BK ke `guru_wali/modals/jurnal_individu_rujukan_form.dart`.
2. **`dialog_cetak_jurnal_periode.dart` (634 baris)**:
   - Ekstrak picker periode tanggal ke `jurnal_mengajar/modals/cetak_date_range_card.dart`.
   - Ekstrak format options & button ke `jurnal_mengajar/modals/cetak_options_bar.dart`.
3. **`modal_detail_konsultasi.dart` (591 baris)** (Sisi Siswa):
   - Ekstrak log balasan guru ke `guru_wali/modals/konsultasi_siswa_thread_view.dart`.
4. **`modal_jurnal_klasikal.dart` (507 baris)**:
   - Ekstrak form dinamika kelas ke `guru_wali/modals/klasikal_dinamika_kelas_form.dart`.

---

### 🔹 BATCH C: Perampingan Screen Controllers (> 600 Baris)

Screen berikut masih memiliki logika dialog inline dan layout scaffold yang cukup tebal:
1. **`profil_guru_screen.dart` (848 baris)** & **`profil_siswa_screen.dart` (696 baris)**:
   - Ekstrak dialog ganti password, dialog crop/unggah foto, dan bottom sheet kontak menjadi modul terpisah.
2. **`perpustakaan_screen.dart` (828 baris)**:
   - Ekstrak floating quick search dan filter bar modal keluar dari file screen utama.
3. **`presensi_sholat_dhuhur_screen.dart` (715 baris)** & **`presensi_kelas_screen.dart` (514 baris)**:
   - Bersihkan helper konversi waktu dan dialog sinkronisasi manual menjadi controller terpisah.
4. **`detail_presensi_siswa_screen.dart` (680 baris)**:
   - Ekstrak kalender matriks bulanan per siswa ke widget terpisah.
5. **`form_jurnal_mengajar_screen.dart` (642 baris)**:
   - Ekstrak stepper progress indicator dan dialog batal form ke komponen terpisah.
6. **`login_screen.dart` (579 baris)**:
   - Ekstrak card form credentials, toggle role (Siswa/Guru), dan dialog info bantuan login ke folder `features/auth/screens/widgets/`.

---

### 🔹 BATCH D: Pemecahan Card & Section Widget (570–616 Baris)

1. **`sholat_daily_attendance.dart` (616 baris)** & **`presensi_daily_attendance.dart` (588 baris)**:
   - Ekstrak empty state card, summary chip row, dan individual student attendance row.
2. **`student_card_widget.dart` (596 baris)** (Data Siswa):
   - Ekstrak quick action popup menu (Kirim WA, Reset Pass, Cetak Kartu, Edit Biodata).
3. **`student_jurnal_attendance_tile.dart` (595 baris)**:
   - Ekstrak note dialog dialog dan radio button status presence.
4. **`sholat_stats_section.dart` (590 baris)** & **`presensi_stats_section.dart` (576 baris)**:
   - Ekstrak diagram donut/progress bar dan legend statistik kehadiran.

---

## 4. 🛡️ Prinsip Keamanan & "Zero Breaking Changes"

Dalam pelaksanaan Fase 7, prinsip-prinsip berikut wajib dijaga:
1. **Zero Route Disruption:** Nama class public (`showChatKonsultasiSheet`, `showModalDetailIjin`, `ProfilGuruScreen`, dll.) dan signature parameternya **tidak boleh berubah sama sekali**.
2. **Zero Behavior Change:** Validasi form, feedback snackbar, dan animasi dialog tetap berjalan persis seperti sebelum dipecah.
3. **Testing Bertahap:** Setiap kali 1 file modal selesai didekonstruksi, langsung lakukan verifikasi `flutter analyze lib/` dan `flutter test` sebelum beralih ke berkas berikutnya.
4. **Clean Commits:** Setiap batch dikomit terpisah dengan deskripsi yang jelas (misal: `refactor(modal): dekonstruksi chat_konsultasi_sheet ke komponen modular`).

---

## 5. 📌 Checklist Review Pengembang

Sebelum eksekusi dimulai, silakan review dan tentukan:
- [ ] Apakah urutan **Batch A (Modal Raksasa)** sudah sesuai prioritas?
- [ ] Apakah ada modal atau komponen tertentu yang ingin dipertahankan apa adanya?
- [ ] Apakah ada penamaan folder atau konvensi baru yang ingin disesuaikan sebelum pengerjaan?

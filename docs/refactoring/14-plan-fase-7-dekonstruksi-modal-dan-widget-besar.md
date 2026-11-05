# 📋 Plan Fase 7: Dekonstruksi Berkas Besar (>500 Baris) & Optimalisasi Komponen Modular

> **Status Dokumen:** FASE 7 - BATCH A SELESAI (100% SUKSES, 0 COMPILATION ERRORS)  
> **Target:** Mengurangi beban baris kode pada modal raksasa, card kompleks, dan screen controller berukuran di atas 500 baris menjadi modul-modul kecil mandiri berukuran <250–300 baris.

---

## 1. 📊 Latar Belakang & Hasil Audit Kode

Setelah penyelesaian Fase 1 s.d. 6 dan pembaruan rilis **v1.0.1** (di mana 18 berkas "God-Widget" di atas 1.000–4.900 baris berhasil didekonstruksi), dilakukan audit lanjutan terhadap seluruh berkas Dart di direktori `lib/`.

Hasil audit menemukan **36 berkas** yang memiliki panjang **di atas 500 baris kode**.

Pada eksekusi **Batch A**, seluruh **8 berkas modal/form raksasa berkisar 750–960 baris** telah berhasil didekonstruksi secara modular dengan tingkat pemangkasan rata-rata **55%–86%** tanpa breaking changes dan lulus `flutter analyze` dengan **0 errors**.

---

## 2. 📑 Inventaris Berkas (> 500 Baris) & Progres Penyelesaian

| No | Lokasi Berkas | Baris Awal | Baris Sekarang | Status | Kategori |
| :-: | :--- | :-: | :-: | :-: | :-: |
| 1 | `lib/features/guru/screens/widgets/guru_wali/chat_konsultasi_sheet.dart` | **961** | **432** | ✅ Selesai (Batch A) | Modal Sheet |
| 2 | `lib/features/guru/screens/widgets/ijin/modals/modal_detail_ijin.dart` | **920** | **428** | ✅ Selesai (Batch A) | Modal Detail |
| 3 | `lib/features/guru/screens/widgets/presensi_kelas/modals/modal_presensi_manual_bulk.dart` | **896** | **384** | ✅ Selesai (Batch A) | Modal Input Massal |
| 4 | `lib/features/guru/screens/widgets/presensi_kelas/modals/modal_presensi_single_student.dart` | **868** | **465** | ✅ Selesai (Batch A) | Modal Input Tunggal |
| 5 | `lib/features/guru/screens/widgets/data_siswa/modal_edit_biodata.dart` | **861** | **392** | ✅ Selesai (Batch A) | Form Biodata |
| 6 | `lib/features/guru/screens/widgets/detail_buku_bottom_sheet.dart` | **783** | **187** | ✅ Selesai (Batch A) | Modal Detail/Pinjam |
| 7 | `lib/features/guru/screens/widgets/form_jurnal/steps/step1_parameter_kbm_card.dart` | **778** | **106** | ✅ Selesai (Batch A) | Form Stepper Card |
| 8 | `lib/features/guru/screens/widgets/presensi_sholat/modals/modal_sholat_bulk_input.dart` | **767** | **254** | ✅ Selesai (Batch A) | Modal Input Massal |
| 9 | `lib/features/guru/screens/profil_guru_screen.dart` | **848** | 848 | 🟠 Menunggu (Batch C) | Screen Controller |
| 10 | `lib/features/guru/screens/perpustakaan_screen.dart` | **828** | 828 | 🟠 Menunggu (Batch C) | Screen Controller |
| 11 | `lib/features/guru/screens/presensi_sholat_dhuhur_screen.dart` | **715** | 715 | 🟠 Menunggu (Batch C) | Screen Controller |
| 12 | `lib/features/guru/screens/widgets/guru_wali/modal_jurnal_individu.dart` | **710** | 247 | ✅ Selesai (Batch B) | Form Konseling |
| 13 | `lib/features/siswa/screens/profil_siswa_screen.dart` | **696** | 696 | 🟠 Menunggu (Batch C) | Screen Controller |
| 14 | `lib/features/guru/screens/detail_presensi_siswa_screen.dart` | **680** | 680 | 🟠 Menunggu (Batch C) | Screen Controller |
| 15 | `lib/features/guru/screens/form_jurnal_mengajar_screen.dart` | **642** | 642 | 🟠 Menunggu (Batch C) | Screen Controller |
| 16 | `lib/features/guru/screens/widgets/jurnal_mengajar/modals/dialog_cetak_jurnal_periode.dart` | **634** | 168 | ✅ Selesai (Batch B) | Dialog Export/Cetak |
| 17 | `lib/features/guru/screens/widgets/presensi_sholat/sections/sholat_daily_attendance.dart` | **616** | 616 | 🟡 Menunggu (Batch D) | Section Widget |
| 18 | `lib/features/guru/screens/widgets/data_siswa/student_card_widget.dart` | **596** | 596 | 🟡 Menunggu (Batch D) | Item Card |
| 19 | `lib/features/guru/screens/widgets/form_jurnal/items/student_jurnal_attendance_tile.dart` | **595** | 595 | 🟡 Menunggu (Batch D) | Item Tile |
| 20 | `lib/features/guru/models/perpustakaan_models.dart` | **592** | 592 | ⚪ Tetap (Data Model) | Data Model DTO |
| 21 | `lib/features/siswa/screens/widgets/guru_wali/modals/modal_detail_konsultasi.dart` | **591** | 268 | ✅ Selesai (Batch B) | Modal Siswa |
| 22 | `lib/features/guru/screens/widgets/presensi_sholat/sections/sholat_stats_section.dart` | **590** | 590 | 🟡 Menunggu (Batch D) | Section Widget |
| 23 | `lib/features/guru/screens/widgets/presensi_kelas/sections/presensi_daily_attendance.dart` | **588** | 588 | 🟡 Menunggu (Batch D) | Section Widget |
| 24 | `lib/features/auth/screens/login_screen.dart` | **579** | 579 | 🟠 Menunggu (Batch C) | Screen Controller |
| 25 | `lib/features/guru/screens/widgets/presensi_kelas/sections/presensi_stats_section.dart` | **576** | 576 | 🟡 Menunggu (Batch D) | Section Widget |
| 26 | `lib/features/guru/services/guru_wali_service.dart` | **549** | 549 | ⚪ Tetap (Service Layer) | Service API |
| 27 | `lib/features/siswa/screens/guru_wali_siswa_screen.dart` | **534** | 534 | 🟢 Menunggu (Batch C) | Screen Controller |
| 28 | `lib/features/guru/screens/jurnal_mengajar_screen.dart` | **534** | 534 | 🟢 Menunggu (Batch C) | Screen Controller |
| 29 | `lib/features/siswa/screens/form_spikap_siswa_screen.dart` | **519** | 519 | 🟢 Menunggu (Batch C) | Screen Controller |
| 30 | `lib/features/siswa/screens/dashboard_siswa_screen.dart` | **517** | 517 | 🟢 Menunggu (Batch C) | Screen Controller |
| 31 | `lib/features/guru/screens/presensi_kelas_screen.dart` | **514** | 514 | 🟢 Menunggu (Batch C) | Screen Controller |
| 32 | `lib/features/guru/screens/guru_wali_screen.dart` | **514** | 514 | 🟢 Menunggu (Batch C) | Screen Controller |
| 33 | `lib/features/siswa/screens/kartu_siswa_screen.dart` | **507** | 507 | 🟢 Menunggu (Batch C) | Screen Controller |
| 34 | `lib/features/guru/screens/widgets/guru_wali/modal_jurnal_klasikal.dart` | **507** | 260 | ✅ Selesai (Batch B) | Form Klasikal |
| 35 | `lib/features/guru/screens/dashboard_guru_screen.dart` | **502** | 502 | 🟢 Menunggu (Batch C) | Screen Controller |
| 36 | `lib/features/guru/screens/spikap_detail_screen.dart` | **501** | 501 | 🟢 Menunggu (Batch C) | Screen Controller |

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
### 🔹 BATCH A: Dekonstruksi Modal & Bottom Sheet Raksasa (✅ 100% Selesai)

Berkas-berkas ini sebelumnya bertindak sebagai "mini-screen" raksasa (750–960 baris). Seluruhnya telah didekonstruksi ke sub-komponen modular:

#### 1. `chat_konsultasi_sheet.dart` (961 baris ➔ **432 baris**)
*Lokasi:* `lib/features/guru/screens/widgets/guru_wali/`
- `chat/chat_topic_banner.dart` (81 baris): Header topik kasus, kategori, dan tombol tutup.
- `chat/chat_message_bubble.dart` (90 baris): Bubble pesan obrolan guru & siswa beserta avatar dan timestamp.
- `chat/chat_input_bar.dart` (98 baris): Kolom input balasan, tombol kirim pesan, dan status terkunci jika selesai.
- `chat/chat_action_dialogs.dart` (389 baris): Dialog konfirmasi pengalihan ke BK, dialog penyelesaian sesi, dan preview foto bukti.

#### 2. `modal_detail_ijin.dart` (920 baris ➔ **428 baris**)
*Lokasi:* `lib/features/guru/screens/widgets/ijin/modals/`
- `detail/ijin_student_parent_card.dart` (110 baris): Card profil siswa, kelas, kontak ortu, dan shortcut WA.
- `detail/ijin_leave_details_card.dart` (111 baris): Jenis izin (S/I), durasi tanggal, dan alasan pengajuan.
- `detail/ijin_attachment_grid.dart` (138 baris): Thumbnail lampiran surat keterangan dokter / foto bukti.
- `detail/ijin_attachment_viewer_dialog.dart` (112 baris): Dialog preview gambar bukti izin fullscreen.
- `detail/ijin_audit_log_card.dart` (71 baris): Histori persetujuan dan verifikasi wali kelas / BK.
- `detail/ijin_detail_bottom_action_bar.dart` (104 baris): Tombol aksi Setujui / Tolak perizinan.

#### 3. `modal_presensi_manual_bulk.dart` (896 baris ➔ **384 baris**)
*Lokasi:* `lib/features/guru/screens/widgets/presensi_kelas/modals/`
- `bulk/manual_bulk_date_picker_card.dart` (105 baris): Kalender pemilih tanggal & status hari aktif KBM.
- `bulk/manual_bulk_quick_setter_bar.dart` (91 baris): Tombol pintas set massal (Hadirkan Semua, dll.).
- `bulk/manual_bulk_student_card.dart` (202 baris): Baris kartu siswa dengan status radio chip (H/S/I/A).
- `bulk/manual_bulk_bottom_bar.dart` (79 baris): Bar aksi Batal & Simpan presensi seluruh kelas.

#### 4. `modal_presensi_single_student.dart` (868 baris ➔ **465 baris**)
*Lokasi:* `lib/features/guru/screens/widgets/presensi_kelas/modals/`
- `single/single_student_info_card.dart` (75 baris): Ringkasan identitas siswa, NIS, dan foto avatar.
- `single/single_status_choice_chip.dart` (61 baris): Reusable segmented chip pilihan status presensi.
- `single/single_student_status_selector.dart` (263 lines): Form detail alasan izin/sakit dan catatan guru.

#### 5. `modal_edit_biodata.dart` (861 baris ➔ **392 baris**)
*Lokasi:* `lib/features/guru/screens/widgets/data_siswa/`
- `edit_biodata/edit_biodata_fields.dart` (70 baris): Reusable field helper label & styled textfield.
- `edit_biodata/tab_edit_identitas.dart` (248 baris): Foto profil picker, nama lengkap, gender radio, agama dropdown, tempat/tanggal lahir, alamat.
- `edit_biodata/tab_edit_sekolah_keluarga.dart` (115 baris): Sekolah asal, tanggal masuk, diterima di kelas, status keluarga, anak ke-.
- `edit_biodata/tab_edit_orang_tua.dart` (118 baris): Nama & pekerjaan ayah, ibu, wali, no HP ortu, no HP siswa.

#### 6. `detail_buku_bottom_sheet.dart` (783 baris ➔ **187 baris**)
*Lokasi:* `lib/features/guru/screens/widgets/`
- `perpustakaan/detail_buku/buku_cover_metadata_header.dart` (215 baris): Cover buku network cached, judul, penulis, rak, status badge.
- `perpustakaan/detail_buku/buku_loan_status_banner.dart` (128 baris): Banner info "Sedang Dipinjam", estimasi kembali, dan tombol baca PDF digital.
- `perpustakaan/detail_buku/buku_bibliografi_card.dart` (106 baris): Tabel rincian penerbit, tahun, ISBN, klasifikasi DDC, mapel.
- `perpustakaan/detail_buku/buku_eksemplar_list_section.dart` (152 baris): Daftar eksemplar fisik buku beserta status dan kondisi.

#### 7. `step1_parameter_kbm_card.dart` (778 baris ➔ **106 baris**)
*Lokasi:* `lib/features/guru/screens/widgets/form_jurnal/steps/`
- `step1/step1_header_and_teacher.dart` (197 baris): Header langkah 01, guru pengampu read-only, pemilih tanggal KBM.
- `step1/step1_mapel_rombel_selector.dart` (176 baris): Dropdown seleksi mata pelajaran & rombel kelas terikat.
- `step1/step1_jp_calculator_strip.dart` (339 baris): Smart JP calculator: tombol jam mulai (1-9), durasi (1-5 JP), hasil jadwal terformat.

#### 8. `modal_sholat_bulk_input.dart` (767 baris ➔ **254 baris**)
*Lokasi:* `lib/features/guru/screens/widgets/presensi_sholat/modals/`
- `bulk/sholat_bulk_modal_header.dart` (66 baris): Header gradien emerald, judul kelas sholat, tombol tutup.
- `bulk/sholat_bulk_control_bar.dart` (187 baris): Pemilih tanggal, tombol sinkronisasi presensi pagi, notifikasi libur, dropdown set massal.
- `bulk/sholat_bulk_student_item.dart` (223 baris): Item siswa muslim (hadir/izin/haid/alpa) dan tag non-muslim tanpa kewajiban sholat.
- `bulk/sholat_bulk_bottom_bar.dart` (57 baris): Tombol aksi batal & simpan presensi sholat 1 kelas.

---

### 🔹 BATCH B: Dekonstruksi Modal Menengah & Dialog Cetak (✅ 100% Selesai)

1. **`modal_jurnal_individu.dart` (710 baris ➔ 247 baris)**:
   *Lokasi:* `lib/features/guru/screens/widgets/guru_wali/`
   - `guru_wali/modals/jurnal_individu/jurnal_individu_summary_header.dart` (128 baris): Foto siswa, status risiko, dan toggle quick-history bimbingan.
   - `guru_wali/modals/jurnal_individu/jurnal_individu_parameter_form.dart` (179 baris): Dropdown bentuk sesi & pilar bimbingan, pemilih tanggal/jam, serta uraian materi.
   - `guru_wali/modals/jurnal_individu/jurnal_individu_badge_card.dart` (104 baris): Status tindak lanjut & rekomendasi sesi.
   - `guru_wali/modals/jurnal_individu/jurnal_individu_rujukan_bk_card.dart` (114 baris): Opsi rujukan BK & kolaborasi lintas guru.

2. **`dialog_cetak_jurnal_periode.dart` (634 baris ➔ 168 baris)**:
   *Lokasi:* `lib/features/guru/screens/widgets/jurnal_mengajar/modals/`
   - `jurnal_mengajar/modals/cetak/cetak_jurnal_modal_header.dart` (67 baris): Header dialog cetak periode KBM & tombol tutup.
   - `jurnal_mengajar/modals/cetak/cetak_jurnal_periode_selector.dart` (187 baris): Segmented preset (Bulan Ini, Semester Ini, Kustom) dan date range picker.
   - `jurnal_mengajar/modals/cetak/cetak_jurnal_target_selector.dart` (159 baris): Filter rombel kelas target dan format dokumen (PDF / Excel).
   - `jurnal_mengajar/modals/cetak/cetak_jurnal_action_buttons.dart` (75 baris): Tombol aksi batal & unduh/cetak dokumen.

3. **`modal_detail_konsultasi.dart` (591 baris ➔ 268 baris)** (Sisi Siswa):
   *Lokasi:* `lib/features/siswa/screens/widgets/guru_wali/modals/`
   - `konsultasi/konsultasi_info_card.dart` (84 baris): Ringkasan status konsultasi, guru wali penanggung jawab, dan tanggal pengajuan.
   - `konsultasi/konsultasi_chat_thread.dart` (91 baris): Thread obrolan kronologis dua arah (siswa dan guru wali).
   - `konsultasi/konsultasi_chat_input_bar.dart` (66 baris): Bar input respons siswa dengan status terkunci jika sesi selesai.
   - `konsultasi/konsultasi_feedback_dialog.dart` (143 baris): Dialog rating & feedback penyelesaian sesi konsultasi.

4. **`modal_jurnal_klasikal.dart` (507 baris ➔ 260 baris)**:
   *Lokasi:* `lib/features/guru/screens/widgets/guru_wali/`
   - `guru_wali/modals/jurnal_klasikal/klasikal_student_selector_card.dart` (88 baris): Daftar centang siswa peserta bimbingan dengan tombol Batal/Pilih Semua.
   - `guru_wali/modals/jurnal_klasikal/klasikal_datetime_picker_row.dart` (76 baris): Pemilih tanggal dan jam pelaksanaan sesi klasikal.
   - `guru_wali/modals/jurnal_klasikal/klasikal_parameter_form.dart` (167 baris): Dropdown bentuk sesi & pilar bimbingan, form uraian materi & RTL kelompok.

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
1. **Zero Route Disruption:** Nama class public (`showChatKonsultasiSheet`, `showModalDetailIjin`, `ModalEditBiodataSheet`, `DetailBukuBottomSheet`, `Step1ParameterKbmCard`, `ModalSholatBulkInput`, dll.) dan signature parameternya **tidak boleh berubah sama sekali**.
2. **Zero Behavior Change:** Validasi form, feedback snackbar, dan animasi dialog tetap berjalan persis seperti sebelum dipecah.
3. **Testing Bertahap:** Setiap kali 1 file modal selesai didekonstruksi, langsung lakukan verifikasi `flutter analyze lib/` dan `flutter test` sebelum beralih ke berkas berikutnya.
4. **Clean Commits:** Setiap batch dikomit terpisah dengan deskripsi yang jelas (misal: `refactor(phase-7): dekonstruksi batch a modal & card raksasa >750 baris`).

---

## 5. 📌 Checklist Eksekusi Fase 7

- [x] **Batch A (Modal & Form Raksasa 750–960 baris)**:
  - [x] `chat_konsultasi_sheet.dart` (961 ➔ 432 baris)
  - [x] `modal_detail_ijin.dart` (920 ➔ 428 baris)
  - [x] `modal_presensi_manual_bulk.dart` (896 ➔ 384 baris)
  - [x] `modal_presensi_single_student.dart` (868 ➔ 465 baris)
  - [x] `modal_edit_biodata.dart` (861 ➔ 392 baris)
  - [x] `detail_buku_bottom_sheet.dart` (783 ➔ 187 baris)
  - [x] `step1_parameter_kbm_card.dart` (778 ➔ 106 baris)
  - [x] `modal_sholat_bulk_input.dart` (767 ➔ 254 baris)
  - [x] Verifikasi `flutter analyze lib/` (0 Errors)
- [x] **Batch B (Modal Menengah & Dialog Cetak 500–710 baris)**:
  - [x] `modal_jurnal_individu.dart` (710 ➔ 247 baris)
  - [x] `dialog_cetak_jurnal_periode.dart` (634 ➔ 168 baris)
  - [x] `modal_detail_konsultasi.dart` (591 ➔ 268 baris)
  - [x] `modal_jurnal_klasikal.dart` (507 ➔ 260 baris)
  - [x] Verifikasi `flutter analyze lib/` (0 Errors)
- [ ] **Batch C (Screen Controllers >600 baris)**
- [ ] **Batch D (Card & Section Widget 570–616 baris)**


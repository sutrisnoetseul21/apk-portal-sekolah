# 🧩 Dokumentasi Master: Refactoring & Modularisasi File Raksasa (>1.000 Baris)

> **Status:** SELURUH FASE 1–6 SELESAI & TERVERIFIKASI (Tag `v1.0.0` untuk versi monolitik awal | Tag `v1.0.1` untuk versi modular modern)  
> **Target:** Memecah seluruh file raksasa (>1.000 baris) dan file formulir besar (700–950 baris) menjadi modul-modul kecil yang rapi, berfokus tunggal (*Single Responsibility*), dan berukuran ringkas per berkas.

---

## 1. 📊 Ringkasan Eksekutif & Hasil Audit Kode

Berdasarkan audit menyeluruh terhadap direktori `lib/` (total **61.093 baris kode** Dart), ditemukan bahwa **64,2% (39.239 baris)** dari seluruh basis kode aplikasi terkonsentrasi hanya pada **18 file "God-Widget"**.

Hal ini menyebabkan:
- Sulitnya navigasi kode (harus menggulir ribuan baris untuk mencari fungsi kecil).
- Tingginya risiko regresi (mengubah satu method dapat merusak tampilan lain).
- Konflik merge yang sering terjadi saat bekerja secara tim/kolaborasi.
- Peningkatan beban memori dan kompilasi hot-reload di IDE.

### Tabel Audit: 18 Berkas Kritis (> 1.000 Baris)

| No | Lokasi Berkas | Jumlah Baris | Kategori Modul | Tingkat Keparahan |
| :-: | :--- | :-: | :--- | :-: |
| 1 | `lib/features/guru/screens/presensi_kelas_screen.dart` | **4.939** | Guru - Menu 1 (Presensi) | 🚨 Sangat Kritis |
| 2 | `lib/features/guru/screens/presensi_sholat_dhuhur_screen.dart` | **4.322** | Guru - Menu 2 (Sholat Dhuhur) | 🚨 Sangat Kritis |
| 3 | `lib/features/guru/screens/perpustakaan_screen.dart` | **3.502** | Guru - Menu 8 (Perpustakaan) | 🚨 Sangat Kritis |
| 4 | `lib/features/siswa/screens/guru_wali_siswa_screen.dart` | **2.782** | Siswa - Menu 3 (SI-WALI) | 🔴 Kritis |
| 5 | `lib/features/guru/screens/form_jurnal_mengajar_screen.dart` | **2.689** | Guru - Menu 3 (Form Jurnal) | 🔴 Kritis |
| 6 | `lib/features/guru/screens/profil_guru_screen.dart` | **2.557** | Guru - Menu 9 (Profil) | 🔴 Kritis |
| 7 | `lib/features/guru/screens/jurnal_mengajar_screen.dart` | **2.508** | Guru - Menu 3 (List Jurnal) | 🔴 Kritis |
| 8 | `lib/features/guru/screens/ijin_kehadiran_screen.dart` | **2.015** | Guru - Menu 4 (Approval Izin) | 🔴 Kritis |
| 9 | `lib/features/guru/screens/guru_wali_screen.dart` | **1.922** | Guru - Menu 5 (Guru Wali) | 🟠 Tinggi |
| 10 | `lib/features/siswa/screens/profil_siswa_screen.dart` | **1.626** | Siswa - Menu 7 (Profil) | 🟠 Tinggi |
| 11 | `lib/features/siswa/screens/kartu_siswa_screen.dart` | **1.596** | Siswa - Menu 6 (Kartu Pelajar) | 🟠 Tinggi |
| 12 | `lib/features/siswa/screens/spikap_siswa_screen.dart` | **1.357** | Siswa - Menu 4 (SPIKAP Siswa) | 🟠 Tinggi |
| 13 | `lib/features/siswa/screens/ijin_kehadiran_siswa_screen.dart` | **1.312** | Siswa - Menu 2 (Ijin Siswa) | 🟡 Menengah-Tinggi |
| 14 | `lib/features/siswa/screens/dashboard_siswa_screen.dart` | **1.304** | Siswa - Dashboard Utama | 🟡 Menengah-Tinggi |
| 15 | `lib/features/guru/screens/spikap_detail_screen.dart` | **1.299** | Guru - Menu 7 (Detail Kasus) | 🟡 Menengah-Tinggi |
| 16 | `lib/features/siswa/screens/perpustakaan_siswa_screen.dart` | **1.256** | Siswa - Menu 5 (Perpustakaan) | 🟡 Menengah-Tinggi |
| 17 | `lib/features/guru/screens/dashboard_guru_screen.dart` | **1.135** | Guru - Dashboard Utama | 🟡 Menengah |
| 18 | `lib/features/guru/screens/spikap_screen.dart` | **1.117** | Guru - Menu 7 (SPIKAP Guru) | 🟡 Menengah |
| **TOTAL** | **18 Berkas Utama** | **39.239** | *(64,2% dari Total 61.093 Baris)* | - |

### Berkas Lanjutan Menjelang 1.000 Baris (Perlu Dipantau)
- `lib/features/guru/screens/widgets/guru_wali/chat_konsultasi_sheet.dart` (961 baris)
- `lib/features/siswa/screens/form_ijin_siswa_screen.dart` (939 baris)
- `lib/features/siswa/screens/presensi_siswa_screen.dart` (910 baris)
- `lib/features/guru/screens/widgets/data_siswa/modal_edit_biodata.dart` (861 baris)
- `lib/features/guru/screens/widgets/detail_buku_bottom_sheet.dart` (783 baris)
- `lib/features/siswa/screens/form_spikap_siswa_screen.dart` (778 baris)
- `lib/features/guru/screens/data_siswa_screen.dart` (777 baris)
- `lib/features/guru/screens/spikap_analitik_screen.dart` (719 baris)

---

## 2. 🔍 Mengapa File-File Tersebut Bisa Menembus Ribuan Baris?

Berdasarkan investigasi arsitektural mendalam, terdapat 5 faktor anti-pattern utama:

```text
               ┌──────────────────────────────────────────────────┐
               │         ANATOMI FILE "GOD-WIDGET" (4.000+ Baris)  │
               └─────────────────────────┬────────────────────────┘
                                         │
    ┌──────────────────┬─────────────────┼──────────────────┬──────────────────┐
    ▼                  ▼                 ▼                  ▼                  ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ Inlined      │ │ Embedded     │ │ Raw Network  │ │ Inlined      │ │ Duplicated   │
│ Multi-Tabs   │ │ Giant Modals │ │ & Logic Code │ │ Form Trees   │ │ Micro-Widgets│
│ Seluruh tab  │ │ Modal input  │ │ Panggilan    │ │ Card stepper,│ │ Badge, chip, │
│ disatukan di │ │ & export     │ │ Dio, URL, &  │ │ custom       │ │ picker dibuat│
│ satu State   │ │ 500-900 baris│ │ state mutasi │ │ painters     │ │ ulang terus  │
└──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘
```

1. **Inlined Multi-Tabs (Seluruh Konten Tab Disatukan)**:
   Contoh di `perpustakaan_screen.dart` (3.502 baris): Layar ini memiliki 5 tab (*Katalog, Pinjaman Saya, Riwayat, Kunjungan, Pinjaman Siswa*). Semua layout, scroll controller, dan pagination per tab ditulis di dalam satu class State.
2. **Embedded Giant Modals (Modal Raksasa di dalam Method)**:
   Contoh di `presensi_kelas_screen.dart` (4.939 baris): Modal input manual massal (`_openInputManualModal`) memakan **885 baris**, modal presensi individu (`_openSingleStudentInputModal`) memakan **836 baris**, modal WhatsApp memakan **350 baris**, dan dialog cetak memakan **290 baris**. Bila diekstrak, screen ini langsung berkurang **2.360 baris**!
3. **Pencampuran Tanggung Jawab (Presentation + Network + Logic)**:
   Banyak screen melakukan query HTTP `Dio` langsung di dalam method class UI, memanipulasi list map mentah `Map<String, dynamic>`, alih-alih mendelegasikan ke lapisan `Service` dan `Model`.
4. **Widget Tree Tanpa Ekstraksi Komponen Kecil**:
   Bagian-bagian berulang seperti `_buildMobileStudentCard`, `_buildMatrixDayCell`, `_buildFilterChip`, `_buildStatGradientCard` diimplementasikan secara private di file induk.
5. **Form Stepper & Custom Painter Panjang**:
   Di `form_jurnal_mengajar_screen.dart`, tiga langkah form (Parameter, Materi, Presensi Siswa) masing-masing memakan 300–700 baris kode di satu file.

---

## 3. 🎯 Sasaran & Standar Hasil Refactoring

| Parameter | Kondisi Saat Ini (As-Is) | Target Baru (To-Be) |
| :--- | :--- | :--- |
| **Ukuran Berkas Screen** | 1.100 s.d. 4.939 baris | **Maksimal 200–350 baris** |
| **Tanggung Jawab Screen** | State, HTTP, Modals, Tabs, Drawing | Hanya *Scaffold* & *Composability* UI |
| **Lokasi Modal & Sheet** | Inlined private methods di screen | Terpisah di folder `widgets/modals/` |
| **Konten Tab Layar** | Inlined di screen utama | Terpisah di folder `widgets/tabs/` |
| **Komponen Reusable** | Copy-paste antar layar | Disatukan di `shared/` atau `widgets/` |
| **Penanganan Network** | Langsung di Screen via `Dio` | Dikelola `Service` dengan typed `Model` |
| **Kompatibilitas** | - | **100% Zero Breaking Changes** pada API & Route |

---

## 4. 🗂️ Indeks Dokumen Panduan Pemecahan

Dokumentasi di dalam folder `docs/refactoring/` ini disusun secara spesifik per domain:

1. [`01-standar-arsitektur-dan-konvensi.md`](./01-standar-arsitektur-dan-konvensi.md)  
   *Panduan resmi struktur folder fitur, aturan penamaan, batas baris kode, dan checklist Separation of Concerns.*
2. [`02-roadmap-dan-tahapan-eksekusi.md`](./02-roadmap-dan-tahapan-eksekusi.md)  
   *Rencana bertahap 5 fase migrasi, estimasi waktu, prosedur uji keamanan (smoke test), dan mitigasi risiko.*
3. [`03-plan-breakdown-presensi.md`](./03-plan-breakdown-presensi.md)  
   *Blueprint pemecahan 2 file monster presensi: Presensi Kelas (4.939) & Sholat Dhuhur (4.322).*
4. [`04-plan-breakdown-jurnal-dan-perpustakaan.md`](./04-plan-breakdown-jurnal-dan-perpustakaan.md)  
   *Blueprint pemecahan Perpustakaan Guru & Siswa, serta Manajemen Jurnal Mengajar (List & Form).*
5. [`05-plan-breakdown-guru-wali-profil-ijin.md`](./05-plan-breakdown-guru-wali-profil-ijin.md)  
   *Blueprint pemecahan SI-WALI Guru & Siswa, Profil Guru & Siswa, Kartu Siswa Digital, serta Persetujuan Izin.*
6. [`06-plan-breakdown-spikap-dan-dashboard.md`](./06-plan-breakdown-spikap-dan-dashboard.md)  
   *Blueprint pemecahan Modul Anti-Perundungan SPIKAP dan Dashboard Utama Guru & Siswa.*
7. [`07-laporan-fase-1-presensi.md`](./07-laporan-fase-1-presensi.md)  
   *Laporan Hasil Penyelesaian Fase 1: Pemecahan 9.261 Baris Presensi Kelas & Sholat Dhuhur.*
8. [`08-laporan-fase-2-jurnal-dan-perpustakaan.md`](./08-laporan-fase-2-jurnal-dan-perpustakaan.md)  
   *Laporan Hasil Penyelesaian Fase 2: Pemecahan 8.699 Baris Perpustakaan, Form Jurnal & Jurnal Mengajar.*
9. [`09-laporan-fase-3-profil-dan-kartu.md`](./09-laporan-fase-3-profil-dan-kartu.md)  
   *Laporan Hasil Penyelesaian Fase 3: Pemecahan 5.779 Baris Profil Guru, Profil Siswa & Kartu Digital.*
10. [`10-laporan-fase-4-siwali-dan-ijin.md`](./10-laporan-fase-4-siwali-dan-ijin.md)  
   *Laporan Hasil Penyelesaian Fase 4: Pemecahan 8.031 Baris SI-WALI Guru & Siswa, serta Manajemen Izin Guru & Siswa.*
11. [`11-laporan-fase-5-spikap-dan-dashboard.md`](./11-laporan-fase-5-spikap-dan-dashboard.md)  
   *Laporan Hasil Penyelesaian Fase 5: Pemecahan 7.468 Baris Dashboard Guru & Siswa, Perpustakaan Siswa, dan Kasus SPIKAP Guru & Siswa.*
12. [`12-plan-fase-6-form-dan-layanan.md`](./12-plan-fase-6-form-dan-layanan.md)  
   *Plan Breakdown Fase 6: Pemecahan 5 Berkas Formulir & Layanan Tambahan (700–950 baris) menuju Tag v1.0.1.*
13. [`13-laporan-fase-6-form-dan-layanan.md`](./13-laporan-fase-6-form-dan-layanan.md)  
   *Laporan Hasil Penyelesaian Fase 6: Pemecahan 4.123 Baris Form Izin, Presensi Mandiri, Form SPIKAP, Data Siswa & Analitik SPIKAP.*

---

## 5. 🚀 Prinsip "Zero Breaking Changes"

Selama pelaksanaan refactoring, prinsip terpenting adalah:
1. **Signature Screen Tidak Berubah**: Parameter konstruktor seperti `token`, `identifier`, `teacherName`, `schoolName` tidak boleh diubah agar navigasi dari `main.dart` dan dashboard tidak error.
2. **Perilaku UI Tetap Sama**: Seluruh interaksi, animasi, snackbar, dan feedback pengguna tetap mempertahankan UX yang ada.
3. **Ekstraksi Terisolasi**: Refactoring dilakukan berkas per berkas, bukan serentak sekaligus, sehingga commit Git tetap kecil, bersih, dan mudah di-revert jika terjadi kendala.


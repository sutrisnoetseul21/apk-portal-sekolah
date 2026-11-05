# 28. Dokumentasi Desain 2-Tab & Analisa Kelas/Siswa pada Jurnal Mengajar Guru

Dokumen ini menjelaskan pembaruan antarmuka dan arsitektur **Menu 3: Jurnal Mengajar** pada **Portal Guru** (baik di aplikasi Android Flutter maupun Web Portal Guru Laravel Livewire `:8001/portal-guru/jurnal-mengajar`).

---

## 1. Latar Belakang & Tujuan Pembaruan

1. **Efisiensi Ruang Layar Mobile (Tanpa Banner & KPI Raksasa)**:
   - Sebelumnya, halaman Jurnal Mengajar menampilkan *Hero Banner* biru besar dan 3 kartu metrik KPI besar yang memakan lebih dari setengah layar ponsel.
   - Kini *Hero Banner* dan 3 kartu KPI besar dihapus pada tampilan mobile:
     - Tombol **Cetak Laporan KBM** dipindahkan ke ikon aksi `AppBar` (`Icons.print_rounded`).
     - Tombol **+ Tulis Jurnal** dijadikan `FloatingActionButton.extended` di kanan bawah agar selalu mudah dijangkau.
     - Ringkasan jumlah sesi dan jam pelajaran ditampilkan melalui `JurnalCompactSummaryBar` yang ringkas (`X Sesi KBM • Y JP • Z Absen`).
2. **Kebutuhan Analisa Mendalam Kelas & Kehadiran Siswa (2 Tab)**:
   - Guru mata pelajaran membutuhkan visibilitas cepat untuk menjawab pertanyaan: *"Di Kelas 8A bulan ini, berapa kali pertemuan yang sudah berlangsung, dan siapa saja siswa yang sering tidak mengikuti KBM / Alpa / Izin / Sakit beserta tanggal dan jam pelajarannya?"*
   - Halaman Jurnal Mengajar kini dibagi menjadi **2 Tab Utama**:
     - **Tab 1: `Riwayat Jurnal`** — Fokus pada filter pencarian dan daftar riwayat jurnal KBM harian.
     - **Tab 2: `Analisa Kelas & Siswa`** — Fokus pada rekapitulasi kotak 2x2 status kehadiran KBM per kelas rombel dan analisa mendalam ketidakhadiran individu siswa.

---

## 2. Struktur 2-Tab Jurnal Mengajar

### A. Tab 1: `Riwayat Jurnal`
- **Filter & Pencarian Ringkas (`JurnalFilterCard`)**:
  - Dropdown **Bulan KBM** (`Semua Bulan` / `Juli 2026` s.d. `Juni 2027`).
  - Dropdown **Mata Pelajaran** (otomatis terkunci jika guru hanya mengampu 1 mapel).
  - Baris **Kelas Rombel** & **Pencarian Kata Kunci Materi/Refleksi** berdampingan agar hemat ruang vertikal.
- **Strip Ringkasan Kompak (`JurnalCompactSummaryBar`)**:
  - Menampilkan `X Sesi KBM • Y JP (Z Menit) • N Absen` beserta tombol pintas `Analisa Siswa` untuk berpindah ke Tab 2.
- **Daftar Kartu Jurnal (`JurnalItemCard`) & Paginasi (`JurnalPaginationBar`)**:
  - Menampilkan daftar sesi KBM beserta aksi **Detail**, **Edit**, dan **Hapus**.

### B. Tab 2: `Analisa Kelas & Siswa` (`JurnalAnalisaSection`)
1. **Filter Periode Bulan & Mata Pelajaran**:
   - Terhubung langsung (*synced*) dengan state filter utama sehingga guru dapat mengganti bulan (`November 2026`, `Semua Bulan`, dll.) atau mata pelajaran langsung dari Tab 2.
2. **Chip Pilihan Kelas Rombel (`Semua Kelas`, `Kelas 8A`, `Kelas 8B`, dst.)**:
   - Menampilkan chip horizontal untuk seluruh kelas yang diampu guru lengkap dengan badge jumlah sesi dan indikator jumlah siswa yang pernah absen (`Kelas 8A • 4 Sesi • 2 Absen`).
   - Mengetuk salah satu chip kelas akan langsung memfilter kotak 2x2 dan daftar analisa siswa khusus untuk kelas tersebut.
3. **Kotak 2x2 Rekap Status Kehadiran KBM (Seragam dengan Portal Siswa)**:
   - Menampilkan 4 kotak status tanpa badge persentase yang membingungkan:
     - **HADIR** (`X kali` — Hijau Emerald, siswa mengikuti KBM)
     - **IZIN / SAKIT** (`X kali` — Biru, dengan rincian `Izin: A • Sakit: B`)
     - **ALPA** (`X kali` — Merah, siswa alpa di gerbang pagi)
     - **TIDAK MENGIKUTI** (`X kali` — Oranye, siswa hadir di gerbang namun meninggalkan kelas / tidak mengikuti jam pelajaran)
4. **Perbandingan Kehadiran Per Kelas**:
   - Muncul ketika chip `Semua Kelas` aktif dan guru mengajar lebih dari 1 kelas.
   - Menampilkan kartu tiap kelas (`Kelas 8A`, `Kelas 8B`, dst.) dengan jumlah pertemuan, total JP, badge jumlah siswa pernah absen, dan 4 pill status (`Hadir`, `Izin/Sakit`, `Alpa`, `Tdk Ikut`).
5. **Analisa Kehadiran Individu Siswa**:
   - Dilengkapi tombol filter cepat:
     - `⚠️ Pernah Tidak Hadir (N)` — langsung menampilkan siswa yang memiliki catatan ketidakhadiran KBM, diurutkan dari jumlah **Tidak Mengikuti** dan **Alpa** tertinggi.
     - `Semua Siswa (M)` — menampilkan seluruh siswa di kelas terpilih.
   - Dilengkapi kolom pencarian nama siswa / NIS.
   - Setiap kartu siswa menampilkan:
     - Nama siswa, badge `Kelas 8A`, NIS, dan total pertemuan KBM yang tercatat.
     - 4 pill statistik individu (`Hadir`, `Izin/Sakit`, `Alpa`, `Tdk Ikut`).
     - **Riwayat Ketidakhadiran KBM**: daftar rincian tanggal (`Kamis, 05 November 2026`), jam pelajaran (`Jam ke 1 - 2 (2 JP)`), judul materi, badge status (`TIDAK MENGIKUTI` / `ALPA` / `SAKIT` / `IZIN`), serta catatan keterangan guru. Mengetuk baris riwayat akan membuka modal `SheetDetailJurnalKbm`.

---

## 3. Aturan Normalisasi Status Kehadiran KBM

Baik di Android maupun di Laravel Backend (`GuruJurnalMengajarController` & `JurnalMengajarList`), status kehadiran siswa pada setiap sesi jurnal dinormalisasi menggunakan aturan yang 100% konsisten dengan Portal Siswa:

- Jika `status_jurnal === 'hadir'` $\rightarrow$ **`hadir`** (*Hadir KBM*)
- Jika `status_jurnal === 'tidak_mengikuti'`:
  - Jika `status_gerbang_snapshot === 'sakit'` $\rightarrow$ **`sakit`** (*Sakit*)
  - Jika `status_gerbang_snapshot === 'izin'` $\rightarrow$ **`izin`** (*Izin*)
  - Jika `status_gerbang_snapshot === 'alpa'` $\rightarrow$ **`alpa`** (*Alpa*)
  - Selain itu (`hadir` / `telat` / `belum_absen` di gerbang tetapi tidak hadir di kelas) $\rightarrow$ **`tidak_mengikuti`** (*Tidak Mengikuti KBM*)

---

## 4. Struktur File Android Flutter (Hasil Refactoring)

Untuk menjaga agar tidak ada file kecil yang terfragmentasi maupun file *dead code*:

- [`lib/features/guru/screens/jurnal_mengajar_screen.dart`](file:///home/sutris-remote/Documents/projek-laravel/apk-android-presensi/lib/features/guru/screens/jurnal_mengajar_screen.dart)
  Orchestrator utama dengan `TabController(length: 2)`, `AppBar` action Cetak Laporan, `FloatingActionButton` Tulis Jurnal, serta pengelola data jurnal dan analitik.
- [`lib/features/guru/screens/widgets/jurnal_mengajar/sections/jurnal_filter_card.dart`](file:///home/sutris-remote/Documents/projek-laravel/apk-android-presensi/lib/features/guru/screens/widgets/jurnal_mengajar/sections/jurnal_filter_card.dart)
  Berisi komponen seksi Tab 1 secara terpadu: `JurnalFilterCard`, `JurnalCompactSummaryBar`, `JurnalEmptyState`, dan `JurnalPaginationBar`.
- [`lib/features/guru/screens/widgets/jurnal_mengajar/sections/jurnal_analisa_section.dart`](file:///home/sutris-remote/Documents/projek-laravel/apk-android-presensi/lib/features/guru/screens/widgets/jurnal_mengajar/sections/jurnal_analisa_section.dart)
  Berisi komponen lengkap Tab 2 (`JurnalAnalisaSection`): filter periode/mapel, chip kelas rombel, kotak 2x2 status KBM, perbandingan antar kelas, serta daftar analisa ketidakhadiran individu siswa.

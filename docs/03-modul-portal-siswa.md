# 🎒 03. Modul Portal Siswa & Orang Tua

Dokumen ini merinci cakupan fungsional, komponen UI, dan interaksi API untuk modul **Portal Siswa** pada aplikasi mobile Flutter.

---

## 📱 1. Fitur Utama Portal Siswa

### A. Kartu Pelajar Digital & Barcode ID
- **Komponen Utama**:
  - Foto resmi siswa dari database master sekolah.
  - Nama lengkap, NISN, NIK, dan Kelas aktif.
  - **Barcode Code 128**: Dihasilkan secara presisi oleh paket `barcode_widget` berbasis string NISN.
  - **QR Code**: Berisi string verifikasi identitas resmi.
- **Fitur Khusus**:
  - *Full Screen Card View*: Kartu dapat disentuh untuk mode layar penuh horizontal (landscape).
  - *High Contrast*: Latar belakang barcode dipastikan putih solid agar alat pemindai laser di gerbang sekolah dapat membaca dalam hitungan milidetik.

### B. Dasbor Ringkas & Status Hari Ini
- **Status Kehadiran Hari Ini**:
  - *Belum Hadir* (abu-abu)
  - *Hadir Tepat Waktu* (hijau) &mdash; menampilkan jam scan masuk.
  - *Terlambat* (kuning) &mdash; menampilkan durasi keterlambatan.
  - *Izin / Sakit* (biru)
- **Status Sholat Dhuhur Hari Ini**:
  - *Berjamaah* (hijau)
  - *Masbuk* (kuning)
  - *Berhalangan / Haid* (ungu - khusus siswi)
  - *Belum Dilaksanakan*

### C. Riwayat Presensi Bulanan
- Rekap persentase kehadiran bulanan (Total Hadir, Sakit, Izin, Terlambat, Alpa).
- Tampilan daftar riwayat harian berurutan dari tanggal terbaru ke terlama.

### D. Pengajuan Izin / Sakit Online
- Formulir pengajuan mandiri dari HP siswa atau orang tua:
  - Pilihan Jenis: **Sakit** atau **Izin**.
  - Tanggal Mulai s/d Tanggal Selesai.
  - Keterangan Alasan tertulis.
  - **Lampiran Bukti Foto**: Menggunakan `image_picker` (ambil langsung foto surat dokter atau surat izin dari orang tua).
- Pelacakan Status:
  - *Pending* (menunggu review wali kelas).
  - *Disetujui* (terverifikasi).
  - *Ditolak* (dengan catatan alasan dari wali kelas).

---

## 🔌 2. Pemetaan Endpoint API Siswa

| Fitur | Method | Endpoint Backend | Parameter / Body |
| :--- | :---: | :--- | :--- |
| Profil & Kartu | `GET` | `/api/v1/siswa/kartu` | - |
| Dasbor Hari Ini | `GET` | `/api/v1/siswa/dashboard` | - |
| Riwayat Bulanan | `GET` | `/api/v1/siswa/presensi/riwayat` | `?month=10&year=2026` |
| Daftar Izin | `GET` | `/api/v1/siswa/izin` | - |
| Kirim Izin Baru | `POST` | `/api/v1/siswa/izin` | `multipart/form-data` (jenis, start_date, end_date, keterangan, lampiran) |
| Laporan SPiKAP | `POST` | `/api/v1/siswa/spikap` | `kategori`, `deskripsi`, `is_anonim` |


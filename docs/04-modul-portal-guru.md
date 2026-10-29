# 👨‍🏫 04. Modul Portal Guru & Wali Kelas

Dokumen ini merinci cakupan fungsional, komponen UI, dan interaksi API untuk modul **Portal Guru & Wali Kelas** pada aplikasi mobile Flutter.

---

## 📱 1. Fitur Utama Portal Guru

### A. Dasbor Guru & Pemilihan Rombel
- Menampilkan daftar kelas yang diampu atau kelas binaan wali kelas (misal: *Kelas 7C*, *Kelas 8A*).
- Menampilkan statistik cepat kehadiran hari ini:
  - Jumlah siswa hadir, sakit, izin, alpa, dan persentase kehadiran rombel.

### B. Presensi Harian Kelas Cepat
- Daftar seluruh siswa dalam satu kelas.
- Tombol *Toggle Status* cepat: **[H] Hadir**, **[S] Sakit**, **[I] Izin**, **[A] Alpa**.
- **Tombol WhatsApp Ortu Instan**:
  - Di samping nama siswa yang belum hadir terdapat tombol hijau WhatsApp.
  - Memanfaatkan `url_launcher` untuk langsung membuka aplikasi WhatsApp di HP guru menuju nomor kontak orang tua dengan template pesan otomatis:
    *"Assalamu'alaikum, menginfokan bahwa ananda [Nama] hari ini belum tercatat hadir di kelas..."*
  - **Kelebihan**: Guru tidak perlu menyimpan ribuan nomor HP orang tua ke kontak HP pribadi.

### C. Presensi Sholat Dhuhur Berjamaah Massal
- Dirancang khusus untuk guru piket atau wali kelas saat mendampingi sholat dhuhur di mushola sekolah.
- **Tombol "Semua Jamaah"**: Mengisi status seluruh siswa menjadi *Jamaah* dalam 1 kali sentuh.
- **Filter Otomatis**:
  - Siswa non-Muslim otomatis disembunyikan/diberi label khusus agar tidak salah data.
  - Penyesuaian satu-klik bagi siswi yang *Berhalangan* (haid) atau siswa yang *Masbuk*.
- Mengirim data massal ke endpoint backend secara efisien dalam 1 request.

### D. Verifikasi & Approval Izin Masuk
- Menampilkan daftar permohonan izin dari siswa kelas binaan yang berstatus *Pending*.
- Guru dapat:
  1. Mengetuk nama siswa untuk melihat surat dokter / foto surat izin orang tua.
  2. Membaca alasan tertulis.
  3. Menekan tombol **Setujui** atau **Tolak** (disertai catatan penolakan).
  4. Status di HP siswa otomatis terupdate seketika.

---

## 🔌 2. Pemetaan Endpoint API Guru

| Fitur | Method | Endpoint Backend | Keterangan |
| :--- | :---: | :--- | :--- |
| Daftar Rombel | `GET` | `/api/v1/guru/classes` | Kelas binaan & mapel yang diampu |
| Presensi Kelas Hari Ini | `GET` | `/api/v1/guru/presensi/today` | Parameter: `?class_id=uuid` |
| Simpan Presensi Siswa | `POST` | `/api/v1/guru/presensi/update` | `student_id`, `status`, `notes` |
| Daftar Sholat Dhuhur | `GET` | `/api/v1/guru/sholat-dhuhur/today` | Parameter: `?class_id=uuid` |
| Simpan Sholat Massal | `POST` | `/api/v1/guru/sholat-dhuhur/bulk` | Array: `[{ student_id, status }]` |
| Daftar Izin Pending | `GET` | `/api/v1/guru/izin/pending` | Daftar izin butuh review wali kelas |
| Eksekusi Approval Izin | `POST` | `/api/v1/guru/izin/{id}/approve` | Body: `is_approved` (true/false), `notes` |


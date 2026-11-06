# 29 - Dokumentasi Prioritas Tab "Menunggu" pada Persetujuan Ijin Siswa (Portal Guru)

## 1. Latar Belakang Masalah
Sebelumnya, ketika Wali Kelas atau Guru BK membuka menu **Persetujuan Ijin Siswa** di Portal Guru:
1. **Default Tab Masih di `Semua` (`all`)**: Guru tidak langsung diarahkan ke daftar siswa yang membutuhkan persetujuan (`Menunggu` / `pending`).
2. **Ketidaksinkronan Badge `Menunggu` dengan Filter Bulan**: Angka metrik `Menunggu` dihitung dari seluruh Tahun Ajaran aktif (lintas bulan), sedangkan daftar permohonan di bawahnya terkunci oleh filter `Bulan Pengajuan` bulan berjalan (misal `November 2026`). Akibatnya, permohonan izin yang masih berstatus `pending` dari bulan sebelumnya tidak muncul di daftar.

---

## 2. Solusi & Perubahan yang Diterapkan

### A. Aplikasi Android (`apk-android-presensi`)
1. **[`lib/features/guru/screens/ijin_kehadiran_screen.dart`](../lib/features/guru/screens/ijin_kehadiran_screen.dart)**:
   - Mengubah state awal `_activeTab` menjadi `'pending'` (**Menunggu**) dan `_selectedMonthKey` menjadi `'all'` (**Semua Bulan**).
   - Saat guru berpindah ke tab **Menunggu** (baik melalui kartu metrik maupun segmented tab), filter bulan otomatis diset ke `'all'` agar seluruh pengajuan siswa yang belum diverifikasi lintas bulan langsung tampil.
   - Menghapus `IjinHeroBanner` dan memindahkan informasi tahun ajaran serta peran (`Wali Kelas & Guru BK`) ke subjudul `AppBar` agar daftar siswa yang menunggu izin langsung terlihat di layar atas tanpa perlu *scroll* jauh.
   - Menyesuaikan *empty state* khusus tab **Menunggu** (`Tidak Ada Permohonan Menunggu`) disertai tombol cepat **Lihat Semua Riwayat Izin**.
2. **[`lib/features/guru/screens/widgets/ijin/sections/ijin_segmented_tabs.dart`](../lib/features/guru/screens/widgets/ijin/sections/ijin_segmented_tabs.dart)**:
   - Mengubah urutan tab menjadi: **`Menunggu (badge)`** ➔ **`Semua`** ➔ **`Disetujui`** ➔ **`Ditolak`**.
3. **[`lib/features/guru/screens/widgets/ijin/sections/ijin_filter_card.dart`](../lib/features/guru/screens/widgets/ijin/sections/ijin_filter_card.dart)**:
   - Memastikan opsi **`Semua Bulan`** (`key: 'all'`) selalu tersedia di urutan pertama dropdown **Bulan Pengajuan**.

### B. Backend API & Web Portal Guru (`projek-absensi-barcode`)
1. **`app/Http/Controllers/Api/Mobile/GuruIjinKehadiranController.php`**:
   - Mengubah default parameter `status` menjadi `'pending'` dan `month` menjadi `'all'`.
   - Menambahkan opsi `['key' => 'all', 'label' => 'Semua Bulan']` pada `available_months`.
   - Menyinkronkan filter `academic_year_id` pada query daftar permohonan agar jumlah item pada daftar `Menunggu` selalu sama persis dengan angka pada kartu/badge `Menunggu`.
2. **`app/Livewire/PortalGuru/IjinKehadiranList.php` & `resources/views/livewire/portal-guru/ijin-kehadiran-list.blade.php`**:
   - Mengubah default `$filterStatus = 'pending'` dan `$filterMonth = ''` (Semua Bulan) saat halaman dibuka.
   - Menambahkan segmented tab cepat (`Menunggu Review`, `Semua`, `Disetujui`, `Ditolak`) beserta badge jumlah permohonan di atas tabel Web Portal Guru.

---

### C. Pop-up Pilihan Cepat Menu Pengajuan Ijin di Portal Siswa (`apk-android-presensi`)
1. **[`lib/features/siswa/screens/widgets/dashboard/grid/dashboard_siswa_menu_grid.dart`](../lib/features/siswa/screens/widgets/dashboard/grid/dashboard_siswa_menu_grid.dart)**:
   - Menambahkan komponen `DialogPilihanIjinSiswa` yang menampilkan 2 pilihan saat siswa menekan menu **2. Pengajuan Ijin Kehadiran**:
     1. **`Ajukan Ijin / Sakit Baru`** (Kartu Utama Bergradasi Rose) ➔ Langsung membuka `FormIjinSiswaScreen`.
     2. **`Lihat Riwayat Pengajuan`** (Kartu Sekunder + indikator badge `Menunggu`) ➔ Membuka daftar riwayat dan status verifikasi di `IjinKehadiranSiswaScreen`.
2. **[`lib/features/siswa/screens/dashboard_siswa_screen.dart`](../lib/features/siswa/screens/dashboard_siswa_screen.dart)**:
   - Mengubah `_navigateToIjinKehadiran()` untuk memunculkan `DialogPilihanIjinSiswa.show(...)` serta menyegarkan ringkasan dashboard (`_fetchSummary()`) setelah siswa kembali dari form maupun halaman riwayat.


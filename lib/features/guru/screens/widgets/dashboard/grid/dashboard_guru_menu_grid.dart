import 'package:flutter/material.dart';
import '../cards/portal_menu_box_card.dart';

/// Grid responsif 9 menu portal guru (1 kolom di HP, 3 kolom di Tablet)
class DashboardGuruMenuGrid extends StatelessWidget {
  final int kelasAmpuCount;
  final bool enableSholatDhuhur;
  final int jurnalHariIniCount;
  final int totalJurnalCount;
  final int pendingLeaveCount;
  final int approvedLeaveCount;
  final int rejectedLeaveCount;
  final int pendingKonsultasiCount;
  final int activeBooksCount;
  final int spikapCount;
  final int spikapDaruratCount;
  final bool canAccessSpikap;

  final VoidCallback onTapPresensi;
  final VoidCallback onTapSholat;
  final VoidCallback onTapJurnal;
  final VoidCallback onTapIjin;
  final VoidCallback onTapGuruWali;
  final VoidCallback onTapDataSiswa;
  final VoidCallback onTapSpikap;
  final VoidCallback onTapPerpustakaan;
  final VoidCallback onTapProfil;

  const DashboardGuruMenuGrid({
    super.key,
    required this.kelasAmpuCount,
    required this.enableSholatDhuhur,
    required this.jurnalHariIniCount,
    required this.totalJurnalCount,
    required this.pendingLeaveCount,
    required this.approvedLeaveCount,
    required this.rejectedLeaveCount,
    required this.pendingKonsultasiCount,
    required this.activeBooksCount,
    required this.spikapCount,
    required this.spikapDaruratCount,
    required this.canAccessSpikap,
    required this.onTapPresensi,
    required this.onTapSholat,
    required this.onTapJurnal,
    required this.onTapIjin,
    required this.onTapGuruWali,
    required this.onTapDataSiswa,
    required this.onTapSpikap,
    required this.onTapPerpustakaan,
    required this.onTapProfil,
  });

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      // MENU 1: Presensi
      PortalMenuBoxCard(
        number: 1,
        title: 'Presensi',
        description:
            'Pantau absensi harian siswa, matriks bulanan, input manual, kirim WA ortu, dan cetak laporan presensi kelas.',
        badgeText: '$kelasAmpuCount Kelas',
        icon: Icons.verified_user_outlined,
        accentColor: const Color(0xFF059669),
        primaryActionLabel: 'Buka Presensi Kelas',
        isReady: true,
        onTap: onTapPresensi,
      ),

      // MENU 2: Presensi Sholat Dhuhur
      if (enableSholatDhuhur)
        PortalMenuBoxCard(
          number: 2,
          title: 'Presensi Sholat Dhuhur',
          description:
              'Pencatatan kehadiran sholat dhuhur berjamaah, sinkron izin/alpa presensi pagi, serta rekapitulasi kepatuhan ibadah.',
          badgeText: 'Ibadah Berjamaah',
          icon: Icons.mosque_outlined,
          accentColor: const Color(0xFF0D9488),
          primaryActionLabel: 'Buka Presensi Sholat',
          isReady: true,
          onTap: onTapSholat,
        ),

      // MENU 3: Jurnal Mengajar
      PortalMenuBoxCard(
        number: 3,
        title: 'Jurnal Mengajar',
        description:
            'Dokumentasi materi pembelajaran harian, pencatatan kehadiran siswa per jam pelajaran, dan unduh rekap PDF.',
        badgeText: jurnalHariIniCount > 0
            ? '$jurnalHariIniCount Terisi Hari Ini'
            : '$totalJurnalCount Total Jurnal',
        icon: Icons.menu_book_rounded,
        accentColor: const Color(0xFF4F46E5),
        primaryActionLabel: 'Buka Jurnal Mengajar',
        isReady: true,
        onTap: onTapJurnal,
      ),

      // MENU 4: Persetujuan Ijin
      PortalMenuBoxCard(
        number: 4,
        title: 'Persetujuan Ijin',
        description:
            'Tinjau dan proses permohonan ijin atau sakit siswa (Diterima: $approvedLeaveCount • Ditolak: $rejectedLeaveCount • Menunggu: $pendingLeaveCount).',
        badgeText: pendingLeaveCount > 0
            ? '$pendingLeaveCount Pending'
            : 'Bersih',
        icon: Icons.assignment_turned_in_outlined,
        accentColor: const Color(0xFFE11D48),
        primaryActionLabel: 'Buka Persetujuan',
        isReady: true,
        onTap: onTapIjin,
      ),

      // MENU 5: Guru Wali (SI-WALI)
      PortalMenuBoxCard(
        number: 5,
        title: 'Guru Wali (SI-WALI)',
        description:
            'Kelola kelompok dampingan Permen 11/2025, tulis jurnal bimbingan, ruang aman bercerita, dan pantau rekam jejak murid.',
        badgeText: pendingKonsultasiCount > 0
            ? '$pendingKonsultasiCount Menunggu Cerita'
            : 'Permen 11/2025',
        icon: Icons.favorite_border_rounded,
        accentColor: const Color(0xFF2563EB),
        primaryActionLabel: 'Buka SI-WALI',
        isReady: true,
        onTap: onTapGuruWali,
      ),

      // MENU 6: Data Siswa
      PortalMenuBoxCard(
        number: 6,
        title: 'Data Siswa',
        description:
            'Kelola data siswa binaan Anda, lihat informasi kontak orang tua, dan pratinjau kartu pelajar QR/Barcode.',
        badgeText: 'QR & Barcode',
        icon: Icons.badge_outlined,
        accentColor: const Color(0xFF7C3AED),
        primaryActionLabel: 'Buka Data Siswa',
        isReady: true,
        onTap: onTapDataSiswa,
      ),

      // MENU 7: SPIKAP
      PortalMenuBoxCard(
        number: 7,
        title: 'SPIKAP (Anti-Perundungan)',
        description:
            'Layanan penanganan perundungan siswa, pantau aduan masuk, dan investigasi tindak lanjut.',
        badgeText: !canAccessSpikap
            ? 'Akses Khusus (BK/Wali/KS)'
            : (spikapDaruratCount > 0
                ? '$spikapDaruratCount Darurat 🚨'
                : '$spikapCount Laporan'),
        icon: Icons.shield_outlined,
        accentColor: !canAccessSpikap
            ? const Color(0xFF64748B)
            : const Color(0xFFDC2626),
        primaryActionLabel: !canAccessSpikap
            ? 'Lihat Ketentuan Akses'
            : 'Buka SPIKAP',
        isReady: true,
        onTap: onTapSpikap,
      ),

      // MENU 8: Perpustakaan
      PortalMenuBoxCard(
        number: 8,
        title: 'Perpustakaan',
        description:
            'Cari koleksi katalog perpustakaan sekolah, pantau pinjaman buku aktif, riwayat kunjungan, dan peminjaman siswa kelas binaan.',
        badgeText: activeBooksCount > 0
            ? '$activeBooksCount Dipinjam'
            : 'Katalog & Koleksi',
        icon: Icons.local_library_outlined,
        accentColor: const Color(0xFFD97706),
        primaryActionLabel: 'Buka Perpustakaan',
        isReady: true,
        onTap: onTapPerpustakaan,
      ),

      // MENU 9: Profil Saya
      PortalMenuBoxCard(
        number: 9,
        title: 'Profil Saya',
        description:
            'Lihat informasi NIP, penugasan akademik, perbarui foto, email, tautan microsite, dan ganti kata sandi akun.',
        badgeText: 'Biodata & Akun',
        icon: Icons.person_outline_rounded,
        accentColor: const Color(0xFF0284C7),
        primaryActionLabel: 'Lihat Profil',
        isReady: true,
        onTap: onTapProfil,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Mode Smartphone Portrait: 1 Kolom
        if (constraints.maxWidth < 650) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: cards,
          );
        }

        // Mode Tablet / Layar Lebar: Grid 3 Kolom per Baris
        const int crossAxisCount = 3;
        final List<Widget> rows = [];
        for (int i = 0; i < cards.length; i += crossAxisCount) {
          final List<Widget> rowItems = [];
          for (int j = 0; j < crossAxisCount; j++) {
            if (i + j < cards.length) {
              rowItems.add(
                Expanded(child: cards[i + j]),
              );
            } else {
              rowItems.add(const Expanded(child: SizedBox.shrink()));
            }
            if (j < crossAxisCount - 1) {
              rowItems.add(const SizedBox(width: 12));
            }
          }
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: rowItems,
              ),
            ),
          );
          rows.add(const SizedBox(height: 12));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
  }
}

/// Pop-up Dialog Pilihan Cepat Menu Jurnal Mengajar (Tambah Jurnal Baru vs Lihat Riwayat Jurnal)
class DialogPilihanJurnalMengajar extends StatelessWidget {
  final int jurnalHariIniCount;
  final int totalJurnalCount;
  final VoidCallback onTambahJurnal;
  final VoidCallback onLihatJurnal;

  const DialogPilihanJurnalMengajar({
    super.key,
    required this.jurnalHariIniCount,
    required this.totalJurnalCount,
    required this.onTambahJurnal,
    required this.onLihatJurnal,
  });

  static Future<void> show(
    BuildContext context, {
    required int jurnalHariIniCount,
    required int totalJurnalCount,
    required VoidCallback onTambahJurnal,
    required VoidCallback onLihatJurnal,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => DialogPilihanJurnalMengajar(
        jurnalHariIniCount: jurnalHariIniCount,
        totalJurnalCount: totalJurnalCount,
        onTambahJurnal: () {
          Navigator.of(ctx).pop();
          onTambahJurnal();
        },
        onLihatJurnal: () {
          Navigator.of(ctx).pop();
          onLihatJurnal();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Pop-up
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Color(0xFF4F46E5),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jurnal Mengajar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          jurnalHariIniCount > 0
                              ? '$jurnalHariIniCount jurnal terisi hari ini • $totalJurnalCount total'
                              : '$totalJurnalCount total jurnal tercatat',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Tutup',
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 16),

              const Text(
                'Pilih aksi yang ingin Anda lakukan:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),

              const SizedBox(height: 12),

              // Opsi 1: Tambah / Tulis Jurnal Baru (Utama)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTambahJurnal,
                  borderRadius: BorderRadius.circular(18),
                  child: Ink(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4338CA), Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.edit_note_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tambah Jurnal Baru',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Langsung isi materi & presensi KBM kelas',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Opsi 2: Lihat Riwayat Jurnal
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onLihatJurnal,
                  borderRadius: BorderRadius.circular(18),
                  child: Ink(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.fact_check_outlined,
                            color: Color(0xFF4F46E5),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lihat Riwayat Jurnal',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Daftar jurnal mengajar, edit, & cetak rekap',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Color(0xFF64748B),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



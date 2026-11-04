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


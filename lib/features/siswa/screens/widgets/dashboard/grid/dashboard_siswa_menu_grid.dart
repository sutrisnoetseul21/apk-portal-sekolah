import 'package:flutter/material.dart';
import '../../models/siswa_dashboard_model.dart';
import '../cards/siswa_menu_box_card.dart';

/// Grid responsif 7 menu portal siswa (1 kolom di HP, 3 kolom di Tablet)
class DashboardSiswaMenuGrid extends StatelessWidget {
  final SiswaDashboardSummary? summary;
  final VoidCallback onTapPresensi;
  final VoidCallback onTapIjin;
  final VoidCallback onTapGuruWali;
  final VoidCallback onTapSpikap;
  final VoidCallback onTapPerpustakaan;
  final VoidCallback onTapKartu;
  final VoidCallback onTapProfil;

  const DashboardSiswaMenuGrid({
    super.key,
    required this.summary,
    required this.onTapPresensi,
    required this.onTapIjin,
    required this.onTapGuruWali,
    required this.onTapSpikap,
    required this.onTapPerpustakaan,
    required this.onTapKartu,
    required this.onTapProfil,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      // MENU 1: Presensi
      SiswaMenuBoxCard(
        number: 1,
        title: 'Presensi & Akademik',
        description:
            'Pantau catatan kehadiran harian, jam scan masuk/pulang, sholat dhuhur, dan matriks kalender bulanan.',
        badgeText: 'Kalender & Rekap',
        icon: Icons.calendar_month_rounded,
        accentColor: const Color(0xFF059669),
        primaryActionLabel: 'Buka Presensi',
        onTap: onTapPresensi,
      ),

      // MENU 2: Pengajuan Ijin Kehadiran
      SiswaMenuBoxCard(
        number: 2,
        title: 'Pengajuan Ijin Kehadiran',
        description:
            'Kirim permohonan ijin atau sakit secara online dilengkapi foto surat dokter (kompresi otomatis hemat kuota).',
        badgeText: (summary?.quickStats.pendingLeavesCount ?? 0) > 0
            ? '${summary!.quickStats.pendingLeavesCount} Menunggu'
            : 'Ijin / Sakit Online',
        icon: Icons.assignment_outlined,
        accentColor: const Color(0xFFE11D48),
        primaryActionLabel: 'Ajukan Ijin',
        onTap: onTapIjin,
      ),

      // MENU 3: SI-WALI
      SiswaMenuBoxCard(
        number: 3,
        title: 'Guru Wali (SI-WALI)',
        description:
            'Ruang aman bercerita dan konsultasi dengan Guru Wali asuh Anda, serta info bimbingan klasikal kelas.',
        badgeText: (summary?.quickStats.activeCounselingCount ?? 0) > 0
            ? '${summary!.quickStats.activeCounselingCount} Sesi Aktif'
            : 'Ruang Cerita & Bimbingan',
        icon: Icons.favorite_border_rounded,
        accentColor: const Color(0xFF2563EB),
        primaryActionLabel: 'Buka SI-WALI',
        onTap: onTapGuruWali,
      ),

      // MENU 4: SPIKAP
      SiswaMenuBoxCard(
        number: 4,
        title: 'SPIKAP (Karakter & Lapor)',
        description:
            'Layanan pengaduan anti-perundungan aman (opsi anonim) dan transparansi buku saku catatan karakter.',
        badgeText: (summary?.quickStats.spikapReportsCount ?? 0) > 0
            ? '${summary!.quickStats.spikapReportsCount} Laporan'
            : 'Anti-Perundungan',
        icon: Icons.shield_outlined,
        accentColor: const Color(0xFFDC2626),
        primaryActionLabel: 'Buka SPIKAP',
        onTap: onTapSpikap,
      ),

      // MENU 5: Perpustakaan
      SiswaMenuBoxCard(
        number: 5,
        title: 'Perpustakaan Siswa',
        description:
            'Cek status buku yang sedang Anda pinjam, riwayat pengembalian, dan histori kunjungan perpustakaan.',
        badgeText: (summary?.quickStats.activeLoansCount ?? 0) > 0
            ? '${summary!.quickStats.activeLoansCount} Buku Dipinjam'
            : 'Pinjaman & Literasi',
        icon: Icons.local_library_outlined,
        accentColor: const Color(0xFFD97706),
        primaryActionLabel: 'Buka Perpustakaan',
        onTap: onTapPerpustakaan,
      ),

      // MENU 6: Kartu Pelajar & Cetak PDF
      SiswaMenuBoxCard(
        number: 6,
        title: 'Kartu Pelajar & Unduh PDF',
        description:
            'Tampilan kartu barcode Code 128 resmi sekolah dan fitur unduh berkas PDF kartu pelajar siap cetak.',
        badgeText: 'Barcode & Cetak PDF',
        icon: Icons.badge_outlined,
        accentColor: const Color(0xFF7C3AED),
        primaryActionLabel: 'Lihat Kartu PDF',
        onTap: onTapKartu,
      ),

      // MENU 7: Profil Saya
      SiswaMenuBoxCard(
        number: 7,
        title: 'Profil Saya',
        description:
            'Lihat biodata resmi, data orang tua/wali, perbarui nomor HP WhatsApp, dan ganti kata sandi akun.',
        badgeText: 'Biodata & Sandi',
        icon: Icons.person_outline_rounded,
        accentColor: const Color(0xFF0284C7),
        primaryActionLabel: 'Buka Profil',
        onTap: onTapProfil,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 650) {
          // Smartphone: 1 Kolom
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: cards,
          );
        }

        // Tablet / Layar Lebar: 3 Kolom per Baris
        const int crossAxisCount = 3;
        final List<Widget> rows = [];
        for (int i = 0; i < cards.length; i += crossAxisCount) {
          final List<Widget> rowItems = [];
          for (int j = 0; j < crossAxisCount; j++) {
            if (i + j < cards.length) {
              rowItems.add(Expanded(child: cards[i + j]));
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


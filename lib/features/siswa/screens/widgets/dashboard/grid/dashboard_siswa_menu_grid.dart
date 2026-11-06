import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_dashboard_model.dart';
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

/// Pop-up Dialog Pilihan Cepat Menu Pengajuan Ijin Kehadiran Siswa
/// (Ajukan Ijin / Sakit Baru vs Lihat Riwayat Pengajuan)
class DialogPilihanIjinSiswa extends StatelessWidget {
  final int pendingLeavesCount;
  final VoidCallback onAjukanIjinBaru;
  final VoidCallback onLihatRiwayat;

  const DialogPilihanIjinSiswa({
    super.key,
    required this.pendingLeavesCount,
    required this.onAjukanIjinBaru,
    required this.onLihatRiwayat,
  });

  static Future<void> show(
    BuildContext context, {
    required int pendingLeavesCount,
    required VoidCallback onAjukanIjinBaru,
    required VoidCallback onLihatRiwayat,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => DialogPilihanIjinSiswa(
        pendingLeavesCount: pendingLeavesCount,
        onAjukanIjinBaru: () {
          Navigator.of(ctx).pop();
          onAjukanIjinBaru();
        },
        onLihatRiwayat: () {
          Navigator.of(ctx).pop();
          onLihatRiwayat();
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
                      color: const Color(0xFFFFE4E6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.assignment_outlined,
                      color: Color(0xFFE11D48),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pengajuan Ijin Kehadiran',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pendingLeavesCount > 0
                              ? '$pendingLeavesCount permohonan sedang menunggu verifikasi'
                              : 'Ijin & sakit online terintegrasi presensi kelas',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: pendingLeavesCount > 0
                                ? const Color(0xFFD97706)
                                : const Color(0xFF64748B),
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
                'Pilih aksi yang ingin kamu lakukan:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),

              const SizedBox(height: 12),

              // Opsi 1: Ajukan Ijin / Sakit Baru (Utama)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onAjukanIjinBaru,
                  borderRadius: BorderRadius.circular(18),
                  child: Ink(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFBE123C), Color(0xFFE11D48)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE11D48).withValues(alpha: 0.25),
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
                            Icons.add_task_rounded,
                            color: Colors.white,
                            size: 23,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ajukan Ijin / Sakit Baru',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Isi formulir permohonan & unggah surat bukti',
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

              // Opsi 2: Lihat Riwayat Pengajuan
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onLihatRiwayat,
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
                            color: const Color(0xFFFFE4E6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.history_edu_rounded,
                            color: Color(0xFFE11D48),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Flexible(
                                    child: Text(
                                      'Lihat Riwayat Pengajuan',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ),
                                  if (pendingLeavesCount > 0) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '$pendingLeavesCount Menunggu',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFD97706),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Pantau status verifikasi Wali Kelas & riwayat ijin',
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


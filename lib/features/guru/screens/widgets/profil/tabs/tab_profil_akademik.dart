import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/guru_profil_model.dart';

/// Tab 2: Informasi Penugasan Akademik Resmi Pendidik
class TabProfilAkademik extends StatelessWidget {
  final GuruProfilData data;

  const TabProfilAkademik({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Card Notice Administrator
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFFD97706),
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Master Data Akademik Terpusat',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Penugasan Wali Kelas, Mata Pelajaran, dan NIP dikelola langsung oleh Administrator Kurikulum sekolah.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFB45309),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Card 1: Penugasan Wali Kelas
        _buildAcademicCard(
          icon: Icons.groups_rounded,
          iconColor: const Color(0xFF059669),
          title: 'Penugasan Wali Kelas',
          badgeText: data.akademik.isWaliKelas ? 'AKTIF' : 'NON-WALI',
          badgeBgColor: data.akademik.isWaliKelas
              ? const Color(0xFFECFDF5)
              : const Color(0xFFF1F5F9),
          badgeTextColor: data.akademik.isWaliKelas
              ? const Color(0xFF047857)
              : const Color(0xFF64748B),
          content: data.akademik.kelasWali.isNotEmpty
              ? Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: data.akademik.kelasWali
                      .map(
                        (k) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_outline_rounded,
                                size: 14,
                                color: Color(0xFF059669),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Kelas $k',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF065F46),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                )
              : const Text(
                  'Tidak bertugas sebagai Wali Kelas pada tahun ajaran aktif ini.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
        ),

        // Card 2: Akses Kelas Pantau BK (Jika ada)
        if (data.akademik.kelasPantau.isNotEmpty) ...[
          const SizedBox(height: 14),
          _buildAcademicCard(
            icon: Icons.visibility_rounded,
            iconColor: const Color(0xFF2563EB),
            title: 'Akses Kelas Pantau (BK)',
            badgeText: '${data.akademik.kelasPantau.length} KELAS',
            badgeBgColor: const Color(0xFFEFF6FF),
            badgeTextColor: const Color(0xFF1D4ED8),
            content: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: data.akademik.kelasPantau
                  .map(
                    (kp) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Text(
                        'Kelas $kp',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E40AF),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],

        const SizedBox(height: 14),

        // Card 3: Mata Pelajaran yang Diampu
        _buildAcademicCard(
          icon: Icons.menu_book_rounded,
          iconColor: const Color(0xFF7C3AED),
          title: 'Mata Pelajaran yang Diampu',
          badgeText: '${data.akademik.mapelDiampu.length} MAPEL',
          badgeBgColor: const Color(0xFFF5F3FF),
          badgeTextColor: const Color(0xFF6D28D9),
          content: data.akademik.mapelDiampu.isNotEmpty
              ? Column(
                  children: data.akademik.mapelDiampu.map((m) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDE9FE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.bookmark_outline_rounded,
                              size: 15,
                              color: Color(0xFF7C3AED),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              m,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
              : const Text(
                  'Belum ada mata pelajaran terdaftar pada tahun ajaran ini.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
        ),

        // Card 4: Jabatan & Tugas Tambahan (Jika ada)
        if (data.akademik.jabatanAktif.isNotEmpty) ...[
          const SizedBox(height: 14),
          _buildAcademicCard(
            icon: Icons.workspace_premium_rounded,
            iconColor: const Color(0xFFD97706),
            title: 'Jabatan & Tugas Tambahan',
            badgeText: 'STRUKTURAL',
            badgeBgColor: const Color(0xFFFEF3C7),
            badgeTextColor: const Color(0xFFB45309),
            content: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: data.akademik.jabatanAktif
                  .map(
                    (j) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Color(0xFFD97706),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            j,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }

  static Widget _buildAcademicCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String badgeText,
    required Color badgeBgColor,
    required Color badgeTextColor,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeTextColor.withOpacity(0.2)),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          content,
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/perpustakaan_models.dart';

/// Banner Header Gradien Modern Perpustakaan Portal Guru
class PerpustakaanHeaderBanner extends StatelessWidget {
  final PerpustakaanSummary summary;
  final bool isLoadingSummary;

  const PerpustakaanHeaderBanner({
    super.key,
    required this.summary,
    required this.isLoadingSummary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris Atas: Badge Portal Guru
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_stories_rounded,
                        color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Portal Guru',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'T.A. Aktif',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Judul & Deskripsi
          Text(
            'Koleksi & Sirkulasi Perpustakaan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cari buku, pantau pinjaman pribadi, dan pantau riwayat pinjaman siswa di kelas yang Anda ampu.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 18),

          // Quick KPI Cards
          Row(
            children: [
              _buildKpiCard(
                label: 'Koleksi Judul',
                value: summary.totalBukuCount.toString(),
                icon: Icons.menu_book_rounded,
              ),
              const SizedBox(width: 8),
              _buildKpiCard(
                label: 'Stok Tersedia',
                value: summary.totalEksemplarTersedia.toString(),
                icon: Icons.check_circle_outline_rounded,
              ),
              const SizedBox(width: 8),
              _buildKpiCard(
                label: 'Pinjaman Anda',
                value: summary.pinjamanAktifCount.toString(),
                icon: Icons.bookmark_added_rounded,
                isHighlight: summary.pinjamanAktifCount > 0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String label,
    required String value,
    required IconData icon,
    bool isHighlight = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isHighlight
              ? const Color(0xFFFEF3C7).withValues(alpha: 0.95)
              : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isHighlight
                ? const Color(0xFFF59E0B)
                : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isHighlight ? const Color(0xFFB45309) : Colors.white70,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isHighlight
                          ? const Color(0xFFB45309)
                          : Colors.white.withValues(alpha: 0.85),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isLoadingSummary ? '...' : value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isHighlight ? const Color(0xFF92400E) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


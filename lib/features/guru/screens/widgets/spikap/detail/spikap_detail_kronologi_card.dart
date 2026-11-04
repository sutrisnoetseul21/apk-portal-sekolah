import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/models/spikap_models.dart';

/// Card kronologi & uraian kejadian kasus SPIKAP
class SpikapDetailKronologiCard extends StatelessWidget {
  final SpikapDetailLaporan laporan;

  const SpikapDetailKronologiCard({
    super.key,
    required this.laporan,
  });

  Widget _buildMetaTag({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.description_outlined,
                size: 16,
                color: Color(0xFF7C3AED),
              ),
              const SizedBox(width: 6),
              Text(
                'Kronologi & Uraian Kejadian',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF475569),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Metadata Kejadian
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMetaTag(
                icon: Icons.category_outlined,
                label: laporan.jenisLabel,
                color: const Color(0xFF7C3AED),
                bgColor: const Color(0xFFF5F3FF),
              ),
              _buildMetaTag(
                icon: Icons.location_on_outlined,
                label: laporan.lokasiKejadian,
                color: const Color(0xFF0284C7),
                bgColor: const Color(0xFFE0F2FE),
              ),
              if (laporan.waktuKejadian != null)
                _buildMetaTag(
                  icon: Icons.access_time_rounded,
                  label: laporan.waktuKejadian!,
                  color: const Color(0xFFD97706),
                  bgColor: const Color(0xFFFEF3C7),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Teks Uraian Kejadian
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              laporan.uraianKejadian,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                height: 1.6,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),

          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Diterima sistem: ${laporan.createdAt ?? '-'}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              if (laporan.lastHandledByName != null)
                Text(
                  'Penangan: ${laporan.lastHandledByName}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2563EB),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}


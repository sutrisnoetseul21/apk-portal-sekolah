import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/models/data_siswa_filter_model.dart';

/// Card ringkasan statistik rombel data siswa (Total, Laki-laki, Perempuan, Barcode)
class DataSiswaStatsCard extends StatelessWidget {
  final StudentRombelStats stats;

  const DataSiswaStatsCard({
    super.key,
    required this.stats,
  });

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', '${stats.totalStudents}', const Color(0xFF0F172A)),
          _buildStatItem('Laki-laki', '${stats.lakiLaki}', const Color(0xFF2563EB)),
          _buildStatItem('Perempuan', '${stats.perempuan}', const Color(0xFFDB2777)),
          _buildStatItem(
            'Barcode',
            '${stats.persenBerbarcode}%',
            stats.persenBerbarcode >= 80
                ? const Color(0xFF10B981)
                : const Color(0xFFD97706),
          ),
        ],
      ),
    );
  }
}


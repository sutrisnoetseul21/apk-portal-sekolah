import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/models/spikap_models.dart';

/// Grid 4 metrik analitik SPIKAP (Total, Darurat, Proses, Selesai)
class SpikapAnalitikMetrikCards extends StatelessWidget {
  final SpikapAnalitikData data;

  const SpikapAnalitikMetrikCards({
    super.key,
    required this.data,
  });

  Widget _buildMetricItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      children: [
        _buildMetricItem(
          label: 'Total Laporan',
          value: data.totalLaporan.toString(),
          icon: Icons.assignment_outlined,
          color: const Color(0xFF0284C7),
          bgColor: const Color(0xFFE0F2FE),
        ),
        _buildMetricItem(
          label: '🚨 Kasus Darurat',
          value: data.totalDarurat.toString(),
          icon: Icons.warning_rounded,
          color: const Color(0xFFDC2626),
          bgColor: const Color(0xFFFEE2E2),
        ),
        _buildMetricItem(
          label: 'Sedang Diproses',
          value: data.totalProses.toString(),
          icon: Icons.hourglass_top_rounded,
          color: const Color(0xFFD97706),
          bgColor: const Color(0xFFFEF3C7),
        ),
        _buildMetricItem(
          label: 'Selesai Ditangani',
          value: data.totalSelesai.toString(),
          icon: Icons.check_circle_outline_rounded,
          color: const Color(0xFF059669),
          bgColor: const Color(0xFFD1FAE5),
        ),
      ],
    );
  }
}


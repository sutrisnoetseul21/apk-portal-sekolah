import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/models/spikap_models.dart';

/// 4 KPI Stat Cards untuk Dasbor SPIKAP Guru
class SpikapKpiGrid extends StatelessWidget {
  final SpikapKpiStats stats;
  final String selectedStatus;
  final String selectedSifat;
  final VoidCallback onReset;
  final ValueChanged<String> onToggleStatus;
  final ValueChanged<String> onToggleSifat;

  const SpikapKpiGrid({
    super.key,
    required this.stats,
    required this.selectedStatus,
    required this.selectedSifat,
    required this.onReset,
    required this.onToggleStatus,
    required this.onToggleSifat,
  });

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    bool isUrgent = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUrgent ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
            width: isUrgent ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isUrgent
                  ? const Color(0xFFDC2626).withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.02),
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
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isUrgent ? const Color(0xFFDC2626) : const Color(0xFF64748B),
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
                color: isUrgent ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
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
        _buildKpiCard(
          title: 'Total Laporan',
          value: stats.total.toString(),
          icon: Icons.shield_outlined,
          color: const Color(0xFF475569),
          bgColor: const Color(0xFFF1F5F9),
          onTap: onReset,
        ),
        _buildKpiCard(
          title: 'Laporan Darurat',
          value: stats.darurat.toString(),
          icon: Icons.warning_rounded,
          color: const Color(0xFFDC2626),
          bgColor: const Color(0xFFFEE2E2),
          isUrgent: stats.darurat > 0,
          onTap: () => onToggleSifat('darurat'),
        ),
        _buildKpiCard(
          title: 'Perlu Penanganan',
          value: stats.aktif.toString(),
          icon: Icons.hourglass_top_rounded,
          color: const Color(0xFFD97706),
          bgColor: const Color(0xFFFEF3C7),
          onTap: () => onToggleStatus('dalam_investigasi'),
        ),
        _buildKpiCard(
          title: 'Tuntas / Selesai',
          value: stats.selesai.toString(),
          icon: Icons.check_circle_outline_rounded,
          color: const Color(0xFF059669),
          bgColor: const Color(0xFFD1FAE5),
          onTap: () => onToggleStatus('selesai'),
        ),
      ],
    );
  }
}


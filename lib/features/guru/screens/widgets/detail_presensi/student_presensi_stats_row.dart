import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

/// Row kartu statistik ringkas presensi siswa (Hadir, Telat, Izin, Sakit, Alpa)
class StudentPresensiStatsRow extends StatelessWidget {
  final Map<String, dynamic> stats;

  const StudentPresensiStatsRow({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildMiniStatCard('Hadir', '${stats['H'] ?? 0}', const Color(0xFF10B981)),
        const SizedBox(width: 8),
        _buildMiniStatCard('Telat', '${stats['T'] ?? 0}', const Color(0xFFF59E0B)),
        const SizedBox(width: 8),
        _buildMiniStatCard('Izin', '${stats['I'] ?? 0}', const Color(0xFF3B82F6)),
        const SizedBox(width: 8),
        _buildMiniStatCard('Sakit', '${stats['S'] ?? 0}', const Color(0xFF8B5CF6)),
        const SizedBox(width: 8),
        _buildMiniStatCard('Alpa', '${stats['A'] ?? 0}', const Color(0xFFEF4444)),
      ],
    );
  }

  Widget _buildMiniStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

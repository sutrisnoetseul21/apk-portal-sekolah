import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_sholat_model.dart';

/// Kartu ringkasan statistik kehadiran sholat dhuhur bulanan siswa
class SholatSiswaStatsCard extends StatelessWidget {
  final SiswaSholatMonthlyStats stats;

  const SholatSiswaStatsCard({
    super.key,
    required this.stats,
  });

  Widget _buildStatPill(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F766E), // Teal 700
            Color(0xFF0D9488), // Teal 600
            Color(0xFF14B8A6), // Teal 500
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kepatuhan Sholat Berjamaah',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${stats.attendancePercentage}%',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${stats.totalBerjamaah} dari ${stats.effectiveDays} Hari',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mosque_rounded,
                  size: 28,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatPill('Berjamaah', '${stats.totalBerjamaah}',
                    const Color(0xFF6EE7B7)),
                Container(
                    height: 24,
                    width: 1,
                    color: Colors.white.withValues(alpha: 0.2)),
                _buildStatPill(
                    'Masbuk', '${stats.totalMasbuk}', const Color(0xFFFDE68A)),
                Container(
                    height: 24,
                    width: 1,
                    color: Colors.white.withValues(alpha: 0.2)),
                _buildStatPill('Ijin/Haid', '${stats.totalIjin}',
                    const Color(0xFFDDD6FE)),
                Container(
                    height: 24,
                    width: 1,
                    color: Colors.white.withValues(alpha: 0.2)),
                _buildStatPill('Alpha', '${stats.totalTidakHadir}',
                    const Color(0xFFFCA5A5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

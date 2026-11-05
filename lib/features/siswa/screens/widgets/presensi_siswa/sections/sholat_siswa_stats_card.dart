import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';
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

/// Section daftar riwayat catatan ibadah sholat dhuhur terbaru siswa
class SholatSiswaRecentActivity extends StatelessWidget {
  final List<SiswaSholatRecentActivity> activities;

  const SholatSiswaRecentActivity({
    super.key,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history_rounded, size: 18, color: Color(0xFF0D9488)),
              SizedBox(width: 8),
              Text(
                'Catatan Ibadah Terbaru',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 20, color: Color(0xFFF1F5F9)),
            itemBuilder: (ctx, idx) {
              final item = activities[idx];
              Color dotColor = const Color(0xFF0D9488);
              Color badgeBg = const Color(0xFFCCFBF1);
              Color badgeFg = const Color(0xFF0F766E);

              switch (item.status) {
                case 'berjamaah':
                  dotColor = const Color(0xFF0D9488);
                  badgeBg = const Color(0xFFCCFBF1);
                  badgeFg = const Color(0xFF0F766E);
                  break;
                case 'masbuk':
                  dotColor = const Color(0xFFD97706);
                  badgeBg = const Color(0xFFFEF3C7);
                  badgeFg = const Color(0xFFB45309);
                  break;
                case 'halangan':
                case 'haid':
                  dotColor = const Color(0xFF7C3AED);
                  badgeBg = const Color(0xFFF3E8FF);
                  badgeFg = const Color(0xFF6D28D9);
                  break;
                case 'ijin':
                case 'izin':
                case 'sakit':
                  dotColor = const Color(0xFF2563EB);
                  badgeBg = const Color(0xFFEFF6FF);
                  badgeFg = const Color(0xFF1D4ED8);
                  break;
                case 'tidak_hadir':
                  dotColor = const Color(0xFFDC2626);
                  badgeBg = const Color(0xFFFEE2E2);
                  badgeFg = const Color(0xFFB91C1C);
                  break;
                default:
                  dotColor = const Color(0xFF64748B);
                  badgeBg = const Color(0xFFF1F5F9);
                  badgeFg = const Color(0xFF64748B);
              }

              return Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.formattedDate,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (item.note != null && item.note!.isNotEmpty)
                          Text(
                            item.note!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item.statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: badgeFg,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

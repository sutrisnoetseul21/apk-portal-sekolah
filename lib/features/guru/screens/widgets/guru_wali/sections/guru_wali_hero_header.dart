import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/models/guru_wali_dashboard_model.dart';

/// Hero Header Summary Card Guru Wali (SI-WALI)
class GuruWaliHeroHeader extends StatelessWidget {
  final GuruWaliDashboardData data;
  final String defaultTeacherName;

  const GuruWaliHeroHeader({
    super.key,
    required this.data,
    required this.defaultTeacherName,
  });

  @override
  Widget build(BuildContext context) {
    final kelompokName = data.kelompok?.namaKelompok ?? 'Kelompok Asuh';
    final teacherName = data.teacher?.name ?? defaultTeacherName;
    final stats = data.statistik;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge Permendikdasmen No. 11/2025
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded, size: 12, color: Colors.white),
                SizedBox(width: 5),
                Text(
                  'SI-WALI • Permendikdasmen No. 11/2025',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Nama Kelompok & Guru
          Text(
            kelompokName,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Pembimbing: $teacherName • 2 JP/Minggu',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 14),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),

          // 4 Metric Mini Stat Cards
          Row(
            children: [
              _buildMetricCard(
                label: 'Siswa Asuh',
                value: '${stats.totalSiswaAktif}',
                unit: 'anak',
                valueColor: Colors.white,
              ),
              const SizedBox(width: 8),
              _buildMetricCard(
                label: 'Didampingi',
                value: '${stats.totalDidampingiBulanIni}',
                unit: '/ ${stats.totalSiswaAktif}',
                valueColor: const Color(0xFF6EE7B7), // Emerald
              ),
              const SizedBox(width: 8),
              _buildMetricCard(
                label: 'Kepatuhan',
                value: '${stats.persenKepatuhan}%',
                unit: data.bulanIni,
                valueColor: stats.persenKepatuhan >= 100
                    ? const Color(0xFF6EE7B7)
                    : (stats.persenKepatuhan >= 50
                        ? const Color(0xFFFDE047)
                        : const Color(0xFFFCA5A5)),
              ),
              const SizedBox(width: 8),
              _buildMetricCard(
                label: 'Cerita Masuk',
                value: '${stats.pendingKonsultasiCount}',
                unit: 'respon',
                valueColor: stats.pendingKonsultasiCount > 0
                    ? const Color(0xFFFCA5A5)
                    : Colors.white70,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required String unit,
    required Color valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: valueColor,
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    unit,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 8.5,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


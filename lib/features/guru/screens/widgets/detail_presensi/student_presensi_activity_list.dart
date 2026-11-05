import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

/// Card daftar riwayat aktivitas presensi harian siswa bulan ini
class StudentPresensiActivityList extends StatelessWidget {
  final List<Map<String, dynamic>> recentActivity;

  const StudentPresensiActivityList({
    super.key,
    required this.recentActivity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Riwayat Presensi Bulan Ini',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (recentActivity.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Belum ada catatan presensi pada bulan ini.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            ...recentActivity.map((act) {
              final st = act['status']?.toString() ?? 'hadir';
              final dateLabel = act['date_label']?.toString() ?? act['date']?.toString() ?? '-';
              final scanIn = act['scan_time']?.toString() ?? '-';
              final scanOut = act['scan_out_time']?.toString() ?? '-';
              final lateMin = (act['late_minutes'] as num?)?.toInt() ?? 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Datang: $scanIn • Pulang: $scanOut',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    _buildStatusBadge(st, lateMin),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, int lateMinutes) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'hadir':
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF065F46);
        label = 'Hadir';
        break;
      case 'telat':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        label = lateMinutes > 0 ? 'Telat (${lateMinutes}m)' : 'Telat';
        break;
      case 'izin':
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1E40AF);
        label = 'Izin';
        break;
      case 'sakit':
        bg = const Color(0xFFEDE9FE);
        fg = const Color(0xFF5B21B6);
        label = 'Sakit';
        break;
      case 'alpa':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        label = 'Alpa';
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}

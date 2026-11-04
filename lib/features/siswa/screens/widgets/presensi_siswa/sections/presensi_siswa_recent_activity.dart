import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../models/siswa_akademik_model.dart';

/// Daftar riwayat aktivitas presensi terbaru siswa
class PresensiSiswaRecentActivity extends StatelessWidget {
  final List<SiswaRecentActivity> activities;

  const PresensiSiswaRecentActivity({
    super.key,
    required this.activities,
  });

  static Color _getStatusBg(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return const Color(0xFFECFDF5);
      case 'telat':
        return const Color(0xFFFEF3C7);
      case 'sakit':
        return const Color(0xFFFFE4E6);
      case 'izin':
        return const Color(0xFFEFF6FF);
      default:
        return const Color(0xFFFEE2E2);
    }
  }

  static Color _getStatusFg(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return const Color(0xFF059669);
      case 'telat':
        return const Color(0xFFD97706);
      case 'sakit':
        return const Color(0xFFE11D48);
      case 'izin':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFFDC2626);
    }
  }

  static IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return Icons.check_circle_outline_rounded;
      case 'telat':
        return Icons.access_time_rounded;
      case 'sakit':
        return Icons.local_hospital_outlined;
      case 'izin':
        return Icons.assignment_turned_in_outlined;
      default:
        return Icons.cancel_outlined;
    }
  }

  static Widget _buildStatusBadge(String status) {
    final bg = _getStatusBg(status);
    final fg = _getStatusFg(status);
    String label = status.toUpperCase();

    switch (status.toLowerCase()) {
      case 'hadir':
        label = 'Tepat Waktu';
        break;
      case 'telat':
        label = 'Terlambat';
        break;
      case 'sakit':
        label = 'Sakit';
        break;
      case 'izin':
        label = 'Izin';
        break;
      case 'alpa':
        label = 'Alpa';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history_rounded, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Riwayat Presensi Terbaru',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (context, index) => const Divider(height: 16),
            itemBuilder: (ctx, index) {
              final item = activities[index];
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusBg(item.status),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getStatusIcon(item.status),
                      size: 18,
                      color: _getStatusFg(item.status),
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
                        if (item.scanTime != null)
                          Text(
                            'Scan Masuk: ${item.scanTime} WIB ${item.lateMinutes > 0 ? "(${item.lateMinutes}m telat)" : ""}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        if (item.note != null && item.note!.isNotEmpty)
                          Text(
                            item.note!,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Colors.black45,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(item.status),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}


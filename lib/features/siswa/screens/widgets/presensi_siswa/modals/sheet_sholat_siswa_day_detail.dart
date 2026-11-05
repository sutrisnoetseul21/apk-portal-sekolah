import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_akademik_model.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_sholat_model.dart';

/// Modal bottom sheet rincian kehadiran sholat dhuhur pada satu tanggal tertentu
class SheetSholatSiswaDayDetail {
  static void show({
    required BuildContext context,
    required int day,
    required SiswaSelectedPeriod period,
    required SiswaDaySholat? att,
  }) {
    final dateStr =
        '${period.year}-${period.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanggal $day',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  _buildStatusBadge(att?.status),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.mosque_rounded,
                      label: 'Status Ibadah',
                      value: att?.statusLabel ?? 'Belum Ada Presensi',
                      color: _getStatusColor(att?.status),
                    ),
                    const Divider(height: 20),
                    _buildDetailRow(
                      icon: Icons.notes_rounded,
                      label: 'Keterangan',
                      value: (att != null && att.keterangan.isNotEmpty)
                          ? att.keterangan
                          : (att?.status == 'libur'
                              ? 'Hari Libur Sholat'
                              : 'Tidak ada catatan khusus'),
                      color: AppColors.textPrimary,
                    ),
                    const Divider(height: 20),
                    _buildDetailRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Hari',
                      value: att?.dayName ?? '-',
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'berjamaah':
        return const Color(0xFF0D9488);
      case 'masbuk':
        return const Color(0xFFD97706);
      case 'halangan':
      case 'haid':
        return const Color(0xFF7C3AED);
      case 'ijin':
      case 'izin':
      case 'sakit':
        return const Color(0xFF2563EB);
      case 'tidak_hadir':
        return const Color(0xFFDC2626);
      case 'libur':
      default:
        return const Color(0xFF64748B);
    }
  }

  static Widget _buildStatusBadge(String? status) {
    String label = 'Belum Ada Data';
    Color bg = const Color(0xFFF1F5F9);
    Color fg = const Color(0xFF64748B);

    switch (status?.toLowerCase()) {
      case 'berjamaah':
        label = 'Berjamaah';
        bg = const Color(0xFFCCFBF1);
        fg = const Color(0xFF0F766E);
        break;
      case 'masbuk':
        label = 'Masbuk';
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        break;
      case 'halangan':
      case 'haid':
        label = 'Halangan/Haid';
        bg = const Color(0xFFF3E8FF);
        fg = const Color(0xFF6D28D9);
        break;
      case 'ijin':
      case 'izin':
      case 'sakit':
        label = 'Izin';
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF1D4ED8);
        break;
      case 'tidak_hadir':
        label = 'Tidak Hadir';
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        break;
      case 'libur':
        label = 'Hari Libur';
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: fg,
        ),
      ),
    );
  }

  static Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

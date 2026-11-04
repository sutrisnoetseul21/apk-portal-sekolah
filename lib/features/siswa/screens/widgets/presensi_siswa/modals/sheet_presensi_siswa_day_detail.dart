import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../models/siswa_akademik_model.dart';

/// Modal bottom sheet rincian kehadiran pada satu tanggal tertentu
class SheetPresensiSiswaDayDetail {
  static void show({
    required BuildContext context,
    required int day,
    required SiswaAkademikPeriod period,
    required SiswaDayAttendance? att,
    required bool isHoliday,
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
                  _buildStatusBadge(att?.status, isHoliday),
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
                      icon: Icons.login_rounded,
                      label: 'Jam Masuk',
                      value: att?.scanTime != null
                          ? '${att!.scanTime} WIB'
                          : (isHoliday ? 'Hari Libur' : 'Tidak Ada Data'),
                      color: att?.scanTime != null
                          ? const Color(0xFF059669)
                          : Colors.black54,
                    ),
                    const Divider(height: 20),
                    _buildDetailRow(
                      icon: Icons.logout_rounded,
                      label: 'Jam Pulang',
                      value: att?.scanOutTime != null
                          ? '${att!.scanOutTime} WIB'
                          : '-',
                      color: Colors.black87,
                    ),
                    if (att != null && att.lateMinutes > 0) ...[
                      const Divider(height: 20),
                      _buildDetailRow(
                        icon: Icons.timer_outlined,
                        label: 'Keterlambatan',
                        value: '${att.lateMinutes} Menit',
                        color: const Color(0xFFD97706),
                      ),
                    ],
                    if (att != null && att.isManualInput) ...[
                      const Divider(height: 20),
                      _buildDetailRow(
                        icon: Icons.edit_note_rounded,
                        label: 'Metode Absen',
                        value: 'Diinput Manual oleh Guru/Admin',
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
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

  static Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  static Widget _buildStatusBadge(String? status, bool isHoliday) {
    Color bg = const Color(0xFFF1F5F9);
    Color fg = const Color(0xFF64748B);
    String label = 'Belum Ada';

    if (isHoliday) {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF64748B);
      label = 'Hari Libur';
    } else if (status != null) {
      switch (status.toLowerCase()) {
        case 'hadir':
          bg = const Color(0xFFECFDF5);
          fg = const Color(0xFF059669);
          label = 'Tepat Waktu';
          break;
        case 'telat':
          bg = const Color(0xFFFEF3C7);
          fg = const Color(0xFFD97706);
          label = 'Terlambat';
          break;
        case 'sakit':
          bg = const Color(0xFFFFE4E6);
          fg = const Color(0xFFE11D48);
          label = 'Sakit';
          break;
        case 'izin':
          bg = const Color(0xFFEFF6FF);
          fg = const Color(0xFF2563EB);
          label = 'Izin';
          break;
        case 'alpa':
          bg = const Color(0xFFFEE2E2);
          fg = const Color(0xFFDC2626);
          label = 'Alpa';
          break;
      }
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
}


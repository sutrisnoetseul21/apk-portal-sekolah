import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_ijin_model.dart';

/// Banner notifikasi pengecekan hari libur kalender sekolah
class FormIjinHolidayNotice extends StatelessWidget {
  final bool isCheckingHolidays;
  final SiswaHolidaysCheckResult? holidayCheckResult;

  const FormIjinHolidayNotice({
    super.key,
    required this.isCheckingHolidays,
    required this.holidayCheckResult,
  });

  @override
  Widget build(BuildContext context) {
    if (isCheckingHolidays) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Mengecek kalender libur sekolah...',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    final result = holidayCheckResult;
    if (result == null) return const SizedBox.shrink();

    if (result.holidayCount > 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFD97706),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Terdapat ${result.holidayCount} Hari Libur Sekolah:',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD97706),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...result.holidayMessages.map((msg) => Padding(
                  padding: const EdgeInsets.only(left: 26, bottom: 2),
                  child: Text(
                    '• $msg',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                  ),
                )),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: Color(0xFF059669),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Seluruh ${result.schoolDaysCount} hari adalah hari aktif sekolah.',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF065F46),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


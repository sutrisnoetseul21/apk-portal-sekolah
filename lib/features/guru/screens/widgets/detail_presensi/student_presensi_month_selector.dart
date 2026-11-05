import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

/// Card selector dropdown pilihan bulan presensi siswa
class StudentPresensiMonthSelector extends StatelessWidget {
  final List<Map<String, dynamic>> availableMonths;
  final String? selectedMonthYear;
  final ValueChanged<String?> onMonthChanged;

  const StudentPresensiMonthSelector({
    super.key,
    required this.availableMonths,
    required this.selectedMonthYear,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (availableMonths.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_month_rounded,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          const Text(
            'Bulan:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedMonthYear,
                isExpanded: true,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                items: availableMonths.map((m) {
                  return DropdownMenuItem<String>(
                    value: m['key']?.toString(),
                    child: Text(m['label']?.toString() ?? ''),
                  );
                }).toList(),
                onChanged: onMonthChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

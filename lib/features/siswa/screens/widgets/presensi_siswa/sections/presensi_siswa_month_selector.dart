import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';
import '../../../models/siswa_akademik_model.dart';

/// Komponen pemilih bulan kalender akademik siswa
class PresensiSiswaMonthSelector extends StatelessWidget {
  final List<SiswaAvailableMonth> availableMonths;
  final String? selectedMonthYearKey;
  final ValueChanged<String> onMonthChanged;

  const PresensiSiswaMonthSelector({
    super.key,
    required this.availableMonths,
    required this.selectedMonthYearKey,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Bulan Kalender',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (availableMonths.isNotEmpty)
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedMonthYearKey,
                icon: const Icon(
                  Icons.arrow_drop_down_rounded,
                  color: AppColors.primary,
                ),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
                items: availableMonths.map((m) {
                  return DropdownMenuItem<String>(
                    value: m.key,
                    child: Text(m.label),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null && val != selectedMonthYearKey) {
                    onMonthChanged(val);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}


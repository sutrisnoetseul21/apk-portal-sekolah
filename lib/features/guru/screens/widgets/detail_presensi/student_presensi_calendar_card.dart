import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

/// Card kalender matriks kehadiran bulanan per siswa
class StudentPresensiCalendarCard extends StatelessWidget {
  final int daysInMonth;
  final int startOffset;
  final Map<String, dynamic> attendanceData;
  final Map<String, dynamic> holidays;

  const StudentPresensiCalendarCard({
    super.key,
    required this.daysInMonth,
    required this.startOffset,
    required this.attendanceData,
    required this.holidays,
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
            'Kalender Kehadiran Bulanan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: d == 'Min' ? Colors.red : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final totalCells = startOffset + daysInMonth;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        if (index < startOffset) {
          return const SizedBox.shrink();
        }
        final day = index - startOffset + 1;
        final dayKey = day.toString();
        final att = attendanceData[dayKey];
        final isHoliday = holidays[dayKey] == true;

        Color bgColor = const Color(0xFFF1F5F9);
        Color textColor = AppColors.textSecondary;
        String code = '';

        if (att != null && att is Map) {
          final status = att['status']?.toString() ?? '';
          switch (status) {
            case 'hadir':
              bgColor = const Color(0xFFD1FAE5);
              textColor = const Color(0xFF047857);
              code = 'H';
              break;
            case 'telat':
              bgColor = const Color(0xFFFEF3C7);
              textColor = const Color(0xFFB45309);
              code = 'T';
              break;
            case 'izin':
              bgColor = const Color(0xFFDBEAFE);
              textColor = const Color(0xFF1D4ED8);
              code = 'I';
              break;
            case 'sakit':
              bgColor = const Color(0xFFEDE9FE);
              textColor = const Color(0xFF6D28D9);
              code = 'S';
              break;
            case 'alpa':
              bgColor = const Color(0xFFFEE2E2);
              textColor = const Color(0xFFB91C1C);
              code = 'A';
              break;
          }
        } else if (isHoliday) {
          bgColor = const Color(0xFFE2E8F0);
          textColor = const Color(0xFF64748B);
          code = 'L';
        }

        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$day',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              if (code.isNotEmpty)
                Text(
                  code,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

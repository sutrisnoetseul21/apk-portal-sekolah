import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_akademik_model.dart';

/// Matriks kalender kehadiran interaktif tanggal 1 s.d. 31
class PresensiSiswaCalendarCard extends StatelessWidget {
  final SiswaSelectedPeriod period;
  final Map<int, SiswaDayAttendance> attendanceMatrix;
  final Map<int, bool> holidays;
  final ValueChanged<int> onDayTap;

  const PresensiSiswaCalendarCard({
    super.key,
    required this.period,
    required this.attendanceMatrix,
    required this.holidays,
    required this.onDayTap,
  });

  Widget _buildLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildDayCell({
    required int day,
    required SiswaDayAttendance? att,
    required bool isHoliday,
    required bool isToday,
    required VoidCallback onTap,
  }) {
    Color bg = Colors.transparent;
    Color dotColor = Colors.transparent;
    Color textColor = AppColors.textPrimary;

    if (isHoliday) {
      bg = const Color(0xFFF1F5F9);
      textColor = const Color(0xFF94A3B8);
    } else if (att != null) {
      switch (att.status.toLowerCase()) {
        case 'hadir':
          bg = const Color(0xFFECFDF5);
          dotColor = const Color(0xFF059669);
          textColor = const Color(0xFF047857);
          break;
        case 'telat':
          bg = const Color(0xFFFEF3C7);
          dotColor = const Color(0xFFD97706);
          textColor = const Color(0xFFB45309);
          break;
        case 'sakit':
          bg = const Color(0xFFFFE4E6);
          dotColor = const Color(0xFFE11D48);
          textColor = const Color(0xFFBE123C);
          break;
        case 'izin':
          bg = const Color(0xFFEFF6FF);
          dotColor = const Color(0xFF2563EB);
          textColor = const Color(0xFF1D4ED8);
          break;
        case 'alpa':
          bg = const Color(0xFFFEE2E2);
          dotColor = const Color(0xFFDC2626);
          textColor = const Color(0xFFB91C1C);
          break;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: isToday
                ? Border.all(color: AppColors.primary, width: 2)
                : Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$day',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isToday ? FontWeight.w900 : FontWeight.bold,
                  color: isToday ? AppColors.primary : textColor,
                ),
              ),
              const SizedBox(height: 2),
              if (dotColor != Colors.transparent)
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                )
              else if (isHoliday)
                Container(
                  width: 6,
                  height: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(1),
                  ),
                )
              else
                const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int daysInMonth = period.daysInMonth;
    final int offset = period.startOfMonthOffset; // 0 = Senin, 6 = Minggu
    final String todayDate = period.todayDate;

    const List<String> dayHeaders = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    // Total cells in grid
    final int totalCells = offset + daysInMonth;
    final int rowsCount = (totalCells / 7).ceil();

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Matriks Kalender Kehadiran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Ketuk tanggal untuk rincian',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Header Hari (Sen - Min)
          Row(
            children: dayHeaders.map((dh) {
              final isWeekend = dh == 'Sab' || dh == 'Min';
              return Expanded(
                child: Center(
                  child: Text(
                    dh,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isWeekend ? const Color(0xFFDC2626) : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Grid Tanggal
          Column(
            children: List.generate(rowsCount, (rowIndex) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: List.generate(7, (colIndex) {
                    final cellIndex = rowIndex * 7 + colIndex;
                    final day = cellIndex - offset + 1;

                    if (day < 1 || day > daysInMonth) {
                      return const Expanded(child: SizedBox(height: 48));
                    }

                    final att = attendanceMatrix[day];
                    final isHoliday = holidays[day] ?? false;
                    final cellDateStr =
                        '${period.year}-${period.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                    final isToday = cellDateStr == todayDate;

                    return Expanded(
                      child: _buildDayCell(
                        day: day,
                        att: att,
                        isHoliday: isHoliday,
                        isToday: isToday,
                        onTap: () => onDayTap(day),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Legenda Status
          Wrap(
            spacing: 12,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _buildLegend(const Color(0xFF059669), 'Hadir'),
              _buildLegend(const Color(0xFFD97706), 'Telat'),
              _buildLegend(const Color(0xFFE11D48), 'Sakit'),
              _buildLegend(const Color(0xFF2563EB), 'Izin'),
              _buildLegend(const Color(0xFFDC2626), 'Alpa'),
              _buildLegend(const Color(0xFF94A3B8), 'Libur'),
            ],
          ),
        ],
      ),
    );
  }
}


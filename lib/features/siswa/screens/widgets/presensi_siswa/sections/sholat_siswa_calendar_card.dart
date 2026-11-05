import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_akademik_model.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_sholat_model.dart';

/// Matriks kalender kehadiran sholat dhuhur interaktif tanggal 1 s.d. 31
class SholatSiswaCalendarCard extends StatelessWidget {
  final SiswaSelectedPeriod period;
  final Map<int, SiswaDaySholat> attendanceMatrix;
  final ValueChanged<int> onDayTap;

  const SholatSiswaCalendarCard({
    super.key,
    required this.period,
    required this.attendanceMatrix,
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
    required SiswaDaySholat? att,
    required bool isToday,
    required VoidCallback onTap,
  }) {
    Color bg = Colors.transparent;
    Color dotColor = Colors.transparent;
    Color textColor = AppColors.textPrimary;
    bool isHoliday = att?.status == 'libur';

    if (isHoliday) {
      bg = const Color(0xFFF1F5F9);
      textColor = const Color(0xFF94A3B8);
    } else if (att != null) {
      switch (att.status.toLowerCase()) {
        case 'berjamaah':
          bg = const Color(0xFFCCFBF1);
          dotColor = const Color(0xFF0D9488);
          textColor = const Color(0xFF0F766E);
          break;
        case 'masbuk':
          bg = const Color(0xFFFEF3C7);
          dotColor = const Color(0xFFD97706);
          textColor = const Color(0xFFB45309);
          break;
        case 'halangan':
        case 'haid':
          bg = const Color(0xFFF3E8FF);
          dotColor = const Color(0xFF7C3AED);
          textColor = const Color(0xFF6D28D9);
          break;
        case 'ijin':
        case 'izin':
        case 'sakit':
          bg = const Color(0xFFEFF6FF);
          dotColor = const Color(0xFF2563EB);
          textColor = const Color(0xFF1D4ED8);
          break;
        case 'tidak_hadir':
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
                ? Border.all(color: const Color(0xFF0D9488), width: 2)
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
                  color: isToday ? const Color(0xFF0D9488) : textColor,
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
                    borderRadius: BorderRadius.circular(2),
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
    const dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final offset = period.startOfMonthOffset;
    final totalCells = offset + period.daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    final now = DateTime.now();
    final currentDay = now.day;
    final isCurrentMonth =
        now.month == period.month && now.year == period.year;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 18,
                    color: Color(0xFF0D9488),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Kalender Sholat Dhuhur',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                period.monthYear,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D9488),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Header Hari (Senin s.d. Minggu)
          Row(
            children: dayNames.map((d) {
              final isWeekend = d == 'Sab' || d == 'Min';
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isWeekend
                          ? const Color(0xFFDC2626)
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Grid Tanggal
          Column(
            children: List.generate(rowCount, (r) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: Row(
                  children: List.generate(7, (c) {
                    final cellIndex = r * 7 + c;
                    final int dayNumber = cellIndex - offset + 1;

                    if (dayNumber < 1 || dayNumber > period.daysInMonth) {
                      return const Expanded(child: SizedBox(height: 48));
                    }

                    final att = attendanceMatrix[dayNumber];
                    final isToday = isCurrentMonth && dayNumber == currentDay;

                    return Expanded(
                      child: _buildDayCell(
                        day: dayNumber,
                        att: att,
                        isToday: isToday,
                        onTap: () => onDayTap(dayNumber),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // Legenda Status
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _buildLegend(const Color(0xFF0D9488), 'Berjamaah'),
              _buildLegend(const Color(0xFFD97706), 'Masbuk'),
              _buildLegend(const Color(0xFF7C3AED), 'Halangan/Haid'),
              _buildLegend(const Color(0xFF2563EB), 'Izin'),
              _buildLegend(const Color(0xFFDC2626), 'Tidak Hadir'),
              _buildLegend(const Color(0xFF94A3B8), 'Libur'),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

/// Tabel Matriks Presensi Bulanan: Tanggal 1 s.d 31, Legenda, & Kolom Ringkasan (H, T, I, S, A)
class PresensiMonthlyMatrix extends StatelessWidget {
  final List<Map<String, dynamic>> filteredStudents;
  final int daysInMonth;
  final void Function(String id, String name) onOpenStudentDetail;

  const PresensiMonthlyMatrix({
    super.key,
    required this.filteredStudents,
    required this.daysInMonth,
    required this.onOpenStudentDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Tabel & Legenda Warna
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tabel Presensi Matriks Bulanan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Menampilkan rekapan harian dari tanggal 1 s.d $daysInMonth',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    _buildLegendItem('H: Hadir', const Color(0xFF10B981)),
                    _buildLegendItem('T: Telat', const Color(0xFFF59E0B)),
                    _buildLegendItem('I: Izin', const Color(0xFF3B82F6)),
                    _buildLegendItem('S: Sakit', const Color(0xFF8B5CF6)),
                    _buildLegendItem('A: Alpa', const Color(0xFFEF4444)),
                    _buildLegendItem('L: Libur', const Color(0xFFCBD5E1)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          if (filteredStudents.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Belum ada data siswa.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFFF8FAFC),
                ),
                columnSpacing: 10,
                horizontalMargin: 14,
                columns: [
                  const DataColumn(
                    label: Text(
                      'NAMA SISWA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  for (int i = 1; i <= daysInMonth; i++)
                    DataColumn(
                      label: SizedBox(
                        width: 24,
                        child: Center(
                          child: Text(
                            '$i',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const DataColumn(
                    label: Text(
                      'H',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ),
                  const DataColumn(
                    label: Text(
                      'T',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ),
                  const DataColumn(
                    label: Text(
                      'I',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                  const DataColumn(
                    label: Text(
                      'S',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  ),
                  const DataColumn(
                    label: Text(
                      'A',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFE11D48),
                      ),
                    ),
                  ),
                ],
                rows: filteredStudents.map((student) {
                  final id = student['id']?.toString() ?? '';
                  final name = student['name']?.toString() ?? '-';
                  final rawMonthly = student['monthly'];
                  final monthly = rawMonthly is Map
                      ? Map<String, dynamic>.from(rawMonthly)
                      : <String, dynamic>{};
                  final rawDaily = monthly['daily'];
                  final daily = rawDaily is Map
                      ? Map<String, dynamic>.from(rawDaily)
                      : <String, dynamic>{};
                  final isAlpaWarn = monthly['is_alpa_warning'] == true;
                  final isTelatWarn = monthly['is_telat_warning'] == true;

                  return DataRow(
                    color: (isAlpaWarn || isTelatWarn)
                        ? WidgetStateProperty.all(const Color(0xFFFEF2F2))
                        : null,
                    cells: [
                      DataCell(
                        InkWell(
                          onTap: () => onOpenStudentDetail(id, name),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              if (isAlpaWarn || isTelatWarn)
                                Row(
                                  children: [
                                    if (isAlpaWarn)
                                      Container(
                                        margin: const EdgeInsets.only(
                                          top: 2,
                                          right: 4,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEE2E2),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          '⚠️ ≥3 Alpa',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFB91C1C),
                                          ),
                                        ),
                                      ),
                                    if (isTelatWarn)
                                      Container(
                                        margin: const EdgeInsets.only(top: 2),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF3C7),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          '⚠️ ≥100m Telat',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFB45309),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      for (int i = 1; i <= daysInMonth; i++)
                        DataCell(
                          _buildMatrixDayCell(
                            daily['$i']?.toString() ?? '-',
                          ),
                        ),
                      DataCell(
                        Text(
                          '${monthly['hadir'] ?? 0}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${monthly['telat'] ?? 0}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${monthly['izin'] ?? 0}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${monthly['sakit'] ?? 0}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${monthly['alpa'] ?? 0}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFE11D48),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMatrixDayCell(String code) {
    Color bg = Colors.transparent;
    Color fg = const Color(0xFFCBD5E1);

    switch (code) {
      case 'H':
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF059669);
        break;
      case 'T':
        bg = const Color(0xFFFFFBEB);
        fg = const Color(0xFFD97706);
        break;
      case 'I':
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF2563EB);
        break;
      case 'S':
        bg = const Color(0xFFEEF2FF);
        fg = const Color(0xFF4F46E5);
        break;
      case 'A':
        bg = const Color(0xFFFEF2F2);
        fg = const Color(0xFFDC2626);
        break;
      case 'L':
        bg = const Color(0xFFE2E8F0);
        fg = const Color(0xFF64748B);
        break;
    }

    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        code,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: fg,
        ),
      ),
    );
  }
}


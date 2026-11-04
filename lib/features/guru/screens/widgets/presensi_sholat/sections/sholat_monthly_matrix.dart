import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

/// Seksi Matriks Presensi Bulanan Sholat Dhuhur:
/// - Judul & Legenda Presensi (H: Hadir, I: Ijin/Halangan, A: Alpa, L: Libur, NM: Non-Muslim)
/// - Tabel Horizontal Scrollable untuk Hari 1–31
/// - Kolom Ringkasan H, I, A, % Kehadiran per Siswa
class SholatMonthlyMatrix extends StatelessWidget {
  final int daysInMonth;
  final List<Map<String, dynamic>> students;

  const SholatMonthlyMatrix({
    super.key,
    required this.daysInMonth,
    required this.students,
  });

  static const Color _emeraldPrimary = Color(0xFF059669);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.grid_on_rounded,
                      size: 16,
                      color: _emeraldPrimary,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Matriks Presensi Sholat Dhuhur Bulanan (1–31)',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildLegendPill(
                      'H: Hadir',
                      const Color(0xFFD1FAE5),
                      const Color(0xFF065F46),
                    ),
                    _buildLegendPill(
                      'I: Ijin / Halangan',
                      const Color(0xFFDBEAFE),
                      const Color(0xFF1E40AF),
                    ),
                    _buildLegendPill(
                      'A: Alpa',
                      const Color(0xFFFFE4E6),
                      const Color(0xFF9F1239),
                    ),
                    _buildLegendPill(
                      'L: Libur',
                      const Color(0xFFF1F5F9),
                      const Color(0xFF64748B),
                    ),
                    _buildLegendPill(
                      'NM: Non-Muslim',
                      const Color(0xFFE0E7FF),
                      const Color(0xFF4338CA),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              columnSpacing: 10,
              horizontalMargin: 12,
              headingTextStyle: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF475569),
              ),
              dataTextStyle: const TextStyle(
                fontSize: 11,
                color: AppColors.textPrimary,
              ),
              columns: [
                const DataColumn(label: Text('NAMA SISWA')),
                for (int d = 1; d <= daysInMonth; d++)
                  DataColumn(label: Text('$d')),
                const DataColumn(label: Text('H')),
                const DataColumn(label: Text('I')),
                const DataColumn(label: Text('A')),
                const DataColumn(label: Text('%')),
              ],
              rows: students.map((st) {
                final name = st['name']?.toString() ?? '-';
                final isNm = st['is_non_muslim'] == true;
                final monthly = st['monthly'] is Map
                    ? Map<String, dynamic>.from(st['monthly'] as Map)
                    : <String, dynamic>{};
                final daily = monthly['daily'] is Map
                    ? Map<String, dynamic>.from(monthly['daily'] as Map)
                    : <String, dynamic>{};
                final hCount = (monthly['hadir'] as num?)?.toInt() ?? 0;
                final iCount = (monthly['ijin'] as num?)?.toInt() ?? 0;
                final aCount = (monthly['tidak_hadir'] as num?)?.toInt() ?? 0;
                final pct = (monthly['persentase'] as num?) ?? 0;

                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 150,
                        child: Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ),
                    for (int d = 1; d <= daysInMonth; d++)
                      DataCell(
                        _buildMatrixCodeCell((daily['$d'] ?? '-').toString()),
                      ),
                    DataCell(
                      Text(
                        isNm ? '-' : '$hCount',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF065F46),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        isNm ? '-' : '$iCount',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        isNm ? '-' : '$aCount',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF9F1239),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        isNm ? 'NM' : '$pct%',
                        style: const TextStyle(fontWeight: FontWeight.w800),
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

  Widget _buildLegendPill(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildMatrixCodeCell(String code) {
    Color bg = Colors.transparent;
    Color fg = const Color(0xFFCBD5E1);
    if (code == 'H') {
      bg = const Color(0xFFD1FAE5);
      fg = const Color(0xFF065F46);
    } else if (code == 'I') {
      bg = const Color(0xFFDBEAFE);
      fg = const Color(0xFF1E40AF);
    } else if (code == 'A') {
      bg = const Color(0xFFFFE4E6);
      fg = const Color(0xFF9F1239);
    } else if (code == 'L') {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF94A3B8);
    } else if (code == 'NM') {
      bg = const Color(0xFFE0E7FF);
      fg = const Color(0xFF4338CA);
    }

    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        code,
        style: TextStyle(
          fontSize: code == 'NM' ? 8.5 : 10.5,
          fontWeight: FontWeight.w900,
          color: fg,
        ),
      ),
    );
  }
}


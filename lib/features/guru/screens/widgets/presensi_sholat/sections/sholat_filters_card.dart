import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

/// Card Filter Presensi Sholat Dhuhur:
/// - Tahun Ajaran Aktif (Terkunci Read-Only)
/// - Pilih Kelas Binaan (Dropdown tunggal jika > 1 kelas, atau terkunci jika 1 kelas)
/// - Bulan Kehadiran
/// - Koordinator PAI
class SholatFiltersCard extends StatelessWidget {
  final String selectedAcademicYearName;
  final List<Map<String, dynamic>> classes;
  final bool isBk;
  final String selectedClassId;
  final String selectedClassName;
  final String selectedClassAccessLabel;
  final ValueChanged<String> onClassChanged;
  final List<Map<String, dynamic>> availableMonths;
  final String selectedMonthYear;
  final ValueChanged<String> onMonthChanged;
  final List<Map<String, dynamic>> koordinators;
  final String selectedKoordinatorId;
  final ValueChanged<String> onKoordinatorChanged;

  const SholatFiltersCard({
    super.key,
    required this.selectedAcademicYearName,
    required this.classes,
    required this.isBk,
    required this.selectedClassId,
    required this.selectedClassName,
    required this.selectedClassAccessLabel,
    required this.onClassChanged,
    required this.availableMonths,
    required this.selectedMonthYear,
    required this.onMonthChanged,
    required this.koordinators,
    required this.selectedKoordinatorId,
    required this.onKoordinatorChanged,
  });

  static const Color _emeraldPrimary = Color(0xFF059669);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Tahun Ajaran Aktif (Terkunci Read-Only)
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 12,
                          color: _emeraldPrimary,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'TAHUN AJARAN AKTIF',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedAcademicYearName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FAE5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'AKTIF',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF065F46),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Pilih Kelas Binaan (1 Dropdown Tunggal jika > 1 kelas, atau Terkunci jika 1 kelas)
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.class_outlined,
                          size: 12,
                          color: _emeraldPrimary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            isBk
                                ? 'PILIH KELAS BINAAN BK (${classes.length})'
                                : 'PILIH KELAS BINAAN (${classes.length})',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (classes.length <= 1)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                selectedClassName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF065F46),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                selectedClassAccessLabel,
                                style: const TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: _emeraldPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedClassId,
                            isExpanded: true,
                            isDense: true,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                            items: classes.map((cls) {
                              final cId = cls['id']?.toString() ?? '';
                              final cName = cls['name']?.toString() ?? '-';
                              final cLabel =
                                  cls['access_label']?.toString() ?? '';
                              return DropdownMenuItem<String>(
                                value: cId,
                                child: Text(
                                  cLabel.isNotEmpty
                                      ? '$cName ($cLabel)'
                                      : cName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null && val != selectedClassId) {
                                onClassChanged(val);
                              }
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Bulan Kehadiran & Koordinator PAI
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          size: 12,
                          color: _emeraldPrimary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'BULAN KEHADIRAN',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedMonthYear,
                          isExpanded: true,
                          isDense: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          items: availableMonths.map((m) {
                            return DropdownMenuItem<String>(
                              value: m['key']?.toString(),
                              child: Text(
                                m['label']?.toString() ?? '-',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null && val != selectedMonthYear) {
                              onMonthChanged(val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (koordinators.isNotEmpty) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.person_pin_outlined,
                            size: 12,
                            color: _emeraldPrimary,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'KOORDINATOR PAI',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: koordinators.any(
                              (k) =>
                                  k['id']?.toString() == selectedKoordinatorId,
                            )
                                ? selectedKoordinatorId
                                : koordinators.first['id']?.toString(),
                            isExpanded: true,
                            isDense: true,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            items: koordinators.map((k) {
                              return DropdownMenuItem<String>(
                                value: k['id']?.toString(),
                                child: Text(
                                  k['name']?.toString() ?? '-',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                onKoordinatorChanged(val);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}


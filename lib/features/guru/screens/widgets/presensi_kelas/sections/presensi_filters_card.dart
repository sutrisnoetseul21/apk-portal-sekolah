import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

/// Kartu Filter Presensi: Tahun Ajaran Terkunci, Pilihan Kelas, & Bulan Kehadiran
class PresensiFiltersCard extends StatelessWidget {
  final String selectedAcademicYearName;
  final List<Map<String, dynamic>> classes;
  final String? selectedClassId;
  final bool isBk;
  final String roleSummary;
  final ValueChanged<String> onClassChanged;
  final String? selectedMonthYear;
  final List<Map<String, dynamic>> availableMonths;
  final ValueChanged<String> onMonthChanged;

  const PresensiFiltersCard({
    super.key,
    required this.selectedAcademicYearName,
    required this.classes,
    required this.selectedClassId,
    required this.isBk,
    required this.roleSummary,
    required this.onClassChanged,
    required this.selectedMonthYear,
    required this.availableMonths,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasSingleClass = classes.length == 1;
    final bool hasMultipleClasses = classes.length > 1;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 1. Tahun Ajaran Aktif (Terkunci / Locked)
              Expanded(
                child: _buildLockedField(
                  label: 'TAHUN AJARAN AKTIF',
                  icon: Icons.date_range_rounded,
                  value: selectedAcademicYearName,
                  badgeText: 'AKTIF',
                  badgeColor: const Color(0xFF059669),
                  badgeBgColor: const Color(0xFFD1FAE5),
                ),
              ),
              const SizedBox(width: 10),
              // 2. Pilih Kelas (Terkunci jika cuma 1 kelas, Dropdown jika >1 kelas)
              Expanded(
                child: hasSingleClass
                    ? _buildLockedField(
                        label: 'KELAS BINAAN',
                        icon: Icons.class_rounded,
                        value: 'Kelas ${classes.first['name'] ?? '-'}',
                        badgeText:
                            classes.first['access_label']?.toString() ??
                            'Wali Kelas',
                        badgeColor: const Color(0xFF1D4ED8),
                        badgeBgColor: const Color(0xFFDBEAFE),
                      )
                    : hasMultipleClasses
                    ? _buildDropdownField(
                        label: isBk ? 'PILIH KELAS BINAAN' : 'PILIH KELAS',
                        icon: Icons.class_rounded,
                        value: selectedClassId,
                        items: classes
                            .map(
                              (c) => DropdownMenuItem<String>(
                                value: c['id']?.toString(),
                                child: Text(
                                  'Kelas ${c['name'] ?? ''} (${c['access_label'] ?? 'Binaan'})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null && val != selectedClassId) {
                            onClassChanged(val);
                          }
                        },
                      )
                    : _buildLockedField(
                        label: 'KELAS BINAAN',
                        icon: Icons.class_rounded,
                        value: 'Belum Ada Kelas',
                        badgeText: '0 KELAS',
                        badgeColor: const Color(0xFF64748B),
                        badgeBgColor: const Color(0xFFF1F5F9),
                      ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          // 3. Filter Bulan Kehadiran
          _buildDropdownField(
            label: 'BULAN KEHADIRAN',
            icon: Icons.calendar_month_rounded,
            value: selectedMonthYear,
            items: availableMonths
                .map(
                  (m) => DropdownMenuItem<String>(
                    value: m['key']?.toString(),
                    child: Text(m['label']?.toString() ?? ''),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null && val != selectedMonthYear) {
                onMonthChanged(val);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLockedField({
    required String label,
    required IconData icon,
    required String value,
    required String badgeText,
    required Color badgeColor,
    required Color badgeBgColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: AppColors.primary),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10.5),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 14,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    final validValue = items.any((item) => item.value == value) ? value : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: AppColors.primary),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: validValue,
              isExpanded: true,
              isDense: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}


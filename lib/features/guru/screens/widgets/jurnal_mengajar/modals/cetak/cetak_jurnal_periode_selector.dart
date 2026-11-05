import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

class CetakJurnalPeriodeSelector extends StatelessWidget {
  final String cetakJenis;
  final ValueChanged<String> onJenisChanged;
  final List<Map<String, dynamic>> availableMonthsList;
  final String cetakBulanYear;
  final ValueChanged<String> onBulanYearChanged;
  final String cetakSemester;
  final ValueChanged<String> onSemesterChanged;

  static const Color _indigoPrimary = Color(0xFF4F46E5);

  const CetakJurnalPeriodeSelector({
    super.key,
    required this.cetakJenis,
    required this.onJenisChanged,
    required this.availableMonthsList,
    required this.cetakBulanYear,
    required this.onBulanYearChanged,
    required this.cetakSemester,
    required this.onSemesterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. PILIH PERIODE LAPORAN',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildPeriodeRadioCard(
              title: 'Bulanan',
              subtitle: 'Per Bulan',
              isSelected: cetakJenis == 'bulanan',
              onTap: () => onJenisChanged('bulanan'),
            ),
            const SizedBox(width: 8),
            _buildPeriodeRadioCard(
              title: 'Semester',
              subtitle: 'Ganjil / Genap',
              isSelected: cetakJenis == 'semester',
              onTap: () => onJenisChanged('semester'),
            ),
            const SizedBox(width: 8),
            _buildPeriodeRadioCard(
              title: 'Tahunan',
              subtitle: '1 Tahun Ajaran',
              isSelected: cetakJenis == 'tahunan',
              onTap: () => onJenisChanged('tahunan'),
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (cetakJenis == 'bulanan' && availableMonthsList.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _indigoPrimary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _indigoPrimary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PILIH BULAN KBM',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: _indigoPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: availableMonthsList.any(
                        (m) => '${m['key']}' == cetakBulanYear,
                      )
                          ? cetakBulanYear
                          : '${availableMonthsList.first['key']}',
                      isExpanded: true,
                      items: availableMonthsList.map((m) {
                        return DropdownMenuItem<String>(
                          value: '${m['key']}',
                          child: Text(
                            '${m['label']}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) onBulanYearChanged(val);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

        if (cetakJenis == 'semester')
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _indigoPrimary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _indigoPrimary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => onSemesterChanged('ganjil'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: cetakSemester == 'ganjil'
                            ? _indigoPrimary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Semester Ganjil',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: cetakSemester == 'ganjil'
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => onSemesterChanged('genap'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: cetakSemester == 'genap'
                            ? _indigoPrimary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Semester Genap',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: cetakSemester == 'genap'
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPeriodeRadioCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? _indigoPrimary.withValues(alpha: 0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? _indigoPrimary : const Color(0xFFE2E8F0),
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? _indigoPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

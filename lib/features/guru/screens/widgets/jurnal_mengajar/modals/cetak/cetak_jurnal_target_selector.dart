import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

class CetakJurnalTargetSelector extends StatelessWidget {
  final String currentTeacherName;
  final List<Map<String, dynamic>> availableMapels;
  final int? cetakMapelId;
  final ValueChanged<int?> onMapelChanged;
  final List<Map<String, dynamic>> classesForModalMapel;
  final String? cetakClassId;
  final ValueChanged<String?> onClassChanged;

  static const Color _indigoPrimary = Color(0xFF4F46E5);

  const CetakJurnalTargetSelector({
    super.key,
    required this.currentTeacherName,
    required this.availableMapels,
    required this.cetakMapelId,
    required this.onMapelChanged,
    required this.classesForModalMapel,
    required this.cetakClassId,
    required this.onClassChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '2. SASARAN CETAK (GURU • MAPEL • KELAS)',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),

        // Guru Pengampu
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                size: 18,
                color: _indigoPrimary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GURU PENGAJAR',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentTeacherName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Mata Pelajaran
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: availableMapels.any(
                (m) => int.tryParse('${m['id']}') == cetakMapelId,
              )
                  ? cetakMapelId
                  : null,
              isExpanded: true,
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text(
                    '-- Semua Mata Pelajaran --',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ...availableMapels.map((m) {
                  final mId = int.tryParse('${m['id']}');
                  return DropdownMenuItem<int?>(
                    value: mId,
                    child: Text(
                      '${m['nama_mapel']}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }),
              ],
              onChanged: onMapelChanged,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Kelas Rombel
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: cetakMapelId == null
                ? const Color(0xFFF1F5F9)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: classesForModalMapel.any(
                (c) => '${c['id']}' == cetakClassId,
              )
                  ? cetakClassId
                  : null,
              isExpanded: true,
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(
                    cetakMapelId == null
                        ? '-- Pilih Mapel Dulu Untuk Filter Kelas --'
                        : '-- Semua Kelas Terjadwal --',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: cetakMapelId == null
                          ? const Color(0xFF94A3B8)
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                ...classesForModalMapel.map((c) {
                  return DropdownMenuItem<String?>(
                    value: '${c['id']}',
                    child: Text(
                      '${c['name']}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }),
              ],
              onChanged: cetakMapelId == null ? null : onClassChanged,
            ),
          ),
        ),
      ],
    );
  }
}

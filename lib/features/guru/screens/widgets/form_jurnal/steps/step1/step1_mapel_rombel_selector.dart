import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

class Step1MapelRombelSelector extends StatelessWidget {
  final bool isSingleMapel;
  final List<Map<String, dynamic>> availableMapels;
  final int? selectedMapelId;
  final ValueChanged<int?> onMapelChanged;
  final List<Map<String, dynamic>> classesForMapel;
  final String? selectedClassId;
  final ValueChanged<String?> onClassChanged;

  const Step1MapelRombelSelector({
    super.key,
    required this.isSingleMapel,
    required this.availableMapels,
    required this.selectedMapelId,
    required this.onMapelChanged,
    required this.classesForMapel,
    required this.selectedClassId,
    required this.onClassChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 3. Mata Pelajaran (Dipilih Dulu)
        const Text(
          'MATA PELAJARAN *',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        if (isSingleMapel && availableMapels.length == 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFECFDF5), Color(0xFFF0FDFA)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF6EE7B7)),
            ),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 8, color: Color(0xFF10B981)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${availableMapels.first['nama_mapel'] ?? '-'}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF064E3B),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA7F3D0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'OTOMATIS',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF065F46),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: availableMapels.any(
                  (m) => int.tryParse('${m['id']}') == selectedMapelId,
                )
                    ? selectedMapelId
                    : null,
                isExpanded: true,
                hint: const Text(
                  '-- Pilih Mata Pelajaran --',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                items: availableMapels.map((m) {
                  final mId = int.tryParse('${m['id']}') ?? 0;
                  return DropdownMenuItem<int>(
                    value: mId,
                    child: Text(
                      '${m['nama_mapel'] ?? '-'}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onMapelChanged,
              ),
            ),
          ),
        const SizedBox(height: 14),

        // 4. Kelas Rombel (Dependent pada Mapel)
        const Text(
          'KELAS ROMBEL *',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        if (selectedMapelId == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
                '-- Pilih Mapel Terlebih Dahulu --',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: classesForMapel.any(
                  (c) => '${c['id']}' == selectedClassId,
                )
                    ? selectedClassId
                    : null,
                isExpanded: true,
                hint: const Text(
                  '-- Pilih Kelas Rombel --',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                items: classesForMapel.map((c) {
                  final cId = '${c['id']}';
                  return DropdownMenuItem<String>(
                    value: cId,
                    child: Text(
                      '${c['name'] ?? '-'}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onClassChanged,
              ),
            ),
          ),
      ],
    );
  }
}

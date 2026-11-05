import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

class SholatBulkStudentItem extends StatelessWidget {
  final Map<String, dynamic> student;
  final bool isHoliday;
  final ValueChanged<String?> onStatusChanged;

  const SholatBulkStudentItem({
    super.key,
    required this.student,
    required this.isHoliday,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isNm = student['is_non_muslim'] == true;
    final gender = student['gender']?.toString() ?? 'L';
    final curStatus = student['status']?.toString() ?? '';
    final isPagiAbsent = student['is_pagi_absent'] == true;

    if (isNm) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFC7D2FE),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                student['name']?.toString() ?? '-',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3730A3),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E7FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Non-Muslim — Tidak Wajib',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4338CA),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['name']?.toString() ?? '-',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          gender == 'P' ? 'Perempuan' : 'Laki-laki',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: gender == 'P'
                                ? const Color(0xFFDB2777)
                                : const Color(0xFF2563EB),
                          ),
                        ),
                        if (isPagiAbsent) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Sinkron Pagi',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Dropdown Status Siswa
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFCBD5E1),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: [
                      'hadir',
                      'ijin',
                      'tidak_hadir',
                      if (gender == 'P') 'haid',
                    ].contains(curStatus)
                        ? curStatus
                        : null,
                    hint: const Text(
                      '-- Pilih --',
                      style: TextStyle(fontSize: 11.5),
                    ),
                    isDense: true,
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: 'hadir',
                        child: Text(
                          'Hadir',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF065F46),
                          ),
                        ),
                      ),
                      const DropdownMenuItem(
                        value: 'ijin',
                        child: Text(
                          'Izin / Sakit',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E40AF),
                          ),
                        ),
                      ),
                      if (gender == 'P')
                        const DropdownMenuItem(
                          value: 'haid',
                          child: Text(
                            '🩸 Halangan / Haid',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF9D174D),
                            ),
                          ),
                        ),
                      const DropdownMenuItem(
                        value: 'tidak_hadir',
                        child: Text(
                          'Alpa',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF9F1239),
                          ),
                        ),
                      ),
                    ],
                    onChanged: isHoliday ? null : onStatusChanged,
                  ),
                ),
              ),
            ],
          ),
          if ((student['keterangan'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Catatan: ${student['keterangan']}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

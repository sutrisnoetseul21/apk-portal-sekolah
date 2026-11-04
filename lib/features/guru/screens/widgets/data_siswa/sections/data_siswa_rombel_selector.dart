import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/data_siswa_filter_model.dart';

/// Dropdown selector tahun ajaran & kelas rombel siswa
class DataSiswaRombelSelector extends StatelessWidget {
  final DataSiswaOptionsModel? options;
  final String? selectedAcademicYearId;
  final String? selectedClassId;
  final ValueChanged<String?> onAcademicYearChanged;
  final ValueChanged<String?> onClassChanged;

  const DataSiswaRombelSelector({
    super.key,
    required this.options,
    required this.selectedAcademicYearId,
    required this.selectedClassId,
    required this.onAcademicYearChanged,
    required this.onClassChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Dropdown Tahun Ajaran
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedAcademicYearId,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                  items: (options?.academicYears ?? []).map((ay) {
                    return DropdownMenuItem<String>(
                      value: ay.id,
                      child: Text(
                        '📅 ${ay.name}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: onAcademicYearChanged,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Dropdown Kelas
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedClassId,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: Color(0xFF2563EB),
                  ),
                  items: (options?.classes ?? []).map((c) {
                    return DropdownMenuItem<String>(
                      value: c.id,
                      child: Text(
                        '🏫 Kelas ${c.name}${c.isWaliKelas ? " (Wali)" : ""}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1D4ED8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: onClassChanged,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

/// Kartu Filter & Pencarian Jurnal Mengajar
class JurnalFilterCard extends StatelessWidget {
  final String academicYearName;
  final bool isSupervisor;
  final List<Map<String, dynamic>> teachers;
  final String? selectedTeacherId;
  final ValueChanged<String?> onTeacherChanged;
  final List<Map<String, dynamic>> availableMonthsList;
  final String selectedMonthYear;
  final ValueChanged<String?> onMonthChanged;
  final bool isSingleMapel;
  final List<Map<String, dynamic>> availableMapels;
  final int? selectedMapelId;
  final ValueChanged<int?> onMapelChanged;
  final List<Map<String, dynamic>> classesForMapel;
  final String? selectedClassId;
  final ValueChanged<String?> onClassChanged;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onSearchCleared;
  final VoidCallback onSearchIconPressed;

  const JurnalFilterCard({
    super.key,
    required this.academicYearName,
    required this.isSupervisor,
    required this.teachers,
    required this.selectedTeacherId,
    required this.onTeacherChanged,
    required this.availableMonthsList,
    required this.selectedMonthYear,
    required this.onMonthChanged,
    required this.isSingleMapel,
    required this.availableMapels,
    required this.selectedMapelId,
    required this.onMapelChanged,
    required this.classesForMapel,
    required this.selectedClassId,
    required this.onClassChanged,
    required this.searchController,
    required this.onSearchSubmitted,
    required this.onSearchCleared,
    required this.onSearchIconPressed,
  });

  static const Color _indigoPrimary = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
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
                    Icons.filter_alt_outlined,
                    size: 17,
                    color: _indigoPrimary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Filter & Pencarian Jurnal',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle, size: 7, color: Color(0xFF10B981)),
                    const SizedBox(width: 5),
                    Text(
                      'TA: $academicYearName',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 22),

          if (isSupervisor && teachers.isNotEmpty) ...[
            const Text(
              'GURU PENGAMPU (MODE SUPERVISI)',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF92400E),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: teachers.any((t) => '${t['id']}' == selectedTeacherId)
                      ? selectedTeacherId
                      : '${teachers.first['id']}',
                  isExpanded: true,
                  items: teachers.map((t) {
                    return DropdownMenuItem<String>(
                      value: '${t['id']}',
                      child: Text(
                        '${t['name']}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: onTeacherChanged,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Baris Bulan KBM & Mata Pelajaran
          Row(
            children: [
              // Bulan KBM
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BULAN KBM',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: availableMonthsList.any(
                            (m) => '${m['key']}' == selectedMonthYear,
                          )
                              ? selectedMonthYear
                              : '',
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem<String>(
                              value: '',
                              child: Text(
                                'Semua Bulan',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            ...availableMonthsList.map((m) {
                              return DropdownMenuItem<String>(
                                value: '${m['key']}',
                                child: Text(
                                  '${m['label']}',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            }),
                          ],
                          onChanged: onMonthChanged,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Mata Pelajaran
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MATA PELAJARAN',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          value: availableMapels.any(
                            (m) => int.tryParse('${m['id']}') == selectedMapelId,
                          )
                              ? selectedMapelId
                              : null,
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text(
                                'Semua Mapel',
                                style: TextStyle(
                                  fontSize: 12.5,
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
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            }),
                          ],
                          onChanged: isSingleMapel ? null : onMapelChanged,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Kelas Rombel (Dependent)
          const Text(
            'KELAS ROMBEL',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: selectedMapelId == null
                  ? const Color(0xFFF1F5F9)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: classesForMapel.any((c) => '${c['id']}' == selectedClassId)
                    ? selectedClassId
                    : null,
                isExpanded: true,
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(
                      selectedMapelId == null
                          ? '-- Pilih Mapel Terlebih Dahulu --'
                          : '-- Semua Kelas Rombel --',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: selectedMapelId == null
                            ? const Color(0xFF94A3B8)
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  ...classesForMapel.map((c) {
                    return DropdownMenuItem<String?>(
                      value: '${c['id']}',
                      child: Text(
                        '${c['name']}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }),
                ],
                onChanged: selectedMapelId == null ? null : onClassChanged,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Cari Materi / Refleksi
          TextField(
            controller: searchController,
            onSubmitted: onSearchSubmitted,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Ketik kata kunci topik materi atau refleksi...',
              hintStyle: const TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 18,
                color: _indigoPrimary,
              ),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 16),
                      onPressed: onSearchCleared,
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: _indigoPrimary,
                      ),
                      onPressed: onSearchIconPressed,
                    ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


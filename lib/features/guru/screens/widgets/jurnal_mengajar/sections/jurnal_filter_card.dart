import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

/// Kartu Filter & Pencarian Jurnal Mengajar (Tab 1: Riwayat Jurnal)
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
      padding: const EdgeInsets.all(15),
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
          const Divider(height: 20),

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
            const SizedBox(height: 10),
          ],

          // Baris Bulan KBM & Mata Pelajaran
          Row(
            children: [
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

          // Kelas Rombel & Pencarian
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: selectedMapelId == null
                        ? const Color(0xFFF1F5F9)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: classesForMapel.any(
                        (c) => '${c['id']}' == selectedClassId,
                      )
                          ? selectedClassId
                          : null,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(
                            selectedMapelId == null
                                ? 'Pilih Mapel Dulu'
                                : 'Semua Kelas',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
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
                              'Kelas ${c['name']}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
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
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 6,
                child: TextField(
                  controller: searchController,
                  onSubmitted: onSearchSubmitted,
                  style: const TextStyle(fontSize: 12.5),
                  decoration: InputDecoration(
                    hintText: 'Cari topik materi...',
                    hintStyle: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF94A3B8),
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 17,
                      color: _indigoPrimary,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 34,
                      minHeight: 34,
                    ),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 15),
                            onPressed: onSearchCleared,
                          )
                        : IconButton(
                            icon: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 15,
                              color: _indigoPrimary,
                            ),
                            onPressed: onSearchIconPressed,
                          ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Strip Ringkasan Kompak di atas Daftar Riwayat Jurnal (Pengganti 3 Kartu KPI Besar)
class JurnalCompactSummaryBar extends StatelessWidget {
  final int totalSesi;
  final int totalJp;
  final int totalTidakHadir;
  final VoidCallback onOpenAnalisaTab;

  const JurnalCompactSummaryBar({
    super.key,
    required this.totalSesi,
    required this.totalJp,
    required this.totalTidakHadir,
    required this.onOpenAnalisaTab,
  });

  static const Color _indigoPrimary = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC7D2FE)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_stories_rounded,
            size: 16,
            color: _indigoPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '$totalSesi Sesi KBM',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E1B4B),
                  ),
                ),
                const Text(
                  '•',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF6366F1),
                  ),
                ),
                Text(
                  '$totalJp JP (${totalJp * 40} Menit)',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4338CA),
                  ),
                ),
                if (totalTidakHadir > 0) ...[
                  const Text(
                    '•',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  Text(
                    '$totalTidakHadir Absen',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ],
              ],
            ),
          ),
          InkWell(
            onTap: onOpenAnalisaTab,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFA5B4FC)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 13,
                    color: _indigoPrimary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Analisa Siswa',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _indigoPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty State Saat Belum Ada Catatan Jurnal Mengajar
class JurnalEmptyState extends StatelessWidget {
  final VoidCallback onTulisJurnal;

  const JurnalEmptyState({
    super.key,
    required this.onTulisJurnal,
  });

  static const Color _indigoPrimary = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _indigoPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 28,
              color: _indigoPrimary,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Belum Ada Catatan Jurnal Mengajar',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Belum ada riwayat pembelajaran yang tercatat pada filter bulan, mata pelajaran, atau kelas yang dipilih.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onTulisJurnal,
            style: ElevatedButton.styleFrom(
              backgroundColor: _indigoPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text(
              'Tulis Jurnal Baru Sekarang',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bar Navigasi Pagination Jurnal Mengajar
class JurnalPaginationBar extends StatelessWidget {
  final int currentPage;
  final int lastPage;
  final int totalItems;
  final ValueChanged<int> onPageChanged;

  const JurnalPaginationBar({
    super.key,
    required this.currentPage,
    required this.lastPage,
    required this.totalItems,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(
            onPressed:
                currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left_rounded, size: 18),
            label: const Text('Sebelumnya', style: TextStyle(fontSize: 12)),
          ),
          Text(
            'Hal $currentPage / $lastPage ($totalItems)',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          OutlinedButton.icon(
            onPressed: currentPage < lastPage
                ? () => onPageChanged(currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right_rounded, size: 18),
            label: const Text('Berikutnya', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

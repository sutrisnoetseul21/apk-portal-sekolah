import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../items/student_jurnal_attendance_tile.dart';

/// Langkah 03: Presensi Siswa di Jam KBM
class Step3PresensiSiswaCard extends StatelessWidget {
  final List<Map<String, dynamic>> students;
  final bool isLoadingStudents;
  final TextEditingController studentSearchController;
  final String studentSearchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onMarkAllHadir;
  final Map<String, TextEditingController> noteControllers;
  final void Function(int realIndex, String status) onSetStatusJurnal;
  final void Function(int realIndex, String? manualStatus) onSetManualStatusBelumAbsen;

  const Step3PresensiSiswaCard({
    super.key,
    required this.students,
    required this.isLoadingStudents,
    required this.studentSearchController,
    required this.studentSearchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onMarkAllHadir,
    required this.noteControllers,
    required this.onSetStatusJurnal,
    required this.onSetManualStatusBelumAbsen,
  });

  static const Color _indigoPrimary = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    final filteredStudents = <MapEntry<int, Map<String, dynamic>>>[];
    for (var i = 0; i < students.length; i++) {
      final s = students[i];
      if (studentSearchQuery.isNotEmpty) {
        final q = studentSearchQuery.toLowerCase();
        final name = '${s['name'] ?? ''}'.toLowerCase();
        final nis = '${s['nis'] ?? ''}'.toLowerCase();
        if (!name.contains(q) && !nis.contains(q)) continue;
      }
      filteredStudents.add(MapEntry(i, s));
    }

    int hadirCount = 0;
    int tidakMengikutiCount = 0;
    for (final s in students) {
      if ('${s['status_jurnal']}' == 'hadir') {
        hadirCount++;
      } else {
        tidakMengikutiCount++;
      }
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
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
          // Header Langkah 03
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF0D9488)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '03',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Flexible(
                          child: Text(
                            'Presensi Siswa di Jam KBM',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${students.length} Siswa',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF065F46),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Terintegrasi otomatis dengan presensi gerbang. Siswa sakit/izin/alpa dikunci demi validitas.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Live Status Legend Chips
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'PETUNJUK:',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF64748B),
                  ),
                ),
                _buildLegendChip(
                  'Hadir Tepat Waktu',
                  const Color(0xFF10B981),
                  const Color(0xFFECFDF5),
                ),
                _buildLegendChip(
                  'Telat Gerbang',
                  const Color(0xFFF59E0B),
                  const Color(0xFFFFFBEB),
                ),
                _buildLegendChip(
                  'Belum Scan Gerbang',
                  const Color(0xFF64748B),
                  const Color(0xFFF1F5F9),
                ),
                _buildLegendChip(
                  'Sakit/Izin/Alpa (Terkunci)',
                  const Color(0xFFE11D48),
                  const Color(0xFFFFF1F2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          if (isLoadingStudents)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: CircularProgressIndicator(color: _indigoPrimary),
              ),
            )
          else if (students.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.groups_2_outlined,
                    size: 40,
                    color: _indigoPrimary,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Daftar Siswa Belum Dimuat',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Silakan pilih Kelas Rombel pada Langkah 01 di atas untuk memuat seluruh peserta didik aktif dan presensi gerbangnya.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // Ringkasan Cepat + Tombol Tandai Semua Hadir KBM
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        'Hadir KBM: $hadirCount',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF059669),
                        ),
                      ),
                      Text(
                        '• Tidak Hadir: $tidakMengikutiCount',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFE11D48),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onMarkAllHadir,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.done_all_rounded, size: 15),
                  label: const Text(
                    'Tandai Semua Hadir KBM',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Pencarian Siswa di Kelas
            TextField(
              controller: studentSearchController,
              onChanged: onSearchChanged,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Cari nama atau NIS siswa di kelas ini...',
                hintStyle: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
                suffixIcon: studentSearchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 16),
                        onPressed: onClearSearch,
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Daftar Kartu Siswa
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredStudents.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final entry = filteredStudents[idx];
                final sId = '${entry.value['student_id']}';
                return StudentJurnalAttendanceTile(
                  realIndex: entry.key,
                  item: entry.value,
                  displayNo: idx + 1,
                  noteController: noteControllers[sId],
                  onSetStatusJurnal: onSetStatusJurnal,
                  onSetManualStatusBelumAbsen: onSetManualStatusBelumAbsen,
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  static Widget _buildLegendChip(String label, Color dotColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: dotColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: dotColor,
            ),
          ),
        ],
      ),
    );
  }
}


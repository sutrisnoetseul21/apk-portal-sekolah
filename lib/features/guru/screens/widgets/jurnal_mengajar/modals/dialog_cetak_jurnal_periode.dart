import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

/// Modal Bottom Sheet Cetak Rekap Laporan Jurnal Mengajar
class DialogCetakJurnalPeriode {
  static const Color _indigoPrimary = Color(0xFF4F46E5);
  static const Color _purpleAccent = Color(0xFF7C3AED);

  static void show(
    BuildContext context, {
    required String currentMonthYear,
    required List<Map<String, dynamic>> availableMonthsList,
    required int? currentMapelId,
    required List<Map<String, dynamic>> availableMapels,
    required String? currentClassId,
    required List<Map<String, dynamic>> allTeachingClasses,
    required String currentTeacherName,
    required void Function({
      required String format,
      required String jenis,
      required String monthYear,
      required String semester,
      int? mapelId,
      String? classId,
    }) onExport,
  }) {
    String cetakJenis = 'bulanan'; // bulanan | semester | tahunan
    String cetakBulanYear = currentMonthYear.isNotEmpty
        ? currentMonthYear
        : (availableMonthsList.isNotEmpty
            ? '${availableMonthsList.first['key']}'
            : '');
    String cetakSemester = DateTime.now().month >= 7 ? 'ganjil' : 'genap';
    int? cetakMapelId = currentMapelId ??
        (availableMapels.length == 1
            ? int.tryParse('${availableMapels.first['id']}')
            : null);
    String? cetakClassId = currentClassId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final classesForModalMapel = <Map<String, dynamic>>[];
            if (cetakMapelId != null) {
              final seen = <String>{};
              for (final c in allTeachingClasses) {
                final mId = int.tryParse('${c['mata_pelajaran_id']}');
                final cId = '${c['id']}';
                if (mId == cetakMapelId && !seen.contains(cId)) {
                  seen.add(cId);
                  classesForModalMapel.add(c);
                }
              }
            }

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Modal Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_indigoPrimary, _purpleAccent],
                        ),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(26),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.print_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cetak Rekap Jurnal Mengajar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Pilih periode dan target kelas KBM yang ingin dicetak',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
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
                                onTap: () =>
                                    setModalState(() => cetakJenis = 'bulanan'),
                              ),
                              const SizedBox(width: 8),
                              _buildPeriodeRadioCard(
                                title: 'Semester',
                                subtitle: 'Ganjil / Genap',
                                isSelected: cetakJenis == 'semester',
                                onTap: () => setModalState(
                                  () => cetakJenis = 'semester',
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildPeriodeRadioCard(
                                title: 'Tahunan',
                                subtitle: '1 Tahun Ajaran',
                                isSelected: cetakJenis == 'tahunan',
                                onTap: () =>
                                    setModalState(() => cetakJenis = 'tahunan'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          if (cetakJenis == 'bulanan' &&
                              availableMonthsList.isNotEmpty)
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
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
                                          (m) =>
                                              '${m['key']}' == cetakBulanYear,
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
                                          if (val != null) {
                                            setModalState(
                                              () => cetakBulanYear = val,
                                            );
                                          }
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
                                      onTap: () => setModalState(
                                        () => cetakSemester = 'ganjil',
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: cetakSemester == 'ganjil'
                                              ? _indigoPrimary
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
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
                                      onTap: () => setModalState(
                                        () => cetakSemester = 'genap',
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: cetakSemester == 'genap'
                                              ? _indigoPrimary
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
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

                          const SizedBox(height: 16),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                  (m) =>
                                      int.tryParse('${m['id']}') ==
                                      cetakMapelId,
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
                                onChanged: (val) {
                                  setModalState(() {
                                    cetakMapelId = val;
                                    cetakClassId = null;
                                  });
                                },
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
                                onChanged: cetakMapelId == null
                                    ? null
                                    : (val) => setModalState(
                                        () => cetakClassId = val,
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Tombol Unduh Excel & Cetak PDF
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                    onExport(
                                      format: 'excel',
                                      jenis: cetakJenis,
                                      monthYear: cetakBulanYear,
                                      semester: cetakSemester,
                                      mapelId: cetakMapelId,
                                      classId: cetakClassId,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF059669),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.table_view_rounded,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Unduh Excel',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                    onExport(
                                      format: 'pdf',
                                      jenis: cetakJenis,
                                      monthYear: cetakBulanYear,
                                      semester: cetakSemester,
                                      mapelId: cetakMapelId,
                                      classId: cetakClassId,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE11D48),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.picture_as_pdf_rounded,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Cetak PDF',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildPeriodeRadioCard({
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


import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

/// Tab 2: Analisa Kelas & Kehadiran Siswa Mendalam pada Jurnal Mengajar
class JurnalAnalisaSection extends StatefulWidget {
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
  final String? selectedClassId;
  final ValueChanged<String?> onClassChanged;
  final bool isLoading;
  final bool isAnalyticsLoading;
  final Map<String, dynamic> overallTotals;
  final List<Map<String, dynamic>> classesSummary;
  final List<Map<String, dynamic>> studentsSummary;
  final ValueChanged<String> onOpenJurnalById;

  const JurnalAnalisaSection({
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
    required this.selectedClassId,
    required this.onClassChanged,
    required this.isLoading,
    required this.isAnalyticsLoading,
    required this.overallTotals,
    required this.classesSummary,
    required this.studentsSummary,
    required this.onOpenJurnalById,
  });

  @override
  State<JurnalAnalisaSection> createState() => _JurnalAnalisaSectionState();
}

class _JurnalAnalisaSectionState extends State<JurnalAnalisaSection> {
  static const Color _indigoPrimary = Color(0xFF4F46E5);

  bool _onlyAbsentStudents = true;
  final TextEditingController _studentSearchController =
      TextEditingController();
  String _studentSearchQuery = '';

  @override
  void dispose() {
    _studentSearchController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _activeTotals {
    final cid = widget.selectedClassId;
    if (cid != null && cid.isNotEmpty) {
      final match = widget.classesSummary.where(
        (c) => '${c['class_id']}' == cid,
      );
      if (match.isNotEmpty) {
        return match.first;
      }
    }
    return widget.overallTotals;
  }

  String get _activeScopeLabel {
    final cid = widget.selectedClassId;
    if (cid != null && cid.isNotEmpty) {
      final match = widget.classesSummary.where(
        (c) => '${c['class_id']}' == cid,
      );
      if (match.isNotEmpty) {
        return 'Kelas ${match.first['class_name'] ?? '-'}';
      }
    }
    return 'Semua Kelas Rombel';
  }

  List<Map<String, dynamic>> get _studentsForSelectedScope {
    final cid = widget.selectedClassId;
    if (cid == null || cid.isEmpty) {
      return widget.studentsSummary;
    }
    return widget.studentsSummary
        .where((s) => '${s['class_id']}' == cid)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final totals = _activeTotals;
    final totalSesi = int.tryParse('${totals['total_sesi'] ?? 0}') ?? 0;
    final totalJp = int.tryParse('${totals['total_jp'] ?? 0}') ?? 0;
    final hadir = int.tryParse('${totals['hadir'] ?? 0}') ?? 0;
    final izin = int.tryParse('${totals['izin'] ?? 0}') ?? 0;
    final sakit = int.tryParse('${totals['sakit'] ?? 0}') ?? 0;
    final izinSakit = izin + sakit;
    final alpa = int.tryParse('${totals['alpa'] ?? 0}') ?? 0;
    final tidakMengikuti =
        int.tryParse('${totals['tidak_mengikuti'] ?? 0}') ?? 0;

    final scopedStudents = _studentsForSelectedScope;
    final absentStudentsCount = scopedStudents
        .where((s) => (int.tryParse('${s['total_absen'] ?? 0}') ?? 0) > 0)
        .length;

    // Jika tidak ada siswa yang pernah absen sama sekali, tampilkan semua siswa otomatis
    final effectiveOnlyAbsent =
        _onlyAbsentStudents && absentStudentsCount > 0;

    final filteredStudents = scopedStudents.where((s) {
      final totalAbsen = int.tryParse('${s['total_absen'] ?? 0}') ?? 0;
      if (effectiveOnlyAbsent && totalAbsen <= 0) {
        return false;
      }
      if (_studentSearchQuery.isNotEmpty) {
        final q = _studentSearchQuery.toLowerCase();
        final name = '${s['student_name'] ?? ''}'.toLowerCase();
        final nis = '${s['nis'] ?? ''}'.toLowerCase();
        final cname = '${s['class_name'] ?? ''}'.toLowerCase();
        return name.contains(q) || nis.contains(q) || cname.contains(q);
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Kartu Filter Bulan & Mapel
        _buildPeriodAndMapelFilter(),
        const SizedBox(height: 12),

        // 2. Baris Chip Pilihan Kelas Rombel (Semua Kelas / Kelas 8A / Kelas 8B)
        if (widget.classesSummary.isNotEmpty) ...[
          _buildClassSelectorChips(),
          const SizedBox(height: 14),
        ],

        if (widget.isLoading || widget.isAnalyticsLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: CircularProgressIndicator(color: _indigoPrimary),
            ),
          )
        else ...[
          // 3. Kotak 2x2 Breakdown Kehadiran KBM (Gaya Portal Siswa)
          _buildAttendance2x2Card(
            scopeLabel: _activeScopeLabel,
            totalSesi: totalSesi,
            totalJp: totalJp,
            hadir: hadir,
            izinSakit: izinSakit,
            izin: izin,
            sakit: sakit,
            alpa: alpa,
            tidakMengikuti: tidakMengikuti,
          ),
          const SizedBox(height: 16),

          // 4. Ringkasan Per Kelas (Muncul jika mode "Semua Kelas" & ada >1 kelas)
          if ((widget.selectedClassId == null ||
                  widget.selectedClassId!.isEmpty) &&
              widget.classesSummary.length > 1) ...[
            _buildPerClassBreakdownSection(),
            const SizedBox(height: 16),
          ],

          // 5. Daftar Analisa Kehadiran Siswa
          _buildStudentAnalyticsSection(
            scopedStudentsCount: scopedStudents.length,
            absentStudentsCount: absentStudentsCount,
            effectiveOnlyAbsent: effectiveOnlyAbsent,
            filteredStudents: filteredStudents,
          ),
        ],
      ],
    );
  }

  Widget _buildPeriodAndMapelFilter() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isSupervisor && widget.teachers.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: widget.teachers.any(
                    (t) => '${t['id']}' == widget.selectedTeacherId,
                  )
                      ? widget.selectedTeacherId
                      : '${widget.teachers.first['id']}',
                  isExpanded: true,
                  items: widget.teachers.map((t) {
                    return DropdownMenuItem<String>(
                      value: '${t['id']}',
                      child: Text(
                        'Guru: ${t['name']}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: widget.onTeacherChanged,
                ),
              ),
            ),
          ],
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PERIODE BULAN KBM',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: widget.availableMonthsList.any(
                            (m) => '${m['key']}' == widget.selectedMonthYear,
                          )
                              ? widget.selectedMonthYear
                              : '',
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem<String>(
                              value: '',
                              child: Text(
                                'Semua Bulan (1 TA)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            ...widget.availableMonthsList.map((m) {
                              return DropdownMenuItem<String>(
                                value: '${m['key']}',
                                child: Text(
                                  '${m['label']}',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            }),
                          ],
                          onChanged: widget.onMonthChanged,
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
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          value: widget.availableMapels.any(
                            (m) =>
                                int.tryParse('${m['id']}') ==
                                widget.selectedMapelId,
                          )
                              ? widget.selectedMapelId
                              : null,
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text(
                                'Semua Mapel',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            ...widget.availableMapels.map((m) {
                              final mId = int.tryParse('${m['id']}');
                              return DropdownMenuItem<int?>(
                                value: mId,
                                child: Text(
                                  '${m['nama_mapel']}',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            }),
                          ],
                          onChanged: widget.isSingleMapel
                              ? null
                              : widget.onMapelChanged,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassSelectorChips() {
    final isAllSelected =
        widget.selectedClassId == null || widget.selectedClassId!.isEmpty;
    final totalAllSesi =
        int.tryParse('${widget.overallTotals['total_sesi'] ?? 0}') ?? 0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildClassChip(
            label: 'Semua Kelas',
            badge: '$totalAllSesi Sesi',
            isSelected: isAllSelected,
            onTap: () => widget.onClassChanged(null),
          ),
          const SizedBox(width: 8),
          ...widget.classesSummary.map((c) {
            final cid = '${c['class_id']}';
            final cname = '${c['class_name'] ?? '-'}';
            final sesi = int.tryParse('${c['total_sesi'] ?? 0}') ?? 0;
            final absenCount =
                int.tryParse('${c['siswa_pernah_absen_count'] ?? 0}') ?? 0;
            final isSelected = widget.selectedClassId == cid;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildClassChip(
                label: 'Kelas $cname',
                badge: absenCount > 0
                    ? '$sesi Sesi • $absenCount Absen'
                    : '$sesi Sesi',
                isSelected: isSelected,
                hasWarning: absenCount > 0,
                onTap: () => widget.onClassChanged(cid),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildClassChip({
    required String label,
    required String badge,
    required bool isSelected,
    bool hasWarning = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? _indigoPrimary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? _indigoPrimary
                : (hasWarning
                      ? const Color(0xFFFECACA)
                      : const Color(0xFFCBD5E1)),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _indigoPrimary.withValues(alpha: 0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.groups_rounded,
              size: 15,
              color: isSelected ? Colors.white : _indigoPrimary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : (hasWarning
                          ? const Color(0xFFFEF2F2)
                          : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? Colors.white
                      : (hasWarning
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF475569)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendance2x2Card({
    required String scopeLabel,
    required int totalSesi,
    required int totalJp,
    required int hadir,
    required int izinSakit,
    required int izin,
    required int sakit,
    required int alpa,
    required int tidakMengikuti,
  }) {
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
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  color: _indigoPrimary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rekap Status KBM • $scopeLabel',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$totalSesi Pertemuan Tercatat • Total $totalJp JP (${totalJp * 40} Menit)',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Kotak 2x2 Status Kehadiran (Seragam dengan Portal Siswa)
          Row(
            children: [
              Expanded(
                child: _buildStatusBox(
                  label: 'HADIR',
                  count: hadir,
                  subtitle: 'Mengikuti KBM',
                  bgColor: const Color(0xFFECFDF5),
                  borderColor: const Color(0xFFA7F3D0),
                  labelColor: const Color(0xFF047857),
                  valueColor: const Color(0xFF065F46),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusBox(
                  label: 'IZIN / SAKIT',
                  count: izinSakit,
                  subtitle: 'Izin: $izin • Sakit: $sakit',
                  bgColor: const Color(0xFFEFF6FF),
                  borderColor: const Color(0xFFBFDBFE),
                  labelColor: const Color(0xFF1D4ED8),
                  valueColor: const Color(0xFF1E40AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatusBox(
                  label: 'ALPA',
                  count: alpa,
                  subtitle: 'Tanpa Keterangan',
                  bgColor: const Color(0xFFFEF2F2),
                  borderColor: const Color(0xFFFECACA),
                  labelColor: const Color(0xFFB91C1C),
                  valueColor: const Color(0xFF991B1B),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusBox(
                  label: 'TIDAK MENGIKUTI',
                  count: tidakMengikuti,
                  subtitle: 'Meninggalkan Kelas',
                  bgColor: const Color(0xFFFFF7ED),
                  borderColor: const Color(0xFFFED7AA),
                  labelColor: const Color(0xFFC2410C),
                  valueColor: const Color(0xFF9A3412),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBox({
    required String label,
    required int count,
    required String subtitle,
    required Color bgColor,
    required Color borderColor,
    required Color labelColor,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              color: labelColor,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: valueColor,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'kali',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: labelColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: labelColor.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerClassBreakdownSection() {
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
          const Row(
            children: [
              Icon(
                Icons.class_outlined,
                size: 17,
                color: _indigoPrimary,
              ),
              SizedBox(width: 6),
              Text(
                'Perbandingan Kehadiran Per Kelas',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Ketuk salah satu kelas untuk melihat analisa mendalam siswa di kelas tersebut.',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          ...widget.classesSummary.map((c) {
            final cid = '${c['class_id']}';
            final cname = '${c['class_name'] ?? '-'}';
            final totalSesi = int.tryParse('${c['total_sesi'] ?? 0}') ?? 0;
            final totalJp = int.tryParse('${c['total_jp'] ?? 0}') ?? 0;
            final hadir = int.tryParse('${c['hadir'] ?? 0}') ?? 0;
            final izinSakit = int.tryParse('${c['izin_sakit'] ?? 0}') ?? 0;
            final alpa = int.tryParse('${c['alpa'] ?? 0}') ?? 0;
            final tidakIkut =
                int.tryParse('${c['tidak_mengikuti'] ?? 0}') ?? 0;
            final siswaAbsenCount =
                int.tryParse('${c['siswa_pernah_absen_count'] ?? 0}') ?? 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => widget.onClassChanged(cid),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _indigoPrimary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Kelas $cname',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$totalSesi Pertemuan • $totalJp JP',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              if (siswaAbsenCount > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFFECACA),
                                    ),
                                  ),
                                  child: Text(
                                    '$siswaAbsenCount Siswa Absen',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFDC2626),
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildMiniCounterPill(
                            'Hadir: $hadir',
                            const Color(0xFFECFDF5),
                            const Color(0xFF047857),
                          ),
                          const SizedBox(width: 6),
                          _buildMiniCounterPill(
                            'Izin/Sakit: $izinSakit',
                            const Color(0xFFEFF6FF),
                            const Color(0xFF1D4ED8),
                          ),
                          const SizedBox(width: 6),
                          _buildMiniCounterPill(
                            'Alpa: $alpa',
                            const Color(0xFFFEF2F2),
                            const Color(0xFFB91C1C),
                          ),
                          const SizedBox(width: 6),
                          _buildMiniCounterPill(
                            'Tdk Ikut: $tidakIkut',
                            const Color(0xFFFFF7ED),
                            const Color(0xFFC2410C),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMiniCounterPill(String text, Color bg, Color fg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: fg,
          ),
        ),
      ),
    );
  }

  Widget _buildStudentAnalyticsSection({
    required int scopedStudentsCount,
    required int absentStudentsCount,
    required bool effectiveOnlyAbsent,
    required List<Map<String, dynamic>> filteredStudents,
  }) {
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
            children: [
              const Icon(
                Icons.person_search_rounded,
                size: 18,
                color: _indigoPrimary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Analisa Kehadiran Siswa ($_activeScopeLabel)',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Toggle Filter: Pernah Tidak Hadir vs Semua Siswa
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _onlyAbsentStudents = true),
                  borderRadius: BorderRadius.circular(11),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: effectiveOnlyAbsent
                          ? const Color(0xFFFEF2F2)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: effectiveOnlyAbsent
                            ? const Color(0xFFF87171)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '⚠️ Pernah Tidak Hadir ($absentStudentsCount)',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: effectiveOnlyAbsent
                            ? const Color(0xFFB91C1C)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _onlyAbsentStudents = false),
                  borderRadius: BorderRadius.circular(11),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: !effectiveOnlyAbsent
                          ? const Color(0xFFEEF2FF)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: !effectiveOnlyAbsent
                            ? _indigoPrimary
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Semua Siswa ($scopedStudentsCount)',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: !effectiveOnlyAbsent
                            ? _indigoPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Pencarian Nama Siswa / NIS
          TextField(
            controller: _studentSearchController,
            onChanged: (val) => setState(() => _studentSearchQuery = val.trim()),
            style: const TextStyle(fontSize: 12.5),
            decoration: InputDecoration(
              hintText: 'Cari nama siswa atau NIS...',
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
                minWidth: 36,
                minHeight: 34,
              ),
              suffixIcon: _studentSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 15),
                      onPressed: () {
                        _studentSearchController.clear();
                        setState(() => _studentSearchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 9,
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
          const SizedBox(height: 12),

          if (scopedStudentsCount == 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 28,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Belum ada data presensi KBM siswa pada periode/kelas ini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else if (filteredStudents.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.verified_rounded,
                    size: 28,
                    color: Color(0xFF15803D),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Tidak ada siswa yang cocok dengan pencarian / filter ketidakhadiran.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF166534),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredStudents.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _buildStudentAnalyticsCard(filteredStudents[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStudentAnalyticsCard(Map<String, dynamic> student) {
    final name = '${student['student_name'] ?? '-'}';
    final nis = '${student['nis'] ?? '-'}';
    final className = '${student['class_name'] ?? '-'}';
    final totalPertemuan =
        int.tryParse('${student['total_pertemuan'] ?? 0}') ?? 0;
    final hadir = int.tryParse('${student['hadir'] ?? 0}') ?? 0;
    final izin = int.tryParse('${student['izin'] ?? 0}') ?? 0;
    final sakit = int.tryParse('${student['sakit'] ?? 0}') ?? 0;
    final izinSakit = izin + sakit;
    final alpa = int.tryParse('${student['alpa'] ?? 0}') ?? 0;
    final tidakIkut = int.tryParse('${student['tidak_mengikuti'] ?? 0}') ?? 0;
    final totalAbsen = int.tryParse('${student['total_absen'] ?? 0}') ?? 0;

    final rawLogs = student['absence_logs'] as List? ?? [];
    final logs = rawLogs
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final hasBolosOrAlpa = tidakIkut > 0 || alpa > 0;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: totalAbsen > 0
            ? (hasBolosOrAlpa
                  ? const Color(0xFFFFFBFB)
                  : const Color(0xFFF8FAFC))
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasBolosOrAlpa
              ? const Color(0xFFFECACA)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Kelas $className',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: _indigoPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'NIS: $nis • $totalPertemuan Sesi',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (totalAbsen > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: hasBolosOrAlpa
                        ? const Color(0xFFFEF2F2)
                        : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: hasBolosOrAlpa
                          ? const Color(0xFFFECACA)
                          : const Color(0xFFBFDBFE),
                    ),
                  ),
                  child: Text(
                    '$totalAbsen Kali Tidak Hadir',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: hasBolosOrAlpa
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF1D4ED8),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '100% Hadir',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF047857),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // 4 Kotak Mini Statistik Siswa
          Row(
            children: [
              _buildMiniCounterPill(
                'Hadir: $hadir',
                const Color(0xFFECFDF5),
                const Color(0xFF047857),
              ),
              const SizedBox(width: 6),
              _buildMiniCounterPill(
                'Izin/Sakit: $izinSakit',
                const Color(0xFFEFF6FF),
                const Color(0xFF1D4ED8),
              ),
              const SizedBox(width: 6),
              _buildMiniCounterPill(
                'Alpa: $alpa',
                const Color(0xFFFEF2F2),
                const Color(0xFFB91C1C),
              ),
              const SizedBox(width: 6),
              _buildMiniCounterPill(
                'Tdk Ikut: $tidakIkut',
                const Color(0xFFFFF7ED),
                const Color(0xFFC2410C),
              ),
            ],
          ),

          // Rincian Pertemuan Tidak Hadir
          if (logs.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RIWAYAT KETIDAKHADIRAN KBM:',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...logs.map((log) {
                    final status = '${log['status'] ?? 'tidak_mengikuti'}';
                    final statusLabel = '${log['status_label'] ?? 'Tidak Mengikuti'}';
                    final tanggalFormatted =
                        '${log['tanggal_formatted'] ?? log['tanggal'] ?? '-'}';
                    final jamKe = '${log['jam_ke_label'] ?? ''}';
                    final materi = '${log['materi'] ?? '-'}';
                    final ket = '${log['keterangan'] ?? ''}'.trim();
                    final jurnalId = '${log['jurnal_id'] ?? ''}';

                    Color badgeBg = const Color(0xFFFFF7ED);
                    Color badgeFg = const Color(0xFFC2410C);
                    if (status == 'alpa') {
                      badgeBg = const Color(0xFFFEF2F2);
                      badgeFg = const Color(0xFFB91C1C);
                    } else if (status == 'sakit' || status == 'izin') {
                      badgeBg = const Color(0xFFEFF6FF);
                      badgeFg = const Color(0xFF1D4ED8);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: InkWell(
                        onTap: jurnalId.isNotEmpty
                            ? () => widget.onOpenJurnalById(jurnalId)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                statusLabel.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: badgeFg,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$tanggalFormatted • $jamKe',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Materi: $materi${ket.isNotEmpty ? ' ($ket)' : ''}',
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

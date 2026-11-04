import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/pdf_print_util.dart';
import '../models/data_siswa_filter_model.dart';
import '../models/student_model.dart';
import '../services/data_siswa_service.dart';
import 'widgets/data_siswa/student_card_widget.dart';

/// Layar Utama Menu 6: Data Siswa (/portal-guru/data-siswa)
class DataSiswaScreen extends StatefulWidget {
  final String teacherName;
  final String? token;
  final String? identifier;
  final String schoolName;

  const DataSiswaScreen({
    super.key,
    required this.teacherName,
    this.token,
    this.identifier,
    required this.schoolName,
  });

  @override
  State<DataSiswaScreen> createState() => _DataSiswaScreenState();
}

class _DataSiswaScreenState extends State<DataSiswaScreen> {
  late final DataSiswaService _service;

  bool _isInitLoading = true;
  bool _isFetchingStudents = false;
  String? _errorMessage;

  DataSiswaOptionsModel? _options;
  String? _selectedAcademicYearId;
  String? _selectedClassId;

  List<StudentModel> _students = [];
  StudentRombelStats? _stats;
  Map<String, dynamic> _currentClassMeta = {};

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  // Filter chips: 'all', 'with_barcode', 'without_barcode', 'missing_nohp'
  String _selectedFilterChip = 'all';

  @override
  void initState() {
    super.initState();
    _service = DataSiswaService.create(
      token: widget.token,
      identifier: widget.identifier,
    );
    _loadOptions();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    setState(() {
      _isInitLoading = true;
      _errorMessage = null;
    });

    try {
      final opts = await _service.getOptions();
      _options = opts;

      // Pilih default tahun ajaran dan kelas
      _selectedAcademicYearId = opts.activeAcademicYearId ??
          (opts.academicYears.isNotEmpty ? opts.academicYears.first.id : null);

      if (opts.classes.isNotEmpty) {
        // Cari kelas yang sesuai tahun ajaran atau default
        final matchClass = opts.classes.firstWhere(
          (c) => c.id == opts.defaultClassId,
          orElse: () => opts.classes.first,
        );
        _selectedClassId = matchClass.id;
      }

      setState(() {
        _isInitLoading = false;
      });

      if (_selectedClassId != null && _selectedAcademicYearId != null) {
        _fetchStudents();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _fetchStudents() async {
    if (_selectedClassId == null || _selectedAcademicYearId == null) return;

    setState(() {
      _isFetchingStudents = true;
      _errorMessage = null;
    });

    try {
      String? filterBarcode;
      String? filterNohp;

      if (_selectedFilterChip == 'with_barcode') {
        filterBarcode = 'yes';
      } else if (_selectedFilterChip == 'without_barcode') {
        filterBarcode = 'no';
      } else if (_selectedFilterChip == 'missing_nohp') {
        filterNohp = 'missing';
      }

      final res = await _service.getStudents(
        classId: _selectedClassId!,
        academicYearId: _selectedAcademicYearId!,
        search: _searchController.text.trim(),
        filterBarcode: filterBarcode,
        filterNohp: filterNohp,
      );

      if (!mounted) return;
      setState(() {
        _students = res.students;
        _stats = res.stats;
        _currentClassMeta = res.kelas;
        _isFetchingStudents = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFetchingStudents = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _onSearchChanged(String val) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _fetchStudents();
    });
  }

  void _onFilterChipChanged(String chipKey) {
    if (_selectedFilterChip == chipKey) return;
    setState(() {
      _selectedFilterChip = chipKey;
    });
    _fetchStudents();
  }

  void _onClassChanged(String? newClassId) {
    if (newClassId == null || newClassId == _selectedClassId) return;
    setState(() {
      _selectedClassId = newClassId;
    });
    _fetchStudents();
  }

  void _onAcademicYearChanged(String? newYearId) {
    if (newYearId == null || newYearId == _selectedAcademicYearId) return;
    setState(() {
      _selectedAcademicYearId = newYearId;
    });
    _fetchStudents();
  }

  void _handleStudentUpdated(StudentModel updated) {
    setState(() {
      final index = _students.indexWhere((s) => s.id == updated.id);
      if (index != -1) {
        _students[index] = updated;
      }
    });
  }

  Future<void> _printOrSavePdf(String url, String title) async {
    await PdfPrintUtil.printOrSavePdf(
      context: context,
      url: url,
      title: title,
      identifier: _service.identifier,
    );
  }

  void _showBatchPrintDialog() {
    if (_selectedClassId == null || _selectedAcademicYearId == null) return;

    final currentClassName = _currentClassMeta['name'] ?? 'Kelas Terpilih';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Cetak / Unduh Massal Rombel',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'Format PDF resmi untuk rombel $currentClassName',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),

                // Opsi 1: Cetak Kartu Siswa 1 Rombel
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.print_rounded,
                        color: Color(0xFF2563EB)),
                  ),
                  title: Text(
                    'Cetak Kartu Pelajar 1 Kelas (PDF)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text('Kartu barcode seluruh siswa kelas ini'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    final url = _service.getCetakKartuMassalUrl(
                      _selectedClassId!,
                      _selectedAcademicYearId!,
                    );
                    _printOrSavePdf(url, 'Kartu Siswa - $currentClassName');
                  },
                ),

                const Divider(height: 1),

                // Opsi 2: Unduh Biodata Lengkap 1 Rombel
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded,
                        color: Color(0xFFDC2626)),
                  ),
                  title: Text(
                    'Unduh Biodata Siswa 1 Kelas (PDF)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle:
                      const Text('Rekap lembar biodata resmi seluruh siswa'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    final url = _service.getCetakBiodataMassalUrl(
                      _selectedClassId!,
                      _selectedAcademicYearId!,
                    );
                    _printOrSavePdf(url, 'Biodata Siswa - $currentClassName');
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentClassName =
        _currentClassMeta['name']?.toString() ?? 'Kelas';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Siswa',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            Text(
              widget.schoolName,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showBatchPrintDialog,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Cetak Massal Rombel',
          ),
          IconButton(
            onPressed: () {
              _fetchStudents();
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan Data',
          ),
        ],
      ),
      body: _isInitLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await _fetchStudents();
              },
              child: Column(
                children: [
                  // 1. SELECTOR TAHUN AJARAN & KELAS (STICKY HEADER)
                  Container(
                    color: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        // Dropdown Tahun Ajaran
                        Expanded(
                          flex: 5,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedAcademicYearId,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down,
                                    size: 18),
                                items: (_options?.academicYears ?? []).map((ay) {
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
                                onChanged: _onAcademicYearChanged,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Dropdown Kelas
                        Expanded(
                          flex: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedClassId,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down,
                                    size: 18, color: Color(0xFF2563EB)),
                                items: (_options?.classes ?? []).map((c) {
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
                                onChanged: _onClassChanged,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. SEARCH & FILTER BAR
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Column(
                      children: [
                        // Search Box
                        TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: 'Cari nama, NISN, atau NIS siswa...',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF94A3B8),
                            ),
                            prefixIcon: const Icon(Icons.search_rounded,
                                size: 20, color: Color(0xFF64748B)),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      _fetchStudents();
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFF2563EB), width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Filter Chips Horisontal
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip(
                                'all',
                                'Semua (${_stats?.totalStudents ?? _students.length})',
                              ),
                              const SizedBox(width: 6),
                              _buildFilterChip(
                                'with_barcode',
                                'Ada Barcode (${_stats?.berbarcode ?? 0})',
                              ),
                              const SizedBox(width: 6),
                              _buildFilterChip(
                                'without_barcode',
                                'Belum Barcode (${_stats?.belumBarcode ?? 0})',
                              ),
                              const SizedBox(width: 6),
                              _buildFilterChip(
                                'missing_nohp',
                                'Belum No. HP',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. STATISTIK ROMBEL WIDGET
                  if (_stats != null) _buildStatsSection(_stats!),

                  // 4. DAFTAR SISWA (LIST INTERAKTIF)
                  Expanded(
                    child: _isFetchingStudents
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : _errorMessage != null
                            ? _buildErrorView()
                            : _students.isEmpty
                                ? _buildEmptyView()
                                : ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 12, 16, 80),
                                    itemCount: _students.length,
                                    itemBuilder: (ctx, index) {
                                      final student = _students[index];
                                      return StudentCardWidget(
                                        student: student,
                                        schoolName: widget.schoolName,
                                        className: currentClassName,
                                        service: _service,
                                        onStudentUpdated: _handleStudentUpdated,
                                      );
                                    },
                                  ),
                  ),
                ],
              ),
            ),
      // FLOATING ACTION BAR: CETAK MASSAL
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showBatchPrintDialog,
                icon: const Icon(Icons.print_rounded, size: 18),
                label: Text(
                  'Cetak Rombel PDF',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilterChip == key;
    return InkWell(
      onTap: () => _onFilterChipChanged(key),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2563EB)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(StudentRombelStats stats) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', '${stats.totalStudents}', const Color(0xFF0F172A)),
          _buildStatItem('Laki-laki', '${stats.lakiLaki}', const Color(0xFF2563EB)),
          _buildStatItem('Perempuan', '${stats.perempuan}', const Color(0xFFDB2777)),
          _buildStatItem(
            'Barcode',
            '${stats.persenBerbarcode}%',
            stats.persenBerbarcode >= 80
                ? const Color(0xFF10B981)
                : const Color(0xFFD97706),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search_rounded,
              size: 54,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada data siswa',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Coba sesuaikan kata kunci pencarian atau filter yang dipilih.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 50,
              color: Color(0xFFE11D48),
            ),
            const SizedBox(height: 12),
            Text(
              'Terjadi Kendala',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? 'Gagal memuat data',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchStudents,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

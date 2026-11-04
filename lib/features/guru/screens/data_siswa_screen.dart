import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/pdf_print_util.dart';
import '../models/data_siswa_filter_model.dart';
import '../models/student_model.dart';
import '../services/data_siswa_service.dart';
import 'widgets/data_siswa/student_card_widget.dart';
import 'widgets/data_siswa/sections/data_siswa_rombel_selector.dart';
import 'widgets/data_siswa/sections/data_siswa_search_filter_bar.dart';
import 'widgets/data_siswa/sections/data_siswa_stats_card.dart';
import 'widgets/data_siswa/modals/modal_batch_print_dialog.dart';

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

    ModalBatchPrintDialog.show(
      context: context,
      className: currentClassName,
      onPrintKartuMassal: () {
        final url = _service.getCetakKartuMassalUrl(
          _selectedClassId!,
          _selectedAcademicYearId!,
        );
        _printOrSavePdf(url, 'Kartu Siswa - $currentClassName');
      },
      onPrintBiodataMassal: () {
        final url = _service.getCetakBiodataMassalUrl(
          _selectedClassId!,
          _selectedAcademicYearId!,
        );
        _printOrSavePdf(url, 'Biodata Siswa - $currentClassName');
      },
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
            onPressed: _fetchStudents,
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
                  // 1. Selector Tahun Ajaran & Kelas
                  DataSiswaRombelSelector(
                    options: _options,
                    selectedAcademicYearId: _selectedAcademicYearId,
                    selectedClassId: _selectedClassId,
                    onAcademicYearChanged: _onAcademicYearChanged,
                    onClassChanged: _onClassChanged,
                  ),

                  // 2. Search & Filter Bar
                  DataSiswaSearchFilterBar(
                    searchController: _searchController,
                    onSearchChanged: _onSearchChanged,
                    onClearSearch: () {
                      _searchController.clear();
                      _fetchStudents();
                    },
                    selectedFilterChip: _selectedFilterChip,
                    onFilterChipChanged: _onFilterChipChanged,
                    totalCount: _stats?.totalStudents ?? _students.length,
                    berbarcodeCount: _stats?.berbarcode ?? 0,
                    belumBarcodeCount: _stats?.belumBarcode ?? 0,
                  ),

                  // 3. Statistik Rombel Widget
                  if (_stats != null) DataSiswaStatsCard(stats: _stats!),

                  // 4. Daftar Siswa
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
      // Floating Bottom Bar: Cetak Massal
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
}

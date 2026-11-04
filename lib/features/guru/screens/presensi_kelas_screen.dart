import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import 'detail_presensi_siswa_screen.dart';
import 'widgets/presensi_kelas/modals/modal_presensi_cetak.dart';
import 'widgets/presensi_kelas/modals/modal_presensi_manual_bulk.dart';
import 'widgets/presensi_kelas/modals/modal_presensi_single_student.dart';
import 'widgets/presensi_kelas/modals/modal_presensi_wa.dart';
import 'widgets/presensi_kelas/presensi_kelas_demo_data.dart';
import 'widgets/presensi_kelas/sections/presensi_daily_attendance.dart';
import 'widgets/presensi_kelas/sections/presensi_filters_card.dart';
import 'widgets/presensi_kelas/sections/presensi_header_banner.dart';
import 'widgets/presensi_kelas/sections/presensi_monthly_matrix.dart';
import 'widgets/presensi_kelas/sections/presensi_stats_section.dart';

/// Halaman Menu 1: Presensi Kelas (Modularized)
/// Mengikuti persis struktur & fitur Blade /portal-guru/akademik (WaliKelasDashboard)
class PresensiKelasScreen extends StatefulWidget {
  final String teacherName;
  final String? token;
  final String? identifier;
  final String schoolName;

  const PresensiKelasScreen({
    super.key,
    required this.teacherName,
    this.token,
    this.identifier,
    this.schoolName = '',
  });

  @override
  State<PresensiKelasScreen> createState() => _PresensiKelasScreenState();
}

class _PresensiKelasScreenState extends State<PresensiKelasScreen> {
  bool _isLoading = true;
  String _rekapMode = 'harian'; // 'harian' | 'bulanan'
  String _dailyFilter = 'all'; // 'all' | 'belum' | 'hadir' | 'telat' | 'izin' | 'alpa'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Filter Data (Tahun Ajaran Dikunci ke Tahun Ajaran Aktif)
  List<Map<String, dynamic>> _academicYears = [];
  String? _selectedAcademicYearId;
  String _selectedAcademicYearName = '-';

  List<Map<String, dynamic>> _classes = [];
  String? _selectedClassId;
  String _selectedClassName = '-';
  String _selectedClassAccessLabel = 'Wali Kelas';
  String _roleSummary = 'Wali Kelas';
  bool _isBk = false;

  List<Map<String, dynamic>> _availableMonths = [];
  String? _selectedMonthYear;
  String _selectedMonthLabel = '';

  // Info Hari Ini & Bulan
  String _todayDate = '';
  String _todayDateLabel = 'Hari Ini';
  int _daysInMonth = 30;
  bool _enableCheckout = true;
  bool _isNotifBelumActive = true;
  bool _isNotifTelatActive = true;

  // Statistik Harian & Bulanan
  Map<String, dynamic> _todayStats = {
    'hadir': 0,
    'telat': 0,
    'izin': 0,
    'sakit': 0,
    'alpa': 0,
    'belum': 0,
    'total': 0,
    'persentase_hadir': 0,
  };

  Map<String, dynamic> _classMonthlyStats = {
    'hadir': 0,
    'telat': 0,
    'izin': 0,
    'sakit': 0,
    'alpa': 0,
    'effective_days': 20,
    'max_possible': 0,
    'total_students': 0,
  };

  List<Map<String, dynamic>> _students = [];

  late final Dio _dio;

  @override
  void initState() {
    super.initState();
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json',
          if (widget.token != null && widget.token!.isNotEmpty)
            'Authorization': 'Bearer ${widget.token}',
          if (widget.identifier != null && widget.identifier!.isNotEmpty)
            'X-User-Identifier': widget.identifier,
        },
      ),
    );
    _loadDashboardData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/guru/presensi/dashboard',
        queryParameters: {
          if (_selectedClassId != null) 'class_id': _selectedClassId,
          if (_selectedMonthYear != null) 'month_year': _selectedMonthYear,
          if (widget.identifier != null) 'identifier': widget.identifier,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _academicYears = List<Map<String, dynamic>>.from(
              (data['academic_years'] as List? ?? [])
                  .map((e) => Map<String, dynamic>.from(e)),
            );
            _selectedAcademicYearId =
                data['selected_academic_year_id']?.toString();
            _selectedAcademicYearName =
                data['selected_academic_year_name']?.toString() ??
                (_academicYears.isNotEmpty
                    ? (_academicYears.first['name']?.toString() ?? '-')
                    : '-');

            _isBk = data['is_bk'] == true;
            _roleSummary = data['role_summary']?.toString() ?? 'Wali Kelas';

            _classes = List<Map<String, dynamic>>.from(
              (data['classes'] as List? ?? [])
                  .map((e) => Map<String, dynamic>.from(e)),
            );
            _selectedClassId = data['selected_class_id']?.toString();
            _selectedClassName =
                data['selected_class_name']?.toString() ?? '-';
            _selectedClassAccessLabel =
                data['selected_class_access_label']?.toString() ?? _roleSummary;

            _availableMonths = List<Map<String, dynamic>>.from(
              (data['available_months'] as List? ?? [])
                  .map((e) => Map<String, dynamic>.from(e)),
            );
            _selectedMonthYear = data['selected_month_year']?.toString();
            _selectedMonthLabel =
                data['selected_month_label']?.toString() ?? '';

            _todayDate = data['today_date']?.toString() ?? '';
            _todayDateLabel =
                data['today_date_label']?.toString() ?? 'Hari Ini';
            _daysInMonth = (data['days_in_month'] as num?)?.toInt() ?? 30;
            _enableCheckout = data['enable_checkout'] == true;
            _isNotifBelumActive = data['is_notif_belum_active'] ?? true;
            _isNotifTelatActive = data['is_notif_telat_active'] ?? true;

            if (data['today_stats'] is Map) {
              _todayStats = Map<String, dynamic>.from(
                data['today_stats'] as Map,
              );
            }
            if (data['class_monthly_stats'] is Map) {
              _classMonthlyStats = Map<String, dynamic>.from(
                data['class_monthly_stats'] as Map,
              );
            }

            _students = List<Map<String, dynamic>>.from(
              (data['students'] as List? ?? [])
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e)),
            );
          });
        }
      }
    } catch (_) {
      // Gunakan data simulasi jika server lokal belum merespons
      if (_students.isEmpty && mounted) {
        _populateFallbackDemoData();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _populateFallbackDemoData() {
    final demo = PresensiKelasDemoData.getFallbackData();
    _academicYears = List<Map<String, dynamic>>.from(demo['academic_years']);
    _selectedAcademicYearId = demo['selected_academic_year_id']?.toString();
    _selectedAcademicYearName = demo['selected_academic_year_name']?.toString() ?? '-';
    _classes = List<Map<String, dynamic>>.from(demo['classes']);
    _selectedClassId = demo['selected_class_id']?.toString();
    _selectedClassName = demo['selected_class_name']?.toString() ?? '-';
    _selectedClassAccessLabel = demo['selected_class_access_label']?.toString() ?? 'Wali Kelas';
    _availableMonths = List<Map<String, dynamic>>.from(demo['available_months']);
    _selectedMonthYear = demo['selected_month_year']?.toString();
    _selectedMonthLabel = demo['selected_month_label']?.toString() ?? '';
    _todayDate = demo['today_date']?.toString() ?? '';
    _todayDateLabel = demo['today_date_label']?.toString() ?? 'Hari Ini';
    _daysInMonth = (demo['days_in_month'] as num?)?.toInt() ?? 31;
    _todayStats = Map<String, dynamic>.from(demo['today_stats']);
    _classMonthlyStats = Map<String, dynamic>.from(demo['class_monthly_stats']);
    _students = List<Map<String, dynamic>>.from(demo['students']);
  }

  List<Map<String, dynamic>> get _filteredStudents {
    return _students.where((s) {
      final name = (s['name']?.toString() ?? '').toLowerCase();
      final nisn = (s['nisn']?.toString() ?? '').toLowerCase();
      final q = _searchQuery.toLowerCase().trim();
      final matchesSearch = q.isEmpty || name.contains(q) || nisn.contains(q);
      if (!matchesSearch) return false;

      if (_rekapMode == 'bulanan') return true;

      final today = Map<String, dynamic>.from(s['today'] ?? {});
      final status = today['status']?.toString() ?? 'belum';

      switch (_dailyFilter) {
        case 'belum':
          return status == 'belum';
        case 'hadir':
          return status == 'hadir';
        case 'telat':
          return status == 'telat';
        case 'izin':
          return status == 'izin' || status == 'sakit';
        case 'alpa':
          return status == 'alpa';
        default:
          return true;
      }
    }).toList();
  }

  void _openStudentDetail(String studentId, String studentName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetailPresensiSiswaScreen(
          studentId: studentId,
          studentName: studentName,
          initialMonthYear: _selectedMonthYear,
          token: widget.token,
          identifier: widget.identifier,
        ),
      ),
    );
  }

  void _openCetakModal() {
    ModalPresensiCetak.show(
      context,
      academicYearId: _selectedAcademicYearId,
      classId: _selectedClassId,
      initialMonthYear: _selectedMonthYear,
      availableMonths: _availableMonths,
    );
  }

  void _openInputManualModal() {
    ModalPresensiManualBulk.show(
      context,
      dio: _dio,
      students: _students,
      todayDate: _todayDate,
      academicYearId: _selectedAcademicYearId,
      selectedClassId: _selectedClassId,
      identifier: widget.identifier,
      initialEnableCheckout: _enableCheckout,
      onPresensiSaved: _loadDashboardData,
    );
  }

  void _openSingleStudentInputModal(Map<String, dynamic> student) {
    ModalPresensiSingleStudent.show(
      context,
      dio: _dio,
      student: student,
      todayDate: _todayDate,
      academicYearId: _selectedAcademicYearId,
      selectedClassId: _selectedClassId,
      selectedClassName: _selectedClassName,
      identifier: widget.identifier,
      initialEnableCheckout: _enableCheckout,
      onPresensiSaved: _loadDashboardData,
    );
  }

  void _openWaModal(Map<String, dynamic> student, String type) {
    ModalPresensiWa.show(
      context,
      dio: _dio,
      student: student,
      type: type,
      selectedClassName: _selectedClassName,
      selectedClassId: _selectedClassId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalToday = (_todayStats['total'] as num?)?.toInt() ?? 0;
    final belumToday = (_todayStats['belum'] as num?)?.toInt() ?? 0;
    final sudahAbsenToday = (totalToday - belumToday).clamp(0, 9999);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Presensi Kelas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.schoolName.isNotEmpty ? widget.schoolName : AppConfig.appName} • Kelas $_selectedClassName',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Muat Ulang',
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Header Banner Card
                    PresensiHeaderBanner(
                      selectedClassName: _selectedClassName,
                      selectedClassAccessLabel: _selectedClassAccessLabel,
                      sudahAbsen: sudahAbsenToday,
                      belumAbsen: belumToday,
                      hasClasses: _classes.isNotEmpty,
                      onOpenCetak: _openCetakModal,
                      onOpenInputManual: _openInputManualModal,
                    ),

                    const SizedBox(height: 14),

                    // 2. Filters Card
                    PresensiFiltersCard(
                      selectedAcademicYearName: _selectedAcademicYearName,
                      classes: _classes,
                      selectedClassId: _selectedClassId,
                      isBk: _isBk,
                      roleSummary: _roleSummary,
                      selectedMonthYear: _selectedMonthYear,
                      availableMonths: _availableMonths,
                      onClassChanged: (val) {
                        final chosen = _classes.firstWhere(
                          (c) => c['id']?.toString() == val,
                          orElse: () => <String, dynamic>{},
                        );
                        setState(() {
                          _selectedClassId = val;
                          if (chosen.isNotEmpty) {
                            _selectedClassName =
                                chosen['name']?.toString() ?? '-';
                            _selectedClassAccessLabel =
                                chosen['access_label']?.toString() ??
                                _roleSummary;
                          }
                        });
                        _loadDashboardData();
                      },
                      onMonthChanged: (val) {
                        setState(() => _selectedMonthYear = val);
                        _loadDashboardData();
                      },
                    ),

                    const SizedBox(height: 16),

                    if (_classes.isEmpty)
                      _buildEmptyClassState()
                    else ...[
                      // 3. Rekapitulasi & 4 Kartu Statistik
                      PresensiStatsSection(
                        rekapMode: _rekapMode,
                        onRekapModeChanged: (mode) {
                          setState(() => _rekapMode = mode);
                        },
                        todayDateLabel: _todayDateLabel,
                        selectedMonthLabel: _selectedMonthLabel,
                        todayStats: _todayStats,
                        classMonthlyStats: _classMonthlyStats,
                        dailyFilter: _dailyFilter,
                        onDailyFilterChanged: (filter) {
                          setState(() => _dailyFilter = filter);
                        },
                        searchController: _searchController,
                        searchQuery: _searchQuery,
                        onSearchQueryChanged: (query) {
                          setState(() => _searchQuery = query);
                        },
                        totalStudents: _students.length,
                      ),

                      const SizedBox(height: 12),

                      if (_rekapMode == 'harian')
                        PresensiDailyAttendance(
                          filteredStudents: _filteredStudents,
                          todayStats: _todayStats,
                          dailyFilter: _dailyFilter,
                          onDailyFilterChanged: (filter) {
                            setState(() => _dailyFilter = filter);
                          },
                          totalStudents: _students.length,
                          isNotifBelumActive: _isNotifBelumActive,
                          isNotifTelatActive: _isNotifTelatActive,
                          onOpenStudentDetail: _openStudentDetail,
                          onOpenWaModal: _openWaModal,
                          onOpenSingleInputModal: _openSingleStudentInputModal,
                        )
                      else
                        PresensiMonthlyMatrix(
                          filteredStudents: _filteredStudents,
                          daysInMonth: _daysInMonth,
                          onOpenStudentDetail: _openStudentDetail,
                        ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyClassState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_rounded,
              size: 34,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Belum Memiliki Kelas Binaan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Anda belum terdaftar mengampu kelas manapun sebagai Wali Kelas maupun Guru BK pada Tahun Ajaran Aktif ($_selectedAcademicYearName). Silakan hubungi Administrator melalui menu Manajemen Akses Portal.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import 'widgets/presensi_sholat/modals/modal_sholat_bulk_input.dart';
import 'widgets/presensi_sholat/modals/modal_sholat_cetak.dart';
import 'widgets/presensi_sholat/modals/modal_sholat_single_student.dart';
import 'widgets/presensi_sholat/modals/modal_sholat_wa.dart';
import 'widgets/presensi_sholat/presensi_sholat_demo_data.dart';
import 'widgets/presensi_sholat/sections/sholat_daily_attendance.dart';
import 'widgets/presensi_sholat/sections/sholat_filters_card.dart';
import 'widgets/presensi_sholat/sections/sholat_header_banner.dart';
import 'widgets/presensi_sholat/sections/sholat_monthly_matrix.dart';
import 'widgets/presensi_sholat/sections/sholat_stats_section.dart';

/// Halaman Menu 2: Presensi Sholat Dhuhur
/// Mengikuti persis struktur & fitur Blade /portal-guru/sholat-dhuhur (WaliKelasSholatDhuhur)
class PresensiSholatDhuhurScreen extends StatefulWidget {
  final String teacherName;
  final String? token;
  final String? identifier;
  final String schoolName;

  const PresensiSholatDhuhurScreen({
    super.key,
    required this.teacherName,
    this.token,
    this.identifier,
    this.schoolName = '',
  });

  @override
  State<PresensiSholatDhuhurScreen> createState() =>
      _PresensiSholatDhuhurScreenState();
}

class _PresensiSholatDhuhurScreenState
    extends State<PresensiSholatDhuhurScreen> {
  bool _isLoading = true;
  bool _isSyncingMorning = false;
  bool _isFeatureDisabled = false;
  String _featureDisabledMessage =
      'Fitur Presensi Sholat Dhuhur sedang dinonaktifkan di Pengaturan Presensi.';

  String _rekapMode = 'harian'; // 'harian' | 'bulanan'
  String _dailyFilter =
      'all'; // 'all' | 'belum' | 'hadir' | 'ijin' | 'tidak_hadir' | 'non_muslim'
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

  List<Map<String, dynamic>> _koordinators = [];
  String? _selectedKoordinatorId;

  // Info Hari Ini & Bulan
  String _selectedDailyDate = '';
  String _todayDateLabel = 'Hari Ini';
  int _daysInMonth = 30;
  bool _isNotifSholatActive = true;

  // Statistik Harian & Bulanan
  Map<String, dynamic> _todayStats = {
    'hadir': 0,
    'ijin': 0,
    'tidak_hadir': 0,
    'belum': 0,
    'total': 0,
    'total_all': 0,
    'non_muslim_count': 0,
    'persentase_hadir': 0,
    'is_holiday': false,
    'holiday_desc': null,
  };

  Map<String, dynamic> _classMonthlyStats = {
    'hadir': 0,
    'ijin': 0,
    'tidak_hadir': 0,
    'effective_days': 20,
    'max_possible': 0,
    'total_students': 0,
    'total_all_students': 0,
    'non_muslim_count': 0,
    'class_percentage': 0,
  };

  List<Map<String, dynamic>> _students = [];

  late final Dio _dio;

  // Warna khas Sholat Dhuhur (Emerald - Teal)
  static const Color _emeraldPrimary = Color(0xFF059669);

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
    setState(() {
      _isLoading = true;
      _isFeatureDisabled = false;
    });
    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/guru/sholat-dhuhur/dashboard',
        queryParameters: {
          if (_selectedClassId != null) 'class_id': _selectedClassId,
          if (_selectedMonthYear != null) 'month_year': _selectedMonthYear,
          if (_selectedDailyDate.isNotEmpty) 'daily_date': _selectedDailyDate,
          if (_selectedKoordinatorId != null)
            'koordinator_id': _selectedKoordinatorId,
          if (widget.identifier != null) 'identifier': widget.identifier,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = Map<String, dynamic>.from(response.data['data'] as Map);
        if (mounted) {
          setState(() {
            _academicYears = List<Map<String, dynamic>>.from(
              (data['academic_years'] as List? ?? [])
                  .whereType<Map>()
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
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e)),
            );
            _selectedClassId = data['selected_class_id']?.toString();
            _selectedClassName =
                data['selected_class_name']?.toString() ?? '-';
            _selectedClassAccessLabel =
                data['selected_class_access_label']?.toString() ?? _roleSummary;

            _availableMonths = List<Map<String, dynamic>>.from(
              (data['available_months'] as List? ?? [])
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e)),
            );
            _selectedMonthYear = data['selected_month_year']?.toString();
            _selectedMonthLabel =
                data['selected_month_label']?.toString() ?? '';

            _koordinators = List<Map<String, dynamic>>.from(
              (data['koordinators'] as List? ?? [])
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e)),
            );
            _selectedKoordinatorId =
                data['selected_koordinator_id']?.toString();

            _selectedDailyDate = data['today_date']?.toString() ?? '';
            _todayDateLabel =
                data['today_date_label']?.toString() ?? 'Hari Ini';
            _daysInMonth = (data['days_in_month'] as num?)?.toInt() ?? 30;
            _isNotifSholatActive = data['is_notif_sholat_active'] == true;

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
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        if (mounted) {
          setState(() {
            _isFeatureDisabled = true;
            _featureDisabledMessage =
                e.response?.data?['message']?.toString() ??
                'Fitur Presensi Sholat Dhuhur sedang dinonaktifkan di Pengaturan Presensi.';
          });
        }
      } else if (_students.isEmpty && mounted) {
        _populateFallbackDemoData();
      }
    } catch (_) {
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
    final fallback = PresensiSholatDemoData.getFallbackData();
    setState(() {
      _academicYears = List<Map<String, dynamic>>.from(
        fallback['academic_years'] as List,
      );
      _selectedAcademicYearId = fallback['selected_academic_year_id']?.toString();
      _selectedAcademicYearName =
          fallback['selected_academic_year_name']?.toString() ?? '-';
      _classes = List<Map<String, dynamic>>.from(fallback['classes'] as List);
      _selectedClassId = fallback['selected_class_id']?.toString();
      _selectedClassName = fallback['selected_class_name']?.toString() ?? '-';
      _selectedClassAccessLabel =
          fallback['selected_class_access_label']?.toString() ?? 'Wali Kelas';
      _availableMonths = List<Map<String, dynamic>>.from(
        fallback['available_months'] as List,
      );
      _selectedMonthYear = fallback['selected_month_year']?.toString();
      _selectedMonthLabel = fallback['selected_month_label']?.toString() ?? '';
      _koordinators = List<Map<String, dynamic>>.from(
        fallback['koordinators'] as List,
      );
      _selectedKoordinatorId = fallback['selected_koordinator_id']?.toString();
      _selectedDailyDate = fallback['selected_daily_date']?.toString() ?? '';
      _todayDateLabel = fallback['today_date_label']?.toString() ?? 'Hari Ini';
      _daysInMonth = (fallback['days_in_month'] as num?)?.toInt() ?? 31;
      _todayStats = Map<String, dynamic>.from(fallback['today_stats'] as Map);
      _classMonthlyStats = Map<String, dynamic>.from(
        fallback['class_monthly_stats'] as Map,
      );
      _students = List<Map<String, dynamic>>.from(fallback['students'] as List);
    });
  }

  /// Sinkronisasi dari Presensi Pagi (HANYA mengambil siswa yang berstatus Izin, Sakit, atau Alpa)
  Future<void> _syncFromMorningAttendance() async {
    if (_selectedClassId == null || _isSyncingMorning) return;

    setState(() => _isSyncingMorning = true);
    try {
      final response = await _dio.post(
        '${AppConfig.baseUrl}/guru/sholat-dhuhur/sync-morning',
        data: {
          'academic_year_id': _selectedAcademicYearId,
          'class_id': _selectedClassId,
          'date': _selectedDailyDate.isNotEmpty
              ? _selectedDailyDate
              : DateTime.now().toIso8601String().substring(0, 10),
          if (widget.identifier != null) 'identifier': widget.identifier,
        },
      );

      final msg =
          response.data?['message']?.toString() ??
          'Sinkronisasi dari presensi pagi selesai.';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: _emeraldPrimary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      await _loadDashboardData();
    } on DioException catch (e) {
      final errMsg =
          e.response?.data?['message']?.toString() ??
          'Gagal menyinkronkan data dari presensi pagi.';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errMsg),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncingMorning = false);
      }
    }
  }

  Future<void> _pickDailyDate() async {
    final initial =
        DateTime.tryParse(_selectedDailyDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final formatted =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() => _selectedDailyDate = formatted);
      _loadDashboardData();
    }
  }

  Future<void> _downloadExport({
    required String jenis,
    String? monthYear,
    String? semester,
  }) async {
    final params = <String, String>{
      if (_selectedAcademicYearId != null)
        'academic_year_id': _selectedAcademicYearId!,
      if (_selectedClassId != null) 'class_id': _selectedClassId!,
      'jenis': jenis,
      if (monthYear != null) 'month_year': monthYear,
      if (semester != null) 'semester': semester,
      if (_selectedDailyDate.isNotEmpty) 'date': _selectedDailyDate,
      if (_selectedKoordinatorId != null)
        'koordinator_id': _selectedKoordinatorId!,
      if (widget.identifier != null && widget.identifier!.isNotEmpty)
        'identifier': widget.identifier!,
    };

    final uri = Uri.parse(
      '${AppConfig.baseUrl}/guru/sholat-dhuhur/export',
    ).replace(queryParameters: params);

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _openCetakModal() {
    ModalSholatCetak.show(
      context,
      academicYearId: _selectedAcademicYearId,
      classId: _selectedClassId,
      initialMonthYear: _selectedMonthYear,
      selectedDailyDate: _selectedDailyDate,
      selectedKoordinatorId: _selectedKoordinatorId,
      identifier: widget.identifier,
      availableMonths: _availableMonths,
    );
  }

  void _openBulkInputModal() {
    if (_selectedClassId == null) return;
    ModalSholatBulkInput.show(
      context,
      dio: _dio,
      academicYearId: _selectedAcademicYearId,
      classId: _selectedClassId,
      selectedClassName: _selectedClassName,
      selectedDailyDate: _selectedDailyDate,
      identifier: widget.identifier,
      onSaved: _loadDashboardData,
    );
  }

  void _openSingleStudentInputModal(Map<String, dynamic> student) {
    ModalSholatSingleStudent.show(
      context,
      dio: _dio,
      student: student,
      selectedClassName: _selectedClassName,
      academicYearId: _selectedAcademicYearId,
      classId: _selectedClassId,
      selectedDailyDate: _selectedDailyDate,
      todayDateLabel: _todayDateLabel,
      onSaved: _loadDashboardData,
    );
  }

  void _openWaModal(Map<String, dynamic> student) {
    ModalSholatWa.show(
      context,
      dio: _dio,
      student: student,
      selectedClassName: _selectedClassName,
    );
  }

  List<Map<String, dynamic>> get _filteredStudents {
    return _students.where((st) {
      final today = st['today'] is Map
          ? Map<String, dynamic>.from(st['today'] as Map)
          : <String, dynamic>{};
      final status = (today['status'] ?? 'belum').toString();

      if (_dailyFilter != 'all') {
        if (_dailyFilter == 'belum' && status != 'belum') return false;
        if (_dailyFilter == 'hadir' && status != 'hadir') return false;
        if (_dailyFilter == 'ijin' && status != 'ijin') return false;
        if (_dailyFilter == 'tidak_hadir' && status != 'tidak_hadir') {
          return false;
        }
        if (_dailyFilter == 'non_muslim' && status != 'non_muslim') {
          return false;
        }
      }

      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final name = (st['name'] ?? '').toString().toLowerCase();
        final nisn = (st['nisn'] ?? '').toString().toLowerCase();
        if (!name.contains(q) && !nisn.contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final hadir = (_todayStats['hadir'] as num?)?.toInt() ?? 0;
    final belum = (_todayStats['belum'] as num?)?.toInt() ?? 0;
    final ijin = (_todayStats['ijin'] as num?)?.toInt() ?? 0;
    final tidakHadir = (_todayStats['tidak_hadir'] as num?)?.toInt() ?? 0;
    final total = (_todayStats['total'] as num?)?.toInt() ?? 0;
    final nonMuslimCount =
        (_todayStats['non_muslim_count'] as num?)?.toInt() ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: _emeraldPrimary,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Presensi Sholat Dhuhur',
              style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
            ),
            Text(
              '${widget.schoolName.isNotEmpty ? widget.schoolName : AppConfig.appName} • $_selectedClassName',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan Data',
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _emeraldPrimary),
            )
          : _isFeatureDisabled
          ? _buildFeatureDisabledState()
          : RefreshIndicator(
              color: _emeraldPrimary,
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. HEADER BANNER EMERALD-TEAL
                    SholatHeaderBanner(
                      selectedClassName: _selectedClassName,
                      selectedClassAccessLabel: _selectedClassAccessLabel,
                      hadir: hadir,
                      belum: belum,
                      isSyncingMorning: _isSyncingMorning,
                      onSyncMorning: _syncFromMorningAttendance,
                      onOpenCetak: _openCetakModal,
                      onOpenBulkInput: _openBulkInputModal,
                    ),
                    const SizedBox(height: 16),

                    // 2. FILTER CARD
                    SholatFiltersCard(
                      selectedAcademicYearName: _selectedAcademicYearName,
                      classes: _classes,
                      isBk: _isBk,
                      selectedClassId: _selectedClassId ?? '',
                      selectedClassName: _selectedClassName,
                      selectedClassAccessLabel: _selectedClassAccessLabel,
                      onClassChanged: (val) {
                        setState(() => _selectedClassId = val);
                        _loadDashboardData();
                      },
                      availableMonths: _availableMonths,
                      selectedMonthYear: _selectedMonthYear ?? '',
                      onMonthChanged: (val) {
                        setState(() => _selectedMonthYear = val);
                        _loadDashboardData();
                      },
                      koordinators: _koordinators,
                      selectedKoordinatorId: _selectedKoordinatorId ?? '',
                      onKoordinatorChanged: (val) {
                        setState(() => _selectedKoordinatorId = val);
                      },
                    ),
                    const SizedBox(height: 18),

                    if (_classes.isEmpty)
                      _buildNoClassAssignedState()
                    else ...[
                      // 3. STATISTIK HARIAN / BULANAN & MODE SWITCHER
                      SholatStatsSection(
                        rekapMode: _rekapMode,
                        onRekapModeChanged: (val) {
                          setState(() => _rekapMode = val);
                        },
                        todayStats: _todayStats,
                        classMonthlyStats: _classMonthlyStats,
                        todayDateLabel: _todayDateLabel,
                        selectedMonthLabel: _selectedMonthLabel,
                        selectedDailyDate: _selectedDailyDate,
                        onPickDailyDate: _pickDailyDate,
                        onDownloadExport: _downloadExport,
                        dailyFilter: _dailyFilter,
                        onDailyFilterChanged: (val) {
                          setState(() => _dailyFilter = val);
                        },
                      ),
                      const SizedBox(height: 16),

                      // 4. DAFTAR SISWA HARIAN ATAU TABEL MATRIKS BULANAN 1-31
                      if (_rekapMode == 'harian')
                        SholatDailyAttendance(
                          searchController: _searchController,
                          searchQuery: _searchQuery,
                          onSearchChanged: (val) {
                            setState(() => _searchQuery = val);
                          },
                          onClearSearch: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          total: total,
                          belum: belum,
                          hadir: hadir,
                          ijin: ijin,
                          tidakHadir: tidakHadir,
                          nonMuslimCount: nonMuslimCount,
                          dailyFilter: _dailyFilter,
                          onDailyFilterChanged: (val) {
                            setState(() => _dailyFilter = val);
                          },
                          filteredStudents: _filteredStudents,
                          isNotifSholatActive: _isNotifSholatActive,
                          token: widget.token,
                          identifier: widget.identifier,
                          onOpenWaModal: _openWaModal,
                          onOpenSingleStudentModal:
                              _openSingleStudentInputModal,
                        )
                      else
                        SholatMonthlyMatrix(
                          daysInMonth: _daysInMonth,
                          students: _students,
                        ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFeatureDisabledState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.mosque_outlined,
                  color: Color(0xFFD97706),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Fitur Sholat Dhuhur Nonaktif',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _featureDisabledMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _emeraldPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Kembali ke Beranda'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoClassAssignedState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.class_outlined,
            size: 42,
            color: Color(0xFF94A3B8),
          ),
          SizedBox(height: 10),
          Text(
            'Belum Ada Kelas Binaan Aktif',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Akun Anda belum memiliki penugasan Wali Kelas atau Kelas Binaan BK pada Tahun Ajaran Aktif ini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import 'detail_presensi_siswa_screen.dart';

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
    this.schoolName = 'SMP Negeri 3 Kedungreja',
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
  static const Color _tealDark = Color(0xFF0F766E);

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
    _academicYears = [
      {'id': 'ay-1', 'name': '2026/2027', 'is_active': true, 'is_locked': true},
    ];
    _selectedAcademicYearId = 'ay-1';
    _selectedAcademicYearName = '2026/2027';
    _classes = [
      {
        'id': 'cls-7a',
        'name': 'Kelas 7A',
        'access_type': 'wali_kelas',
        'access_label': 'Wali Kelas',
      },
    ];
    _selectedClassId = 'cls-7a';
    _selectedClassName = 'Kelas 7A';
    _selectedClassAccessLabel = 'Wali Kelas';
    _availableMonths = [
      {'key': '10-2026', 'label': 'Oktober 2026'},
    ];
    _selectedMonthYear = '10-2026';
    _selectedMonthLabel = 'Oktober 2026';
    _koordinators = [
      {'id': 'guru-pai-1', 'name': 'Drs. H. Asis, M.Pd.I', 'group': 'Guru PAI'},
    ];
    _selectedKoordinatorId = 'guru-pai-1';
    _selectedDailyDate = '2026-10-29';
    _todayDateLabel = 'Kamis, 29 Oktober 2026';
    _daysInMonth = 31;
    _todayStats = {
      'hadir': 2,
      'ijin': 1,
      'tidak_hadir': 0,
      'belum': 1,
      'total': 4,
      'total_all': 4,
      'non_muslim_count': 0,
      'persentase_hadir': 50,
      'is_holiday': false,
    };
    _classMonthlyStats = {
      'hadir': 68,
      'ijin': 8,
      'tidak_hadir': 2,
      'effective_days': 20,
      'max_possible': 80,
      'total_students': 4,
      'class_percentage': 87.2,
    };
    _students = [
      {
        'id': 'st-1',
        'name': 'Ahmad Fauzi Pratama',
        'initials': 'AF',
        'nisn': '0098123401',
        'gender': 'L',
        'religion': 'Islam',
        'is_non_muslim': false,
        'phone_raw': '081234567801',
        'phone_clean': '6281234567801',
        'today': {
          'status': 'hadir',
          'ui_status': 'hadir',
          'is_halangan': false,
          'keterangan': null,
          'time': '12:14',
          'wa_text': '',
        },
        'monthly': {
          'hadir': 18,
          'ijin': 1,
          'tidak_hadir': 0,
          'persentase': 90,
          'is_non_muslim': false,
          'daily': {'1': 'H', '2': 'H', '3': 'L'},
        },
      },
      {
        'id': 'st-2',
        'name': 'Siti Aisyah Putri',
        'initials': 'SA',
        'nisn': '0098123402',
        'gender': 'P',
        'religion': 'Islam',
        'is_non_muslim': false,
        'phone_raw': '081234567802',
        'phone_clean': '6281234567802',
        'today': {
          'status': 'ijin',
          'ui_status': 'haid',
          'is_halangan': true,
          'keterangan': 'Halangan / Haid',
          'time': null,
          'wa_text': '',
        },
        'monthly': {
          'hadir': 15,
          'ijin': 4,
          'tidak_hadir': 0,
          'persentase': 75,
          'is_non_muslim': false,
          'daily': {'1': 'H', '2': 'I', '3': 'L'},
        },
      },
    ];
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
              '${widget.schoolName} • $_selectedClassName',
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
                    // 1. HEADER BANNER EMERALD-TEAL (Mengacu pada header.blade.php)
                    _buildHeaderBanner(),
                    const SizedBox(height: 16),

                    // 2. FILTER CARD (TA Aktif Terkunci + 1 Dropdown Kelas + Bulan + Koordinator PAI)
                    _buildFiltersCard(),
                    const SizedBox(height: 18),

                    if (_classes.isEmpty)
                      _buildNoClassAssignedState()
                    else ...[
                      // 3. STATISTIK HARIAN / BULANAN & MODE SWITCHER
                      _buildStatsSection(),
                      const SizedBox(height: 16),

                      // 4. DAFTAR SISWA HARIAN ATAU TABEL MATRIKS BULANAN 1-31
                      if (_rekapMode == 'harian')
                        _buildDailyAttendanceSection()
                      else
                        _buildMonthlyMatrixSection(),
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

  // =========================================================================
  // 1. HEADER BANNER EMERALD-TEAL (Mengacu pada sholat-dhuhur/header.blade.php)
  // =========================================================================
  Widget _buildHeaderBanner() {
    final hadir = (_todayStats['hadir'] as num?)?.toInt() ?? 0;
    final belum = (_todayStats['belum'] as num?)?.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF065F46), Color(0xFF047857), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _emeraldPrimary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: const Icon(
                  Icons.mosque_rounded,
                  color: Color(0xFF6EE7B7),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Presensi Sholat Dhuhur',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (_selectedClassName != '-')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(
                                alpha: 0.25,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF6EE7B7).withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                            child: Text(
                              '$_selectedClassName • $_selectedClassAccessLabel',
                              style: const TextStyle(
                                color: Color(0xFFD1FAE5),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Pantau ibadah sholat dhuhur berjamaah siswa, catat siswi berhalangan/haid, dan sinkronkan izin/sakit/alpa dari presensi pagi.',
                      style: TextStyle(
                        color: Color(0xFFD1FAE5),
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Indikator Pill Real-Time: Hadir Berjamaah & Belum Sholat
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34D399),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Hadir Berjamaah: $hadir',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: belum > 0
                            ? const Color(0xFFFBBF24)
                            : const Color(0xFF94A3B8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Belum Sholat: $belum',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tombol Aksi Cepat di Header: Sinkron Presensi Pagi, Cetak Laporan, Input Presensi Sholat
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tombol Sinkron Presensi Pagi (Khusus Izin/Sakit/Alpa)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B).withValues(
                    alpha: 0.2,
                  ),
                  foregroundColor: const Color(0xFFFEF3C7),
                  side: BorderSide(
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSyncingMorning
                    ? null
                    : _syncFromMorningAttendance,
                icon: _isSyncingMorning
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFFEF3C7),
                        ),
                      )
                    : const Icon(Icons.sync_rounded, size: 16),
                label: Text(
                  _isSyncingMorning
                      ? 'Menyinkronkan Presensi Pagi...'
                      : 'Sinkron Presensi Pagi (Izin / Sakit / Alpa)',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _openCetakModal,
                      icon: const Icon(Icons.print_outlined, size: 16),
                      label: const Text(
                        'Cetak Laporan',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF065F46),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _openBulkInputModal,
                      icon: const Icon(Icons.edit_note_rounded, size: 17),
                      label: const Text(
                        'Input Presensi',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 2. FILTER CARD (TA Aktif Terkunci + 1 Dropdown Kelas + Bulan + Koordinator)
  // =========================================================================
  Widget _buildFiltersCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Tahun Ajaran Aktif (Terkunci Read-Only)
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 12,
                          color: _emeraldPrimary,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'TAHUN AJARAN AKTIF',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedAcademicYearName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FAE5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'AKTIF',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF065F46),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Pilih Kelas Binaan (1 Dropdown Tunggal jika > 1 kelas, atau Terkunci jika 1 kelas)
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.class_outlined,
                          size: 12,
                          color: _emeraldPrimary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _isBk
                                ? 'PILIH KELAS BINAAN BK (${_classes.length})'
                                : 'PILIH KELAS BINAAN (${_classes.length})',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (_classes.length <= 1)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedClassName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF065F46),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _selectedClassAccessLabel,
                                style: const TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: _emeraldPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedClassId,
                            isExpanded: true,
                            isDense: true,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                            items: _classes.map((cls) {
                              final cId = cls['id']?.toString() ?? '';
                              final cName = cls['name']?.toString() ?? '-';
                              final cLabel =
                                  cls['access_label']?.toString() ?? '';
                              return DropdownMenuItem<String>(
                                value: cId,
                                child: Text(
                                  cLabel.isNotEmpty
                                      ? '$cName ($cLabel)'
                                      : cName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null && val != _selectedClassId) {
                                setState(() => _selectedClassId = val);
                                _loadDashboardData();
                              }
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Bulan Kehadiran & Koordinator PAI
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          size: 12,
                          color: _emeraldPrimary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'BULAN KEHADIRAN',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedMonthYear,
                          isExpanded: true,
                          isDense: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          items: _availableMonths.map((m) {
                            return DropdownMenuItem<String>(
                              value: m['key']?.toString(),
                              child: Text(
                                m['label']?.toString() ?? '-',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null && val != _selectedMonthYear) {
                              setState(() => _selectedMonthYear = val);
                              _loadDashboardData();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_koordinators.isNotEmpty) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.person_pin_outlined,
                            size: 12,
                            color: _emeraldPrimary,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'KOORDINATOR PAI',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _koordinators.any(
                              (k) =>
                                  k['id']?.toString() == _selectedKoordinatorId,
                            )
                                ? _selectedKoordinatorId
                                : _koordinators.first['id']?.toString(),
                            isExpanded: true,
                            isDense: true,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            items: _koordinators.map((k) {
                              return DropdownMenuItem<String>(
                                value: k['id']?.toString(),
                                child: Text(
                                  k['name']?.toString() ?? '-',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedKoordinatorId = val);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 3. STATISTIK HARIAN / BULANAN & MODE SWITCHER (stats-monthly.blade.php)
  // =========================================================================
  Widget _buildStatsSection() {
    final hadir = (_todayStats['hadir'] as num?)?.toInt() ?? 0;
    final ijin = (_todayStats['ijin'] as num?)?.toInt() ?? 0;
    final tidakHadir = (_todayStats['tidak_hadir'] as num?)?.toInt() ?? 0;
    final belum = (_todayStats['belum'] as num?)?.toInt() ?? 0;
    final total = (_todayStats['total'] as num?)?.toInt() ?? 0;
    final persenHadir = (_todayStats['persentase_hadir'] as num?) ?? 0;
    final isHoliday = _todayStats['is_holiday'] == true;
    final holidayDesc = _todayStats['holiday_desc']?.toString();

    final mHadir = (_classMonthlyStats['hadir'] as num?)?.toInt() ?? 0;
    final mIjin = (_classMonthlyStats['ijin'] as num?)?.toInt() ?? 0;
    final mTidakHadir =
        (_classMonthlyStats['tidak_hadir'] as num?)?.toInt() ?? 0;
    final mEffDays =
        (_classMonthlyStats['effective_days'] as num?)?.toInt() ?? 0;
    final mMax = (_classMonthlyStats['max_possible'] as num?)?.toInt() ?? 0;
    final mPct = (_classMonthlyStats['class_percentage'] as num?) ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul & Mode Toggle Pill
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      _rekapMode == 'harian'
                          ? 'Sholat Dhuhur Harian'
                          : 'Rekap Sholat Bulanan',
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _rekapMode == 'harian'
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _rekapMode == 'harian' ? 'Harian' : '1 Bulan',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _rekapMode == 'harian'
                            ? const Color(0xFF065F46)
                            : const Color(0xFF1E40AF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildModeToggleBtn('Harian', 'harian'),
                  _buildModeToggleBtn('Bulanan', 'bulanan'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        if (_rekapMode == 'harian')
          Text(
            'Tanggal: $_todayDateLabel • Wajib Sholat: $total Siswa • Kehadiran: $persenHadir%',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          )
        else
          Text(
            'Potensi Maksimal: $mMax ($total Siswa × $mEffDays Hari Sholat • $_selectedMonthLabel)',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),

        if (_rekapMode == 'harian') ...[
          const SizedBox(height: 10),
          // Action Bar Harian: Pilih Tanggal + Cetak Rekap Kelas PDF + Export Excel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.event_note_rounded,
                      size: 16,
                      color: _emeraldPrimary,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Tanggal Harian:',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: _pickDailyDate,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDailyDate,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 13,
                                color: _emeraldPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _emeraldPrimary,
                          side: const BorderSide(color: Color(0xFFA7F3D0)),
                          backgroundColor: const Color(0xFFECFDF5),
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () =>
                            _downloadExport(jenis: 'rekap_kelas'),
                        icon: const Icon(Icons.picture_as_pdf_outlined, size: 14),
                        label: const Text(
                          'Rekap Kelas (PDF)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF047857),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () =>
                            _downloadExport(jenis: 'excel_harian'),
                        icon: const Icon(Icons.table_view_outlined, size: 14),
                        label: const Text(
                          'Export Excel',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
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

        if (isHoliday && _rekapMode == 'harian') ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFD97706),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tanggal ini adalah Hari Libur Sholat Dhuhur (${holidayDesc ?? 'Libur'}).',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 12),

        // Grid 2x2 Kartu Statistik Berwarna
        if (_rekapMode == 'harian')
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatGradientCard(
                      title: 'Hadir Berjamaah',
                      mainValue: '$hadir',
                      subValue: '/ $total',
                      badgeText: total > 0
                          ? '${((hadir / total) * 100).round()}%'
                          : '0%',
                      icon: Icons.check_circle_outline_rounded,
                      colors: const [Color(0xFF10B981), Color(0xFF0D9488)],
                      isSelected: _dailyFilter == 'hadir',
                      onTap: () {
                        setState(() {
                          _dailyFilter =
                              _dailyFilter == 'hadir' ? 'all' : 'hadir';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatGradientCard(
                      title: 'Ijin / Halangan',
                      mainValue: '$ijin',
                      subValue: '/ $total',
                      badgeText: 'Haid / Sakit',
                      icon: Icons.info_outline_rounded,
                      colors: const [Color(0xFF3B82F6), Color(0xFF4F46E5)],
                      isSelected: _dailyFilter == 'ijin',
                      onTap: () {
                        setState(() {
                          _dailyFilter =
                              _dailyFilter == 'ijin' ? 'all' : 'ijin';
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildStatGradientCard(
                      title: 'Tidak Hadir',
                      mainValue: '$tidakHadir',
                      subValue: '/ $total',
                      badgeText: tidakHadir > 0 ? 'Perlu Pantau' : 'Nihil',
                      icon: Icons.cancel_outlined,
                      colors: const [Color(0xFFF43F5E), Color(0xFFDB2777)],
                      isSelected: _dailyFilter == 'tidak_hadir',
                      onTap: () {
                        setState(() {
                          _dailyFilter = _dailyFilter == 'tidak_hadir'
                              ? 'all'
                              : 'tidak_hadir';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatGradientCard(
                      title: 'Belum Absen Sholat',
                      mainValue: '$belum',
                      subValue: '/ $total',
                      badgeText: belum == 0 ? '✓ Tuntas' : 'Perlu Tindakan',
                      icon: belum == 0
                          ? Icons.verified_rounded
                          : Icons.warning_amber_rounded,
                      colors: belum == 0
                          ? const [Color(0xFF4F46E5), Color(0xFF6D28D9)]
                          : const [Color(0xFF334155), Color(0xFF0F172A)],
                      isSelected: _dailyFilter == 'belum',
                      onTap: () {
                        setState(() {
                          _dailyFilter =
                              _dailyFilter == 'belum' ? 'all' : 'belum';
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          )
        else
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatGradientCard(
                      title: 'Total Hadir',
                      mainValue: '$mHadir',
                      subValue: '/ $mMax',
                      badgeText: mMax > 0
                          ? '${((mHadir / mMax) * 100).toStringAsFixed(1)}%'
                          : '0%',
                      icon: Icons.check_circle_outline_rounded,
                      colors: const [Color(0xFF10B981), Color(0xFF0D9488)],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatGradientCard(
                      title: 'Total Ijin/Halangan',
                      mainValue: '$mIjin',
                      subValue: '/ $mMax',
                      badgeText: mMax > 0
                          ? '${((mIjin / mMax) * 100).toStringAsFixed(1)}%'
                          : '0%',
                      icon: Icons.info_outline_rounded,
                      colors: const [Color(0xFF3B82F6), Color(0xFF4F46E5)],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildStatGradientCard(
                      title: 'Total Alpa',
                      mainValue: '$mTidakHadir',
                      subValue: '/ $mMax',
                      badgeText: mMax > 0
                          ? '${((mTidakHadir / mMax) * 100).toStringAsFixed(1)}%'
                          : '0%',
                      icon: Icons.cancel_outlined,
                      colors: const [Color(0xFFF43F5E), Color(0xFFDB2777)],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatGradientCard(
                      title: '% Kepatuhan',
                      mainValue: '$mPct%',
                      subValue: '',
                      badgeText: '$mEffDays Hari',
                      icon: Icons.bar_chart_rounded,
                      colors: const [Color(0xFF334155), Color(0xFF1E293B)],
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildModeToggleBtn(String label, String modeValue) {
    final active = _rekapMode == modeValue;
    return GestureDetector(
      onTap: () => setState(() => _rekapMode = modeValue),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            color: active ? _emeraldPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildStatGradientCard({
    required String title,
    required String mainValue,
    required String subValue,
    required String badgeText,
    required IconData icon,
    required List<Color> colors,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: isSelected
              ? Border.all(color: Colors.white, width: 2.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: isSelected ? 0.45 : 0.22),
              blurRadius: isSelected ? 14 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  mainValue,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (subValue.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(
                    subValue,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 4A. DAFTAR PRESENSI SHOLAT HARIAN (table.blade.php)
  // =========================================================================
  Widget _buildDailyAttendanceSection() {
    final total = (_todayStats['total'] as num?)?.toInt() ?? 0;
    final belum = (_todayStats['belum'] as num?)?.toInt() ?? 0;
    final hadir = (_todayStats['hadir'] as num?)?.toInt() ?? 0;
    final ijin = (_todayStats['ijin'] as num?)?.toInt() ?? 0;
    final tidakHadir = (_todayStats['tidak_hadir'] as num?)?.toInt() ?? 0;
    final nonMuslimCount =
        (_todayStats['non_muslim_count'] as num?)?.toInt() ?? 0;

    final filtered = _filteredStudents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Kolom Pencarian Nama / NISN
        TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val),
          decoration: InputDecoration(
            hintText: 'Cari nama siswa atau NISN...',
            hintStyle: const TextStyle(fontSize: 12.5),
            prefixIcon: const Icon(Icons.search_rounded, size: 19),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Filter Chips Horizontal
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                label: 'Semua',
                count: total,
                filterKey: 'all',
                activeColor: const Color(0xFF1E293B),
              ),
              const SizedBox(width: 6),
              _buildFilterChip(
                label: 'Belum Sholat',
                count: belum,
                filterKey: 'belum',
                activeColor: const Color(0xFF4F46E5),
              ),
              const SizedBox(width: 6),
              _buildFilterChip(
                label: 'Hadir Berjamaah',
                count: hadir,
                filterKey: 'hadir',
                activeColor: _emeraldPrimary,
              ),
              const SizedBox(width: 6),
              _buildFilterChip(
                label: 'Ijin / Halangan',
                count: ijin,
                filterKey: 'ijin',
                activeColor: const Color(0xFF2563EB),
              ),
              const SizedBox(width: 6),
              _buildFilterChip(
                label: 'Tidak Hadir',
                count: tidakHadir,
                filterKey: 'tidak_hadir',
                activeColor: const Color(0xFFE11D48),
              ),
              if (nonMuslimCount > 0) ...[
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Non-Muslim',
                  count: nonMuslimCount,
                  filterKey: 'non_muslim',
                  activeColor: const Color(0xFF6366F1),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Banner Spesial jika Filter 'belum' dipilih & belum == 0
        if (_dailyFilter == 'belum' && belum == 0)
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFECFDF5), Colors.white, Color(0xFFF0FDFA)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _emeraldPrimary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Alhamdulillah! Seluruh Siswa Sudah Terdata',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Seluruh $total siswa wajib sholat telah tercatat statusnya pada tanggal ini.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _emeraldPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => setState(() => _dailyFilter = 'all'),
                  child: const Text(
                    'Tampilkan Semua Siswa',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),

        // Daftar Kartu Siswa Harian
        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Text(
                'Tidak ada siswa yang sesuai dengan saringan ini.',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          ...filtered.map(_buildStudentDailyCard),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required String filterKey,
    required Color activeColor,
  }) {
    final isSelected = _dailyFilter == filterKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _dailyFilter =
              (_dailyFilter == filterKey && filterKey != 'all')
                  ? 'all'
                  : filterKey;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.22)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentDailyCard(Map<String, dynamic> student) {
    final id = student['id']?.toString() ?? '';
    final name = student['name']?.toString() ?? '-';
    final initials = student['initials']?.toString() ??
        (name.length >= 2
            ? name.substring(0, 2).toUpperCase()
            : name.toUpperCase());
    final nisn = student['nisn']?.toString() ?? '-';
    final gender = student['gender']?.toString() ?? 'L';
    final isNonMuslim = student['is_non_muslim'] == true;

    final today = student['today'] is Map
        ? Map<String, dynamic>.from(student['today'] as Map)
        : <String, dynamic>{};
    final status =
        isNonMuslim ? 'non_muslim' : (today['status'] ?? 'belum').toString();
    final isHalangan = today['is_halangan'] == true ||
        (today['keterangan']?.toString().toLowerCase().contains('haid') ??
            false) ||
        (today['keterangan']?.toString().toLowerCase().contains('halangan') ??
            false);
    final keterangan = today['keterangan']?.toString();
    final time = today['time']?.toString();

    Color badgeBg;
    Color badgeText;
    String badgeLabel;

    if (status == 'non_muslim') {
      badgeBg = const Color(0xFFE0E7FF);
      badgeText = const Color(0xFF4338CA);
      badgeLabel = 'Non-Muslim';
    } else if (status == 'hadir') {
      badgeBg = const Color(0xFFD1FAE5);
      badgeText = const Color(0xFF065F46);
      badgeLabel = time != null && time.isNotEmpty
          ? 'Hadir ($time)'
          : 'Hadir Berjamaah';
    } else if (status == 'ijin') {
      badgeBg = isHalangan ? const Color(0xFFFCE7F3) : const Color(0xFFDBEAFE);
      badgeText =
          isHalangan ? const Color(0xFF9D174D) : const Color(0xFF1E40AF);
      badgeLabel = isHalangan ? 'Halangan / Haid' : 'Ijin / Sakit';
    } else if (status == 'tidak_hadir') {
      badgeBg = const Color(0xFFFFE4E6);
      badgeText = const Color(0xFF9F1239);
      badgeLabel = 'Tidak Hadir';
    } else {
      badgeBg = const Color(0xFFF1F5F9);
      badgeText = const Color(0xFF475569);
      badgeLabel = 'Belum Sholat';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Inisial
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: badgeText,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'NISN: $nisn',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          ' • ',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          gender == 'P' ? 'Perempuan' : 'Laki-laki',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: gender == 'P'
                                ? const Color(0xFFDB2777)
                                : const Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4.5,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: badgeText,
                  ),
                ),
              ),
            ],
          ),

          // Keterangan jika ada (misal: Halangan / Haid, Izin di presensi pagi)
          if (keterangan != null && keterangan.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Text(
                'Keterangan: $keterangan',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),

          // Footer Aksi Cepat: Detail Siswa | WA Ortu + Input Presensi (Pop-up 1 Siswa)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  if (id.isNotEmpty) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DetailPresensiSiswaScreen(
                          studentId: id,
                          studentName: name,
                          token: widget.token,
                          identifier: widget.identifier,
                        ),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Row(
                    children: [
                      Text(
                        'Detail Siswa',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 3),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              if (isNonMuslim)
                const Text(
                  'Tidak Wajib Sholat',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6366F1),
                  ),
                )
              else
                Row(
                  children: [
                    if ((status == 'belum' || status == 'tidak_hadir') &&
                        _isNotifSholatActive) ...[
                      InkWell(
                        onTap: () => _openWaModal(student),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 13,
                                color: Color(0xFF047857),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'WA Ortu',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF047857),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // Tombol Input Presensi / Ubah -> Membuka Pop-Up Khusus 1 Siswa Ini Saja!
                    InkWell(
                      onTap: () => _openSingleStudentInputModal(student),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: (status == 'belum' || status == 'tidak_hadir')
                              ? const Color(0xFFD1FAE5)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                (status == 'belum' || status == 'tidak_hadir')
                                    ? const Color(0xFF6EE7B7)
                                    : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          (status == 'belum' || status == 'tidak_hadir')
                              ? 'Input Presensi'
                              : 'Ubah',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color:
                                (status == 'belum' || status == 'tidak_hadir')
                                    ? const Color(0xFF065F46)
                                    : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 4B. TABEL MATRIKS BULANAN 1-31 (table.blade.php)
  // =========================================================================
  Widget _buildMonthlyMatrixSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.grid_on_rounded,
                      size: 16,
                      color: _emeraldPrimary,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Matriks Presensi Sholat Dhuhur Bulanan (1–31)',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildLegendPill('H: Hadir', const Color(0xFFD1FAE5), const Color(0xFF065F46)),
                    _buildLegendPill('I: Ijin / Halangan', const Color(0xFFDBEAFE), const Color(0xFF1E40AF)),
                    _buildLegendPill('A: Alpa', const Color(0xFFFFE4E6), const Color(0xFF9F1239)),
                    _buildLegendPill('L: Libur', const Color(0xFFF1F5F9), const Color(0xFF64748B)),
                    _buildLegendPill('NM: Non-Muslim', const Color(0xFFE0E7FF), const Color(0xFF4338CA)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              columnSpacing: 10,
              horizontalMargin: 12,
              headingTextStyle: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF475569),
              ),
              dataTextStyle: const TextStyle(
                fontSize: 11,
                color: AppColors.textPrimary,
              ),
              columns: [
                const DataColumn(label: Text('NAMA SISWA')),
                for (int d = 1; d <= _daysInMonth; d++)
                  DataColumn(label: Text('$d')),
                const DataColumn(label: Text('H')),
                const DataColumn(label: Text('I')),
                const DataColumn(label: Text('A')),
                const DataColumn(label: Text('%')),
              ],
              rows: _students.map((st) {
                final name = st['name']?.toString() ?? '-';
                final isNm = st['is_non_muslim'] == true;
                final monthly = st['monthly'] is Map
                    ? Map<String, dynamic>.from(st['monthly'] as Map)
                    : <String, dynamic>{};
                final daily = monthly['daily'] is Map
                    ? Map<String, dynamic>.from(monthly['daily'] as Map)
                    : <String, dynamic>{};
                final hCount = (monthly['hadir'] as num?)?.toInt() ?? 0;
                final iCount = (monthly['ijin'] as num?)?.toInt() ?? 0;
                final aCount = (monthly['tidak_hadir'] as num?)?.toInt() ?? 0;
                final pct = (monthly['persentase'] as num?) ?? 0;

                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 150,
                        child: Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ),
                    for (int d = 1; d <= _daysInMonth; d++)
                      DataCell(
                        _buildMatrixCodeCell(
                          (daily['$d'] ?? '-').toString(),
                        ),
                      ),
                    DataCell(
                      Text(
                        isNm ? '-' : '$hCount',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF065F46),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        isNm ? '-' : '$iCount',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        isNm ? '-' : '$aCount',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF9F1239),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        isNm ? 'NM' : '$pct%',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendPill(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildMatrixCodeCell(String code) {
    Color bg = Colors.transparent;
    Color fg = const Color(0xFFCBD5E1);
    if (code == 'H') {
      bg = const Color(0xFFD1FAE5);
      fg = const Color(0xFF065F46);
    } else if (code == 'I') {
      bg = const Color(0xFFDBEAFE);
      fg = const Color(0xFF1E40AF);
    } else if (code == 'A') {
      bg = const Color(0xFFFFE4E6);
      fg = const Color(0xFF9F1239);
    } else if (code == 'L') {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF94A3B8);
    } else if (code == 'NM') {
      bg = const Color(0xFFE0E7FF);
      fg = const Color(0xFF4338CA);
    }

    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        code,
        style: TextStyle(
          fontSize: code == 'NM' ? 8.5 : 10.5,
          fontWeight: FontWeight.w900,
          color: fg,
        ),
      ),
    );
  }

  // =========================================================================
  // 5. POP-UP INPUT KHUSUS 1 SISWA (Saat Klik Input Presensi / Ubah di Kartu)
  // =========================================================================
  Future<void> _openSingleStudentInputModal(
    Map<String, dynamic> student,
  ) async {
    final studentId = student['id']?.toString() ?? '';
    final studentName = student['name']?.toString() ?? '-';
    final studentNisn = student['nisn']?.toString() ?? '-';
    final gender = student['gender']?.toString() ?? 'L';

    final today = student['today'] is Map
        ? Map<String, dynamic>.from(student['today'] as Map)
        : <String, dynamic>{};

    String selectedStatus = (today['ui_status'] ?? today['status'] ?? 'hadir')
        .toString();
    if (selectedStatus == 'belum' || selectedStatus.isEmpty) {
      selectedStatus = 'hadir';
    }
    final TextEditingController noteCtrl = TextEditingController(
      text: today['keterangan']?.toString() ?? '',
    );
    bool isSaving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Widget buildChoiceChip({
              required String value,
              required String label,
              required IconData icon,
              required Color activeColor,
            }) {
              final isSelected = selectedStatus == value;
              return InkWell(
                onTap: () {
                  setModalState(() {
                    selectedStatus = value;
                    if (value == 'haid' && noteCtrl.text.trim().isEmpty) {
                      noteCtrl.text = 'Halangan / Haid';
                    } else if (value != 'haid' &&
                        noteCtrl.text.trim() == 'Halangan / Haid') {
                      noteCtrl.clear();
                    }
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeColor.withValues(alpha: 0.12)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? activeColor
                          : const Color(0xFFE2E8F0),
                      width: isSelected ? 1.8 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 18,
                        color: isSelected
                            ? activeColor
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected
                                ? FontWeight.w900
                                : FontWeight.w700,
                            color: isSelected
                                ? activeColor
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: activeColor,
                        ),
                    ],
                  ),
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Emerald-Teal
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_emeraldPrimary, _tealDark],
                        ),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(26),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.mosque_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Input Presensi Sholat Siswa',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  'Tanggal: $_todayDateLabel',
                                  style: const TextStyle(
                                    color: Color(0xFFD1FAE5),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
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
                          // Kartu Identitas Siswa
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFFD1FAE5),
                                  foregroundColor: const Color(0xFF065F46),
                                  child: Text(
                                    studentName.isNotEmpty
                                        ? studentName[0].toUpperCase()
                                        : 'S',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        studentName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Kelas $_selectedClassName • NISN: $studentNisn',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'PILIH STATUS SHOLAT DHUHUR',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),

                          buildChoiceChip(
                            value: 'hadir',
                            label: 'Hadir Berjamaah',
                            icon: Icons.check_circle_outline_rounded,
                            activeColor: _emeraldPrimary,
                          ),
                          const SizedBox(height: 8),
                          buildChoiceChip(
                            value: 'ijin',
                            label: 'Izin / Sakit',
                            icon: Icons.info_outline_rounded,
                            activeColor: const Color(0xFF2563EB),
                          ),
                          if (gender == 'P') ...[
                            const SizedBox(height: 8),
                            buildChoiceChip(
                              value: 'haid',
                              label: '🩸 Halangan / Haid (Siswi Perempuan)',
                              icon: Icons.favorite_border_rounded,
                              activeColor: const Color(0xFFDB2777),
                            ),
                          ],
                          const SizedBox(height: 8),
                          buildChoiceChip(
                            value: 'tidak_hadir',
                            label: 'Tidak Hadir / Alpa',
                            icon: Icons.cancel_outlined,
                            activeColor: const Color(0xFFE11D48),
                          ),

                          const SizedBox(height: 14),
                          const Text(
                            'CATATAN / KETERANGAN (OPSIONAL)',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: noteCtrl,
                            decoration: InputDecoration(
                              hintText:
                                  'Contoh: Halangan / Haid, Sakit di UKS, Izin pulang...',
                              hintStyle: const TextStyle(fontSize: 12),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFCBD5E1),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: isSaving
                                      ? null
                                      : () => Navigator.pop(ctx),
                                  child: const Text('Batal'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _emeraldPrimary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: isSaving
                                      ? null
                                      : () async {
                                          setModalState(() => isSaving = true);
                                          try {
                                            final resp = await _dio.post(
                                              '${AppConfig.baseUrl}/guru/sholat-dhuhur/manual-input',
                                              data: {
                                                'academic_year_id':
                                                    _selectedAcademicYearId,
                                                'class_id': _selectedClassId,
                                                'date': _selectedDailyDate
                                                        .isNotEmpty
                                                    ? _selectedDailyDate
                                                    : DateTime.now()
                                                          .toIso8601String()
                                                          .substring(0, 10),
                                                'students': [
                                                  {
                                                    'id': studentId,
                                                    'status': selectedStatus,
                                                    'is_halangan':
                                                        selectedStatus ==
                                                        'haid',
                                                    'keterangan': noteCtrl.text
                                                        .trim(),
                                                  },
                                                ],
                                              },
                                            );
                                            if (ctx.mounted) {
                                              Navigator.pop(ctx);
                                            }
                                            if (mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    resp.data?['message']
                                                            ?.toString() ??
                                                        'Presensi sholat $studentName berhasil disimpan!',
                                                  ),
                                                  backgroundColor:
                                                      _emeraldPrimary,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                            await _loadDashboardData();
                                          } on DioException catch (e) {
                                            setModalState(
                                              () => isSaving = false,
                                            );
                                            if (mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    e.response?.data?['message']
                                                            ?.toString() ??
                                                        'Gagal menyimpan presensi sholat.',
                                                  ),
                                                  backgroundColor: const Color(
                                                    0xFFDC2626,
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                  icon: isSaving
                                      ? const SizedBox(
                                          width: 15,
                                          height: 15,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.save_outlined,
                                          size: 17,
                                        ),
                                  label: Text(
                                    isSaving
                                        ? 'Menyimpan...'
                                        : 'Simpan Presensi',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
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

  // =========================================================================
  // 6. MODAL INPUT MASSAL SELURUH KELAS (modal-input.blade.php)
  // =========================================================================
  Future<void> _openBulkInputModal() async {
    if (_selectedClassId == null) return;

    String modalDate = _selectedDailyDate.isNotEmpty
        ? _selectedDailyDate
        : DateTime.now().toIso8601String().substring(0, 10);
    bool isLoadingModal = true;
    bool isSavingModal = false;
    bool isHoliday = false;
    String holidayDesc = '';
    String bulkStatus = '';
    List<Map<String, dynamic>> inputStudents = [];

    Future<void> loadModalStudents(
      StateSetter setModalState, {
      bool pullMorning = false,
    }) async {
      setModalState(() => isLoadingModal = true);
      try {
        final response = await _dio.get(
          '${AppConfig.baseUrl}/guru/sholat-dhuhur/manual-input',
          queryParameters: {
            'academic_year_id': _selectedAcademicYearId,
            'class_id': _selectedClassId,
            'date': modalDate,
            if (pullMorning) 'pull_morning': 1,
            if (widget.identifier != null) 'identifier': widget.identifier,
          },
        );

        if (response.statusCode == 200 && response.data['success'] == true) {
          final d = Map<String, dynamic>.from(response.data['data'] as Map);
          setModalState(() {
            isHoliday = d['is_holiday'] == true;
            holidayDesc = d['holiday_desc']?.toString() ?? '';
            inputStudents = List<Map<String, dynamic>>.from(
              (d['students'] as List? ?? [])
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e)),
            );
            isLoadingModal = false;
          });
          if (pullMorning && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  response.data['message']?.toString() ??
                      'Data Izin/Sakit/Alpa presensi pagi berhasil ditarik.',
                ),
                backgroundColor: _emeraldPrimary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (_) {
        setModalState(() => isLoadingModal = false);
      }
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        bool initialized = false;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            if (!initialized) {
              initialized = true;
              Future.microtask(() => loadModalStudents(setModalState));
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.88,
              minChildSize: 0.55,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(26),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Modal Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_emeraldPrimary, _tealDark],
                          ),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(26),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.playlist_add_check_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Input Presensi Sholat Dhuhur (1 Kelas)',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    'Kelas $_selectedClassName • Pencatatan Ibadah Berjamaah',
                                    style: const TextStyle(
                                      color: Color(0xFFD1FAE5),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(ctx),
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bar Tanggal, Sinkron Presensi Pagi, dan Set Massal
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                          color: Color(0xFFECFDF5),
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFA7F3D0)),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: ctx,
                                        initialDate:
                                            DateTime.tryParse(modalDate) ??
                                            DateTime.now(),
                                        firstDate: DateTime(2023),
                                        lastDate: DateTime(2030),
                                      );
                                      if (picked != null) {
                                        modalDate =
                                            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                                        await loadModalStudents(setModalState);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFFA7F3D0),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today_rounded,
                                            size: 14,
                                            color: _emeraldPrimary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            modalDate,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (!isHoliday)
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFEF3C7),
                                      foregroundColor: const Color(0xFF92400E),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: const BorderSide(
                                          color: Color(0xFFFDE68A),
                                        ),
                                      ),
                                    ),
                                    onPressed: () => loadModalStudents(
                                      setModalState,
                                      pullMorning: true,
                                    ),
                                    icon: const Icon(
                                      Icons.sync_rounded,
                                      size: 15,
                                    ),
                                    label: const Text(
                                      'Sinkron Pagi (Izin/Alpa)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (isHoliday)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Hari Libur Sholat: ${holidayDesc.isNotEmpty ? holidayDesc : 'Libur'} (Input Dinonaktifkan)',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF991B1B),
                                  ),
                                ),
                              )
                            else
                              Row(
                                children: [
                                  const Text(
                                    'Set Massal:',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF065F46),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFF6EE7B7),
                                        ),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: bulkStatus.isEmpty
                                              ? null
                                              : bulkStatus,
                                          hint: const Text(
                                            '-- Pilih Set Massal --',
                                            style: TextStyle(fontSize: 11.5),
                                          ),
                                          isExpanded: true,
                                          isDense: true,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 6,
                                          ),
                                          items: const [
                                            DropdownMenuItem(
                                              value: 'hadir',
                                              child: Text(
                                                '⚡ Hadir Berjamaah Semua',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: 'ijin',
                                              child: Text(
                                                'Izin Semua',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: 'tidak_hadir',
                                              child: Text(
                                                'Alpa Semua',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                          onChanged: (val) {
                                            if (val == null) return;
                                            setModalState(() {
                                              bulkStatus = val;
                                              for (final st in inputStudents) {
                                                if (st['is_non_muslim'] ==
                                                    true) {
                                                  continue;
                                                }
                                                st['status'] = val;
                                                st['is_halangan'] = false;
                                                if (st['keterangan'] ==
                                                    'Halangan / Haid') {
                                                  st['keterangan'] = '';
                                                }
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                      // Body Daftar Siswa
                      Expanded(
                        child: isLoadingModal
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: _emeraldPrimary,
                                ),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                padding: const EdgeInsets.all(14),
                                itemCount: inputStudents.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (_, idx) {
                                  final st = inputStudents[idx];
                                  final isNm = st['is_non_muslim'] == true;
                                  final gender =
                                      st['gender']?.toString() ?? 'L';
                                  final curStatus =
                                      st['status']?.toString() ?? '';
                                  final isPagiAbsent =
                                      st['is_pagi_absent'] == true;

                                  if (isNm) {
                                    return Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEEF2FF),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFC7D2FE),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              st['name']?.toString() ?? '-',
                                              style: const TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF3730A3),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE0E7FF),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Non-Muslim — Tidak Wajib',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF4338CA),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    st['name']?.toString() ??
                                                        '-',
                                                    style: const TextStyle(
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        gender == 'P'
                                                            ? 'Perempuan'
                                                            : 'Laki-laki',
                                                        style: TextStyle(
                                                          fontSize: 10.5,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: gender == 'P'
                                                              ? const Color(
                                                                  0xFFDB2777,
                                                                )
                                                              : const Color(
                                                                  0xFF2563EB,
                                                                ),
                                                        ),
                                                      ),
                                                      if (isPagiAbsent) ...[
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 6,
                                                                vertical: 1,
                                                              ),
                                                          decoration:
                                                              BoxDecoration(
                                                                color:
                                                                    const Color(
                                                                      0xFFFEF3C7,
                                                                    ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      6,
                                                                    ),
                                                              ),
                                                          child: const Text(
                                                            'Sinkron Pagi',
                                                            style: TextStyle(
                                                              fontSize: 9.5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              color: Color(
                                                                0xFF92400E,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Dropdown Status Siswa
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF8FAFC),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFFCBD5E1,
                                                  ),
                                                ),
                                              ),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  value:
                                                      [
                                                        'hadir',
                                                        'ijin',
                                                        'tidak_hadir',
                                                        if (gender == 'P')
                                                          'haid',
                                                      ].contains(curStatus)
                                                      ? curStatus
                                                      : null,
                                                  hint: const Text(
                                                    '-- Pilih --',
                                                    style: TextStyle(
                                                      fontSize: 11.5,
                                                    ),
                                                  ),
                                                  isDense: true,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 6,
                                                      ),
                                                  items: [
                                                    const DropdownMenuItem(
                                                      value: 'hadir',
                                                      child: Text(
                                                        'Hadir',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color: Color(
                                                            0xFF065F46,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const DropdownMenuItem(
                                                      value: 'ijin',
                                                      child: Text(
                                                        'Izin / Sakit',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color: Color(
                                                            0xFF1E40AF,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    if (gender == 'P')
                                                      const DropdownMenuItem(
                                                        value: 'haid',
                                                        child: Text(
                                                          '🩸 Halangan / Haid',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color: Color(
                                                              0xFF9D174D,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    const DropdownMenuItem(
                                                      value: 'tidak_hadir',
                                                      child: Text(
                                                        'Alpa',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color: Color(
                                                            0xFF9F1239,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  onChanged: isHoliday
                                                      ? null
                                                      : (val) {
                                                          if (val == null) {
                                                            return;
                                                          }
                                                          setModalState(() {
                                                            st['status'] = val;
                                                            if (val == 'haid') {
                                                              st['is_halangan'] =
                                                                  true;
                                                              st['keterangan'] =
                                                                  'Halangan / Haid';
                                                            } else {
                                                              st['is_halangan'] =
                                                                  false;
                                                              if (st['keterangan'] ==
                                                                  'Halangan / Haid') {
                                                                st['keterangan'] =
                                                                    '';
                                                              }
                                                            }
                                                          });
                                                        },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if ((st['keterangan'] ?? '')
                                            .toString()
                                            .isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            'Catatan: ${st['keterangan']}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),

                      // Footer Simpan Massal
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(
                            top: BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isSavingModal
                                    ? null
                                    : () => Navigator.pop(ctx),
                                child: const Text('Batal'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _emeraldPrimary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: (isHoliday || isSavingModal)
                                    ? null
                                    : () async {
                                        setModalState(
                                          () => isSavingModal = true,
                                        );
                                        try {
                                          final resp = await _dio.post(
                                            '${AppConfig.baseUrl}/guru/sholat-dhuhur/manual-input',
                                            data: {
                                              'academic_year_id':
                                                  _selectedAcademicYearId,
                                              'class_id': _selectedClassId,
                                              'date': modalDate,
                                              'students': inputStudents,
                                            },
                                          );
                                          if (ctx.mounted) Navigator.pop(ctx);
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  resp.data?['message']
                                                          ?.toString() ??
                                                      'Presensi sholat kelas berhasil disimpan!',
                                                ),
                                                backgroundColor:
                                                    _emeraldPrimary,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                          await _loadDashboardData();
                                        } on DioException catch (e) {
                                          setModalState(
                                            () => isSavingModal = false,
                                          );
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  e.response?.data?['message']
                                                          ?.toString() ??
                                                      'Gagal menyimpan presensi.',
                                                ),
                                                backgroundColor: const Color(
                                                  0xFFDC2626,
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                icon: const Icon(Icons.save_outlined, size: 17),
                                label: Text(
                                  isSavingModal
                                      ? 'Menyimpan...'
                                      : 'Simpan Presensi Kelas',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // =========================================================================
  // 7. MODAL KIRIM WHATSAPP SHOLAT DHUHUR KE ORANG TUA
  // =========================================================================
  Future<void> _openWaModal(Map<String, dynamic> student) async {
    final studentId = student['id']?.toString() ?? '';
    final studentName = student['name']?.toString() ?? '-';
    final studentNisn = student['nisn']?.toString() ?? '-';
    final today = student['today'] is Map
        ? Map<String, dynamic>.from(student['today'] as Map)
        : <String, dynamic>{};
    final originalText = today['wa_text']?.toString() ?? '';
    final phoneCtrl = TextEditingController(
      text: (student['phone_clean'] ?? student['phone_raw'] ?? '').toString(),
    );
    final msgCtrl = TextEditingController(text: originalText);
    bool isSaving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_emeraldPrimary, _tealDark],
                        ),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(26),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.chat_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Kirim WA Sholat Dhuhur ke Ortu',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
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
                          Text(
                            '$studentName (Kelas $_selectedClassName • NISN: $studentNisn)',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Nomor WhatsApp Orang Tua',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: msgCtrl,
                            maxLines: 5,
                            decoration: InputDecoration(
                              labelText: 'Isi Pesan WhatsApp',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    String clean = phoneCtrl.text.replaceAll(
                                      RegExp(r'[^0-9]'),
                                      '',
                                    );
                                    if (clean.startsWith('0')) {
                                      clean = '62${clean.substring(1)}';
                                    }
                                    final uri = Uri.parse(
                                      'https://wa.me/$clean?text=${Uri.encodeComponent(msgCtrl.text)}',
                                    );
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.open_in_new_rounded,
                                    size: 16,
                                  ),
                                  label: const Text('Buka Aplikasi WA'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _emeraldPrimary,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: isSaving
                                      ? null
                                      : () async {
                                          setModalState(() => isSaving = true);
                                          try {
                                            final resp = await _dio.post(
                                              '${AppConfig.baseUrl}/guru/sholat-dhuhur/send-wa',
                                              data: {
                                                'student_id': studentId,
                                                'phone': phoneCtrl.text.trim(),
                                                'message': msgCtrl.text.trim(),
                                                'type': 'sholat_dhuhur',
                                              },
                                            );
                                            if (ctx.mounted) Navigator.pop(ctx);
                                            if (mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    resp.data?['message']
                                                            ?.toString() ??
                                                        'Pesan WhatsApp terkirim!',
                                                  ),
                                                  backgroundColor:
                                                      _emeraldPrimary,
                                                ),
                                              );
                                            }
                                          } on DioException catch (e) {
                                            setModalState(
                                              () => isSaving = false,
                                            );
                                            if (mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    e.response?.data?['message']
                                                            ?.toString() ??
                                                        'Gagal mengirim via gateway.',
                                                  ),
                                                  backgroundColor: const Color(
                                                    0xFFDC2626,
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                  icon: const Icon(Icons.send_rounded, size: 16),
                                  label: Text(
                                    isSaving ? 'Mengirim...' : 'Kirim Gateway',
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

  // =========================================================================
  // 8. MODAL CETAK LAPORAN SHOLAT DHUHUR (modal-cetak.blade.php)
  // =========================================================================
  Future<void> _downloadExport({
    required String jenis,
    String? monthYear,
    String? semester,
  }) async {
    final params = <String, String>{
      'academic_year_id': ?_selectedAcademicYearId,
      'class_id': ?_selectedClassId,
      'jenis': jenis,
      'month_year': ?monthYear,
      'semester': ?semester,
      if (_selectedDailyDate.isNotEmpty) 'date': _selectedDailyDate,
      'koordinator_id': ?_selectedKoordinatorId,
      if (widget.identifier != null && widget.identifier!.isNotEmpty)
        'identifier': widget.identifier!,
    };

    final uri = Uri.parse(
      '${AppConfig.baseUrl}/guru/sholat-dhuhur/export',
    ).replace(queryParameters: params);

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openCetakModal() async {
    String cetakJenis = 'bulanan'; // 'bulanan' | 'semester'
    String cetakMonthYear =
        _selectedMonthYear ??
        (_availableMonths.isNotEmpty
            ? _availableMonths.first['key'].toString()
            : '10-2026');
    String cetakSemester = DateTime.now().month >= 7 ? 'ganjil' : 'genap';

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Cetak Laporan Sholat Dhuhur (PDF Landscape)',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () =>
                              setModalState(() => cetakJenis = 'bulanan'),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cetakJenis == 'bulanan'
                                  ? const Color(0xFFECFDF5)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: cetakJenis == 'bulanan'
                                    ? _emeraldPrimary
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: const Column(
                              children: [
                                Text(
                                  'Bulanan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'Matriks Harian 1-31',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () =>
                              setModalState(() => cetakJenis = 'semester'),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cetakJenis == 'semester'
                                  ? const Color(0xFFECFDF5)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: cetakJenis == 'semester'
                                    ? _emeraldPrimary
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: const Column(
                              children: [
                                Text(
                                  'Semester',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'Rekapitulasi 6 Bulan',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (cetakJenis == 'bulanan' && _availableMonths.isNotEmpty)
                    DropdownButtonFormField<String>(
                      initialValue: cetakMonthYear,
                      decoration: InputDecoration(
                        labelText: 'Pilih Bulan Laporan',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _availableMonths
                          .map(
                            (m) => DropdownMenuItem(
                              value: m['key'].toString(),
                              child: Text(m['label'].toString()),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setModalState(() => cetakMonthYear = v);
                      },
                    )
                  else
                    DropdownButtonFormField<String>(
                      initialValue: cetakSemester,
                      decoration: InputDecoration(
                        labelText: 'Pilih Semester',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'ganjil',
                          child: Text('Semester Ganjil (Juli - Desember)'),
                        ),
                        DropdownMenuItem(
                          value: 'genap',
                          child: Text('Semester Genap (Januari - Juni)'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) setModalState(() => cetakSemester = v);
                      },
                    ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _emeraldPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _downloadExport(
                        jenis: cetakJenis,
                        monthYear: cetakMonthYear,
                        semester: cetakSemester,
                      );
                    },
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text(
                      'Unduh Laporan PDF',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

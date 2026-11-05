import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../models/siswa_akademik_model.dart';
import '../models/siswa_presensi_kbm_model.dart';
import '../models/siswa_sholat_model.dart';
import '../services/siswa_dashboard_service.dart';
import 'widgets/presensi_siswa/sections/presensi_siswa_month_selector.dart';
import 'widgets/presensi_siswa/sections/presensi_siswa_stats_card.dart';
import 'widgets/presensi_siswa/sections/presensi_siswa_calendar_card.dart';
import 'widgets/presensi_siswa/sections/presensi_siswa_recent_activity.dart';
import 'widgets/presensi_siswa/sections/sholat_siswa_stats_card.dart';
import 'widgets/presensi_siswa/sections/sholat_siswa_calendar_card.dart';
import 'widgets/presensi_siswa/sections/kbm_siswa_summary_card.dart';
import 'widgets/presensi_siswa/sections/kbm_siswa_subject_list.dart';
import 'widgets/presensi_siswa/modals/sheet_presensi_siswa_day_detail.dart';
import 'widgets/presensi_siswa/modals/sheet_sholat_siswa_day_detail.dart';

enum SiswaPresensiTabType {
  harian,
  sholat,
  kbm,
}

/// Layar Menu 1: Presensi & Akademik Siswa
/// Mendukung 3 Tab Dinamis:
/// 1. Presensi Harian (Masuk & Pulang)
/// 2. Sholat Dhuhur Berjamaah (Jika diaktifkan di admin)
/// 3. Presensi KBM / Mapel (Jika diaktifkan di admin)
class PresensiSiswaScreen extends StatefulWidget {
  final String identifier;
  final String studentName;
  final String schoolName;
  final String? token;
  final String? schoolLogoUrl;
  final String? schoolLogoBase64;
  final int initialTabIndex;

  const PresensiSiswaScreen({
    super.key,
    required this.identifier,
    required this.studentName,
    this.schoolName = '',
    this.token,
    this.schoolLogoUrl,
    this.schoolLogoBase64,
    this.initialTabIndex = 0,
  });

  @override
  State<PresensiSiswaScreen> createState() => _PresensiSiswaScreenState();
}

class _PresensiSiswaScreenState extends State<PresensiSiswaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late SiswaDashboardService _service;

  // State Tab 1: Presensi Harian
  bool _isLoading = true;
  String? _errorMessage;
  SiswaAkademikDashboardResponse? _data;
  String? _selectedMonthYearKey;

  // State Tab 2: Sholat Dhuhur
  bool _isSholatLoading = true;
  String? _sholatErrorMessage;
  SiswaSholatDashboardResponse? _sholatData;
  String? _selectedSholatMonthYearKey;

  // State Tab 3: Presensi KBM (per Mapel)
  bool _isKbmLoading = true;
  String? _kbmErrorMessage;
  SiswaPresensiKbmResponse? _kbmData;
  String? _selectedKbmMonthYearKey;

  // Saklar Fitur dari Admin
  bool _enableSholatDhuhur = true;
  bool _enablePresensiKbm = true;

  List<SiswaPresensiTabType> get _activeTabs {
    final tabs = <SiswaPresensiTabType>[SiswaPresensiTabType.harian];
    if (_enableSholatDhuhur) {
      tabs.add(SiswaPresensiTabType.sholat);
    }
    if (_enablePresensiKbm) {
      tabs.add(SiswaPresensiTabType.kbm);
    }
    return tabs;
  }

  @override
  void initState() {
    super.initState();
    _service = SiswaDashboardService.create(
      token: widget.token,
      identifier: widget.identifier,
    );

    final tabs = _activeTabs;
    final initialIdx = widget.initialTabIndex.clamp(0, tabs.length - 1);

    _tabController = TabController(
      length: tabs.length,
      vsync: this,
      initialIndex: initialIdx,
    );

    _loadData();
    _loadSholatData();
    _loadKbmData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateSettings({bool? enableSholat, bool? enableKbm}) {
    bool changed = false;
    if (enableSholat != null && enableSholat != _enableSholatDhuhur) {
      _enableSholatDhuhur = enableSholat;
      changed = true;
    }
    if (enableKbm != null && enableKbm != _enablePresensiKbm) {
      _enablePresensiKbm = enableKbm;
      changed = true;
    }
    if (changed) {
      final activeCount = _activeTabs.length;
      if (_tabController.length != activeCount) {
        final currentIdx = _tabController.index.clamp(0, activeCount - 1);
        final oldController = _tabController;
        _tabController = TabController(
          length: activeCount,
          vsync: this,
          initialIndex: currentIdx,
        );
        oldController.dispose();
      }
    }
  }

  /// Memuat data presensi harian akademik siswa (Tab 1)
  Future<void> _loadData({String? monthYearKey}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _service.getAkademikDashboard(
        monthYear: monthYearKey,
        identifier: widget.identifier,
      );

      if (mounted) {
        setState(() {
          _data = response;
          _selectedMonthYearKey = response.selectedPeriod.monthYear;
          _isLoading = false;
          _updateSettings(
            enableSholat: response.enableSholatDhuhur,
            enableKbm: response.enablePresensiKbm,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  /// Memuat data kalender sholat dhuhur siswa (Tab 2)
  Future<void> _loadSholatData({String? monthYearKey}) async {
    setState(() {
      _isSholatLoading = true;
      _sholatErrorMessage = null;
    });

    try {
      final response = await _service.getSholatDhuhurDashboard(
        monthYear: monthYearKey,
        identifier: widget.identifier,
      );

      if (mounted) {
        setState(() {
          _sholatData = response;
          _selectedSholatMonthYearKey = response.selectedPeriod.monthYear;
          _isSholatLoading = false;
          _updateSettings(
            enableSholat: response.enableSholatDhuhur,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _sholatErrorMessage = e.toString().replaceFirst('Exception: ', '');
          _isSholatLoading = false;
        });
      }
    }
  }

  /// Memuat data presensi KBM per mapel siswa (Tab 3)
  Future<void> _loadKbmData({String? monthYearKey}) async {
    setState(() {
      _isKbmLoading = true;
      _kbmErrorMessage = null;
    });

    try {
      final response = await _service.getPresensiKbmDashboard(
        monthYear: monthYearKey,
        identifier: widget.identifier,
      );

      if (mounted) {
        setState(() {
          _kbmData = response;
          _selectedKbmMonthYearKey = response.selectedPeriod.monthYear;
          _isKbmLoading = false;
          _updateSettings(
            enableKbm: response.enablePresensiKbm,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _kbmErrorMessage = e.toString().replaceFirst('Exception: ', '');
          _isKbmLoading = false;
        });
      }
    }
  }

  void _showDayDetail(int day) {
    if (_data == null) return;
    final period = _data!.selectedPeriod;
    final att = _data!.attendanceMatrix[day];
    final isHoliday = _data!.holidays[day] ?? false;

    SheetPresensiSiswaDayDetail.show(
      context: context,
      day: day,
      period: period,
      att: att,
      isHoliday: isHoliday,
    );
  }

  void _showSholatDayDetail(int day) {
    if (_sholatData == null) return;
    final period = _sholatData!.selectedPeriod;
    final att = _sholatData!.attendanceMatrix[day];

    SheetSholatSiswaDayDetail.show(
      context: context,
      day: day,
      period: period,
      att: att,
    );
  }

  Widget _buildErrorView(String? error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 54, color: Color(0xFFDC2626)),
            const SizedBox(height: 14),
            Text(
              error ?? 'Terjadi kesalahan saat memuat data presensi.',
              style:
                  const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  /// Tampilan Tab 1: Presensi Harian (Masuk & Pulang)
  Widget _buildPresensiHarianTab() {
    if (_isLoading && _data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _data == null) {
      return _buildErrorView(
        _errorMessage,
        () => _loadData(monthYearKey: _selectedMonthYearKey),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadData(monthYearKey: _selectedMonthYearKey),
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Selector Bulan Akademik
            if (_data != null)
              PresensiSiswaMonthSelector(
                availableMonths: _data!.availableMonths,
                selectedMonthYearKey: _selectedMonthYearKey,
                onMonthChanged: (val) => _loadData(monthYearKey: val),
              ),

            const SizedBox(height: 16),

            // 2. Statistik Kehadiran Bulanan
            if (_data != null) PresensiSiswaStatsCard(stats: _data!.stats),

            const SizedBox(height: 20),

            // 3. Matriks Kalender 1..31
            if (_data != null)
              PresensiSiswaCalendarCard(
                period: _data!.selectedPeriod,
                attendanceMatrix: _data!.attendanceMatrix,
                holidays: _data!.holidays,
                onDayTap: _showDayDetail,
              ),

            const SizedBox(height: 20),

            // 4. Riwayat Aktivitas Terbaru
            if (_data != null && _data!.recentActivity.isNotEmpty)
              PresensiSiswaRecentActivity(
                activities: _data!.recentActivity,
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Tampilan Tab 2: Sholat Dhuhur Berjamaah
  Widget _buildSholatDhuhurTab() {
    if (_isSholatLoading && _sholatData == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0D9488)),
      );
    }

    if (_sholatErrorMessage != null && _sholatData == null) {
      return _buildErrorView(
        _sholatErrorMessage,
        () => _loadSholatData(monthYearKey: _selectedSholatMonthYearKey),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          _loadSholatData(monthYearKey: _selectedSholatMonthYearKey),
      color: const Color(0xFF0D9488),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner Khusus Siswa Non-Muslim
            if (_sholatData?.isNonMuslim == true) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: Color(0xFF2563EB), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Siswa tercatat beragama ${_sholatData!.religion}. Presensi Sholat Dhuhur tidak diwajibkan.',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF1E40AF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 1. Selector Bulan Akademik
            if (_sholatData != null)
              PresensiSiswaMonthSelector(
                availableMonths: _sholatData!.availableMonths,
                selectedMonthYearKey: _selectedSholatMonthYearKey,
                onMonthChanged: (val) =>
                    _loadSholatData(monthYearKey: val),
              ),

            const SizedBox(height: 16),

            // 2. Statistik Sholat Bulanan
            if (_sholatData != null)
              SholatSiswaStatsCard(stats: _sholatData!.stats),

            const SizedBox(height: 20),

            // 3. Matriks Kalender Sholat 1..31
            if (_sholatData != null)
              SholatSiswaCalendarCard(
                period: _sholatData!.selectedPeriod,
                attendanceMatrix: _sholatData!.attendanceMatrix,
                onDayTap: _showSholatDayDetail,
              ),

            const SizedBox(height: 20),

            // 4. Riwayat Sholat Terbaru
            if (_sholatData != null && _sholatData!.recentActivity.isNotEmpty)
              _buildSholatRecentActivitySection(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Section Riwayat Aktivitas Sholat Dhuhur
  Widget _buildSholatRecentActivitySection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history_rounded, size: 18, color: Color(0xFF0D9488)),
              SizedBox(width: 8),
              Text(
                'Catatan Ibadah Terbaru',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _sholatData!.recentActivity.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 20, color: Color(0xFFF1F5F9)),
            itemBuilder: (ctx, idx) {
              final item = _sholatData!.recentActivity[idx];
              Color dotColor = const Color(0xFF0D9488);
              Color badgeBg = const Color(0xFFCCFBF1);
              Color badgeFg = const Color(0xFF0F766E);

              switch (item.status) {
                case 'berjamaah':
                  dotColor = const Color(0xFF0D9488);
                  badgeBg = const Color(0xFFCCFBF1);
                  badgeFg = const Color(0xFF0F766E);
                  break;
                case 'masbuk':
                  dotColor = const Color(0xFFD97706);
                  badgeBg = const Color(0xFFFEF3C7);
                  badgeFg = const Color(0xFFB45309);
                  break;
                case 'halangan':
                case 'haid':
                  dotColor = const Color(0xFF7C3AED);
                  badgeBg = const Color(0xFFF3E8FF);
                  badgeFg = const Color(0xFF6D28D9);
                  break;
                case 'ijin':
                case 'izin':
                case 'sakit':
                  dotColor = const Color(0xFF2563EB);
                  badgeBg = const Color(0xFFEFF6FF);
                  badgeFg = const Color(0xFF1D4ED8);
                  break;
                case 'tidak_hadir':
                  dotColor = const Color(0xFFDC2626);
                  badgeBg = const Color(0xFFFEE2E2);
                  badgeFg = const Color(0xFFB91C1C);
                  break;
                default:
                  dotColor = const Color(0xFF64748B);
                  badgeBg = const Color(0xFFF1F5F9);
                  badgeFg = const Color(0xFF64748B);
              }

              return Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.formattedDate,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (item.note != null && item.note!.isNotEmpty)
                          Text(
                            item.note!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item.statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: badgeFg,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Tampilan Tab 3: Presensi KBM (per Mata Pelajaran)
  Widget _buildPresensiKbmTab() {
    if (_isKbmLoading && _kbmData == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
      );
    }

    if (_kbmErrorMessage != null && _kbmData == null) {
      return _buildErrorView(
        _kbmErrorMessage,
        () => _loadKbmData(monthYearKey: _selectedKbmMonthYearKey),
      );
    }

    final availableMonths = _kbmData?.availableMonths ?? [];

    return RefreshIndicator(
      onRefresh: () => _loadKbmData(monthYearKey: _selectedKbmMonthYearKey),
      color: const Color(0xFF4F46E5),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Selector Periode / Bulan KBM
            if (_kbmData != null && availableMonths.isNotEmpty)
              PresensiSiswaMonthSelector(
                availableMonths: availableMonths
                    .map((m) => SiswaAvailableMonth(
                          key: m.key,
                          month: m.month,
                          year: m.year,
                          label: m.label,
                        ))
                    .toList(),
                selectedMonthYearKey:
                    _selectedKbmMonthYearKey ?? _kbmData!.selectedPeriod.monthYear,
                onMonthChanged: (val) => _loadKbmData(monthYearKey: val),
              ),

            const SizedBox(height: 16),

            // 2. Kartu Ringkasan KBM Terdata (Indigo Gradient Card)
            if (_kbmData != null)
              KbmSiswaSummaryCard(summary: _kbmData!.summary),

            const SizedBox(height: 20),

            // 3. Daftar 11-12 Mata Pelajaran
            if (_kbmData != null) ...[
              if (_kbmData!.subjects.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.menu_book_rounded,
                          size: 44, color: Color(0xFF94A3B8)),
                      SizedBox(height: 10),
                      Text(
                        'Belum Ada Jadwal Mata Pelajaran',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Rombongan belajar Anda belum memiliki daftar mata pelajaran aktif.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                KbmSiswaSubjectList(subjects: _kbmData!.subjects),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final schoolDisplayName =
        widget.schoolName.isNotEmpty ? widget.schoolName : AppConfig.appName;
    final activeTabs = _activeTabs;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Presensi & Akademik',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              schoolDisplayName,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan',
            onPressed: () {
              if (activeTabs.isEmpty) return;
              final currentIdx =
                  _tabController.index.clamp(0, activeTabs.length - 1);
              final activeType = activeTabs[currentIdx];
              switch (activeType) {
                case SiswaPresensiTabType.harian:
                  _loadData(monthYearKey: _selectedMonthYearKey);
                  break;
                case SiswaPresensiTabType.sholat:
                  _loadSholatData(monthYearKey: _selectedSholatMonthYearKey);
                  break;
                case SiswaPresensiTabType.kbm:
                  _loadKbmData(monthYearKey: _selectedKbmMonthYearKey);
                  break;
              }
            },
          ),
        ],
        bottom: activeTabs.length > 1
            ? TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                isScrollable: activeTabs.length > 2,
                tabAlignment: activeTabs.length > 2 ? TabAlignment.start : null,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                tabs: activeTabs.map((type) {
                  switch (type) {
                    case SiswaPresensiTabType.harian:
                      return const Tab(
                        icon: Icon(Icons.calendar_today_rounded, size: 18),
                        text: 'Presensi Harian',
                      );
                    case SiswaPresensiTabType.sholat:
                      return const Tab(
                        icon: Icon(Icons.mosque_rounded, size: 18),
                        text: 'Sholat Dhuhur',
                      );
                    case SiswaPresensiTabType.kbm:
                      return const Tab(
                        icon: Icon(Icons.menu_book_rounded, size: 18),
                        text: 'Presensi Mapel',
                      );
                  }
                }).toList(),
              )
            : null,
      ),
      body: activeTabs.length > 1
          ? TabBarView(
              controller: _tabController,
              children: activeTabs.map((type) {
                switch (type) {
                  case SiswaPresensiTabType.harian:
                    return _buildPresensiHarianTab();
                  case SiswaPresensiTabType.sholat:
                    return _buildSholatDhuhurTab();
                  case SiswaPresensiTabType.kbm:
                    return _buildPresensiKbmTab();
                }
              }).toList(),
            )
          : _buildPresensiHarianTab(),
    );
  }
}

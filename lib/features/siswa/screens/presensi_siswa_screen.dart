import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../models/siswa_akademik_model.dart';
import '../services/siswa_dashboard_service.dart';
import 'widgets/presensi_siswa/sections/presensi_siswa_month_selector.dart';
import 'widgets/presensi_siswa/sections/presensi_siswa_stats_card.dart';
import 'widgets/presensi_siswa/sections/presensi_siswa_calendar_card.dart';
import 'widgets/presensi_siswa/sections/presensi_siswa_recent_activity.dart';
import 'widgets/presensi_siswa/modals/sheet_presensi_siswa_day_detail.dart';

/// Layar Menu 1: Presensi & Kalender Akademik Siswa
class PresensiSiswaScreen extends StatefulWidget {
  final String identifier;
  final String studentName;
  final String schoolName;
  final String? token;
  final String? schoolLogoUrl;
  final String? schoolLogoBase64;

  const PresensiSiswaScreen({
    super.key,
    required this.identifier,
    required this.studentName,
    this.schoolName = '',
    this.token,
    this.schoolLogoUrl,
    this.schoolLogoBase64,
  });

  @override
  State<PresensiSiswaScreen> createState() => _PresensiSiswaScreenState();
}

class _PresensiSiswaScreenState extends State<PresensiSiswaScreen> {
  late SiswaDashboardService _service;
  bool _isLoading = true;
  String? _errorMessage;
  SiswaAkademikDashboardResponse? _data;
  String? _selectedMonthYearKey;

  @override
  void initState() {
    super.initState();
    _service = SiswaDashboardService.create(
      token: widget.token,
      identifier: widget.identifier,
    );
    _loadData();
  }

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

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 54, color: Color(0xFFDC2626)),
            const SizedBox(height: 14),
            Text(
              _errorMessage ?? 'Terjadi kesalahan saat memuat data presensi.',
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _loadData(monthYearKey: _selectedMonthYearKey),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              widget.schoolName.isNotEmpty ? widget.schoolName : AppConfig.appName,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan',
            onPressed: () => _loadData(monthYearKey: _selectedMonthYearKey),
          ),
        ],
      ),
      body: _isLoading && _data == null
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null && _data == null
              ? _buildErrorView()
              : RefreshIndicator(
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
                        if (_data != null)
                          PresensiSiswaStatsCard(stats: _data!.stats),

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
                ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/siswa_akademik_model.dart';
import '../services/siswa_dashboard_service.dart';

/// Layar Menu 1: Presensi & Kalender Akademik Siswa
/// Menampilkan statistik kehadiran bulanan, matriks kalender interaktif 1..31,
/// filter bulan tahun ajaran, dan daftar riwayat aktivitas presensi terbaru.
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
    this.schoolName = 'SMP Negeri 3 Kedungreja',
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

    final dateStr = '${period.year}-${period.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanggal $day',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        dateStr,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  _buildStatusBadge(att?.status, isHoliday),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.login_rounded,
                      label: 'Jam Masuk',
                      value: att?.scanTime != null ? '${att!.scanTime} WIB' : (isHoliday ? 'Hari Libur' : 'Tidak Ada Data'),
                      color: att?.scanTime != null ? const Color(0xFF059669) : Colors.black54,
                    ),
                    const Divider(height: 20),
                    _buildDetailRow(
                      icon: Icons.logout_rounded,
                      label: 'Jam Pulang',
                      value: att?.scanOutTime != null ? '${att!.scanOutTime} WIB' : '-',
                      color: Colors.black87,
                    ),
                    if (att != null && att.lateMinutes > 0) ...[
                      const Divider(height: 20),
                      _buildDetailRow(
                        icon: Icons.timer_outlined,
                        label: 'Keterlambatan',
                        value: '${att.lateMinutes} Menit',
                        color: const Color(0xFFD97706),
                      ),
                    ],
                    if (att != null && att.isManualInput) ...[
                      const Divider(height: 20),
                      _buildDetailRow(
                        icon: Icons.edit_note_rounded,
                        label: 'Metode Absen',
                        value: 'Diinput Manual oleh Guru/Admin',
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String? status, bool isHoliday) {
    Color bg = const Color(0xFFF1F5F9);
    Color fg = const Color(0xFF64748B);
    String label = 'Belum Ada';

    if (isHoliday) {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF64748B);
      label = 'Hari Libur';
    } else if (status != null) {
      switch (status.toLowerCase()) {
        case 'hadir':
          bg = const Color(0xFFECFDF5);
          fg = const Color(0xFF059669);
          label = 'Tepat Waktu';
          break;
        case 'telat':
          bg = const Color(0xFFFEF3C7);
          fg = const Color(0xFFD97706);
          label = 'Terlambat';
          break;
        case 'sakit':
          bg = const Color(0xFFFFE4E6);
          fg = const Color(0xFFE11D48);
          label = 'Sakit';
          break;
        case 'izin':
          bg = const Color(0xFFEFF6FF);
          fg = const Color(0xFF2563EB);
          label = 'Izin';
          break;
        case 'alpa':
          bg = const Color(0xFFFEE2E2);
          fg = const Color(0xFFDC2626);
          label = 'Alpa';
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fg),
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
              widget.schoolName,
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
                        _buildMonthSelector(),

                        const SizedBox(height: 16),

                        // 2. Statistik Kehadiran Bulanan
                        if (_data != null) _buildStatsCard(_data!.stats),

                        const SizedBox(height: 20),

                        // 3. Matriks Kalender 1..31
                        if (_data != null) _buildCalendarCard(),

                        const SizedBox(height: 20),

                        // 4. Riwayat Aktivitas Terbaru
                        if (_data != null && _data!.recentActivity.isNotEmpty)
                          _buildRecentActivitySection(_data!.recentActivity),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
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

  Widget _buildMonthSelector() {
    final available = _data?.availableMonths ?? [];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Bulan Kalender',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ),
          if (available.isNotEmpty)
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedMonthYearKey,
                icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
                items: available.map((m) {
                  return DropdownMenuItem<String>(
                    value: m.key,
                    child: Text(m.label),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null && val != _selectedMonthYearKey) {
                    _loadData(monthYearKey: val);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(SiswaMonthlyStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF047857),
            Color(0xFF059669),
            Color(0xFF10B981),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tingkat Kehadiran',
                    style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${stats.attendancePercentage}%',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'dari ${stats.effectiveDays} Hari Efektif',
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.insights_rounded, color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatPill('Hadir', stats.totalHadir.toString(), Colors.white),
                _buildStatPill('Telat', stats.totalTelat.toString(), const Color(0xFFFDE68A)),
                _buildStatPill('Sakit', stats.totalSakit.toString(), const Color(0xFFFECDD3)),
                _buildStatPill('Izin', stats.totalIzin.toString(), const Color(0xFFBAE6FD)),
                _buildStatPill('Alpa', stats.totalAlpa.toString(), const Color(0xFFFECACA)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildCalendarCard() {
    final period = _data!.selectedPeriod;
    final int daysInMonth = period.daysInMonth;
    final int offset = period.startOfMonthOffset; // 0 = Senin, 6 = Minggu
    final String todayDate = period.todayDate;

    const List<String> dayHeaders = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    // Total cells in grid
    final int totalCells = offset + daysInMonth;
    final int rowsCount = (totalCells / 7).ceil();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Matriks Kalender Kehadiran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Ketuk tanggal untuk rincian',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Header Hari (Sen - Min)
          Row(
            children: dayHeaders.map((dh) {
              final isWeekend = dh == 'Sab' || dh == 'Min';
              return Expanded(
                child: Center(
                  child: Text(
                    dh,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isWeekend ? const Color(0xFFDC2626) : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Grid Tanggal
          Column(
            children: List.generate(rowsCount, (rowIndex) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: List.generate(7, (colIndex) {
                    final cellIndex = rowIndex * 7 + colIndex;
                    final day = cellIndex - offset + 1;

                    if (day < 1 || day > daysInMonth) {
                      return const Expanded(child: SizedBox(height: 48));
                    }

                    final att = _data!.attendanceMatrix[day];
                    final isHoliday = _data!.holidays[day] ?? false;
                    final cellDateStr = '${period.year}-${period.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                    final isToday = cellDateStr == todayDate;

                    return Expanded(
                      child: _buildDayCell(
                        day: day,
                        att: att,
                        isHoliday: isHoliday,
                        isToday: isToday,
                        onTap: () => _showDayDetail(day),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Legenda Status
          Wrap(
            spacing: 12,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _buildLegend(const Color(0xFF059669), 'Hadir'),
              _buildLegend(const Color(0xFFD97706), 'Telat'),
              _buildLegend(const Color(0xFFE11D48), 'Sakit'),
              _buildLegend(const Color(0xFF2563EB), 'Izin'),
              _buildLegend(const Color(0xFFDC2626), 'Alpa'),
              _buildLegend(const Color(0xFF94A3B8), 'Libur'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell({
    required int day,
    required SiswaDayAttendance? att,
    required bool isHoliday,
    required bool isToday,
    required VoidCallback onTap,
  }) {
    Color bg = Colors.transparent;
    Color dotColor = Colors.transparent;
    Color textColor = AppColors.textPrimary;

    if (isHoliday) {
      bg = const Color(0xFFF1F5F9);
      textColor = const Color(0xFF94A3B8);
    } else if (att != null) {
      switch (att.status.toLowerCase()) {
        case 'hadir':
          bg = const Color(0xFFECFDF5);
          dotColor = const Color(0xFF059669);
          textColor = const Color(0xFF047857);
          break;
        case 'telat':
          bg = const Color(0xFFFEF3C7);
          dotColor = const Color(0xFFD97706);
          textColor = const Color(0xFFB45309);
          break;
        case 'sakit':
          bg = const Color(0xFFFFE4E6);
          dotColor = const Color(0xFFE11D48);
          textColor = const Color(0xFFBE123C);
          break;
        case 'izin':
          bg = const Color(0xFFEFF6FF);
          dotColor = const Color(0xFF2563EB);
          textColor = const Color(0xFF1D4ED8);
          break;
        case 'alpa':
          bg = const Color(0xFFFEE2E2);
          dotColor = const Color(0xFFDC2626);
          textColor = const Color(0xFFB91C1C);
          break;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: isToday
                ? Border.all(color: AppColors.primary, width: 2)
                : Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$day',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isToday ? FontWeight.w900 : FontWeight.bold,
                  color: isToday ? AppColors.primary : textColor,
                ),
              ),
              const SizedBox(height: 2),
              if (dotColor != Colors.transparent)
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                )
              else if (isHoliday)
                Container(
                  width: 6,
                  height: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(1),
                  ),
                )
              else
                const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection(List<SiswaRecentActivity> activities) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          const Row(
            children: [
              Icon(Icons.history_rounded, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Riwayat Presensi Terbaru',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (context, index) => const Divider(height: 16),
            itemBuilder: (ctx, index) {
              final item = activities[index];
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusBg(item.status),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_getStatusIcon(item.status), size: 18, color: _getStatusFg(item.status)),
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
                        if (item.scanTime != null)
                          Text(
                            'Scan Masuk: ${item.scanTime} WIB ${item.lateMinutes > 0 ? "(${item.lateMinutes}m telat)" : ""}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        if (item.note != null && item.note!.isNotEmpty)
                          Text(
                            item.note!,
                            style: const TextStyle(fontSize: 10.5, color: Colors.black45, fontStyle: FontStyle.italic),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(item.status, false),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getStatusBg(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return const Color(0xFFECFDF5);
      case 'telat':
        return const Color(0xFFFEF3C7);
      case 'sakit':
        return const Color(0xFFFFE4E6);
      case 'izin':
        return const Color(0xFFEFF6FF);
      default:
        return const Color(0xFFFEE2E2);
    }
  }

  Color _getStatusFg(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return const Color(0xFF059669);
      case 'telat':
        return const Color(0xFFD97706);
      case 'sakit':
        return const Color(0xFFE11D48);
      case 'izin':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFFDC2626);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return Icons.check_circle_outline_rounded;
      case 'telat':
        return Icons.access_time_rounded;
      case 'sakit':
        return Icons.local_hospital_outlined;
      case 'izin':
        return Icons.assignment_turned_in_outlined;
      default:
        return Icons.cancel_outlined;
    }
  }
}


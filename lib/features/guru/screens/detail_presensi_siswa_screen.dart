import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';

/// Halaman Detail Presensi Individual Siswa (/portal-guru/siswa/{id})
/// Mengikuti komponen Livewire WaliKelasStudentDetail
class DetailPresensiSiswaScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String? initialMonthYear;
  final String? token;
  final String? identifier;

  const DetailPresensiSiswaScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    this.initialMonthYear,
    this.token,
    this.identifier,
  });

  @override
  State<DetailPresensiSiswaScreen> createState() =>
      _DetailPresensiSiswaScreenState();
}

class _DetailPresensiSiswaScreenState extends State<DetailPresensiSiswaScreen> {
  bool _isLoading = true;
  String? _selectedMonthYear;

  Map<String, dynamic> _studentInfo = {};
  List<Map<String, dynamic>> _availableMonths = [];
  int _daysInMonth = 30;
  int _startOffset = 0;
  double _attendancePercentage = 0;
  Map<String, dynamic> _stats = {
    'H': 0,
    'T': 0,
    'S': 0,
    'I': 0,
    'A': 0,
    'late_minutes': 0,
  };
  Map<String, dynamic> _holidays = {};
  Map<String, dynamic> _attendanceData = {};
  List<Map<String, dynamic>> _recentActivity = [];

  late final Dio _dio;

  @override
  void initState() {
    super.initState();
    _selectedMonthYear = widget.initialMonthYear;
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
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() => _isLoading = true);
    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/guru/presensi/student/${widget.studentId}',
        queryParameters: {
          if (_selectedMonthYear != null) 'month_year': _selectedMonthYear,
          if (widget.identifier != null) 'identifier': widget.identifier,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _studentInfo = Map<String, dynamic>.from(data['student'] ?? {});
            _availableMonths = List<Map<String, dynamic>>.from(
              (data['available_months'] as List? ?? [])
                  .map((e) => Map<String, dynamic>.from(e)),
            );
            _selectedMonthYear = data['selected_month_year']?.toString();
            _daysInMonth = (data['days_in_month'] as num?)?.toInt() ?? 30;
            _startOffset = (data['start_offset'] as num?)?.toInt() ?? 0;
            _attendancePercentage =
                (data['attendance_percentage'] as num?)?.toDouble() ?? 0.0;
            _stats = Map<String, dynamic>.from(data['stats'] ?? _stats);
            _holidays = Map<String, dynamic>.from(data['holidays'] ?? {});
            _attendanceData =
                Map<String, dynamic>.from(data['attendance_data'] ?? {});
            _recentActivity = List<Map<String, dynamic>>.from(
              (data['recent_activity'] as List? ?? [])
                  .map((e) => Map<String, dynamic>.from(e)),
            );
          });
        }
      }
    } catch (_) {
      // Fallback jika offline
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _studentInfo['name']?.toString() ?? widget.studentName;
    final nisn = _studentInfo['nisn']?.toString() ?? '-';
    final className = _studentInfo['class_name']?.toString() ?? '-';
    final academicYear = _studentInfo['academic_year']?.toString() ?? '-';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail Presensi Siswa',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              name,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchDetail,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Kartu Profil Ringkas Siswa
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              name.length >= 2
                                  ? name.substring(0, 2).toUpperCase()
                                  : 'S',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'NISN: $nisn • Kelas $className',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Tahun Ajaran $academicYear',
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '$_attendancePercentage%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const Text(
                                  'Hadir',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 2. Pilih Bulan Kehadiran
                    if (_availableMonths.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Bulan:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedMonthYear,
                                  isExpanded: true,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  items: _availableMonths.map((m) {
                                    return DropdownMenuItem<String>(
                                      value: m['key']?.toString(),
                                      child: Text(m['label']?.toString() ?? ''),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedMonthYear = val);
                                      _fetchDetail();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    // 3. Statistik Ringkas Bulan Ini
                    Row(
                      children: [
                        _buildMiniStatCard(
                          'Hadir',
                          '${_stats['H'] ?? 0}',
                          const Color(0xFF10B981),
                        ),
                        const SizedBox(width: 8),
                        _buildMiniStatCard(
                          'Telat',
                          '${_stats['T'] ?? 0}',
                          const Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 8),
                        _buildMiniStatCard(
                          'Izin',
                          '${_stats['I'] ?? 0}',
                          const Color(0xFF3B82F6),
                        ),
                        const SizedBox(width: 8),
                        _buildMiniStatCard(
                          'Sakit',
                          '${_stats['S'] ?? 0}',
                          const Color(0xFF8B5CF6),
                        ),
                        const SizedBox(width: 8),
                        _buildMiniStatCard(
                          'Alpa',
                          '${_stats['A'] ?? 0}',
                          const Color(0xFFEF4444),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 4. Kalender Kehadiran Bulanan
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kalender Kehadiran Bulanan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
                                .map(
                                  (d) => Expanded(
                                    child: Center(
                                      child: Text(
                                        d,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: d == 'Min'
                                              ? Colors.red
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 8),
                          _buildCalendarGrid(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 5. Riwayat Aktivitas Terakhir
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Riwayat Presensi Bulan Ini',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_recentActivity.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  'Belum ada catatan presensi pada bulan ini.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            )
                          else
                            ..._recentActivity.map((act) {
                              final st = act['status']?.toString() ?? 'hadir';
                              final dateLabel =
                                  act['date_label']?.toString() ??
                                  act['date']?.toString() ??
                                  '-';
                              final scanIn = act['scan_time']?.toString() ?? '-';
                              final scanOut =
                                  act['scan_out_time']?.toString() ?? '-';
                              final lateMin =
                                  (act['late_minutes'] as num?)?.toInt() ?? 0;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dateLabel,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Datang: $scanIn • Pulang: $scanOut',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    _buildStatusBadge(st, lateMin),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMiniStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final totalCells = _startOffset + _daysInMonth;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        if (index < _startOffset) {
          return const SizedBox.shrink();
        }
        final day = index - _startOffset + 1;
        final dayKey = day.toString();
        final att = _attendanceData[dayKey];
        final isHoliday = _holidays[dayKey] == true;

        Color bgColor = const Color(0xFFF1F5F9);
        Color textColor = AppColors.textSecondary;
        String code = '';

        if (att != null && att is Map) {
          final status = att['status']?.toString() ?? '';
          switch (status) {
            case 'hadir':
              bgColor = const Color(0xFFD1FAE5);
              textColor = const Color(0xFF047857);
              code = 'H';
              break;
            case 'telat':
              bgColor = const Color(0xFFFEF3C7);
              textColor = const Color(0xFFB45309);
              code = 'T';
              break;
            case 'izin':
              bgColor = const Color(0xFFDBEAFE);
              textColor = const Color(0xFF1D4ED8);
              code = 'I';
              break;
            case 'sakit':
              bgColor = const Color(0xFFEDE9FE);
              textColor = const Color(0xFF6D28D9);
              code = 'S';
              break;
            case 'alpa':
              bgColor = const Color(0xFFFEE2E2);
              textColor = const Color(0xFFB91C1C);
              code = 'A';
              break;
          }
        } else if (isHoliday) {
          bgColor = const Color(0xFFE2E8F0);
          textColor = const Color(0xFF64748B);
          code = 'L';
        }

        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$day',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              if (code.isNotEmpty)
                Text(
                  code,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status, int lateMinutes) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'hadir':
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF065F46);
        label = 'Hadir';
        break;
      case 'telat':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        label = lateMinutes > 0 ? 'Telat (${lateMinutes}m)' : 'Telat';
        break;
      case 'izin':
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1E40AF);
        label = 'Izin';
        break;
      case 'sakit':
        bg = const Color(0xFFEDE9FE);
        fg = const Color(0xFF5B21B6);
        label = 'Sakit';
        break;
      case 'alpa':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        label = 'Alpa';
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}

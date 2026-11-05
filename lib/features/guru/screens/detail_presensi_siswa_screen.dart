import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import 'widgets/detail_presensi/student_presensi_profile_header.dart';
import 'widgets/detail_presensi/student_presensi_month_selector.dart';
import 'widgets/detail_presensi/student_presensi_stats_row.dart';
import 'widgets/detail_presensi/student_presensi_calendar_card.dart';
import 'widgets/detail_presensi/student_presensi_activity_list.dart';

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
                    StudentPresensiProfileHeader(
                      name: name,
                      nisn: nisn,
                      className: className,
                      academicYear: academicYear,
                      attendancePercentage: _attendancePercentage,
                    ),
                    const SizedBox(height: 16),
                    StudentPresensiMonthSelector(
                      availableMonths: _availableMonths,
                      selectedMonthYear: _selectedMonthYear,
                      onMonthChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedMonthYear = val);
                          _fetchDetail();
                        }
                      },
                    ),
                    if (_availableMonths.isNotEmpty) const SizedBox(height: 16),
                    StudentPresensiStatsRow(stats: _stats),
                    const SizedBox(height: 16),
                    StudentPresensiCalendarCard(
                      daysInMonth: _daysInMonth,
                      startOffset: _startOffset,
                      attendanceData: _attendanceData,
                      holidays: _holidays,
                    ),
                    const SizedBox(height: 16),
                    StudentPresensiActivityList(recentActivity: _recentActivity),
                  ],
                ),
              ),
            ),
    );
  }
}

/// Model Pilihan Bulan Akademik
class SiswaAvailableMonth {
  final String key;
  final int month;
  final int year;
  final String label;

  const SiswaAvailableMonth({
    required this.key,
    required this.month,
    required this.year,
    required this.label,
  });

  factory SiswaAvailableMonth.fromJson(Map<String, dynamic> json) {
    return SiswaAvailableMonth(
      key: json['key']?.toString() ?? '',
      month: (json['month'] as num?)?.toInt() ?? 1,
      year: (json['year'] as num?)?.toInt() ?? 2026,
      label: json['label']?.toString() ?? '',
    );
  }
}

/// Model Statistik Presensi Bulanan
class SiswaMonthlyStats {
  final int totalHadir;
  final int totalTelat;
  final int totalSakit;
  final int totalIzin;
  final int totalAlpa;
  final int totalLateMinutes;
  final double attendancePercentage;
  final int effectiveDays;

  const SiswaMonthlyStats({
    this.totalHadir = 0,
    this.totalTelat = 0,
    this.totalSakit = 0,
    this.totalIzin = 0,
    this.totalAlpa = 0,
    this.totalLateMinutes = 0,
    this.attendancePercentage = 0.0,
    this.effectiveDays = 1,
  });

  factory SiswaMonthlyStats.fromJson(Map<String, dynamic> json) {
    return SiswaMonthlyStats(
      totalHadir: (json['total_hadir'] as num?)?.toInt() ?? 0,
      totalTelat: (json['total_telat'] as num?)?.toInt() ?? 0,
      totalSakit: (json['total_sakit'] as num?)?.toInt() ?? 0,
      totalIzin: (json['total_izin'] as num?)?.toInt() ?? 0,
      totalAlpa: (json['total_alpa'] as num?)?.toInt() ?? 0,
      totalLateMinutes: (json['total_late_minutes'] as num?)?.toInt() ?? 0,
      attendancePercentage: (json['attendance_percentage'] as num?)?.toDouble() ?? 0.0,
      effectiveDays: (json['effective_days'] as num?)?.toInt() ?? 1,
    );
  }
}

/// Model Entri Kehadiran per Hari pada Matriks Kalender
class SiswaDayAttendance {
  final int day;
  final String status;
  final int lateMinutes;
  final String? scanTime;
  final String? scanOutTime;
  final String? date;
  final bool isManualInput;

  const SiswaDayAttendance({
    required this.day,
    required this.status,
    this.lateMinutes = 0,
    this.scanTime,
    this.scanOutTime,
    this.date,
    this.isManualInput = false,
  });

  factory SiswaDayAttendance.fromJson(Map<String, dynamic> json) {
    return SiswaDayAttendance(
      day: (json['day'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString().toLowerCase() ?? 'hadir',
      lateMinutes: (json['late_minutes'] as num?)?.toInt() ?? 0,
      scanTime: json['scan_time']?.toString(),
      scanOutTime: json['scan_out_time']?.toString(),
      date: json['date']?.toString(),
      isManualInput: json['is_manual_input'] == true,
    );
  }
}

/// Model Riwayat Aktivitas Presensi
class SiswaRecentActivity {
  final String id;
  final String date;
  final String formattedDate;
  final String status;
  final String? scanTime;
  final String? scanOutTime;
  final int lateMinutes;
  final String? note;

  const SiswaRecentActivity({
    required this.id,
    required this.date,
    required this.formattedDate,
    required this.status,
    this.scanTime,
    this.scanOutTime,
    this.lateMinutes = 0,
    this.note,
  });

  factory SiswaRecentActivity.fromJson(Map<String, dynamic> json) {
    return SiswaRecentActivity(
      id: json['id']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      formattedDate: json['formatted_date']?.toString() ?? '',
      status: json['status']?.toString().toLowerCase() ?? '',
      scanTime: json['scan_time']?.toString(),
      scanOutTime: json['scan_out_time']?.toString(),
      lateMinutes: (json['late_minutes'] as num?)?.toInt() ?? 0,
      note: json['note']?.toString(),
    );
  }
}

/// Model Periode Kalender Terpilih
class SiswaSelectedPeriod {
  final int month;
  final int year;
  final String monthYear;
  final int daysInMonth;
  final int startOfMonthOffset;
  final String todayDate;

  const SiswaSelectedPeriod({
    required this.month,
    required this.year,
    required this.monthYear,
    required this.daysInMonth,
    required this.startOfMonthOffset,
    required this.todayDate,
  });

  factory SiswaSelectedPeriod.fromJson(Map<String, dynamic> json) {
    return SiswaSelectedPeriod(
      month: (json['month'] as num?)?.toInt() ?? 1,
      year: (json['year'] as num?)?.toInt() ?? 2026,
      monthYear: json['month_year']?.toString() ?? '',
      daysInMonth: (json['days_in_month'] as num?)?.toInt() ?? 30,
      startOfMonthOffset: (json['start_of_month_offset'] as num?)?.toInt() ?? 0,
      todayDate: json['today_date']?.toString() ?? '',
    );
  }
}

/// Model Keseluruhan Response Dashboard Akademik Presensi Siswa
class SiswaAkademikDashboardResponse {
  final SiswaSelectedPeriod selectedPeriod;
  final List<SiswaAvailableMonth> availableMonths;
  final SiswaMonthlyStats stats;
  final Map<int, SiswaDayAttendance> attendanceMatrix;
  final Map<int, bool> holidays;
  final List<SiswaRecentActivity> recentActivity;

  const SiswaAkademikDashboardResponse({
    required this.selectedPeriod,
    required this.availableMonths,
    required this.stats,
    required this.attendanceMatrix,
    required this.holidays,
    required this.recentActivity,
  });

  factory SiswaAkademikDashboardResponse.fromJson(Map<String, dynamic> json) {
    final periodJson = json['selected_period'] as Map<String, dynamic>? ?? {};
    final statsJson = json['stats'] as Map<String, dynamic>? ?? {};
    final monthsList = (json['available_months'] as List<dynamic>? ?? [])
        .map((e) => SiswaAvailableMonth.fromJson(e as Map<String, dynamic>))
        .toList();

    final matrixJson = json['attendance_matrix'] as Map<String, dynamic>? ?? {};
    final Map<int, SiswaDayAttendance> matrixMap = {};
    matrixJson.forEach((key, val) {
      final dayInt = int.tryParse(key);
      if (dayInt != null && val is Map<String, dynamic>) {
        matrixMap[dayInt] = SiswaDayAttendance.fromJson(val);
      }
    });

    final holidaysJson = json['holidays'] as Map<String, dynamic>? ?? {};
    final Map<int, bool> holidaysMap = {};
    holidaysJson.forEach((key, val) {
      final dayInt = int.tryParse(key);
      if (dayInt != null) {
        holidaysMap[dayInt] = val == true;
      }
    });

    final recentList = (json['recent_activity'] as List<dynamic>? ?? [])
        .map((e) => SiswaRecentActivity.fromJson(e as Map<String, dynamic>))
        .toList();

    return SiswaAkademikDashboardResponse(
      selectedPeriod: SiswaSelectedPeriod.fromJson(periodJson),
      availableMonths: monthsList,
      stats: SiswaMonthlyStats.fromJson(statsJson),
      attendanceMatrix: matrixMap,
      holidays: holidaysMap,
      recentActivity: recentList,
    );
  }
}


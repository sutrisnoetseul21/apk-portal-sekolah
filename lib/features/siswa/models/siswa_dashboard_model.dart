/// Model Ringkasan Profil Siswa
class SiswaProfileInfo {
  final String id;
  final String name;
  final String nisn;
  final String? nis;
  final String gender;
  final String? avatarUrl;
  final String? classId;
  final String className;
  final String academicYear;
  final String barcodeCode;
  final String? noHp;

  const SiswaProfileInfo({
    required this.id,
    required this.name,
    required this.nisn,
    this.nis,
    this.gender = 'L',
    this.avatarUrl,
    this.classId,
    this.className = 'Kelas Siswa',
    this.academicYear = 'Tahun Ajaran Aktif',
    required this.barcodeCode,
    this.noHp,
  });

  factory SiswaProfileInfo.fromJson(Map<String, dynamic> json) {
    return SiswaProfileInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Siswa',
      nisn: json['nisn']?.toString() ?? '',
      nis: json['nis']?.toString(),
      gender: json['gender']?.toString() ?? 'L',
      avatarUrl: json['avatar_url']?.toString(),
      classId: json['class_id']?.toString(),
      className: json['class_name']?.toString() ?? 'Kelas Siswa',
      academicYear: json['academic_year']?.toString() ?? 'Tahun Ajaran Aktif',
      barcodeCode: json['barcode_code']?.toString() ?? json['nisn']?.toString() ?? '',
      noHp: json['no_hp']?.toString(),
    );
  }
}

/// Model Status Presensi Hari Ini
class SiswaTodayAttendance {
  final String date;
  final String? dayName;
  final String? formattedDate;
  final bool hasScannedIn;
  final String? scanInTime;
  final bool hasScannedOut;
  final String? scanOutTime;
  final String status;
  final String statusLabel;
  final int lateMinutes;
  final bool isHoliday;

  const SiswaTodayAttendance({
    required this.date,
    this.dayName,
    this.formattedDate,
    required this.hasScannedIn,
    this.scanInTime,
    required this.hasScannedOut,
    this.scanOutTime,
    required this.status,
    required this.statusLabel,
    this.lateMinutes = 0,
    this.isHoliday = false,
  });

  factory SiswaTodayAttendance.fromJson(Map<String, dynamic> json) {
    return SiswaTodayAttendance(
      date: json['date']?.toString() ?? '',
      dayName: json['day_name']?.toString(),
      formattedDate: json['formatted_date']?.toString(),
      hasScannedIn: json['has_scanned_in'] == true,
      scanInTime: json['scan_in_time']?.toString(),
      hasScannedOut: json['has_scanned_out'] == true,
      scanOutTime: json['scan_out_time']?.toString(),
      status: json['status']?.toString() ?? 'belum_hadir',
      statusLabel: json['status_label']?.toString() ?? 'Belum Presensi',
      lateMinutes: (json['late_minutes'] as num?)?.toInt() ?? 0,
      isHoliday: json['is_holiday'] == true,
    );
  }
}

/// Model Status Sholat Dhuhur Hari Ini
class SiswaTodaySholat {
  final bool enabled;
  final String status;
  final String statusLabel;
  final bool isHoliday;

  const SiswaTodaySholat({
    this.enabled = true,
    required this.status,
    required this.statusLabel,
    this.isHoliday = false,
  });

  factory SiswaTodaySholat.fromJson(Map<String, dynamic> json) {
    return SiswaTodaySholat(
      enabled: json['enabled'] != false,
      status: json['status']?.toString() ?? 'belum',
      statusLabel: json['status_label']?.toString() ?? 'Belum Sholat',
      isHoliday: json['is_holiday'] == true,
    );
  }
}

/// Model Quick Stats / Badge Counter 7 Menu Siswa
class SiswaQuickStats {
  final int pendingLeavesCount;
  final int activeCounselingCount;
  final int activeLoansCount;
  final int spikapReportsCount;

  const SiswaQuickStats({
    this.pendingLeavesCount = 0,
    this.activeCounselingCount = 0,
    this.activeLoansCount = 0,
    this.spikapReportsCount = 0,
  });

  factory SiswaQuickStats.fromJson(Map<String, dynamic> json) {
    return SiswaQuickStats(
      pendingLeavesCount: (json['pending_leaves_count'] as num?)?.toInt() ?? 0,
      activeCounselingCount: (json['active_counseling_count'] as num?)?.toInt() ?? 0,
      activeLoansCount: (json['active_loans_count'] as num?)?.toInt() ?? 0,
      spikapReportsCount: (json['spikap_reports_count'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Model Data Lengkap Dashboard Summary Siswa
class SiswaDashboardSummary {
  final SiswaProfileInfo student;
  final String schoolName;
  final String? schoolLogoUrl;
  final SiswaTodayAttendance todayAttendance;
  final SiswaTodaySholat todaySholat;
  final SiswaQuickStats quickStats;

  const SiswaDashboardSummary({
    required this.student,
    required this.schoolName,
    this.schoolLogoUrl,
    required this.todayAttendance,
    required this.todaySholat,
    required this.quickStats,
  });

  factory SiswaDashboardSummary.fromJson(Map<String, dynamic> json) {
    final studentJson = json['student'] as Map<String, dynamic>? ?? {};
    final schoolJson = json['school'] as Map<String, dynamic>? ?? {};
    final attendanceJson = json['today_attendance'] as Map<String, dynamic>? ?? {};
    final sholatJson = json['today_sholat'] as Map<String, dynamic>? ?? {};
    final quickStatsJson = json['quick_stats'] as Map<String, dynamic>? ?? {};

    return SiswaDashboardSummary(
      student: SiswaProfileInfo.fromJson(studentJson),
      schoolName: schoolJson['name']?.toString() ?? 'SMP Negeri 3 Kedungreja',
      schoolLogoUrl: schoolJson['logo_url']?.toString(),
      todayAttendance: SiswaTodayAttendance.fromJson(attendanceJson),
      todaySholat: SiswaTodaySholat.fromJson(sholatJson),
      quickStats: SiswaQuickStats.fromJson(quickStatsJson),
    );
  }
}


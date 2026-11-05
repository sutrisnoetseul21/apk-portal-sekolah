import 'siswa_akademik_model.dart';

/// Model Statistik Sholat Dhuhur Bulanan Siswa
class SiswaSholatMonthlyStats {
  final int totalBerjamaah;
  final int totalMasbuk;
  final int totalIjin;
  final int totalTidakHadir;
  final int totalLibur;
  final double attendancePercentage;
  final int effectiveDays;

  const SiswaSholatMonthlyStats({
    this.totalBerjamaah = 0,
    this.totalMasbuk = 0,
    this.totalIjin = 0,
    this.totalTidakHadir = 0,
    this.totalLibur = 0,
    this.attendancePercentage = 0.0,
    this.effectiveDays = 0,
  });

  factory SiswaSholatMonthlyStats.fromJson(Map<String, dynamic> json) {
    return SiswaSholatMonthlyStats(
      totalBerjamaah: (json['total_berjamaah'] as num?)?.toInt() ?? 0,
      totalMasbuk: (json['total_masbuk'] as num?)?.toInt() ?? 0,
      totalIjin: (json['total_ijin'] as num?)?.toInt() ?? 0,
      totalTidakHadir: (json['total_tidak_hadir'] as num?)?.toInt() ?? 0,
      totalLibur: (json['total_libur'] as num?)?.toInt() ?? 0,
      attendancePercentage:
          (json['attendance_percentage'] as num?)?.toDouble() ?? 0.0,
      effectiveDays: (json['effective_days'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Model Entri Sholat Dhuhur per Hari pada Matriks Kalender
class SiswaDaySholat {
  final int day;
  final String date;
  final String status;
  final String statusLabel;
  final String keterangan;
  final String dayName;

  const SiswaDaySholat({
    required this.day,
    required this.date,
    required this.status,
    required this.statusLabel,
    required this.keterangan,
    required this.dayName,
  });

  factory SiswaDaySholat.fromJson(Map<String, dynamic> json) {
    return SiswaDaySholat(
      day: (json['day'] as num?)?.toInt() ?? 0,
      date: json['date']?.toString() ?? '',
      status: json['status']?.toString().toLowerCase() ?? 'belum',
      statusLabel: json['status_label']?.toString() ?? 'Belum Presensi',
      keterangan: json['keterangan']?.toString() ?? '',
      dayName: json['day_name']?.toString() ?? '',
    );
  }
}

/// Model Riwayat Aktivitas Sholat Dhuhur Terakhir
class SiswaSholatRecentActivity {
  final String date;
  final String formattedDate;
  final String status;
  final String statusLabel;
  final String? note;

  const SiswaSholatRecentActivity({
    required this.date,
    required this.formattedDate,
    required this.status,
    required this.statusLabel,
    this.note,
  });

  factory SiswaSholatRecentActivity.fromJson(Map<String, dynamic> json) {
    return SiswaSholatRecentActivity(
      date: json['date']?.toString() ?? '',
      formattedDate: json['formatted_date']?.toString() ?? '',
      status: json['status']?.toString().toLowerCase() ?? '',
      statusLabel: json['status_label']?.toString() ?? '',
      note: json['note']?.toString(),
    );
  }
}

/// Model Keseluruhan Response Dashboard Sholat Dhuhur Siswa
class SiswaSholatDashboardResponse {
  final bool enableSholatDhuhur;
  final bool isNonMuslim;
  final String studentName;
  final String studentNisn;
  final String className;
  final String religion;
  final SiswaSelectedPeriod selectedPeriod;
  final List<SiswaAvailableMonth> availableMonths;
  final SiswaSholatMonthlyStats stats;
  final Map<int, SiswaDaySholat> attendanceMatrix;
  final List<SiswaSholatRecentActivity> recentActivity;

  const SiswaSholatDashboardResponse({
    required this.enableSholatDhuhur,
    required this.isNonMuslim,
    required this.studentName,
    required this.studentNisn,
    required this.className,
    required this.religion,
    required this.selectedPeriod,
    required this.availableMonths,
    required this.stats,
    required this.attendanceMatrix,
    required this.recentActivity,
  });

  factory SiswaSholatDashboardResponse.fromJson(Map<String, dynamic> json) {
    final studentJson = json['student'] is Map<String, dynamic>
        ? json['student'] as Map<String, dynamic>
        : <String, dynamic>{};
    final periodJson = json['selected_period'] is Map<String, dynamic>
        ? json['selected_period'] as Map<String, dynamic>
        : <String, dynamic>{};
    final statsJson = json['stats'] is Map<String, dynamic>
        ? json['stats'] as Map<String, dynamic>
        : <String, dynamic>{};

    final monthsList = (json['available_months'] is List
            ? json['available_months'] as List
            : [])
        .whereType<Map<String, dynamic>>()
        .map((e) => SiswaAvailableMonth.fromJson(e))
        .toList();

    final Map<int, SiswaDaySholat> matrixMap = {};
    if (json['attendance_matrix'] is Map) {
      final matrixJson = json['attendance_matrix'] as Map;
      matrixJson.forEach((key, val) {
        final dayInt = int.tryParse(key.toString());
        if (dayInt != null && val is Map<String, dynamic>) {
          matrixMap[dayInt] = SiswaDaySholat.fromJson(val);
        }
      });
    }

    final recentList = (json['recent_activity'] is List
            ? json['recent_activity'] as List
            : [])
        .whereType<Map<String, dynamic>>()
        .map((e) => SiswaSholatRecentActivity.fromJson(e))
        .toList();

    return SiswaSholatDashboardResponse(
      enableSholatDhuhur: json['enable_sholat_dhuhur'] == true,
      isNonMuslim: json['is_non_muslim'] == true,
      studentName: studentJson['name']?.toString() ?? '',
      studentNisn: studentJson['nisn']?.toString() ?? '',
      className: studentJson['class_name']?.toString() ?? '',
      religion: studentJson['religion']?.toString() ?? 'Islam',
      selectedPeriod: SiswaSelectedPeriod.fromJson(periodJson),
      availableMonths: monthsList,
      stats: SiswaSholatMonthlyStats.fromJson(statsJson),
      attendanceMatrix: matrixMap,
      recentActivity: recentList,
    );
  }
}

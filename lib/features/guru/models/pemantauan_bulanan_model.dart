/// Model Data Pemantauan Bulanan (Matriks 12 Bulan & 4 Pilar)
class PemantauanBulananResponse {
  final bool success;
  final List<BulanHeaderItem> bulanHeaders;
  final List<MatriksSiswaModel> matriksSiswa;
  final Map<String, int> distribusiPilar;
  final int totalSeluruhSesi;

  PemantauanBulananResponse({
    required this.success,
    required this.bulanHeaders,
    required this.matriksSiswa,
    required this.distribusiPilar,
    required this.totalSeluruhSesi,
  });

  factory PemantauanBulananResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final rawHeaders = data['bulan_headers'] as List? ?? [];
    final rawMatriks = data['matriks_siswa'] as List? ?? [];
    final rawDistribusi = data['distribusi_pilar'] as Map<String, dynamic>? ?? {};

    final mapPilar = <String, int>{};
    rawDistribusi.forEach((k, v) {
      mapPilar[k] = (v as num?)?.toInt() ?? 0;
    });

    return PemantauanBulananResponse(
      success: json['success'] == true,
      bulanHeaders: rawHeaders
          .whereType<Map<String, dynamic>>()
          .map((e) => BulanHeaderItem.fromJson(e))
          .toList(),
      matriksSiswa: rawMatriks
          .whereType<Map<String, dynamic>>()
          .map((e) => MatriksSiswaModel.fromJson(e))
          .toList(),
      distribusiPilar: mapPilar,
      totalSeluruhSesi: (data['total_seluruh_sesi'] as num?)?.toInt() ?? 0,
    );
  }
}

class BulanHeaderItem {
  final String key;
  final String label;
  final int bulan;
  final int tahun;

  BulanHeaderItem({
    required this.key,
    required this.label,
    required this.bulan,
    required this.tahun,
  });

  factory BulanHeaderItem.fromJson(Map<String, dynamic> json) {
    return BulanHeaderItem(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      bulan: (json['bulan'] as num?)?.toInt() ?? 1,
      tahun: (json['tahun'] as num?)?.toInt() ?? 2026,
    );
  }
}

class MatriksSiswaModel {
  final String studentId;
  final String name;
  final String nisn;
  final String kelasName;
  final String? avatarUrl;
  final int totalSesi;
  final int totalBulanDidampingi;
  final int kepatuhanPersen;
  final List<MonthlyStatusItem> monthlyStatus;

  MatriksSiswaModel({
    required this.studentId,
    required this.name,
    required this.nisn,
    required this.kelasName,
    this.avatarUrl,
    required this.totalSesi,
    required this.totalBulanDidampingi,
    required this.kepatuhanPersen,
    required this.monthlyStatus,
  });

  factory MatriksSiswaModel.fromJson(Map<String, dynamic> json) {
    final rawMonthly = json['monthly_status'] as List? ?? [];

    return MatriksSiswaModel(
      studentId: (json['student_id'] ?? '').toString(),
      name: json['name'] as String? ?? 'Siswa',
      nisn: json['nisn'] as String? ?? '-',
      kelasName: json['kelas_name'] as String? ?? '-',
      avatarUrl: json['avatar_url'] as String?,
      totalSesi: (json['total_sesi'] as num?)?.toInt() ?? 0,
      totalBulanDidampingi: (json['total_bulan_didampingi'] as num?)?.toInt() ?? 0,
      kepatuhanPersen: (json['kepatuhan_persen'] as num?)?.toInt() ?? 0,
      monthlyStatus: rawMonthly
          .whereType<Map<String, dynamic>>()
          .map((e) => MonthlyStatusItem.fromJson(e))
          .toList(),
    );
  }
}

class MonthlyStatusItem {
  final String key;
  final String label;
  final bool isDidampingi;
  final int count;

  MonthlyStatusItem({
    required this.key,
    required this.label,
    required this.isDidampingi,
    required this.count,
  });

  factory MonthlyStatusItem.fromJson(Map<String, dynamic> json) {
    return MonthlyStatusItem(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      isDidampingi: json['is_didampingi'] == true,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

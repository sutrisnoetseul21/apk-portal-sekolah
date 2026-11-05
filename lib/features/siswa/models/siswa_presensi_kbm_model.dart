/// Model Data Presensi KBM Mata Pelajaran Siswa (Menu 1 - Tab 3)
/// Menghitung kehadiran berdasarkan pertemuan terlaksana / terdata dari Jurnal Mengajar Guru
library;

class SiswaKbmStudent {
  final String name;
  final String nisn;
  final String className;

  const SiswaKbmStudent({
    required this.name,
    required this.nisn,
    required this.className,
  });

  factory SiswaKbmStudent.fromJson(Map<String, dynamic> json) {
    return SiswaKbmStudent(
      name: json['name']?.toString() ?? '',
      nisn: json['nisn']?.toString() ?? '',
      className: json['class_name']?.toString() ?? '',
    );
  }
}

class SiswaKbmPeriod {
  final bool isAllMonths;
  final String monthYear;
  final int? month;
  final int? year;

  const SiswaKbmPeriod({
    this.isAllMonths = true,
    this.monthYear = 'all',
    this.month,
    this.year,
  });

  factory SiswaKbmPeriod.fromJson(Map<String, dynamic> json) {
    return SiswaKbmPeriod(
      isAllMonths: json['is_all_months'] == true,
      monthYear: json['month_year']?.toString() ?? 'all',
      month: (json['month'] as num?)?.toInt(),
      year: (json['year'] as num?)?.toInt(),
    );
  }
}

class SiswaKbmAvailableMonth {
  final String key;
  final int month;
  final int year;
  final String label;

  const SiswaKbmAvailableMonth({
    required this.key,
    required this.month,
    required this.year,
    required this.label,
  });

  factory SiswaKbmAvailableMonth.fromJson(Map<String, dynamic> json) {
    return SiswaKbmAvailableMonth(
      key: json['key']?.toString() ?? '',
      month: (json['month'] as num?)?.toInt() ?? 0,
      year: (json['year'] as num?)?.toInt() ?? 0,
      label: json['label']?.toString() ?? '',
    );
  }
}

class SiswaKbmSummary {
  final int totalPertemuanTerdata;
  final int totalHadir;
  final int totalSakit;
  final int totalIzin;
  final int totalAlpa;
  final int totalTidakMengikuti;
  final double persentaseKehadiran;

  const SiswaKbmSummary({
    this.totalPertemuanTerdata = 0,
    this.totalHadir = 0,
    this.totalSakit = 0,
    this.totalIzin = 0,
    this.totalAlpa = 0,
    this.totalTidakMengikuti = 0,
    this.persentaseKehadiran = 100.0,
  });

  factory SiswaKbmSummary.fromJson(Map<String, dynamic> json) {
    return SiswaKbmSummary(
      totalPertemuanTerdata: (json['total_pertemuan_terdata'] as num?)?.toInt() ?? 0,
      totalHadir: (json['total_hadir'] as num?)?.toInt() ?? 0,
      totalSakit: (json['total_sakit'] as num?)?.toInt() ?? 0,
      totalIzin: (json['total_izin'] as num?)?.toInt() ?? 0,
      totalAlpa: (json['total_alpa'] as num?)?.toInt() ?? 0,
      totalTidakMengikuti: (json['total_tidak_mengikuti'] as num?)?.toInt() ?? 0,
      persentaseKehadiran: (json['persentase_kehadiran'] as num?)?.toDouble() ?? 100.0,
    );
  }
}

class SiswaKbmGuru {
  final String id;
  final String name;
  final String nip;
  final String? photoUrl;

  const SiswaKbmGuru({
    required this.id,
    required this.name,
    required this.nip,
    this.photoUrl,
  });

  factory SiswaKbmGuru.fromJson(Map<String, dynamic> json) {
    return SiswaKbmGuru(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Guru Pengampu',
      nip: json['nip']?.toString() ?? '-',
      photoUrl: json['photo_url']?.toString(),
    );
  }
}

class SiswaKbmSubjectStats {
  final int totalPertemuanTerdata;
  final int hadir;
  final int sakit;
  final int izin;
  final int alpa;
  final int tidakMengikuti;
  final double persentaseKehadiran;

  const SiswaKbmSubjectStats({
    this.totalPertemuanTerdata = 0,
    this.hadir = 0,
    this.sakit = 0,
    this.izin = 0,
    this.alpa = 0,
    this.tidakMengikuti = 0,
    this.persentaseKehadiran = 100.0,
  });

  factory SiswaKbmSubjectStats.fromJson(Map<String, dynamic> json) {
    return SiswaKbmSubjectStats(
      totalPertemuanTerdata: (json['total_pertemuan_terdata'] as num?)?.toInt() ?? 0,
      hadir: (json['hadir'] as num?)?.toInt() ?? 0,
      sakit: (json['sakit'] as num?)?.toInt() ?? 0,
      izin: (json['izin'] as num?)?.toInt() ?? 0,
      alpa: (json['alpa'] as num?)?.toInt() ?? 0,
      tidakMengikuti: (json['tidak_mengikuti'] as num?)?.toInt() ?? 0,
      persentaseKehadiran: (json['persentase_kehadiran'] as num?)?.toDouble() ?? 100.0,
    );
  }
}

class SiswaKbmPertemuan {
  final String jurnalId;
  final int pertemuanKe;
  final String tanggal;
  final String tanggalFormatted;
  final String hari;
  final String jamKeLabel;
  final int durasiJp;
  final String materi;
  final String uraianMateri;
  final String status;
  final String statusLabel;
  final String statusGerbang;
  final String keterangan;
  final String guruNama;

  const SiswaKbmPertemuan({
    required this.jurnalId,
    required this.pertemuanKe,
    required this.tanggal,
    required this.tanggalFormatted,
    required this.hari,
    required this.jamKeLabel,
    required this.durasiJp,
    required this.materi,
    required this.uraianMateri,
    required this.status,
    required this.statusLabel,
    required this.statusGerbang,
    required this.keterangan,
    required this.guruNama,
  });

  factory SiswaKbmPertemuan.fromJson(Map<String, dynamic> json) {
    return SiswaKbmPertemuan(
      jurnalId: json['jurnal_id']?.toString() ?? '',
      pertemuanKe: (json['pertemuan_ke'] as num?)?.toInt() ?? 1,
      tanggal: json['tanggal']?.toString() ?? '',
      tanggalFormatted: json['tanggal_formatted']?.toString() ?? '',
      hari: json['hari']?.toString() ?? '',
      jamKeLabel: json['jam_ke_label']?.toString() ?? '',
      durasiJp: (json['durasi_jp'] as num?)?.toInt() ?? 2,
      materi: json['materi']?.toString() ?? '-',
      uraianMateri: json['uraian_materi']?.toString() ?? '',
      status: json['status']?.toString().toLowerCase() ?? 'hadir',
      statusLabel: json['status_label']?.toString() ?? 'Hadir',
      statusGerbang: json['status_gerbang']?.toString() ?? 'hadir',
      keterangan: json['keterangan']?.toString() ?? '',
      guruNama: json['guru_nama']?.toString() ?? '-',
    );
  }
}

class SiswaKbmSubject {
  final dynamic mataPelajaranId;
  final String namaMapel;
  final String kodeMapel;
  final String kategori;
  final double kkm;
  final SiswaKbmGuru guruPengampu;
  final SiswaKbmSubjectStats stats;
  final bool hasData;
  final List<SiswaKbmPertemuan> pertemuanList;

  const SiswaKbmSubject({
    required this.mataPelajaranId,
    required this.namaMapel,
    required this.kodeMapel,
    required this.kategori,
    required this.kkm,
    required this.guruPengampu,
    required this.stats,
    required this.hasData,
    required this.pertemuanList,
  });

  factory SiswaKbmSubject.fromJson(Map<String, dynamic> json) {
    final guruJson = json['guru_pengampu'] is Map<String, dynamic>
        ? json['guru_pengampu'] as Map<String, dynamic>
        : <String, dynamic>{};
    final statsJson = json['stats'] is Map<String, dynamic>
        ? json['stats'] as Map<String, dynamic>
        : <String, dynamic>{};
    final meetings = (json['pertemuan_list'] is List ? json['pertemuan_list'] as List : [])
        .whereType<Map<String, dynamic>>()
        .map((e) => SiswaKbmPertemuan.fromJson(e))
        .toList();

    return SiswaKbmSubject(
      mataPelajaranId: json['mata_pelajaran_id'],
      namaMapel: json['nama_mapel']?.toString() ?? 'Mata Pelajaran',
      kodeMapel: json['kode_mapel']?.toString() ?? 'MP',
      kategori: json['kategori']?.toString() ?? 'Umum',
      kkm: (json['kkm'] as num?)?.toDouble() ?? 75.0,
      guruPengampu: SiswaKbmGuru.fromJson(guruJson),
      stats: SiswaKbmSubjectStats.fromJson(statsJson),
      hasData: json['has_data'] == true,
      pertemuanList: meetings,
    );
  }
}

class SiswaKbmRecentActivity {
  final String jurnalId;
  final String namaMapel;
  final String materi;
  final String tanggal;
  final String tanggalFormatted;
  final String jamKeLabel;
  final String status;
  final String statusLabel;
  final String guruNama;

  const SiswaKbmRecentActivity({
    required this.jurnalId,
    required this.namaMapel,
    required this.materi,
    required this.tanggal,
    required this.tanggalFormatted,
    required this.jamKeLabel,
    required this.status,
    required this.statusLabel,
    required this.guruNama,
  });

  factory SiswaKbmRecentActivity.fromJson(Map<String, dynamic> json) {
    return SiswaKbmRecentActivity(
      jurnalId: json['jurnal_id']?.toString() ?? '',
      namaMapel: json['nama_mapel']?.toString() ?? '-',
      materi: json['materi']?.toString() ?? 'KBM',
      tanggal: json['tanggal']?.toString() ?? '',
      tanggalFormatted: json['tanggal_formatted']?.toString() ?? '',
      jamKeLabel: json['jam_ke_label']?.toString() ?? '',
      status: json['status']?.toString().toLowerCase() ?? 'hadir',
      statusLabel: json['status_label']?.toString() ?? 'Hadir',
      guruNama: json['guru_nama']?.toString() ?? '-',
    );
  }
}

class SiswaPresensiKbmResponse {
  final bool enablePresensiKbm;
  final SiswaKbmStudent student;
  final SiswaKbmPeriod selectedPeriod;
  final List<SiswaKbmAvailableMonth> availableMonths;
  final SiswaKbmSummary summary;
  final List<SiswaKbmSubject> subjects;
  final List<SiswaKbmRecentActivity> recentActivity;

  const SiswaPresensiKbmResponse({
    required this.enablePresensiKbm,
    required this.student,
    required this.selectedPeriod,
    required this.availableMonths,
    required this.summary,
    required this.subjects,
    required this.recentActivity,
  });

  factory SiswaPresensiKbmResponse.fromJson(Map<String, dynamic> json) {
    final studentJson = json['student'] is Map<String, dynamic>
        ? json['student'] as Map<String, dynamic>
        : <String, dynamic>{};
    final periodJson = json['selected_period'] is Map<String, dynamic>
        ? json['selected_period'] as Map<String, dynamic>
        : <String, dynamic>{};
    final summaryJson = json['summary'] is Map<String, dynamic>
        ? json['summary'] as Map<String, dynamic>
        : <String, dynamic>{};

    final months = (json['available_months'] is List ? json['available_months'] as List : [])
        .whereType<Map<String, dynamic>>()
        .map((e) => SiswaKbmAvailableMonth.fromJson(e))
        .toList();

    final subjectsList = (json['subjects'] is List ? json['subjects'] as List : [])
        .whereType<Map<String, dynamic>>()
        .map((e) => SiswaKbmSubject.fromJson(e))
        .toList();

    final recentList = (json['recent_activity'] is List ? json['recent_activity'] as List : [])
        .whereType<Map<String, dynamic>>()
        .map((e) => SiswaKbmRecentActivity.fromJson(e))
        .toList();

    return SiswaPresensiKbmResponse(
      enablePresensiKbm: json['enable_presensi_kbm'] != false,
      student: SiswaKbmStudent.fromJson(studentJson),
      selectedPeriod: SiswaKbmPeriod.fromJson(periodJson),
      availableMonths: months,
      summary: SiswaKbmSummary.fromJson(summaryJson),
      subjects: subjectsList,
      recentActivity: recentList,
    );
  }
}

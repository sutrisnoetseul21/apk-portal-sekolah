/// Model Data Dashboard & Siswa Asuh Guru Wali (SI-WALI)
class GuruWaliDashboardResponse {
  final bool success;
  final bool hasKelompok;
  final String? message;
  final GuruWaliDashboardData? data;

  GuruWaliDashboardResponse({
    required this.success,
    required this.hasKelompok,
    this.message,
    this.data,
  });

  factory GuruWaliDashboardResponse.fromJson(Map<String, dynamic> json) {
    return GuruWaliDashboardResponse(
      success: json['success'] == true,
      hasKelompok: json['has_kelompok'] == true,
      message: json['message'] as String?,
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? GuruWaliDashboardData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class GuruWaliDashboardData {
  final GuruWaliTeacherModel? teacher;
  final GuruWaliKelompokModel? kelompok;
  final GuruWaliTahunAjaranModel? tahunAjaran;
  final String bulanIni;
  final GuruWaliStatistikModel statistik;
  final List<SiswaAsuhModel> siswaAktif;
  final List<SiswaArsipModel> siswaArsip;

  GuruWaliDashboardData({
    this.teacher,
    this.kelompok,
    this.tahunAjaran,
    required this.bulanIni,
    required this.statistik,
    required this.siswaAktif,
    required this.siswaArsip,
  });

  factory GuruWaliDashboardData.fromJson(Map<String, dynamic> json) {
    final rawAktif = json['siswa_aktif'] as List? ?? [];
    final rawArsip = json['siswa_arsip'] as List? ?? [];

    return GuruWaliDashboardData(
      teacher: json['teacher'] != null
          ? GuruWaliTeacherModel.fromJson(json['teacher'] as Map<String, dynamic>)
          : null,
      kelompok: json['kelompok'] != null
          ? GuruWaliKelompokModel.fromJson(json['kelompok'] as Map<String, dynamic>)
          : null,
      tahunAjaran: json['tahun_ajaran'] != null
          ? GuruWaliTahunAjaranModel.fromJson(json['tahun_ajaran'] as Map<String, dynamic>)
          : null,
      bulanIni: json['bulan_ini'] as String? ?? '',
      statistik: GuruWaliStatistikModel.fromJson(
        json['statistik'] as Map<String, dynamic>? ?? {},
      ),
      siswaAktif: rawAktif
          .whereType<Map<String, dynamic>>()
          .map((e) => SiswaAsuhModel.fromJson(e))
          .toList(),
      siswaArsip: rawArsip
          .whereType<Map<String, dynamic>>()
          .map((e) => SiswaArsipModel.fromJson(e))
          .toList(),
    );
  }
}

class GuruWaliTeacherModel {
  final String id;
  final String name;
  final String nip;
  final String bebanJp;

  GuruWaliTeacherModel({
    required this.id,
    required this.name,
    required this.nip,
    required this.bebanJp,
  });

  factory GuruWaliTeacherModel.fromJson(Map<String, dynamic> json) {
    return GuruWaliTeacherModel(
      id: (json['id'] ?? '').toString(),
      name: json['name'] as String? ?? 'Guru Pembimbing',
      nip: json['nip'] as String? ?? '-',
      bebanJp: json['beban_jp'] as String? ?? '2 JP/Minggu',
    );
  }
}

class GuruWaliKelompokModel {
  final String id;
  final String namaKelompok;
  final bool statusAktif;

  GuruWaliKelompokModel({
    required this.id,
    required this.namaKelompok,
    required this.statusAktif,
  });

  factory GuruWaliKelompokModel.fromJson(Map<String, dynamic> json) {
    return GuruWaliKelompokModel(
      id: (json['id'] ?? '').toString(),
      namaKelompok: json['nama_kelompok'] as String? ?? 'Kelompok Asuh',
      statusAktif: json['status_aktif'] == true || json['status_aktif'] == 1,
    );
  }
}

class GuruWaliTahunAjaranModel {
  final String? id;
  final String name;

  GuruWaliTahunAjaranModel({this.id, required this.name});

  factory GuruWaliTahunAjaranModel.fromJson(Map<String, dynamic> json) {
    return GuruWaliTahunAjaranModel(
      id: json['id']?.toString(),
      name: json['name'] as String? ?? '-',
    );
  }
}

class GuruWaliStatistikModel {
  final int totalSiswaAktif;
  final int totalDidampingiBulanIni;
  final int persenKepatuhan;
  final int totalSiswaArsip;
  final int pendingKonsultasiCount;

  GuruWaliStatistikModel({
    required this.totalSiswaAktif,
    required this.totalDidampingiBulanIni,
    required this.persenKepatuhan,
    required this.totalSiswaArsip,
    required this.pendingKonsultasiCount,
  });

  factory GuruWaliStatistikModel.fromJson(Map<String, dynamic> json) {
    return GuruWaliStatistikModel(
      totalSiswaAktif: _parseInt(json['total_siswa_aktif']),
      totalDidampingiBulanIni: _parseInt(json['total_didampingi_bulan_ini']),
      persenKepatuhan: _parseInt(json['persen_kepatuhan']),
      totalSiswaArsip: _parseInt(json['total_siswa_arsip']),
      pendingKonsultasiCount: _parseInt(json['pending_konsultasi_count']),
    );
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }
}

/// Model Siswa Asuh dalam Model Kotak-Kotak (Grid Cards)
class SiswaAsuhModel {
  final String anggotaId;
  final String studentId;
  final String name;
  final String nisn;
  final String gender;
  final String kelasName;
  final String? avatarUrl;
  final dynamic tahunMasuk;
  final bool hasBimbingan;
  final int bimbinganCount;
  final String? lastBimbinganAt;
  final String? lastBimbinganDateFormatted;
  final String? lastKategori;
  final String? lastStatus;
  final bool hasActiveKonsultasi;
  final String? activeKonsultasiId;
  final String? activeKonsultasiStatus;
  final int unreadKonsultasiCount;

  SiswaAsuhModel({
    required this.anggotaId,
    required this.studentId,
    required this.name,
    required this.nisn,
    required this.gender,
    required this.kelasName,
    this.avatarUrl,
    this.tahunMasuk,
    required this.hasBimbingan,
    required this.bimbinganCount,
    this.lastBimbinganAt,
    this.lastBimbinganDateFormatted,
    this.lastKategori,
    this.lastStatus,
    required this.hasActiveKonsultasi,
    this.activeKonsultasiId,
    this.activeKonsultasiStatus,
    required this.unreadKonsultasiCount,
  });

  factory SiswaAsuhModel.fromJson(Map<String, dynamic> json) {
    return SiswaAsuhModel(
      anggotaId: (json['anggota_id'] ?? '').toString(),
      studentId: (json['student_id'] ?? '').toString(),
      name: json['name'] as String? ?? 'Tanpa Nama',
      nisn: json['nisn'] as String? ?? '-',
      gender: json['gender'] as String? ?? 'L',
      kelasName: json['kelas_name'] as String? ?? '-',
      avatarUrl: json['avatar_url'] as String?,
      tahunMasuk: json['tahun_masuk'],
      hasBimbingan: json['has_bimbingan'] == true || json['has_bimbingan'] == 1,
      bimbinganCount: (json['bimbingan_count'] as num?)?.toInt() ?? 0,
      lastBimbinganAt: json['last_bimbingan_at'] as String?,
      lastBimbinganDateFormatted: json['last_bimbingan_date_formatted'] as String?,
      lastKategori: json['last_kategori'] as String?,
      lastStatus: json['last_status'] as String?,
      hasActiveKonsultasi: json['has_active_konsultasi'] == true,
      activeKonsultasiId: json['active_konsultasi_id']?.toString(),
      activeKonsultasiStatus: json['active_konsultasi_status'] as String?,
      unreadKonsultasiCount: (json['unread_konsultasi_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class SiswaArsipModel {
  final String anggotaId;
  final String studentId;
  final String name;
  final String nisn;
  final String kelasName;
  final dynamic tahunMasuk;

  SiswaArsipModel({
    required this.anggotaId,
    required this.studentId,
    required this.name,
    required this.nisn,
    required this.kelasName,
    this.tahunMasuk,
  });

  factory SiswaArsipModel.fromJson(Map<String, dynamic> json) {
    return SiswaArsipModel(
      anggotaId: (json['anggota_id'] ?? '').toString(),
      studentId: (json['student_id'] ?? '').toString(),
      name: json['name'] as String? ?? 'Tanpa Nama',
      nisn: json['nisn'] as String? ?? '-',
      kelasName: json['kelas_name'] as String? ?? '-',
      tahunMasuk: json['tahun_masuk'],
    );
  }
}


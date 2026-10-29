/// Model Data Jurnal Guru Wali (SI-WALI)
class JurnalGuruWaliListResponse {
  final bool success;
  final List<JurnalGuruWaliItem> data;
  final JurnalPaginationMeta? pagination;

  JurnalGuruWaliListResponse({
    required this.success,
    required this.data,
    this.pagination,
  });

  factory JurnalGuruWaliListResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List? ?? [];
    return JurnalGuruWaliListResponse(
      success: json['success'] == true,
      data: list
          .whereType<Map<String, dynamic>>()
          .map((e) => JurnalGuruWaliItem.fromJson(e))
          .toList(),
      pagination: json['pagination'] != null && json['pagination'] is Map<String, dynamic>
          ? JurnalPaginationMeta.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }
}

class JurnalGuruWaliItem {
  final String id;
  final String studentId;
  final String studentName;
  final String studentNisn;
  final String? studentAvatar;
  final String kelasName;
  final String tanggalWaktu;
  final String tanggalWaktuFormatted;
  final String jenisPendampingan;
  final String kategoriPendampingan;
  final String uraianPembahasan;
  final String statusSesi;
  final String rujukanKolaborasi;
  final String rencanaTindakLanjut;
  final String kategoriSentimen;
  final bool isPublicNote;
  final bool isRujukBk;
  final String? rujukBkId;
  final String? rujukBkStatus;

  JurnalGuruWaliItem({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentNisn,
    this.studentAvatar,
    required this.kelasName,
    required this.tanggalWaktu,
    required this.tanggalWaktuFormatted,
    required this.jenisPendampingan,
    required this.kategoriPendampingan,
    required this.uraianPembahasan,
    required this.statusSesi,
    required this.rujukanKolaborasi,
    required this.rencanaTindakLanjut,
    required this.kategoriSentimen,
    required this.isPublicNote,
    required this.isRujukBk,
    this.rujukBkId,
    this.rujukBkStatus,
  });

  factory JurnalGuruWaliItem.fromJson(Map<String, dynamic> json) {
    return JurnalGuruWaliItem(
      id: (json['id'] ?? '').toString(),
      studentId: (json['student_id'] ?? '').toString(),
      studentName: json['student_name'] as String? ?? 'Siswa',
      studentNisn: json['student_nisn'] as String? ?? '-',
      studentAvatar: json['student_avatar'] as String?,
      kelasName: json['kelas_name'] as String? ?? '-',
      tanggalWaktu: json['tanggal_waktu'] as String? ?? '',
      tanggalWaktuFormatted: json['tanggal_waktu_formatted'] as String? ?? '',
      jenisPendampingan: json['jenis_pendampingan'] as String? ?? 'Individu',
      kategoriPendampingan: json['kategori_pendampingan'] as String? ?? 'Akademik',
      uraianPembahasan: json['uraian_pembahasan'] as String? ?? '',
      statusSesi: json['status_sesi'] as String? ?? 'Tuntas / Selesai',
      rujukanKolaborasi: json['rujukan_kolaborasi'] as String? ?? 'Mandiri',
      rencanaTindakLanjut: json['rencana_tindak_lanjut'] as String? ?? '',
      kategoriSentimen: json['kategori_sentimen'] as String? ?? 'Netral',
      isPublicNote: json['is_public_note'] == true || json['is_public_note'] == 1,
      isRujukBk: json['is_rujuk_bk'] == true,
      rujukBkId: json['rujuk_bk_id']?.toString(),
      rujukBkStatus: json['rujuk_bk_status'] as String?,
    );
  }
}

class JurnalPaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  JurnalPaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory JurnalPaginationMeta.fromJson(Map<String, dynamic> json) {
    return JurnalPaginationMeta(
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
      perPage: (json['per_page'] as num?)?.toInt() ?? 15,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}


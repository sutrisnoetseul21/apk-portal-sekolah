/// Model Data Ruang Aman Cerita & Konsultasi Siswa Guru Wali (SI-WALI)
class KonsultasiGuruWaliListResponse {
  final bool success;
  final List<KonsultasiGuruWaliItem> data;

  KonsultasiGuruWaliListResponse({
    required this.success,
    required this.data,
  });

  factory KonsultasiGuruWaliListResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List? ?? [];
    return KonsultasiGuruWaliListResponse(
      success: json['success'] == true,
      data: list
          .whereType<Map<String, dynamic>>()
          .map((e) => KonsultasiGuruWaliItem.fromJson(e))
          .toList(),
    );
  }
}

class KonsultasiGuruWaliItem {
  final String id;
  final String studentId;
  final String studentName;
  final String studentNisn;
  final String? studentAvatar;
  final String kelasName;
  final String kategoriPendampingan;
  final String topikKonsultasi;
  final String detailPermasalahan;
  final String modeKonsultasi;
  final String statusPengajuan;
  final String? usulanTanggalWaktu;
  final String? jadwalPasti;
  final String? jadwalPastiFormatted;
  final String? tanggapanGuru;
  final String? alasanPenolakan;
  final String createdAt;
  final String createdAtFormatted;
  final int unreadMessagesCount;
  final int totalMessagesCount;
  final PesanSingkatModel? lastMessage;
  final bool isDikonversi;
  final String? jurnalId;
  final List<PesanKonsultasiItem> messages;

  KonsultasiGuruWaliItem({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentNisn,
    this.studentAvatar,
    required this.kelasName,
    required this.kategoriPendampingan,
    required this.topikKonsultasi,
    required this.detailPermasalahan,
    required this.modeKonsultasi,
    required this.statusPengajuan,
    this.usulanTanggalWaktu,
    this.jadwalPasti,
    this.jadwalPastiFormatted,
    this.tanggapanGuru,
    this.alasanPenolakan,
    required this.createdAt,
    required this.createdAtFormatted,
    required this.unreadMessagesCount,
    required this.totalMessagesCount,
    this.lastMessage,
    required this.isDikonversi,
    this.jurnalId,
    this.messages = const [],
  });

  factory KonsultasiGuruWaliItem.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'] as List? ?? [];

    return KonsultasiGuruWaliItem(
      id: (json['id'] ?? '').toString(),
      studentId: (json['student_id'] ?? '').toString(),
      studentName: json['student_name'] as String? ?? 'Siswa',
      studentNisn: json['student_nisn'] as String? ?? '-',
      studentAvatar: json['student_avatar'] as String?,
      kelasName: json['kelas_name'] as String? ?? '-',
      kategoriPendampingan: json['kategori_pendampingan'] as String? ?? 'Akademik',
      topikKonsultasi: json['topik_konsultasi'] as String? ?? '',
      detailPermasalahan: json['detail_permasalahan'] as String? ?? '',
      modeKonsultasi: json['mode_konsultasi'] as String? ?? 'Tatap Muka',
      statusPengajuan: json['status_pengajuan'] as String? ?? 'Menunggu Konfirmasi',
      usulanTanggalWaktu: json['usulan_tanggal_waktu'] as String?,
      jadwalPasti: json['jadwal_pasti'] as String?,
      jadwalPastiFormatted: json['jadwal_pasti_formatted'] as String?,
      tanggapanGuru: json['tanggapan_guru'] as String?,
      alasanPenolakan: json['alasan_penolakan'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      createdAtFormatted: json['created_at_formatted'] as String? ?? '',
      unreadMessagesCount: (json['unread_messages_count'] as num?)?.toInt() ?? 0,
      totalMessagesCount: (json['total_messages_count'] as num?)?.toInt() ?? 0,
      lastMessage: json['last_message'] != null && json['last_message'] is Map<String, dynamic>
          ? PesanSingkatModel.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
      isDikonversi: json['is_dikonversi'] == true,
      jurnalId: json['jurnal_id']?.toString(),
      messages: rawMessages
          .whereType<Map<String, dynamic>>()
          .map((e) => PesanKonsultasiItem.fromJson(e))
          .toList(),
    );
  }
}

class PesanSingkatModel {
  final String pesan;
  final String senderType;
  final String createdAtFormatted;

  PesanSingkatModel({
    required this.pesan,
    required this.senderType,
    required this.createdAtFormatted,
  });

  factory PesanSingkatModel.fromJson(Map<String, dynamic> json) {
    return PesanSingkatModel(
      pesan: json['pesan'] as String? ?? '',
      senderType: json['sender_type'] as String? ?? 'siswa',
      createdAtFormatted: json['created_at_formatted'] as String? ?? '',
    );
  }
}

class PesanKonsultasiItem {
  final String id;
  final String senderType;
  final bool isMe;
  final String pesan;
  final String createdAt;
  final String createdAtFormatted;
  final bool isRead;

  PesanKonsultasiItem({
    required this.id,
    required this.senderType,
    required this.isMe,
    required this.pesan,
    required this.createdAt,
    required this.createdAtFormatted,
    required this.isRead,
  });

  factory PesanKonsultasiItem.fromJson(Map<String, dynamic> json) {
    return PesanKonsultasiItem(
      id: (json['id'] ?? '').toString(),
      senderType: json['sender_type'] as String? ?? 'siswa',
      isMe: json['is_me'] == true,
      pesan: json['pesan'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      createdAtFormatted: json['created_at_formatted'] as String? ?? '',
      isRead: json['is_read'] == true,
    );
  }
}

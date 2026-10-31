/// Model DTO Profil Guru Wali Asuh
class SiswaGuruWaliProfile {
  final String id;
  final String name;
  final String nip;
  final String? photoUrl;
  final String? phone;
  final String namaKelompok;
  final String? tahunAjaran;
  final String? tanggalBergabung;
  final String? formattedTanggalBergabung;

  const SiswaGuruWaliProfile({
    required this.id,
    required this.name,
    required this.nip,
    this.photoUrl,
    this.phone,
    required this.namaKelompok,
    this.tahunAjaran,
    this.tanggalBergabung,
    this.formattedTanggalBergabung,
  });

  factory SiswaGuruWaliProfile.fromJson(Map<String, dynamic> json) {
    return SiswaGuruWaliProfile(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Guru Wali',
      nip: json['nip']?.toString() ?? '-',
      photoUrl: json['photo_url']?.toString(),
      phone: json['phone']?.toString(),
      namaKelompok: json['nama_kelompok']?.toString() ?? 'Kelompok Asuh',
      tahunAjaran: json['tahun_ajaran']?.toString(),
      tanggalBergabung: json['tanggal_bergabung']?.toString(),
      formattedTanggalBergabung: json['formatted_tanggal_bergabung']?.toString(),
    );
  }
}

/// Model DTO Hitungan Ringkasan Status Konsultasi & Klasikal
class SiswaGuruWaliCounts {
  final int semua;
  final int menunggu;
  final int dijadwalkan;
  final int selesai;
  final int ditolak;
  final int klasikal;
  final int kelompokKecil;
  final int totalKlasikal;
  final int catatanGuru;

  const SiswaGuruWaliCounts({
    required this.semua,
    required this.menunggu,
    required this.dijadwalkan,
    required this.selesai,
    required this.ditolak,
    required this.klasikal,
    this.kelompokKecil = 0,
    this.totalKlasikal = 0,
    required this.catatanGuru,
  });

  factory SiswaGuruWaliCounts.fromJson(Map<String, dynamic> json) {
    return SiswaGuruWaliCounts(
      semua: json['semua'] is int ? json['semua'] : 0,
      menunggu: json['menunggu'] is int ? json['menunggu'] : 0,
      dijadwalkan: json['dijadwalkan'] is int ? json['dijadwalkan'] : 0,
      selesai: json['selesai'] is int ? json['selesai'] : 0,
      ditolak: json['ditolak'] is int ? json['ditolak'] : 0,
      klasikal: json['klasikal'] is int ? json['klasikal'] : 0,
      kelompokKecil: json['kelompok_kecil'] is int ? json['kelompok_kecil'] : 0,
      totalKlasikal: json['total_klasikal'] is int
          ? json['total_klasikal']
          : (json['klasikal'] is int ? json['klasikal'] : 0),
      catatanGuru: json['catatan_guru'] is int ? json['catatan_guru'] : 0,
    );
  }
}

/// Model Respons Dashboard SI-WALI Siswa
class SiswaGuruWaliDashboardResponse {
  final bool hasGuruWali;
  final SiswaGuruWaliProfile? guruWali;
  final SiswaGuruWaliCounts counts;

  const SiswaGuruWaliDashboardResponse({
    required this.hasGuruWali,
    this.guruWali,
    required this.counts,
  });

  factory SiswaGuruWaliDashboardResponse.fromJson(Map<String, dynamic> json) {
    final rawGuruWali = json['guru_wali'] as Map<String, dynamic>?;
    final rawCounts = json['counts'] as Map<String, dynamic>? ?? {};

    return SiswaGuruWaliDashboardResponse(
      hasGuruWali: json['has_guru_wali'] == true,
      guruWali: rawGuruWali != null ? SiswaGuruWaliProfile.fromJson(rawGuruWali) : null,
      counts: SiswaGuruWaliCounts.fromJson(rawCounts),
    );
  }
}

/// Model DTO Item Konsultasi Siswa
class SiswaKonsultasiItem {
  final String id;
  final String kategori;
  final String topik;
  final String detail;
  final String mode; // 'Tatap Muka' | 'Pesan Portal'
  final String status;
  final String statusLabel;
  final String statusKey; // 'menunggu' | 'dijadwalkan' | 'selesai' | 'ditolak'
  final bool isCancellable;
  final bool canChat;
  final bool canFeedback;
  final int unreadMessagesCount;
  final String guruName;
  final String? usulanWaktu;
  final String? formattedUsulanWaktu;
  final String? jadwalPasti;
  final String? formattedJadwalPasti;
  final String? tanggapanGuru;
  final String? alasanPenolakan;
  final int? feedbackRating;
  final String? feedbackEmoji;
  final String? feedbackNote;
  final String createdAt;
  final String formattedCreatedAt;

  const SiswaKonsultasiItem({
    required this.id,
    required this.kategori,
    required this.topik,
    required this.detail,
    required this.mode,
    required this.status,
    required this.statusLabel,
    required this.statusKey,
    required this.isCancellable,
    required this.canChat,
    required this.canFeedback,
    required this.unreadMessagesCount,
    required this.guruName,
    this.usulanWaktu,
    this.formattedUsulanWaktu,
    this.jadwalPasti,
    this.formattedJadwalPasti,
    this.tanggapanGuru,
    this.alasanPenolakan,
    this.feedbackRating,
    this.feedbackEmoji,
    this.feedbackNote,
    required this.createdAt,
    required this.formattedCreatedAt,
  });

  factory SiswaKonsultasiItem.fromJson(Map<String, dynamic> json) {
    return SiswaKonsultasiItem(
      id: json['id']?.toString() ?? '',
      kategori: json['kategori']?.toString() ?? 'Akademik',
      topik: json['topik']?.toString() ?? '',
      detail: json['detail']?.toString() ?? '',
      mode: json['mode']?.toString() ?? 'Tatap Muka',
      status: json['status']?.toString() ?? 'Menunggu Konfirmasi',
      statusLabel: json['status_label']?.toString() ?? 'Menunggu Konfirmasi',
      statusKey: json['status_key']?.toString() ?? 'menunggu',
      isCancellable: json['is_cancellable'] == true,
      canChat: json['can_chat'] == true,
      canFeedback: json['can_feedback'] == true,
      unreadMessagesCount: json['unread_messages_count'] is int ? json['unread_messages_count'] : 0,
      guruName: json['guru_name']?.toString() ?? 'Guru Wali',
      usulanWaktu: json['usulan_waktu']?.toString(),
      formattedUsulanWaktu: json['formatted_usulan_waktu']?.toString(),
      jadwalPasti: json['jadwal_pasti']?.toString(),
      formattedJadwalPasti: json['formatted_jadwal_pasti']?.toString(),
      tanggapanGuru: json['tanggapan_guru']?.toString(),
      alasanPenolakan: json['alasan_penolakan']?.toString(),
      feedbackRating: json['feedback_rating'] is int ? json['feedback_rating'] : null,
      feedbackEmoji: json['feedback_emoji']?.toString(),
      feedbackNote: json['feedback_note']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      formattedCreatedAt: json['formatted_created_at']?.toString() ?? '',
    );
  }
}

/// Model DTO Pesan Obrolan Chat Konsultasi
class SiswaPesanItem {
  final String id;
  final String senderType; // 'siswa' | 'guru'
  final bool isMe;
  final String pesan;
  final bool isRead;
  final String? createdAt;
  final String formattedTime;
  final String? formattedDate;

  const SiswaPesanItem({
    required this.id,
    required this.senderType,
    required this.isMe,
    required this.pesan,
    required this.isRead,
    this.createdAt,
    required this.formattedTime,
    this.formattedDate,
  });

  factory SiswaPesanItem.fromJson(Map<String, dynamic> json) {
    return SiswaPesanItem(
      id: json['id']?.toString() ?? '',
      senderType: json['sender_type']?.toString() ?? 'siswa',
      isMe: json['is_me'] == true,
      pesan: json['pesan']?.toString() ?? '',
      isRead: json['is_read'] == true,
      createdAt: json['created_at']?.toString(),
      formattedTime: json['formatted_time']?.toString() ?? '',
      formattedDate: json['formatted_date']?.toString(),
    );
  }
}

/// Model DTO Detail Lengkap Konsultasi Siswa + Daftar Pesan
class SiswaKonsultasiDetail {
  final SiswaKonsultasiItem item;
  final List<SiswaPesanItem> messages;

  const SiswaKonsultasiDetail({
    required this.item,
    required this.messages,
  });

  factory SiswaKonsultasiDetail.fromJson(Map<String, dynamic> json) {
    final item = SiswaKonsultasiItem.fromJson(json);
    final rawMessages = json['messages'] as List<dynamic>? ?? [];

    return SiswaKonsultasiDetail(
      item: item,
      messages: rawMessages.map((e) => SiswaPesanItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

/// Model DTO Sesi Pendampingan Klasikal / Kelompok
class SiswaBimbinganKlasikalItem {
  final String id;
  final String jenisPendampingan; // 'Klasikal' | 'Kelompok Kecil' | 'Individual'
  final String kategoriPendampingan;
  final String? tanggalWaktu;
  final String formattedDate;
  final String formattedTime;
  final String uraianPembahasan;
  final String? rencanaTindakLanjut;
  final String statusSesi;
  final String guruName;
  final bool isPublicNote;

  const SiswaBimbinganKlasikalItem({
    required this.id,
    required this.jenisPendampingan,
    required this.kategoriPendampingan,
    this.tanggalWaktu,
    required this.formattedDate,
    required this.formattedTime,
    required this.uraianPembahasan,
    this.rencanaTindakLanjut,
    required this.statusSesi,
    required this.guruName,
    required this.isPublicNote,
  });

  factory SiswaBimbinganKlasikalItem.fromJson(Map<String, dynamic> json) {
    return SiswaBimbinganKlasikalItem(
      id: json['id']?.toString() ?? '',
      jenisPendampingan: json['jenis_pendampingan']?.toString() ?? 'Klasikal',
      kategoriPendampingan: json['kategori_pendampingan']?.toString() ?? 'Akademik',
      tanggalWaktu: json['tanggal_waktu']?.toString(),
      formattedDate: json['formatted_date']?.toString() ?? '',
      formattedTime: json['formatted_time']?.toString() ?? '',
      uraianPembahasan: json['uraian_pembahasan']?.toString() ?? '',
      rencanaTindakLanjut: json['rencana_tindak_lanjut']?.toString(),
      statusSesi: json['status_sesi']?.toString() ?? 'Tuntas / Selesai',
      guruName: json['guru_name']?.toString() ?? 'Guru Wali',
      isPublicNote: json['is_public_note'] == true,
    );
  }
}

/// Model Respons Paginated Daftar Konsultasi
class SiswaKonsultasiListResponse {
  final List<SiswaKonsultasiItem> items;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool hasMore;

  const SiswaKonsultasiListResponse({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.hasMore,
  });

  factory SiswaKonsultasiListResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final rawPagination = json['pagination'] as Map<String, dynamic>? ?? {};

    return SiswaKonsultasiListResponse(
      items: rawItems.map((e) => SiswaKonsultasiItem.fromJson(e as Map<String, dynamic>)).toList(),
      currentPage: rawPagination['current_page'] is int ? rawPagination['current_page'] : 1,
      lastPage: rawPagination['last_page'] is int ? rawPagination['last_page'] : 1,
      total: rawPagination['total'] is int ? rawPagination['total'] : 0,
      hasMore: rawPagination['has_more'] == true,
    );
  }
}

/// Model Respons Paginated Daftar Bimbingan Klasikal
class SiswaKlasikalListResponse {
  final List<SiswaBimbinganKlasikalItem> items;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool hasMore;

  const SiswaKlasikalListResponse({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.hasMore,
  });

  factory SiswaKlasikalListResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final rawPagination = json['pagination'] as Map<String, dynamic>? ?? {};

    return SiswaKlasikalListResponse(
      items: rawItems.map((e) => SiswaBimbinganKlasikalItem.fromJson(e as Map<String, dynamic>)).toList(),
      currentPage: rawPagination['current_page'] is int ? rawPagination['current_page'] : 1,
      lastPage: rawPagination['last_page'] is int ? rawPagination['last_page'] : 1,
      total: rawPagination['total'] is int ? rawPagination['total'] : 0,
      hasMore: rawPagination['has_more'] == true,
    );
  }
}


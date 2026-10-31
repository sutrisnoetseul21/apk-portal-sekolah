/// Informasi Hak Akses Pengguna ke Modul SPIKAP
class SpikapAccessInfo {
  final bool canAccess;
  final String roleLabel;
  final bool isBk;
  final bool isWali;
  final bool isKs;
  final bool isAdmin;
  final SpikapKpiStats stats;

  const SpikapAccessInfo({
    required this.canAccess,
    required this.roleLabel,
    this.isBk = false,
    this.isWali = false,
    this.isKs = false,
    this.isAdmin = false,
    required this.stats,
  });

  factory SpikapAccessInfo.fromJson(Map<String, dynamic> json) {
    return SpikapAccessInfo(
      canAccess: json['can_access'] == true,
      roleLabel: json['role_label']?.toString() ?? 'Tamu',
      isBk: json['is_bk'] == true,
      isWali: json['is_wali'] == true,
      isKs: json['is_ks'] == true,
      isAdmin: json['is_admin'] == true,
      stats: json['stats'] is Map<String, dynamic>
          ? SpikapKpiStats.fromJson(json['stats'] as Map<String, dynamic>)
          : const SpikapKpiStats(total: 0, darurat: 0, aktif: 0, selesai: 0),
    );
  }
}

/// Ringkasan Metrik KPI Laporan SPIKAP
class SpikapKpiStats {
  final int total;
  final int darurat;
  final int aktif;
  final int selesai;

  const SpikapKpiStats({
    required this.total,
    required this.darurat,
    required this.aktif,
    required this.selesai,
  });

  factory SpikapKpiStats.fromJson(Map<String, dynamic> json) {
    return SpikapKpiStats(
      total: (json['total'] as num?)?.toInt() ?? 0,
      darurat: (json['darurat'] as num?)?.toInt() ?? 0,
      aktif: (json['aktif'] as num?)?.toInt() ?? 0,
      selesai: (json['selesai'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Ringkasan Data Siswa Pelapor / Terkait
class SpikapStudentSummary {
  final String id;
  final String name;
  final String nisn;
  final String gender;
  final String className;
  final String? namaAyah;
  final String? namaIbu;
  final String? noHp;
  final String? noHpOrtu;
  final String? waHpOrtu;
  final String? photoUrl;

  const SpikapStudentSummary({
    required this.id,
    required this.name,
    required this.nisn,
    this.gender = '-',
    this.className = '-',
    this.namaAyah,
    this.namaIbu,
    this.noHp,
    this.noHpOrtu,
    this.waHpOrtu,
    this.photoUrl,
  });

  factory SpikapStudentSummary.fromJson(Map<String, dynamic> json) {
    return SpikapStudentSummary(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Siswa Tidak Diketahui',
      nisn: json['nisn']?.toString() ?? '-',
      gender: json['gender']?.toString() ?? '-',
      className: json['class_name']?.toString() ?? '-',
      namaAyah: json['nama_ayah']?.toString(),
      namaIbu: json['nama_ibu']?.toString(),
      noHp: json['no_hp']?.toString(),
      noHpOrtu: json['no_hp_orang_tua']?.toString(),
      waHpOrtu: json['wa_hp_ortu']?.toString(),
      photoUrl: json['photo_url']?.toString(),
    );
  }
}

/// Item Tiket Laporan Aduan SPIKAP (Untuk List View Inbox)
class SpikapLaporanItem {
  final int id;
  final String ticketNumber;
  final SpikapStudentSummary student;
  final String sifatLaporan; // 'darurat' / 'biasa'
  final bool isDarurat;
  final String sifatLabel;
  final String jenisPerundungan; // 'fisik', 'verbal', 'sosial', 'digital', 'lainnya'
  final String jenisLabel;
  final String status; // 'diterima', 'dalam_investigasi', 'selesai'
  final String statusLabel;
  final String uraianKejadian;
  final String uraianPreview;
  final String lokasiKejadian;
  final String? waktuKejadian;
  final String waktuRelatif;
  final int lampiranCount;
  final bool hasLampiran;
  final String? lastHandledByName;
  final String? createdAt;

  const SpikapLaporanItem({
    required this.id,
    required this.ticketNumber,
    required this.student,
    required this.sifatLaporan,
    required this.isDarurat,
    required this.sifatLabel,
    required this.jenisPerundungan,
    required this.jenisLabel,
    required this.status,
    required this.statusLabel,
    required this.uraianKejadian,
    required this.uraianPreview,
    required this.lokasiKejadian,
    this.waktuKejadian,
    required this.waktuRelatif,
    required this.lampiranCount,
    required this.hasLampiran,
    this.lastHandledByName,
    this.createdAt,
  });

  factory SpikapLaporanItem.fromJson(Map<String, dynamic> json) {
    return SpikapLaporanItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      ticketNumber: json['ticket_number']?.toString() ?? '#SPK',
      student: json['student'] is Map<String, dynamic>
          ? SpikapStudentSummary.fromJson(json['student'] as Map<String, dynamic>)
          : const SpikapStudentSummary(id: '', name: 'Siswa', nisn: '-'),
      sifatLaporan: json['sifat_laporan']?.toString() ?? 'biasa',
      isDarurat: json['is_darurat'] == true || json['sifat_laporan'] == 'darurat',
      sifatLabel: json['sifat_label']?.toString() ?? 'Biasa',
      jenisPerundungan: json['jenis_perundungan']?.toString() ?? 'lainnya',
      jenisLabel: json['jenis_label']?.toString() ?? 'Lainnya',
      status: json['status']?.toString() ?? 'diterima',
      statusLabel: json['status_label']?.toString() ?? 'Diterima',
      uraianKejadian: json['uraian_kejadian']?.toString() ?? '',
      uraianPreview: json['uraian_preview']?.toString() ?? '',
      lokasiKejadian: json['lokasi_kejadian']?.toString() ?? 'Lingkungan Sekolah',
      waktuKejadian: json['waktu_kejadian']?.toString(),
      waktuRelatif: json['waktu_relatif']?.toString() ?? '-',
      lampiranCount: (json['lampiran_count'] as num?)?.toInt() ?? 0,
      hasLampiran: json['has_lampiran'] == true,
      lastHandledByName: json['last_handled_by_name']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

/// Berkas Lampiran Bukti (Foto/Video)
class SpikapLampiranItem {
  final int id;
  final String tipeFile; // 'foto' atau 'video'
  final String namaAsli;
  final int ukuranBytes;
  final String ukuranLabel;
  final String url;

  const SpikapLampiranItem({
    required this.id,
    required this.tipeFile,
    required this.namaAsli,
    required this.ukuranBytes,
    required this.ukuranLabel,
    required this.url,
  });

  factory SpikapLampiranItem.fromJson(Map<String, dynamic> json) {
    return SpikapLampiranItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      tipeFile: json['tipe_file']?.toString() ?? 'foto',
      namaAsli: json['nama_asli']?.toString() ?? 'berkas_bukti',
      ukuranBytes: (json['ukuran_bytes'] as num?)?.toInt() ?? 0,
      ukuranLabel: json['ukuran_label']?.toString() ?? '-',
      url: json['url']?.toString() ?? '',
    );
  }
}

/// Audit Trail Log Status Investigasi
class SpikapAuditLogItem {
  final int id;
  final String? statusLama;
  final String statusLamaLabel;
  final String statusBaru;
  final String statusBaruLabel;
  final String catatan;
  final String changedByName;
  final String? createdAt;
  final String createdAtFormatted;
  final String waktuRelatif;

  const SpikapAuditLogItem({
    required this.id,
    this.statusLama,
    required this.statusLamaLabel,
    required this.statusBaru,
    required this.statusBaruLabel,
    required this.catatan,
    required this.changedByName,
    this.createdAt,
    required this.createdAtFormatted,
    required this.waktuRelatif,
  });

  factory SpikapAuditLogItem.fromJson(Map<String, dynamic> json) {
    return SpikapAuditLogItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      statusLama: json['status_lama']?.toString(),
      statusLamaLabel: json['status_lama_label']?.toString() ?? '-',
      statusBaru: json['status_baru']?.toString() ?? 'diterima',
      statusBaruLabel: json['status_baru_label']?.toString() ?? 'Diterima',
      catatan: json['catatan']?.toString() ?? 'Tanpa catatan',
      changedByName: json['changed_by_name']?.toString() ?? 'Sistem Otomatis',
      createdAt: json['created_at']?.toString(),
      createdAtFormatted: json['created_at_formatted']?.toString() ?? '-',
      waktuRelatif: json['waktu_relatif']?.toString() ?? '-',
    );
  }
}

/// Detail Lengkap Laporan Aduan SPIKAP (Untuk Halaman Detail Investigasi)
class SpikapDetailLaporan {
  final int id;
  final String ticketNumber;
  final SpikapStudentSummary student;
  final String sifatLaporan;
  final bool isDarurat;
  final String sifatLabel;
  final String jenisPerundungan;
  final String jenisLabel;
  final String status;
  final String statusLabel;
  final String uraianKejadian;
  final String lokasiKejadian;
  final String? waktuKejadian;
  final String? createdAt;
  final String createdAtRelatif;
  final String? lastHandledByName;
  final bool canUpdateStatus;
  final List<SpikapLampiranItem> lampiran;
  final List<SpikapAuditLogItem> auditLogs;

  const SpikapDetailLaporan({
    required this.id,
    required this.ticketNumber,
    required this.student,
    required this.sifatLaporan,
    required this.isDarurat,
    required this.sifatLabel,
    required this.jenisPerundungan,
    required this.jenisLabel,
    required this.status,
    required this.statusLabel,
    required this.uraianKejadian,
    required this.lokasiKejadian,
    this.waktuKejadian,
    this.createdAt,
    required this.createdAtRelatif,
    this.lastHandledByName,
    required this.canUpdateStatus,
    required this.lampiran,
    required this.auditLogs,
  });

  factory SpikapDetailLaporan.fromJson(Map<String, dynamic> json) {
    return SpikapDetailLaporan(
      id: (json['id'] as num?)?.toInt() ?? 0,
      ticketNumber: json['ticket_number']?.toString() ?? '#SPK',
      student: json['student'] is Map<String, dynamic>
          ? SpikapStudentSummary.fromJson(json['student'] as Map<String, dynamic>)
          : const SpikapStudentSummary(id: '', name: 'Siswa', nisn: '-'),
      sifatLaporan: json['sifat_laporan']?.toString() ?? 'biasa',
      isDarurat: json['is_darurat'] == true || json['sifat_laporan'] == 'darurat',
      sifatLabel: json['sifat_label']?.toString() ?? 'Biasa',
      jenisPerundungan: json['jenis_perundungan']?.toString() ?? 'lainnya',
      jenisLabel: json['jenis_label']?.toString() ?? 'Lainnya',
      status: json['status']?.toString() ?? 'diterima',
      statusLabel: json['status_label']?.toString() ?? 'Diterima',
      uraianKejadian: json['uraian_kejadian']?.toString() ?? '',
      lokasiKejadian: json['lokasi_kejadian']?.toString() ?? 'Lingkungan Sekolah',
      waktuKejadian: json['waktu_kejadian']?.toString(),
      createdAt: json['created_at']?.toString(),
      createdAtRelatif: json['created_at_relatif']?.toString() ?? '-',
      lastHandledByName: json['last_handled_by_name']?.toString(),
      canUpdateStatus: json['can_update_status'] == true,
      lampiran: (json['lampiran'] as List<dynamic>?)
              ?.map((e) => SpikapLampiranItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      auditLogs: (json['audit_logs'] as List<dynamic>?)
              ?.map((e) => SpikapAuditLogItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Data Kategori Perundungan untuk Analitik
class SpikapKategoriStat {
  final String key;
  final String label;
  final int count;
  final double percentage;

  const SpikapKategoriStat({
    required this.key,
    required this.label,
    required this.count,
    required this.percentage,
  });

  factory SpikapKategoriStat.fromJson(Map<String, dynamic> json) {
    return SpikapKategoriStat(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Data Tren Kasus Per Bulan
class SpikapMonthlyTrend {
  final String key;
  final String label;
  final int total;
  final int darurat;
  final int biasa;

  const SpikapMonthlyTrend({
    required this.key,
    required this.label,
    required this.total,
    required this.darurat,
    required this.biasa,
  });

  factory SpikapMonthlyTrend.fromJson(Map<String, dynamic> json) {
    return SpikapMonthlyTrend(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      total: (json['total'] as num?)?.toInt() ?? 0,
      darurat: (json['darurat'] as num?)?.toInt() ?? 0,
      biasa: (json['biasa'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Data Lengkap Dasbor Analitik Kasus (Khusus KS & BK)
class SpikapAnalitikData {
  final int totalLaporan;
  final int totalDarurat;
  final int totalBiasa;
  final int totalSelesai;
  final int totalProses;
  final double persenSelesai;
  final List<SpikapKategoriStat> kategoriStats;
  final List<SpikapMonthlyTrend> monthlyTrend;

  const SpikapAnalitikData({
    required this.totalLaporan,
    required this.totalDarurat,
    required this.totalBiasa,
    required this.totalSelesai,
    required this.totalProses,
    required this.persenSelesai,
    required this.kategoriStats,
    required this.monthlyTrend,
  });

  factory SpikapAnalitikData.fromJson(Map<String, dynamic> json) {
    return SpikapAnalitikData(
      totalLaporan: (json['total_laporan'] as num?)?.toInt() ?? 0,
      totalDarurat: (json['total_darurat'] as num?)?.toInt() ?? 0,
      totalBiasa: (json['total_biasa'] as num?)?.toInt() ?? 0,
      totalSelesai: (json['total_selesai'] as num?)?.toInt() ?? 0,
      totalProses: (json['total_proses'] as num?)?.toInt() ?? 0,
      persenSelesai: (json['persen_selesai'] as num?)?.toDouble() ?? 0.0,
      kategoriStats: (json['kategori_stats'] as List<dynamic>?)
              ?.map((e) => SpikapKategoriStat.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      monthlyTrend: (json['monthly_trend'] as List<dynamic>?)
              ?.map((e) => SpikapMonthlyTrend.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Model data SPIKAP (Sistem Informasi Karakter & Anti-Perundungan) Portal Siswa
class SiswaSpikapBranding {
  final String namaAplikasi;
  final String subJudul;
  final String penjelasan;

  const SiswaSpikapBranding({
    required this.namaAplikasi,
    required this.subJudul,
    required this.penjelasan,
  });

  factory SiswaSpikapBranding.fromJson(Map<String, dynamic> json) {
    return SiswaSpikapBranding(
      namaAplikasi: json['nama_aplikasi']?.toString() ?? 'SPIKAP',
      subJudul: json['sub_judul']?.toString() ?? 'Anti-Perundungan & Pengaduan Siswa',
      penjelasan: json['penjelasan']?.toString() ??
          'Sistem Pelaporan Integratif Konflik & Anti-Perundungan',
    );
  }
}

class SiswaSpikapCounts {
  final int total;
  final int diterima;
  final int dalamInvestigasi;
  final int selesai;
  final int darurat;
  final int biasa;

  const SiswaSpikapCounts({
    required this.total,
    required this.diterima,
    required this.dalamInvestigasi,
    required this.selesai,
    required this.darurat,
    this.biasa = 0,
  });

  factory SiswaSpikapCounts.fromJson(Map<String, dynamic> json) {
    final total = (json['total'] as num?)?.toInt() ?? 0;
    final darurat = (json['darurat'] as num?)?.toInt() ?? 0;
    final biasa = (json['biasa'] as num?)?.toInt() ?? (total >= darurat ? total - darurat : 0);
    return SiswaSpikapCounts(
      total: total,
      diterima: (json['diterima'] as num?)?.toInt() ?? 0,
      dalamInvestigasi: (json['dalam_investigasi'] as num?)?.toInt() ?? 0,
      selesai: (json['selesai'] as num?)?.toInt() ?? 0,
      darurat: darurat,
      biasa: biasa,
    );
  }
}

class SiswaSpikapLampiranItem {
  final int id;
  final String tipeFile; // 'foto' atau 'video'
  final String namaAsli;
  final int ukuranBytes;
  final String ukuranLabel;
  final String url;
  final String? downloadUrl;

  const SiswaSpikapLampiranItem({
    required this.id,
    required this.tipeFile,
    required this.namaAsli,
    this.ukuranBytes = 0,
    required this.ukuranLabel,
    required this.url,
    this.downloadUrl,
  });

  bool get isFoto => tipeFile.toLowerCase() == 'foto';
  bool get isVideo => tipeFile.toLowerCase() == 'video';

  factory SiswaSpikapLampiranItem.fromJson(Map<String, dynamic> json) {
    return SiswaSpikapLampiranItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      tipeFile: json['tipe_file']?.toString() ?? 'foto',
      namaAsli: json['nama_asli']?.toString() ?? 'Berkas Lampiran',
      ukuranBytes: (json['ukuran_bytes'] as num?)?.toInt() ?? 0,
      ukuranLabel: json['ukuran_label']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      downloadUrl: json['download_url']?.toString(),
    );
  }
}

class SiswaSpikapPetugas {
  final String nama;
  final String peran;

  const SiswaSpikapPetugas({
    required this.nama,
    required this.peran,
  });

  factory SiswaSpikapPetugas.fromJson(Map<String, dynamic> json) {
    return SiswaSpikapPetugas(
      nama: json['nama']?.toString() ?? 'Petugas SPIKAP',
      peran: json['peran']?.toString() ?? 'Sistem',
    );
  }
}

class SiswaSpikapTrackingLog {
  final int id;
  final String? statusLama;
  final String statusBaru;
  final String labelStatusBaru;
  final String catatan;
  final SiswaSpikapPetugas petugas;
  final String? createdAt;
  final String? createdAtHuman;
  final String? createdAtFormatted;

  const SiswaSpikapTrackingLog({
    required this.id,
    this.statusLama,
    required this.statusBaru,
    required this.labelStatusBaru,
    required this.catatan,
    required this.petugas,
    this.createdAt,
    this.createdAtHuman,
    this.createdAtFormatted,
  });

  factory SiswaSpikapTrackingLog.fromJson(Map<String, dynamic> json) {
    return SiswaSpikapTrackingLog(
      id: (json['id'] as num?)?.toInt() ?? 0,
      statusLama: json['status_lama']?.toString(),
      statusBaru: json['status_baru']?.toString() ?? 'diterima',
      labelStatusBaru: json['label_status_baru']?.toString() ?? 'Diterima',
      catatan: json['catatan']?.toString() ?? '-',
      petugas: json['petugas'] is Map<String, dynamic>
          ? SiswaSpikapPetugas.fromJson(json['petugas'] as Map<String, dynamic>)
          : const SiswaSpikapPetugas(nama: 'Sistem SPIKAP', peran: 'Sistem'),
      createdAt: json['created_at']?.toString(),
      createdAtHuman: json['created_at_human']?.toString(),
      createdAtFormatted: json['created_at_formatted']?.toString(),
    );
  }
}

class SiswaSpikapLaporanItem {
  final int id;
  final String sifatLaporan; // 'biasa', 'darurat'
  final bool isDarurat;
  final String labelSifat;
  final String jenisPerundungan; // 'fisik', 'verbal', 'sosial', 'digital', 'lainnya'
  final String labelJenis;
  final String? tujuanPenerima; // 'guru_bk', 'wali_kelas'
  final String labelTujuan;
  final String uraianKejadian;
  final String? lokasiKejadian;
  final String? waktuKejadian;
  final String? waktuKejadianFormatted;
  final String status; // 'diterima', 'dalam_investigasi', 'selesai'
  final String labelStatus;
  final int jumlahLampiran;
  final List<SiswaSpikapLampiranItem> lampiranPreview;
  final String? createdAt;
  final String? createdAtHuman;
  final String? createdAtFormatted;

  const SiswaSpikapLaporanItem({
    required this.id,
    required this.sifatLaporan,
    required this.isDarurat,
    required this.labelSifat,
    required this.jenisPerundungan,
    required this.labelJenis,
    this.tujuanPenerima,
    required this.labelTujuan,
    required this.uraianKejadian,
    this.lokasiKejadian,
    this.waktuKejadian,
    this.waktuKejadianFormatted,
    required this.status,
    required this.labelStatus,
    this.jumlahLampiran = 0,
    this.lampiranPreview = const [],
    this.createdAt,
    this.createdAtHuman,
    this.createdAtFormatted,
  });

  factory SiswaSpikapLaporanItem.fromJson(Map<String, dynamic> json) {
    return SiswaSpikapLaporanItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      sifatLaporan: json['sifat_laporan']?.toString() ?? 'biasa',
      isDarurat: json['is_darurat'] == true || json['sifat_laporan'] == 'darurat',
      labelSifat: json['label_sifat']?.toString() ?? 'Biasa',
      jenisPerundungan: json['jenis_perundungan']?.toString() ?? 'lainnya',
      labelJenis: json['label_jenis']?.toString() ?? 'Lainnya',
      tujuanPenerima: json['tujuan_penerima']?.toString(),
      labelTujuan: json['label_tujuan']?.toString() ?? '-',
      uraianKejadian: json['uraian_kejadian']?.toString() ?? '',
      lokasiKejadian: json['lokasi_kejadian']?.toString(),
      waktuKejadian: json['waktu_kejadian']?.toString(),
      waktuKejadianFormatted: json['waktu_kejadian_formatted']?.toString(),
      status: json['status']?.toString() ?? 'diterima',
      labelStatus: json['label_status']?.toString() ?? 'Diterima',
      jumlahLampiran: (json['jumlah_lampiran'] as num?)?.toInt() ?? 0,
      lampiranPreview: (json['lampiran_preview'] as List<dynamic>?)
              ?.map((e) => SiswaSpikapLampiranItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['created_at']?.toString(),
      createdAtHuman: json['created_at_human']?.toString(),
      createdAtFormatted: json['created_at_formatted']?.toString(),
    );
  }
}

class SiswaSpikapDashboardResponse {
  final SiswaSpikapBranding branding;
  final SiswaSpikapCounts counts;
  final List<SiswaSpikapLaporanItem> recentLaporan;

  const SiswaSpikapDashboardResponse({
    required this.branding,
    required this.counts,
    required this.recentLaporan,
  });

  factory SiswaSpikapDashboardResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return SiswaSpikapDashboardResponse(
      branding: SiswaSpikapBranding.fromJson(data['branding'] as Map<String, dynamic>? ?? {}),
      counts: SiswaSpikapCounts.fromJson(data['counts'] as Map<String, dynamic>? ?? {}),
      recentLaporan: (data['recent_laporan'] as List<dynamic>?)
              ?.map((e) => SiswaSpikapLaporanItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class SiswaSpikapPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const SiswaSpikapPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory SiswaSpikapPagination.fromJson(Map<String, dynamic> json) {
    return SiswaSpikapPagination(
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
      perPage: (json['per_page'] as num?)?.toInt() ?? 15,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

class SiswaSpikapListResponse {
  final List<SiswaSpikapLaporanItem> items;
  final SiswaSpikapPagination pagination;

  const SiswaSpikapListResponse({
    required this.items,
    required this.pagination,
  });

  factory SiswaSpikapListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return SiswaSpikapListResponse(
      items: (data['items'] as List<dynamic>?)
              ?.map((e) => SiswaSpikapLaporanItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      pagination: SiswaSpikapPagination.fromJson(data['pagination'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class SiswaSpikapDetailResponse {
  final SiswaSpikapLaporanItem laporan;
  final List<SiswaSpikapLampiranItem> lampiran;
  final List<SiswaSpikapTrackingLog> trackingLogs;

  const SiswaSpikapDetailResponse({
    required this.laporan,
    required this.lampiran,
    required this.trackingLogs,
  });

  factory SiswaSpikapDetailResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return SiswaSpikapDetailResponse(
      laporan: SiswaSpikapLaporanItem.fromJson(data['laporan'] as Map<String, dynamic>? ?? {}),
      lampiran: (data['lampiran'] as List<dynamic>?)
              ?.map((e) => SiswaSpikapLampiranItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      trackingLogs: (data['tracking_logs'] as List<dynamic>?)
              ?.map((e) => SiswaSpikapTrackingLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}


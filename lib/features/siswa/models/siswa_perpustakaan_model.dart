/// Model data Perpustakaan Portal Siswa (Sirkulasi & Kunjungan Fisik)
class SiswaPerpustakaanStudent {
  final String id;
  final String name;
  final String nisn;
  final String kelas;

  const SiswaPerpustakaanStudent({
    required this.id,
    required this.name,
    required this.nisn,
    required this.kelas,
  });

  factory SiswaPerpustakaanStudent.fromJson(Map<String, dynamic> json) {
    return SiswaPerpustakaanStudent(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Siswa',
      nisn: json['nisn']?.toString() ?? '-',
      kelas: json['kelas']?.toString() ?? '-',
    );
  }
}

class SiswaPerpustakaanCounts {
  final int pinjamanAktif;
  final int pinjamanTerlambat;
  final int totalRiwayatPinjam;
  final int totalKunjungan;

  const SiswaPerpustakaanCounts({
    required this.pinjamanAktif,
    required this.pinjamanTerlambat,
    required this.totalRiwayatPinjam,
    required this.totalKunjungan,
  });

  factory SiswaPerpustakaanCounts.fromJson(Map<String, dynamic> json) {
    return SiswaPerpustakaanCounts(
      pinjamanAktif: (json['pinjaman_aktif'] as num?)?.toInt() ?? 0,
      pinjamanTerlambat: (json['pinjaman_terlambat'] as num?)?.toInt() ?? 0,
      totalRiwayatPinjam: (json['total_riwayat_pinjam'] as num?)?.toInt() ?? 0,
      totalKunjungan: (json['total_kunjungan'] as num?)?.toInt() ?? 0,
    );
  }
}

class SiswaBukuInfo {
  final String? id;
  final String judul;
  final String penulis;
  final String? penerbit;
  final String? isbn;
  final String kategori;
  final String? lokasiRak;
  final String? sampulUrl;

  const SiswaBukuInfo({
    this.id,
    required this.judul,
    required this.penulis,
    this.penerbit,
    this.isbn,
    required this.kategori,
    this.lokasiRak,
    this.sampulUrl,
  });

  factory SiswaBukuInfo.fromJson(Map<String, dynamic> json) {
    return SiswaBukuInfo(
      id: json['id']?.toString(),
      judul: json['judul']?.toString() ?? 'Judul Tidak Diketahui',
      penulis: json['penulis']?.toString() ?? 'Penulis Tidak Diketahui',
      penerbit: json['penerbit']?.toString(),
      isbn: json['isbn']?.toString(),
      kategori: json['kategori']?.toString() ?? 'Umum',
      lokasiRak: json['lokasi_rak']?.toString(),
      sampulUrl: json['sampul_url']?.toString(),
    );
  }
}

class SiswaPinjamanItem {
  final String id;
  final String kodeEksemplar;
  final String nomorBarcode;
  final SiswaBukuInfo buku;
  final String? tanggalPinjam;
  final String tanggalPinjamFormatted;
  final String? tanggalJatuhTempo;
  final String tanggalJatuhTempoFormatted;
  final String? tanggalKembali;
  final String tanggalKembaliFormatted;
  final String status;
  final String labelStatus;
  final bool isTerlambat;
  final int terlambatHari;
  final int? sisaHari;
  final String? catatan;
  final String? createdAt;

  const SiswaPinjamanItem({
    required this.id,
    required this.kodeEksemplar,
    required this.nomorBarcode,
    required this.buku,
    this.tanggalPinjam,
    required this.tanggalPinjamFormatted,
    this.tanggalJatuhTempo,
    required this.tanggalJatuhTempoFormatted,
    this.tanggalKembali,
    required this.tanggalKembaliFormatted,
    required this.status,
    required this.labelStatus,
    this.isTerlambat = false,
    this.terlambatHari = 0,
    this.sisaHari,
    this.catatan,
    this.createdAt,
  });

  factory SiswaPinjamanItem.fromJson(Map<String, dynamic> json) {
    return SiswaPinjamanItem(
      id: json['id']?.toString() ?? '',
      kodeEksemplar: json['kode_eksemplar']?.toString() ?? '-',
      nomorBarcode: json['nomor_barcode']?.toString() ?? '-',
      buku: json['buku'] is Map<String, dynamic>
          ? SiswaBukuInfo.fromJson(json['buku'] as Map<String, dynamic>)
          : const SiswaBukuInfo(judul: '-', penulis: '-', kategori: 'Umum'),
      tanggalPinjam: json['tanggal_pinjam']?.toString(),
      tanggalPinjamFormatted: json['tanggal_pinjam_formatted']?.toString() ?? '-',
      tanggalJatuhTempo: json['tanggal_jatuh_tempo']?.toString(),
      tanggalJatuhTempoFormatted: json['tanggal_jatuh_tempo_formatted']?.toString() ?? '-',
      tanggalKembali: json['tanggal_kembali']?.toString(),
      tanggalKembaliFormatted: json['tanggal_kembali_formatted']?.toString() ?? '-',
      status: json['status']?.toString() ?? 'dipinjam',
      labelStatus: json['label_status']?.toString() ?? 'Sedang Dipinjam',
      isTerlambat: json['is_terlambat'] == true,
      terlambatHari: (json['terlambat_hari'] as num?)?.toInt() ?? 0,
      sisaHari: (json['sisa_hari'] as num?)?.toInt(),
      catatan: json['catatan']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class SiswaKunjunganItem {
  final String id;
  final String? tanggal;
  final String tanggalFormatted;
  final String waktuMasuk;
  final String waktuMasukFormatted;
  final String? tujuanKunjungan;
  final String labelTujuan;
  final String? catatan;
  final String? createdAt;

  const SiswaKunjunganItem({
    required this.id,
    this.tanggal,
    required this.tanggalFormatted,
    required this.waktuMasuk,
    required this.waktuMasukFormatted,
    this.tujuanKunjungan,
    required this.labelTujuan,
    this.catatan,
    this.createdAt,
  });

  factory SiswaKunjunganItem.fromJson(Map<String, dynamic> json) {
    return SiswaKunjunganItem(
      id: json['id']?.toString() ?? '',
      tanggal: json['tanggal']?.toString(),
      tanggalFormatted: json['tanggal_formatted']?.toString() ?? '-',
      waktuMasuk: json['waktu_masuk']?.toString() ?? '-',
      waktuMasukFormatted: json['waktu_masuk_formatted']?.toString() ?? '-',
      tujuanKunjungan: json['tujuan_kunjungan']?.toString(),
      labelTujuan: json['label_tujuan']?.toString() ?? 'Kunjungan Perpustakaan',
      catatan: json['catatan']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class SiswaPerpustakaanPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const SiswaPerpustakaanPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory SiswaPerpustakaanPagination.fromJson(Map<String, dynamic> json) {
    return SiswaPerpustakaanPagination(
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
      perPage: (json['per_page'] as num?)?.toInt() ?? 15,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

class SiswaPerpustakaanSummaryResponse {
  final SiswaPerpustakaanStudent student;
  final SiswaPerpustakaanCounts counts;
  final List<SiswaPinjamanItem> recentPinjaman;

  const SiswaPerpustakaanSummaryResponse({
    required this.student,
    required this.counts,
    required this.recentPinjaman,
  });

  factory SiswaPerpustakaanSummaryResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return SiswaPerpustakaanSummaryResponse(
      student: SiswaPerpustakaanStudent.fromJson(data['student'] as Map<String, dynamic>? ?? {}),
      counts: SiswaPerpustakaanCounts.fromJson(data['counts'] as Map<String, dynamic>? ?? {}),
      recentPinjaman: (data['recent_pinjaman'] as List<dynamic>?)
              ?.map((e) => SiswaPinjamanItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class SiswaPinjamanAktifResponse {
  final int total;
  final List<SiswaPinjamanItem> items;

  const SiswaPinjamanAktifResponse({
    required this.total,
    required this.items,
  });

  factory SiswaPinjamanAktifResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return SiswaPinjamanAktifResponse(
      total: (data['total'] as num?)?.toInt() ?? 0,
      items: (data['items'] as List<dynamic>?)
              ?.map((e) => SiswaPinjamanItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class SiswaRiwayatPinjamResponse {
  final List<SiswaPinjamanItem> items;
  final SiswaPerpustakaanPagination pagination;

  const SiswaRiwayatPinjamResponse({
    required this.items,
    required this.pagination,
  });

  factory SiswaRiwayatPinjamResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return SiswaRiwayatPinjamResponse(
      items: (data['items'] as List<dynamic>?)
              ?.map((e) => SiswaPinjamanItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      pagination: SiswaPerpustakaanPagination.fromJson(data['pagination'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class SiswaRiwayatKunjunganResponse {
  final List<SiswaKunjunganItem> items;
  final SiswaPerpustakaanPagination pagination;

  const SiswaRiwayatKunjunganResponse({
    required this.items,
    required this.pagination,
  });

  factory SiswaRiwayatKunjunganResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return SiswaRiwayatKunjunganResponse(
      items: (data['items'] as List<dynamic>?)
              ?.map((e) => SiswaKunjunganItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      pagination: SiswaPerpustakaanPagination.fromJson(data['pagination'] as Map<String, dynamic>? ?? {}),
    );
  }
}


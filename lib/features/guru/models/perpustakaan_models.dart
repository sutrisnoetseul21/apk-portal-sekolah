/// Model data terpadu untuk Menu 8: Perpustakaan (Portal Guru)

/// 1. Ringkasan Statistik Perpustakaan Guru
class PerpustakaanSummary {
  final int pinjamanAktifCount;
  final int pinjamanTerlambatCount;
  final int riwayatPinjamanCount;
  final int kunjunganCount;
  final int totalBukuCount;
  final int totalEksemplarTersedia;

  const PerpustakaanSummary({
    this.pinjamanAktifCount = 0,
    this.pinjamanTerlambatCount = 0,
    this.riwayatPinjamanCount = 0,
    this.kunjunganCount = 0,
    this.totalBukuCount = 0,
    this.totalEksemplarTersedia = 0,
  });

  factory PerpustakaanSummary.fromJson(Map<String, dynamic> json) {
    return PerpustakaanSummary(
      pinjamanAktifCount:
          (json['pinjaman_aktif_count'] as num?)?.toInt() ?? 0,
      pinjamanTerlambatCount:
          (json['pinjaman_terlambat_count'] as num?)?.toInt() ?? 0,
      riwayatPinjamanCount:
          (json['riwayat_pinjaman_count'] as num?)?.toInt() ?? 0,
      kunjunganCount: (json['kunjungan_count'] as num?)?.toInt() ?? 0,
      totalBukuCount: (json['total_buku_count'] as num?)?.toInt() ?? 0,
      totalEksemplarTersedia:
          (json['total_eksemplar_tersedia'] as num?)?.toInt() ?? 0,
    );
  }
}

/// 2. Kategori Buku Perpustakaan
class KategoriBuku {
  final String id;
  final String namaKategori;
  final String? kodePrefix;
  final bool isBisaDipinjam;
  final bool isBukuPelajaran;
  final int totalBuku;

  const KategoriBuku({
    required this.id,
    required this.namaKategori,
    this.kodePrefix,
    this.isBisaDipinjam = true,
    this.isBukuPelajaran = false,
    this.totalBuku = 0,
  });

  factory KategoriBuku.fromJson(Map<String, dynamic> json) {
    return KategoriBuku(
      id: json['id']?.toString() ?? '',
      namaKategori: json['nama_kategori']?.toString() ?? '-',
      kodePrefix: json['kode_prefix']?.toString(),
      isBisaDipinjam: json['is_bisa_dipinjam'] == true,
      isBukuPelajaran: json['is_buku_pelajaran'] == true,
      totalBuku: (json['total_buku'] as num?)?.toInt() ?? 0,
    );
  }
}

/// 3. Sub-model Sederhana Kategori Buku
class BukuKategoriSimple {
  final String id;
  final String namaKategori;

  const BukuKategoriSimple({
    required this.id,
    required this.namaKategori,
  });

  factory BukuKategoriSimple.fromJson(Map<String, dynamic> json) {
    return BukuKategoriSimple(
      id: json['id']?.toString() ?? '',
      namaKategori: json['nama_kategori']?.toString() ?? '-',
    );
  }
}

/// 4. Sub-model Sederhana Klasifikasi DDC
class BukuKlasifikasiDdcSimple {
  final String id;
  final String? kodeDdc;
  final String? namaKlasifikasi;

  const BukuKlasifikasiDdcSimple({
    required this.id,
    this.kodeDdc,
    this.namaKlasifikasi,
  });

  factory BukuKlasifikasiDdcSimple.fromJson(Map<String, dynamic> json) {
    return BukuKlasifikasiDdcSimple(
      id: json['id']?.toString() ?? '',
      kodeDdc: json['kode_ddc']?.toString(),
      namaKlasifikasi: json['nama_klasifikasi']?.toString(),
    );
  }
}

/// 5. Sub-model Sederhana Mata Pelajaran
class BukuMataPelajaranSimple {
  final String id;
  final String? namaMapel;

  const BukuMataPelajaranSimple({
    required this.id,
    this.namaMapel,
  });

  factory BukuMataPelajaranSimple.fromJson(Map<String, dynamic> json) {
    return BukuMataPelajaranSimple(
      id: json['id']?.toString() ?? '',
      namaMapel: json['nama_mapel']?.toString(),
    );
  }
}

/// 6. Item Eksemplar Buku Fisik
class EksemplarBukuItem {
  final String id;
  final String kodeEksemplar;
  final String status;
  final String kondisiFisik;

  const EksemplarBukuItem({
    required this.id,
    required this.kodeEksemplar,
    required this.status,
    required this.kondisiFisik,
  });

  factory EksemplarBukuItem.fromJson(Map<String, dynamic> json) {
    return EksemplarBukuItem(
      id: json['id']?.toString() ?? '',
      kodeEksemplar: json['kode_eksemplar']?.toString() ?? '-',
      status: json['status']?.toString() ?? 'tersedia',
      kondisiFisik: json['kondisi_fisik']?.toString() ?? 'baik',
    );
  }
}

/// 7. Detail Peminjaman Buku Saya Sendiri
class PeminjamanSayaDetail {
  final String id;
  final String? kodeEksemplar;
  final String? tanggalPinjam;
  final String? tanggalJatuhTempo;

  const PeminjamanSayaDetail({
    required this.id,
    this.kodeEksemplar,
    this.tanggalPinjam,
    this.tanggalJatuhTempo,
  });

  factory PeminjamanSayaDetail.fromJson(Map<String, dynamic> json) {
    return PeminjamanSayaDetail(
      id: json['id']?.toString() ?? '',
      kodeEksemplar: json['kode_eksemplar']?.toString(),
      tanggalPinjam: json['tanggal_pinjam']?.toString(),
      tanggalJatuhTempo: json['tanggal_jatuh_tempo']?.toString(),
    );
  }
}

/// 8. Item Buku Katalog & Detail
class BukuItem {
  final String id;
  final String judul;
  final String penulis;
  final String penerbit;
  final int? tahunTerbit;
  final String? isbn;
  final String lokasiRak;
  final String? sampulBuku;
  final String? sampulBukuUrl;
  final String? callNumber;
  final bool hasPdf;
  final String? filePdfUrl;
  final BukuKategoriSimple? kategori;
  final BukuKlasifikasiDdcSimple? klasifikasiDdc;
  final BukuMataPelajaranSimple? mataPelajaran;
  final int eksemplarTersediaCount;
  final int totalEksemplar;
  final bool dipinjamOlehSaya;
  final String? earliestReturnDate;
  final PeminjamanSayaDetail? peminjamanSaya;
  final List<EksemplarBukuItem> eksemplar;

  const BukuItem({
    required this.id,
    required this.judul,
    required this.penulis,
    required this.penerbit,
    this.tahunTerbit,
    this.isbn,
    required this.lokasiRak,
    this.sampulBuku,
    this.sampulBukuUrl,
    this.callNumber,
    this.hasPdf = false,
    this.filePdfUrl,
    this.kategori,
    this.klasifikasiDdc,
    this.mataPelajaran,
    this.eksemplarTersediaCount = 0,
    this.totalEksemplar = 0,
    this.dipinjamOlehSaya = false,
    this.earliestReturnDate,
    this.peminjamanSaya,
    this.eksemplar = const [],
  });

  factory BukuItem.fromJson(Map<String, dynamic> json) {
    return BukuItem(
      id: json['id']?.toString() ?? '',
      judul: json['judul']?.toString() ?? 'Judul Tidak Diketahui',
      penulis: json['penulis']?.toString() ?? 'Penulis Tidak Diketahui',
      penerbit: json['penerbit']?.toString() ?? '-',
      tahunTerbit: (json['tahun_terbit'] as num?)?.toInt(),
      isbn: json['isbn']?.toString(),
      lokasiRak: json['lokasi_rak']?.toString() ?? 'Tidak Ditentukan',
      sampulBuku: json['sampul_buku']?.toString(),
      sampulBukuUrl: json['sampul_buku_url']?.toString(),
      callNumber: json['call_number']?.toString(),
      hasPdf: json['has_pdf'] == true,
      filePdfUrl: json['file_pdf_url']?.toString(),
      kategori: json['kategori'] is Map<String, dynamic>
          ? BukuKategoriSimple.fromJson(
              json['kategori'] as Map<String, dynamic>)
          : null,
      klasifikasiDdc: json['klasifikasi_ddc'] is Map<String, dynamic>
          ? BukuKlasifikasiDdcSimple.fromJson(
              json['klasifikasi_ddc'] as Map<String, dynamic>)
          : null,
      mataPelajaran: json['mata_pelajaran'] is Map<String, dynamic>
          ? BukuMataPelajaranSimple.fromJson(
              json['mata_pelajaran'] as Map<String, dynamic>)
          : null,
      eksemplarTersediaCount:
          (json['eksemplar_tersedia_count'] as num?)?.toInt() ?? 0,
      totalEksemplar: (json['total_eksemplar'] as num?)?.toInt() ?? 0,
      dipinjamOlehSaya: json['dipinjam_oleh_saya'] == true,
      earliestReturnDate: json['earliest_return_date']?.toString(),
      peminjamanSaya: json['peminjaman_saya'] is Map<String, dynamic>
          ? PeminjamanSayaDetail.fromJson(
              json['peminjaman_saya'] as Map<String, dynamic>)
          : null,
      eksemplar: json['eksemplar'] is List
          ? (json['eksemplar'] as List)
              .whereType<Map<String, dynamic>>()
              .map(EksemplarBukuItem.fromJson)
              .toList()
          : const [],
    );
  }
}

/// 9. Sub-model Buku pada Peminjaman Guru
class BukuPeminjamanSimple {
  final String id;
  final String judul;
  final String penulis;
  final String? sampulBuku;
  final String? sampulBukuUrl;
  final String lokasiRak;
  final String kategoriNama;

  const BukuPeminjamanSimple({
    required this.id,
    required this.judul,
    required this.penulis,
    this.sampulBuku,
    this.sampulBukuUrl,
    required this.lokasiRak,
    required this.kategoriNama,
  });

  factory BukuPeminjamanSimple.fromJson(Map<String, dynamic> json) {
    return BukuPeminjamanSimple(
      id: json['id']?.toString() ?? '',
      judul: json['judul']?.toString() ?? 'Judul Tidak Diketahui',
      penulis: json['penulis']?.toString() ?? '-',
      sampulBuku: json['sampul_buku']?.toString(),
      sampulBukuUrl: json['sampul_buku_url']?.toString(),
      lokasiRak: json['lokasi_rak']?.toString() ?? 'Tidak Ditentukan',
      kategoriNama: json['kategori_nama']?.toString() ?? '-',
    );
  }
}

/// 10. Data Peminjaman Buku Guru (Aktif & Riwayat)
class PeminjamanGuruItem {
  final String id;
  final String eksemplarId;
  final String kodeEksemplar;
  final BukuPeminjamanSimple? buku;
  final String? tanggalPinjam;
  final String? tanggalJatuhTempo;
  final String? tanggalKembali;
  final bool isTerlambat;
  final int hariTerlambat;
  final int sisaHari;
  final String status;
  final String? catatan;

  const PeminjamanGuruItem({
    required this.id,
    required this.eksemplarId,
    required this.kodeEksemplar,
    this.buku,
    this.tanggalPinjam,
    this.tanggalJatuhTempo,
    this.tanggalKembali,
    this.isTerlambat = false,
    this.hariTerlambat = 0,
    this.sisaHari = 0,
    required this.status,
    this.catatan,
  });

  factory PeminjamanGuruItem.fromJson(Map<String, dynamic> json) {
    return PeminjamanGuruItem(
      id: json['id']?.toString() ?? '',
      eksemplarId: json['eksemplar_id']?.toString() ?? '',
      kodeEksemplar: json['kode_eksemplar']?.toString() ?? '-',
      buku: json['buku'] is Map<String, dynamic>
          ? BukuPeminjamanSimple.fromJson(json['buku'] as Map<String, dynamic>)
          : null,
      tanggalPinjam: json['tanggal_pinjam']?.toString(),
      tanggalJatuhTempo: json['tanggal_jatuh_tempo']?.toString(),
      tanggalKembali: json['tanggal_kembali']?.toString(),
      isTerlambat: json['is_terlambat'] == true,
      hariTerlambat: (json['hari_terlambat'] as num?)?.toInt() ?? 0,
      sisaHari: (json['sisa_hari'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'dipinjam',
      catatan: json['catatan']?.toString(),
    );
  }
}

/// 11. Data Kunjungan Fisik Guru ke Perpustakaan
class KunjunganGuruItem {
  final String id;
  final String tanggal;
  final String? tanggalRaw;
  final String waktuMasuk;
  final String tujuanKunjungan;
  final String tujuanKunjunganLabel;
  final String? catatan;

  const KunjunganGuruItem({
    required this.id,
    required this.tanggal,
    this.tanggalRaw,
    required this.waktuMasuk,
    required this.tujuanKunjungan,
    required this.tujuanKunjunganLabel,
    this.catatan,
  });

  factory KunjunganGuruItem.fromJson(Map<String, dynamic> json) {
    return KunjunganGuruItem(
      id: json['id']?.toString() ?? '',
      tanggal: json['tanggal']?.toString() ?? '-',
      tanggalRaw: json['tanggal_raw']?.toString(),
      waktuMasuk: json['waktu_masuk']?.toString() ?? '-',
      tujuanKunjungan: json['tujuan_kunjungan']?.toString() ?? 'umum',
      tujuanKunjunganLabel:
          json['tujuan_kunjungan_label']?.toString() ?? 'Kunjungan Umum',
      catatan: json['catatan']?.toString(),
    );
  }
}

/// 12. Kelas Ampu Guru pada Modul Perpustakaan
class KelasAmpuItem {
  final String id;
  final String name;
  final int? gradeLevel;
  final String role;

  const KelasAmpuItem({
    required this.id,
    required this.name,
    this.gradeLevel,
    required this.role,
  });

  factory KelasAmpuItem.fromJson(Map<String, dynamic> json) {
    return KelasAmpuItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '-',
      gradeLevel: (json['grade_level'] as num?)?.toInt(),
      role: json['role']?.toString() ?? 'Ampu',
    );
  }
}

/// 13. Sub-model Siswa Peminjam Buku
class SiswaPeminjamSimple {
  final String id;
  final String name;
  final String? nisn;
  final String? nis;

  const SiswaPeminjamSimple({
    required this.id,
    required this.name,
    this.nisn,
    this.nis,
  });

  factory SiswaPeminjamSimple.fromJson(Map<String, dynamic> json) {
    return SiswaPeminjamSimple(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Siswa Tidak Diketahui',
      nisn: json['nisn']?.toString(),
      nis: json['nis']?.toString(),
    );
  }
}

/// 14. Sub-model Buku pada Peminjaman Siswa
class BukuPinjamanSiswaSimple {
  final String id;
  final String judul;
  final String penulis;
  final String kodeEksemplar;
  final String? sampulBukuUrl;
  final String lokasiRak;

  const BukuPinjamanSiswaSimple({
    required this.id,
    required this.judul,
    required this.penulis,
    required this.kodeEksemplar,
    this.sampulBukuUrl,
    required this.lokasiRak,
  });

  factory BukuPinjamanSiswaSimple.fromJson(Map<String, dynamic> json) {
    return BukuPinjamanSiswaSimple(
      id: json['id']?.toString() ?? '',
      judul: json['judul']?.toString() ?? 'Judul Tidak Diketahui',
      penulis: json['penulis']?.toString() ?? '-',
      kodeEksemplar: json['kode_eksemplar']?.toString() ?? '-',
      sampulBukuUrl: json['sampul_buku_url']?.toString(),
      lokasiRak: json['lokasi_rak']?.toString() ?? '-',
    );
  }
}

/// 15. Data Peminjaman Buku Siswa pada Kelas Ampu
class PinjamanSiswaItem {
  final String id;
  final SiswaPeminjamSimple siswa;
  final BukuPinjamanSiswaSimple buku;
  final String? tanggalPinjam;
  final String? tanggalJatuhTempo;
  final bool isTerlambat;
  final int hariTerlambat;
  final String status;
  final String? catatan;

  const PinjamanSiswaItem({
    required this.id,
    required this.siswa,
    required this.buku,
    this.tanggalPinjam,
    this.tanggalJatuhTempo,
    this.isTerlambat = false,
    this.hariTerlambat = 0,
    required this.status,
    this.catatan,
  });

  factory PinjamanSiswaItem.fromJson(Map<String, dynamic> json) {
    return PinjamanSiswaItem(
      id: json['id']?.toString() ?? '',
      siswa: json['siswa'] is Map<String, dynamic>
          ? SiswaPeminjamSimple.fromJson(
              json['siswa'] as Map<String, dynamic>)
          : const SiswaPeminjamSimple(id: '', name: 'Siswa'),
      buku: json['buku'] is Map<String, dynamic>
          ? BukuPinjamanSiswaSimple.fromJson(
              json['buku'] as Map<String, dynamic>)
          : const BukuPinjamanSiswaSimple(
              id: '',
              judul: 'Buku',
              penulis: '-',
              kodeEksemplar: '-',
              lokasiRak: '-',
            ),
      tanggalPinjam: json['tanggal_pinjam']?.toString(),
      tanggalJatuhTempo: json['tanggal_jatuh_tempo']?.toString(),
      isTerlambat: json['is_terlambat'] == true,
      hariTerlambat: (json['hari_terlambat'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'dipinjam',
      catatan: json['catatan']?.toString(),
    );
  }
}

/// 16. Metadata Paginasi Standar API
class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMorePages;

  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMorePages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
      perPage: (json['per_page'] as num?)?.toInt() ?? 15,
      total: (json['total'] as num?)?.toInt() ?? 0,
      hasMorePages: json['has_more_pages'] == true,
    );
  }

  factory PaginationMeta.empty() {
    return const PaginationMeta(
      currentPage: 1,
      lastPage: 1,
      perPage: 15,
      total: 0,
      hasMorePages: false,
    );
  }
}

/// 17. Wrapper Hasil Respon Katalog Buku Berpaginasi
class PerpustakaanKatalogResult {
  final List<BukuItem> items;
  final PaginationMeta pagination;

  const PerpustakaanKatalogResult({
    required this.items,
    required this.pagination,
  });
}

/// 18. Wrapper Hasil Respon Peminjaman Guru Berpaginasi
class PerpustakaanPinjamanResult {
  final List<PeminjamanGuruItem> items;
  final PaginationMeta pagination;

  const PerpustakaanPinjamanResult({
    required this.items,
    required this.pagination,
  });
}

/// 19. Wrapper Hasil Respon Kunjungan Guru Berpaginasi
class PerpustakaanKunjunganResult {
  final List<KunjunganGuruItem> items;
  final PaginationMeta pagination;

  const PerpustakaanKunjunganResult({
    required this.items,
    required this.pagination,
  });
}

/// 20. Wrapper Hasil Respon Peminjaman Siswa pada Kelas Ampu
class PerpustakaanPinjamanSiswaResult {
  final KelasAmpuItem? selectedClass;
  final List<PinjamanSiswaItem> items;
  final PaginationMeta pagination;

  const PerpustakaanPinjamanSiswaResult({
    this.selectedClass,
    required this.items,
    required this.pagination,
  });
}

import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/perpustakaan_models.dart';

/// Service untuk menangani komunikasi REST API Menu 8: Perpustakaan (Portal Guru)
class PerpustakaanService {
  final Dio dio;
  final String? token;
  final String? identifier;

  PerpustakaanService({
    required this.dio,
    this.token,
    this.identifier,
  });

  /// Factory untuk membuat instance service dengan token Sanctum dan identifier guru
  factory PerpustakaanService.create({String? token, String? identifier}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          if (identifier != null && identifier.isNotEmpty)
            'X-User-Identifier': identifier,
        },
      ),
    );
    return PerpustakaanService(
      dio: dio,
      token: token,
      identifier: identifier,
    );
  }

  // =========================================================================
  // 1. RINGKASAN DATA PERPUSTAKAAN (SUMMARY)
  // =========================================================================

  /// Mengambil data ringkasan statistik peminjaman dan koleksi perpustakaan
  Future<PerpustakaanSummary> getSummary() async {
    final response = await dio.get(
      ApiEndpoints.guruPerpustakaanSummary,
      queryParameters: {
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final json = response.data as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>? ?? {};
      return PerpustakaanSummary.fromJson(data);
    } else {
      throw Exception(
        response.data?['message'] ??
            'Gagal memuat ringkasan data perpustakaan.',
      );
    }
  }

  // =========================================================================
  // 2. DAFTAR KATEGORI BUKU
  // =========================================================================

  /// Mengambil daftar kategori buku untuk filter katalog
  Future<List<KategoriBuku>> getKategoriList() async {
    final response = await dio.get(
      ApiEndpoints.guruPerpustakaanKategori,
      queryParameters: {
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final json = response.data as Map<String, dynamic>;
      final listRaw = json['data'] as List<dynamic>? ?? [];
      return listRaw
          .whereType<Map<String, dynamic>>()
          .map(KategoriBuku.fromJson)
          .toList();
    } else {
      throw Exception(
        response.data?['message'] ?? 'Gagal memuat daftar kategori buku.',
      );
    }
  }

  // =========================================================================
  // 3. KATALOG BUKU PERPUSTAKAAN
  // =========================================================================

  /// Mengambil daftar katalog buku terfilter dan berpaginasi
  Future<PerpustakaanKatalogResult> getKatalog({
    String search = '',
    String sortBy = 'terbaru',
    String? kategoriId,
    int page = 1,
    int perPage = 15,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      'sort_by': sortBy,
      if (search.trim().isNotEmpty) 'search': search.trim(),
      if (kategoriId != null && kategoriId.isNotEmpty)
        'kategori_id': kategoriId,
      if (identifier != null && identifier!.isNotEmpty)
        'identifier': identifier,
    };

    final response = await dio.get(
      ApiEndpoints.guruPerpustakaanKatalog,
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final json = response.data as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>? ?? {};

      final itemsRaw = data['items'] as List<dynamic>? ?? [];
      final items = itemsRaw
          .whereType<Map<String, dynamic>>()
          .map(BukuItem.fromJson)
          .toList();

      final paginationRaw = data['pagination'] as Map<String, dynamic>?;
      final pagination = paginationRaw != null
          ? PaginationMeta.fromJson(paginationRaw)
          : PaginationMeta.empty();

      return PerpustakaanKatalogResult(
        items: items,
        pagination: pagination,
      );
    } else {
      throw Exception(
        response.data?['message'] ?? 'Gagal memuat katalog buku.',
      );
    }
  }

  // =========================================================================
  // 4. DETAIL BUKU & KETERSEDIAAN EKSEMPLAR
  // =========================================================================

  /// Mengambil detail lengkap 1 buku beserta status eksemplarnya
  Future<BukuItem> getBukuDetail(String id) async {
    final response = await dio.get(
      ApiEndpoints.guruPerpustakaanDetailBuku(id),
      queryParameters: {
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final json = response.data as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>? ?? {};
      return BukuItem.fromJson(data);
    } else {
      throw Exception(
        response.data?['message'] ?? 'Gagal memuat detail buku.',
      );
    }
  }

  // =========================================================================
  // 5. PINJAMAN PRIBADI AKTIF GURU
  // =========================================================================

  /// Mengambil daftar buku yang saat ini sedang dipinjam oleh guru
  Future<PerpustakaanPinjamanResult> getPinjamanSaya({
    int page = 1,
    int perPage = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (identifier != null && identifier!.isNotEmpty)
        'identifier': identifier,
    };

    final response = await dio.get(
      ApiEndpoints.guruPerpustakaanPinjamanSaya,
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final json = response.data as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>? ?? {};

      final itemsRaw = data['items'] as List<dynamic>? ?? [];
      final items = itemsRaw
          .whereType<Map<String, dynamic>>()
          .map(PeminjamanGuruItem.fromJson)
          .toList();

      final paginationRaw = data['pagination'] as Map<String, dynamic>?;
      final pagination = paginationRaw != null
          ? PaginationMeta.fromJson(paginationRaw)
          : PaginationMeta.empty();

      return PerpustakaanPinjamanResult(
        items: items,
        pagination: pagination,
      );
    } else {
      throw Exception(
        response.data?['message'] ??
            'Gagal memuat daftar buku yang sedang Anda pinjam.',
      );
    }
  }

  // =========================================================================
  // 6. RIWAYAT PINJAMAN PRIBADI GURU
  // =========================================================================

  /// Mengambil daftar buku yang sudah selesai dipinjam dan dikembalikan guru
  Future<PerpustakaanPinjamanResult> getRiwayatPinjaman({
    int page = 1,
    int perPage = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (identifier != null && identifier!.isNotEmpty)
        'identifier': identifier,
    };

    final response = await dio.get(
      ApiEndpoints.guruPerpustakaanRiwayatPinjaman,
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final json = response.data as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>? ?? {};

      final itemsRaw = data['items'] as List<dynamic>? ?? [];
      final items = itemsRaw
          .whereType<Map<String, dynamic>>()
          .map(PeminjamanGuruItem.fromJson)
          .toList();

      final paginationRaw = data['pagination'] as Map<String, dynamic>?;
      final pagination = paginationRaw != null
          ? PaginationMeta.fromJson(paginationRaw)
          : PaginationMeta.empty();

      return PerpustakaanPinjamanResult(
        items: items,
        pagination: pagination,
      );
    } else {
      throw Exception(
        response.data?['message'] ??
            'Gagal memuat riwayat peminjaman buku pribadi.',
      );
    }
  }

  // =========================================================================
  // 7. RIWAYAT KUNJUNGAN FISIK GURU
  // =========================================================================

  /// Mengambil riwayat kunjungan fisik guru ke perpustakaan sekolah
  Future<PerpustakaanKunjunganResult> getKunjunganSaya({
    int page = 1,
    int perPage = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (identifier != null && identifier!.isNotEmpty)
        'identifier': identifier,
    };

    final response = await dio.get(
      ApiEndpoints.guruPerpustakaanKunjunganSaya,
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final json = response.data as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>? ?? {};

      final itemsRaw = data['items'] as List<dynamic>? ?? [];
      final items = itemsRaw
          .whereType<Map<String, dynamic>>()
          .map(KunjunganGuruItem.fromJson)
          .toList();

      final paginationRaw = data['pagination'] as Map<String, dynamic>?;
      final pagination = paginationRaw != null
          ? PaginationMeta.fromJson(paginationRaw)
          : PaginationMeta.empty();

      return PerpustakaanKunjunganResult(
        items: items,
        pagination: pagination,
      );
    } else {
      throw Exception(
        response.data?['message'] ??
            'Gagal memuat riwayat kunjungan perpustakaan.',
      );
    }
  }

  // =========================================================================
  // 8. DAFTAR KELAS AMPU GURU
  // =========================================================================

  /// Mengambil daftar kelas yang diampu guru pada tahun ajaran aktif
  Future<List<KelasAmpuItem>> getKelasAmpu() async {
    final response = await dio.get(
      ApiEndpoints.guruPerpustakaanKelasAmpu,
      queryParameters: {
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final json = response.data as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>? ?? {};

      final classesRaw = data['classes'] as List<dynamic>? ?? [];
      return classesRaw
          .whereType<Map<String, dynamic>>()
          .map(KelasAmpuItem.fromJson)
          .toList();
    } else {
      throw Exception(
        response.data?['message'] ?? 'Gagal memuat daftar kelas ampu.',
      );
    }
  }

  // =========================================================================
  // 9. PEMANTAUAN PINJAMAN SISWA KELAS AMPU
  // =========================================================================

  /// Mengambil daftar buku yang sedang dipinjam oleh siswa di kelas ampu terpilih
  Future<PerpustakaanPinjamanSiswaResult> getPinjamanSiswa({
    String? classId,
    String search = '',
    int page = 1,
    int perPage = 15,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (classId != null && classId.isNotEmpty) 'class_id': classId,
      if (search.trim().isNotEmpty) 'search': search.trim(),
      if (identifier != null && identifier!.isNotEmpty)
        'identifier': identifier,
    };

    final response = await dio.get(
      ApiEndpoints.guruPerpustakaanPinjamanSiswa,
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final json = response.data as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>? ?? {};

      KelasAmpuItem? selectedClass;
      if (data['selected_class'] is Map<String, dynamic>) {
        selectedClass = KelasAmpuItem.fromJson(
            data['selected_class'] as Map<String, dynamic>);
      }

      final itemsRaw = data['items'] as List<dynamic>? ?? [];
      final items = itemsRaw
          .whereType<Map<String, dynamic>>()
          .map(PinjamanSiswaItem.fromJson)
          .toList();

      final paginationRaw = data['pagination'] as Map<String, dynamic>?;
      final pagination = paginationRaw != null
          ? PaginationMeta.fromJson(paginationRaw)
          : PaginationMeta.empty();

      return PerpustakaanPinjamanSiswaResult(
        selectedClass: selectedClass,
        items: items,
        pagination: pagination,
      );
    } else {
      throw Exception(
        response.data?['message'] ??
            'Gagal memuat data peminjaman buku siswa.',
      );
    }
  }
}

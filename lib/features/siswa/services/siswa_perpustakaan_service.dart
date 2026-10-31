import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/siswa_perpustakaan_model.dart';

/// Service REST API untuk sirkulasi buku & riwayat kunjungan perpustakaan siswa
class SiswaPerpustakaanService {
  final Dio dio;

  SiswaPerpustakaanService({required this.dio});

  /// Factory instansiasi dengan token otentikasi & identifier siswa
  factory SiswaPerpustakaanService.create({String? token, String? identifier}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          if (identifier != null && identifier.isNotEmpty) 'X-User-Identifier': identifier,
        },
      ),
    );
    return SiswaPerpustakaanService(dio: dio);
  }

  /// Mengambil data ringkasan keanggotaan perpustakaan, jumlah pinjaman aktif, riwayat, dan kunjungan
  Future<SiswaPerpustakaanSummaryResponse> getSummary({String? identifier}) async {
    try {
      final response = await dio.get(
        ApiEndpoints.siswaPerpustakaanSummary,
        queryParameters: {
          if (identifier != null && identifier.isNotEmpty) 'identifier': identifier,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return SiswaPerpustakaanSummaryResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat ringkasan perpustakaan.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(serverMsg ?? 'Terjadi kesalahan jaringan saat memuat ringkasan (${e.type.name}).');
    }
  }

  /// Mengambil daftar seluruh buku yang saat ini sedang dipinjam oleh siswa
  Future<SiswaPinjamanAktifResponse> getPinjamanAktif({String? identifier}) async {
    try {
      final response = await dio.get(
        ApiEndpoints.siswaPerpustakaanPinjamanAktif,
        queryParameters: {
          if (identifier != null && identifier.isNotEmpty) 'identifier': identifier,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return SiswaPinjamanAktifResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat daftar buku yang sedang dipinjam.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(serverMsg ?? 'Terjadi kesalahan jaringan saat memuat pinjaman aktif (${e.type.name}).');
    }
  }

  /// Mengambil histori peminjaman buku yang sudah dikembalikan siswa
  Future<SiswaRiwayatPinjamResponse> getRiwayatPinjam({
    String? search,
    int page = 1,
    int perPage = 15,
    String? identifier,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.siswaPerpustakaanRiwayatPinjam,
        queryParameters: {
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
          'page': page,
          'per_page': perPage,
          if (identifier != null && identifier.isNotEmpty) 'identifier': identifier,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return SiswaRiwayatPinjamResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat riwayat peminjaman buku.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(serverMsg ?? 'Terjadi kesalahan jaringan saat memuat riwayat (${e.type.name}).');
    }
  }

  /// Mengambil catatan kunjungan fisik siswa ke ruang perpustakaan sekolah
  Future<SiswaRiwayatKunjunganResponse> getRiwayatKunjungan({
    int page = 1,
    int perPage = 15,
    String? identifier,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.siswaPerpustakaanRiwayatKunjungan,
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (identifier != null && identifier.isNotEmpty) 'identifier': identifier,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return SiswaRiwayatKunjunganResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat riwayat kunjungan.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(serverMsg ?? 'Terjadi kesalahan jaringan saat memuat kunjungan (${e.type.name}).');
    }
  }
}


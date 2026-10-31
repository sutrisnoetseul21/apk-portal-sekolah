import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/siswa_kartu_model.dart';

/// Service REST API untuk data Kartu Pelajar Digital dan Unduh Berkas PDF Resmi
class SiswaKartuService {
  final Dio dio;

  SiswaKartuService({required this.dio});

  /// Factory instansiasi dengan token otentikasi & identifier siswa
  factory SiswaKartuService.create({String? token, String? identifier}) {
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
    return SiswaKartuService(dio: dio);
  }

  /// Mengambil data lengkap kartu pelajar digital siswa
  Future<SiswaKartuResponse> getDigitalInfo({String? identifier}) async {
    try {
      final response = await dio.get(
        ApiEndpoints.siswaKartuDigitalInfo,
        queryParameters: {
          if (identifier != null && identifier.isNotEmpty) 'identifier': identifier,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return SiswaKartuResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat data kartu pelajar.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(
        serverMsg ?? 'Terjadi kesalahan jaringan saat memuat kartu pelajar (${e.type.name}).',
      );
    }
  }

  /// Mendapatkan URL lengkap untuk mengunduh berkas PDF kartu pelajar
  String getDownloadPdfUrl({String? identifier}) {
    final base = AppConfig.baseUrl.endsWith('/')
        ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1)
        : AppConfig.baseUrl;
    final path = ApiEndpoints.siswaKartuDownloadPdf;
    if (identifier != null && identifier.isNotEmpty) {
      return '$base$path?identifier=$identifier';
    }
    return '$base$path';
  }

  /// Mendapatkan URL lengkap untuk mengunduh berkas PDF biodata lengkap siswa
  String getBiodataPdfUrl({String? identifier}) {
    final base = AppConfig.baseUrl.endsWith('/')
        ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1)
        : AppConfig.baseUrl;
    final path = ApiEndpoints.siswaKartuBiodataPdf;
    if (identifier != null && identifier.isNotEmpty) {
      return '$base$path?identifier=$identifier';
    }
    return '$base$path';
  }
}


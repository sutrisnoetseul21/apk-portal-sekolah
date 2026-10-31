import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/siswa_dashboard_model.dart';
import '../models/siswa_akademik_model.dart';

/// Service untuk menangani komunikasi REST API Dashboard Portal Siswa
class SiswaDashboardService {
  final Dio dio;

  SiswaDashboardService({required this.dio});

  /// Factory untuk membuat instance service dengan token dan identifier siswa
  factory SiswaDashboardService.create({String? token, String? identifier}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 12),
        headers: {
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          if (identifier != null && identifier.isNotEmpty) 'X-User-Identifier': identifier,
        },
      ),
    );
    return SiswaDashboardService(dio: dio);
  }

  /// Mengambil data ringkasan dashboard beranda siswa
  Future<SiswaDashboardSummary> getDashboardSummary({String? identifier}) async {
    try {
      final response = await dio.get(
        ApiEndpoints.siswaDashboardSummary,
        queryParameters: {
          if (identifier != null && identifier.isNotEmpty) 'identifier': identifier,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return SiswaDashboardSummary.fromJson(data);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat ringkasan dashboard siswa.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(serverMsg ?? 'Terjadi kesalahan jaringan saat memuat dashboard siswa (${e.type.name}).');
    }
  }

  /// Mengambil data kalender presensi akademik bulanan siswa (Menu 1)
  Future<SiswaAkademikDashboardResponse> getAkademikDashboard({
    int? month,
    int? year,
    String? monthYear,
    String? identifier,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.siswaAkademikDashboard,
        queryParameters: {
          'month': ?month,
          'year': ?year,
          if (monthYear != null && monthYear.isNotEmpty) 'month_year': monthYear,
          if (identifier != null && identifier.isNotEmpty) 'identifier': identifier,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return SiswaAkademikDashboardResponse.fromJson(data);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat data kalender akademik siswa.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(serverMsg ?? 'Terjadi kesalahan jaringan saat memuat kalender presensi (${e.type.name}).');
    }
  }
}


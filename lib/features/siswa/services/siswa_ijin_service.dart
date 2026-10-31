import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/siswa_ijin_model.dart';

/// Service REST API untuk pengajuan izin & riwayat izin kehadiran siswa
class SiswaIjinService {
  final Dio dio;

  SiswaIjinService({required this.dio});

  /// Factory instansiasi dengan token otentikasi & identifier siswa
  factory SiswaIjinService.create({String? token, String? identifier}) {
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
    return SiswaIjinService(dio: dio);
  }

  /// Mengambil riwayat pengajuan izin siswa dengan filter status & paginasi
  Future<SiswaIjinListResponse> getIjinList({
    String status = 'all',
    String type = 'all',
    int page = 1,
    int perPage = 10,
    String? identifier,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.siswaIjinKehadiran,
        queryParameters: {
          'status': status,
          'type': type,
          'page': page,
          'per_page': perPage,
          if (identifier != null && identifier.isNotEmpty) 'identifier': identifier,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return SiswaIjinListResponse.fromJson(data);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat riwayat pengajuan izin.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(serverMsg ?? 'Terjadi kesalahan jaringan saat memuat riwayat izin (${e.type.name}).');
    }
  }

  /// Mengecek apakah rentang tanggal menyentuh hari libur kalender sekolah
  Future<SiswaHolidaysCheckResult> checkHolidays({
    required String startDate,
    required int durationDays,
    String? identifier,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.siswaIjinCheckHolidays,
        queryParameters: {
          'start_date': startDate,
          'duration_days': durationDays,
          if (identifier != null && identifier.isNotEmpty) 'identifier': identifier,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return SiswaHolidaysCheckResult.fromJson(data);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengecek kalender hari libur.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(serverMsg ?? 'Gagal mengecek kalender hari libur (${e.type.name}).');
    }
  }

  /// Mengambil detail 1 pengajuan izin
  Future<SiswaIjinItem> getIjinDetail({
    required String id,
    String? identifier,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.siswaIjinDetail(id),
        queryParameters: {
          if (identifier != null && identifier.isNotEmpty) 'identifier': identifier,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return SiswaIjinItem.fromJson(data);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat detail pengajuan izin.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(serverMsg ?? 'Gagal memuat detail izin (${e.type.name}).');
    }
  }

  /// Mengirimkan permohonan ijin baru dengan multipart upload lampiran
  Future<Map<String, dynamic>> submitLeaveRequest({
    required String type, // 'sakit' | 'ijin'
    required String startDate, // 'YYYY-MM-DD'
    required int durationDays,
    required String reason,
    List<XFile>? attachments,
    String? identifier,
  }) async {
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('type', type));
      formData.fields.add(MapEntry('start_date', startDate));
      formData.fields.add(MapEntry('duration_days', durationDays.toString()));
      formData.fields.add(MapEntry('reason', reason));
      if (identifier != null && identifier.isNotEmpty) {
        formData.fields.add(MapEntry('identifier', identifier));
      }

      if (attachments != null && attachments.isNotEmpty) {
        for (int i = 0; i < attachments.length; i++) {
          final file = attachments[i];
          final bytes = await file.readAsBytes();
          final multipartFile = MultipartFile.fromBytes(
            bytes,
            filename: file.name.isNotEmpty ? file.name : 'lampiran_${i + 1}.jpg',
          );
          formData.files.add(MapEntry('attachments[]', multipartFile));
        }
      }

      final response = await dio.post(
        ApiEndpoints.siswaIjinKehadiran,
        data: formData,
      );

      if (response.statusCode == 201 || (response.statusCode == 200 && response.data['success'] == true)) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengirim permohonan izin.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(serverMsg ?? 'Gagal mengirim permohonan izin (${e.type.name}).');
    }
  }

  /// Membatalkan permohonan izin (hanya jika status masih 'pending')
  Future<void> cancelLeaveRequest({
    required String id,
    String? identifier,
  }) async {
    try {
      final response = await dio.delete(
        ApiEndpoints.siswaIjinDelete(id),
        queryParameters: {
          if (identifier != null && identifier.isNotEmpty) 'identifier': identifier,
        },
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Gagal membatalkan permohonan izin.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(serverMsg ?? 'Gagal membatalkan permohonan izin (${e.type.name}).');
    }
  }
}


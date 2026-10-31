import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/siswa_guru_wali_model.dart';

/// Service REST API untuk Modul Menu 3: SI-WALI Portal Siswa
class SiswaGuruWaliService {
  final Dio dio;

  SiswaGuruWaliService({required this.dio});

  /// Factory instansiasi service dengan token autentikasi & identifier siswa
  factory SiswaGuruWaliService.create({String? token, String? identifier}) {
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
    return SiswaGuruWaliService(dio: dio);
  }

  /// Mengambil data ringkasan profil guru wali asuh & statistik counter
  Future<SiswaGuruWaliDashboardResponse> getDashboard({String? identifier}) async {
    try {
      final response = await dio.get(
        ApiEndpoints.siswaGuruWaliDashboard,
        queryParameters: {
          if (identifier != null && identifier.isNotEmpty) 'identifier': identifier,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return SiswaGuruWaliDashboardResponse.fromJson(data);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat profil Guru Wali.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(serverMsg ?? 'Gagal memuat profil Guru Wali (${e.type.name}).');
    }
  }

  /// Mengambil riwayat pengajuan konsultasi mandiri siswa
  Future<SiswaKonsultasiListResponse> getKonsultasiList({
    String status = 'all',
    String? kategori,
    String? search,
    int page = 1,
    int perPage = 10,
    String? identifier,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.siswaGuruWaliKonsultasi,
        queryParameters: {
          'status': status,
          if (kategori != null && kategori.isNotEmpty && kategori != 'all') 'kategori': kategori,
          if (search != null && search.isNotEmpty) 'search': search,
          'page': page,
          'per_page': perPage,
          if (identifier != null && identifier.isNotEmpty) 'identifier': identifier,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return SiswaKonsultasiListResponse.fromJson(data);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat daftar konsultasi.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(serverMsg ?? 'Gagal memuat daftar konsultasi (${e.type.name}).');
    }
  }

  /// Mengirimkan permohonan konsultasi / curhat baru ke Guru Wali
  Future<SiswaKonsultasiItem> createKonsultasi({
    required String kategori,
    required String mode,
    required String topik,
    required String detail,
    String? usulanTanggalWaktu,
    String? identifier,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.siswaGuruWaliKonsultasi,
        data: {
          'kategori': kategori,
          'mode': mode,
          'topik': topik,
          'detail': detail,
          if (usulanTanggalWaktu != null && usulanTanggalWaktu.isNotEmpty)
            'usulan_tanggal_waktu': usulanTanggalWaktu,
          if (identifier != null && identifier.isNotEmpty) 'identifier': identifier,
        },
      );

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return SiswaKonsultasiItem.fromJson(data);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengajukan konsultasi.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(serverMsg ?? 'Gagal mengajukan konsultasi (${e.type.name}).');
    }
  }

  /// Mengambil detail 1 sesi konsultasi beserta thread pesan obrolan
  Future<SiswaKonsultasiDetail> getKonsultasiDetail({
    required String id,
    String? identifier,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.siswaGuruWaliKonsultasiDetail(id),
        queryParameters: {
          if (identifier != null && identifier.isNotEmpty) 'identifier': identifier,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return SiswaKonsultasiDetail.fromJson(data);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat detail konsultasi.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(serverMsg ?? 'Gagal memuat detail konsultasi (${e.type.name}).');
    }
  }

  /// Mengirimkan pesan baru dalam sesi konsultasi
  Future<SiswaPesanItem> sendPesan({
    required String id,
    required String pesan,
    String? identifier,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.siswaGuruWaliKonsultasiPesan(id),
        data: {
          'pesan': pesan,
          if (identifier != null && identifier.isNotEmpty) 'identifier': identifier,
        },
      );

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return SiswaPesanItem.fromJson(data);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengirim pesan.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(serverMsg ?? 'Gagal mengirim pesan (${e.type.name}).');
    }
  }

  /// Membatalkan permohonan konsultasi (hanya jika masih Menunggu Konfirmasi)
  Future<void> cancelKonsultasi({
    required String id,
    String? identifier,
  }) async {
    try {
      final response = await dio.delete(
        ApiEndpoints.siswaGuruWaliKonsultasiCancel(id),
        queryParameters: {
          if (identifier != null && identifier.isNotEmpty) 'identifier': identifier,
        },
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Gagal membatalkan konsultasi.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(serverMsg ?? 'Gagal membatalkan konsultasi (${e.type.name}).');
    }
  }

  /// Mengirimkan rating feedback kepuasan setelah sesi konsultasi selesai
  Future<void> submitFeedback({
    required String id,
    required int rating,
    required String emoji,
    String? note,
    String? identifier,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.siswaGuruWaliKonsultasiFeedback(id),
        data: {
          'rating': rating,
          'emoji': emoji,
          if (note != null && note.isNotEmpty) 'note': note,
          if (identifier != null && identifier.isNotEmpty) 'identifier': identifier,
        },
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Gagal mengirim ulasan.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(serverMsg ?? 'Gagal mengirim ulasan (${e.type.name}).');
    }
  }

  /// Mengambil daftar sesi pendampingan klasikal & kelompok asuh
  Future<SiswaKlasikalListResponse> getPendampinganKlasikalList({
    String? jenis,
    String? kategori,
    String? search,
    int page = 1,
    int perPage = 10,
    String? identifier,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.siswaGuruWaliKlasikal,
        queryParameters: {
          if (jenis != null && jenis.isNotEmpty && jenis != 'all') 'jenis': jenis,
          if (kategori != null && kategori.isNotEmpty && kategori != 'all') 'kategori': kategori,
          if (search != null && search.isNotEmpty) 'search': search,
          'page': page,
          'per_page': perPage,
          if (identifier != null && identifier.isNotEmpty) 'identifier': identifier,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return SiswaKlasikalListResponse.fromJson(data);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat daftar pendampingan klasikal.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(serverMsg ?? 'Gagal memuat pendampingan klasikal (${e.type.name}).');
    }
  }
}


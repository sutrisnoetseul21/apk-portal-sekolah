import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/siswa_profil_model.dart';

/// Service REST API untuk Profil Siswa, Perbarui Kontak, Foto Profil, dan Kata Sandi
class SiswaProfilService {
  final Dio dio;

  SiswaProfilService({required this.dio});

  /// Factory instansiasi dengan token otentikasi & identifier siswa
  factory SiswaProfilService.create({String? token, String? identifier}) {
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
    return SiswaProfilService(dio: dio);
  }

  /// Mengambil data lengkap profil biodata siswa
  Future<SiswaProfilResponse> getProfilInfo({String? identifier}) async {
    try {
      final response = await dio.get(
        ApiEndpoints.siswaProfilInfo,
        queryParameters: {
          if (identifier != null && identifier.isNotEmpty) 'identifier': identifier,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return SiswaProfilResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat profil siswa.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(
        serverMsg ?? 'Terjadi kesalahan jaringan saat memuat profil (${e.type.name}).',
      );
    }
  }

  /// Memperbarui alamat domisili dan nomor kontak siswa
  Future<Map<String, dynamic>> updateKontak({
    required String address,
    String? noHp,
    String? noHpOrangTua,
    String? identifier,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.siswaProfilUpdateKontak,
        queryParameters: {
          if (identifier != null && identifier.isNotEmpty) 'identifier': identifier,
        },
        data: {
          'address': address,
          'no_hp': noHp,
          'no_hp_orang_tua': noHpOrangTua,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memperbarui kontak.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(
        serverMsg ?? 'Terjadi kesalahan saat menyimpan perubahan kontak (${e.type.name}).',
      );
    }
  }

  /// Mengunggah berkas foto profil siswa baru
  Future<String> updateFoto({
    required File photoFile,
    String? identifier,
  }) async {
    try {
      final fileName = photoFile.path.split('/').last;
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          photoFile.path,
          filename: fileName,
        ),
      });

      final response = await dio.post(
        ApiEndpoints.siswaProfilUpdateFoto,
        queryParameters: {
          if (identifier != null && identifier.isNotEmpty) 'identifier': identifier,
        },
        data: formData,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return data['photo_url']?.toString() ?? '';
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengunggah foto profil.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(
        serverMsg ?? 'Gagal mengunggah foto profil (${e.type.name}).',
      );
    }
  }

  /// Menghapus foto profil siswa (kembali ke avatar inisial)
  Future<void> hapusFoto({String? identifier}) async {
    try {
      final response = await dio.delete(
        ApiEndpoints.siswaProfilHapusFoto,
        queryParameters: {
          if (identifier != null && identifier.isNotEmpty) 'identifier': identifier,
        },
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Gagal menghapus foto profil.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(
        serverMsg ?? 'Gagal menghapus foto profil (${e.type.name}).',
      );
    }
  }

  /// Memperbarui kata sandi akun login siswa
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
    String? identifier,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.siswaProfilUpdatePassword,
        queryParameters: {
          if (identifier != null && identifier.isNotEmpty) 'identifier': identifier,
        },
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Gagal memperbarui kata sandi.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(
        serverMsg ?? 'Gagal memperbarui kata sandi (${e.type.name}).',
      );
    }
  }
}


import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/guru_profil_model.dart';

/// Service untuk menangani komunikasi REST API Menu 9: Profil Saya (Portal Guru)
class GuruProfilService {
  final Dio dio;
  final String? token;
  final String? identifier;

  GuruProfilService({
    required this.dio,
    this.token,
    this.identifier,
  });

  /// Factory untuk membuat instance service dengan konfigurasi header dan timeout
  factory GuruProfilService.create({String? token, String? identifier}) {
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
    return GuruProfilService(
      dio: dio,
      token: token,
      identifier: identifier,
    );
  }

  // =========================================================================
  // 1. AMBIL PROFIL LENGKAP PENDIDIK
  // =========================================================================

  /// Mengambil data lengkap profil pendidik (User, Teacher, Penugasan Akademik)
  Future<GuruProfilData> getProfile() async {
    try {
      final response = await dio.get(
        ApiEndpoints.guruProfil,
        queryParameters: {
          if (identifier != null && identifier!.isNotEmpty)
            'identifier': identifier,
        },
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final json = response.data as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>? ?? {};
        return GuruProfilData.fromJson(data);
      } else {
        throw Exception(
          response.data?['message']?.toString() ??
              'Gagal memuat profil guru (${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Gagal memuat profil guru'));
    }
  }

  // =========================================================================
  // 2. PERBARUI INFORMASI KONTAK & MICROSITE
  // =========================================================================

  /// Memperbarui alamat email login, nomor WhatsApp, dan link microsite
  Future<void> updateContact({
    required String email,
    String? noHp,
    String? micrositeUrl,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.guruProfilKontak,
        queryParameters: {
          if (identifier != null && identifier!.isNotEmpty)
            'identifier': identifier,
        },
        data: {
          'email': email.trim(),
          'no_hp': noHp?.trim(),
          'microsite_url': micrositeUrl?.trim().isNotEmpty == true
              ? micrositeUrl!.trim()
              : null,
        },
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(
          response.data?['message']?.toString() ??
              'Gagal memperbarui informasi kontak',
        );
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Gagal memperbarui informasi kontak'));
    }
  }

  // =========================================================================
  // 3. UNGGAH FOTO PROFIL (MULTIPART)
  // =========================================================================

  /// Mengunggah file foto profil baru dari memori lokal / kamera
  Future<Map<String, String?>> uploadPhoto(String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final response = await dio.post(
        ApiEndpoints.guruProfilFoto,
        queryParameters: {
          if (identifier != null && identifier!.isNotEmpty)
            'identifier': identifier,
        },
        data: formData,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>? ?? {};
        return {
          'photo_path': data['photo_path']?.toString(),
          'photo_url': data['photo_url']?.toString(),
        };
      } else {
        throw Exception(
          response.data?['message']?.toString() ??
              'Gagal mengunggah foto profil',
        );
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Gagal mengunggah foto profil'));
    }
  }

  // =========================================================================
  // 4. HAPUS FOTO PROFIL
  // =========================================================================

  /// Menghapus foto profil guru dari server dan kembali ke inisial nama
  Future<void> removePhoto() async {
    try {
      final response = await dio.delete(
        ApiEndpoints.guruProfilFoto,
        queryParameters: {
          if (identifier != null && identifier!.isNotEmpty)
            'identifier': identifier,
        },
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(
          response.data?['message']?.toString() ??
              'Gagal menghapus foto profil',
        );
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Gagal menghapus foto profil'));
    }
  }

  // =========================================================================
  // 5. PERBARUI KATA SANDI (PASSWORD)
  // =========================================================================

  /// Memperbarui kata sandi akun pendidik
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.guruProfilPassword,
        queryParameters: {
          if (identifier != null && identifier!.isNotEmpty)
            'identifier': identifier,
        },
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(
          response.data?['message']?.toString() ??
              'Gagal memperbarui kata sandi',
        );
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Gagal memperbarui kata sandi'));
    }
  }

  // =========================================================================
  // HELPER: EKSTRAK PESAN ERROR DARI DIO EXCEPTION
  // =========================================================================

  String _extractErrorMessage(DioException e, String fallback) {
    if (e.response != null && e.response!.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data['message'] != null && data['message'].toString().isNotEmpty) {
        // Cek jika ada errors spesifik
        if (data['errors'] != null && data['errors'] is Map) {
          final errors = data['errors'] as Map;
          final firstKey = errors.keys.firstOrNull;
          if (firstKey != null && errors[firstKey] is List && (errors[firstKey] as List).isNotEmpty) {
            return errors[firstKey][0].toString();
          }
        }
        return data['message'].toString();
      }
    }
    return e.message ?? fallback;
  }
}

import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/data_siswa_filter_model.dart';
import '../models/student_model.dart';

/// Response payload untuk query daftar siswa rombel
class DataSiswaListResponse {
  final List<StudentModel> students;
  final StudentRombelStats stats;
  final Map<String, dynamic> kelas;

  DataSiswaListResponse({
    required this.students,
    required this.stats,
    required this.kelas,
  });
}

/// Service komunikasi REST API Menu 6: Data Siswa (/portal-guru/data-siswa/*)
class DataSiswaService {
  final Dio dio;
  final String? token;
  final String? identifier;

  DataSiswaService({
    required this.dio,
    this.token,
    this.identifier,
  });

  /// Factory untuk membuat instance service dengan konfigurasi header otomatis
  factory DataSiswaService.create({String? token, String? identifier}) {
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
    return DataSiswaService(
      dio: dio,
      token: token,
      identifier: identifier,
    );
  }

  // =========================================================================
  // 1. OPTIONS & DAFTAR SISWA (ROMBEL)
  // =========================================================================

  /// Mengambil daftar Tahun Ajaran dan Kelas ampuan/binaan guru
  Future<DataSiswaOptionsModel> getOptions() async {
    final response = await dio.get(
      ApiEndpoints.guruDataSiswaOptions,
      queryParameters: {
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final res = response.data as Map<String, dynamic>;
      if (res['success'] == true && res['data'] != null) {
        return DataSiswaOptionsModel.fromJson(res['data'] as Map<String, dynamic>);
      }
    }
    throw Exception(response.data?['message'] ?? 'Gagal memuat opsi data siswa');
  }

  /// Mengambil daftar siswa per kelas dan tahun ajaran dengan filter & statistik
  Future<DataSiswaListResponse> getStudents({
    required dynamic classId,
    required dynamic academicYearId,
    String? search,
    String? filterBarcode,
    String? filterNohp,
  }) async {
    final response = await dio.get(
      ApiEndpoints.guruDataSiswaStudents,
      queryParameters: {
        'class_id': classId.toString(),
        'academic_year_id': academicYearId.toString(),
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (filterBarcode != null && filterBarcode.isNotEmpty)
          'filter_barcode': filterBarcode,
        if (filterNohp != null && filterNohp.isNotEmpty)
          'filter_nohp': filterNohp,
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final res = response.data as Map<String, dynamic>;
      if (res['success'] == true && res['data'] != null) {
        final d = res['data'] as Map<String, dynamic>;
        final studentList = (d['students'] as List<dynamic>?)
                ?.map((e) => StudentModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
        final stats = StudentRombelStats.fromJson(
            (d['stats'] ?? {}) as Map<String, dynamic>);
        final kelas = (d['selected_class'] ?? d['kelas'] ?? {}) as Map<String, dynamic>;

        return DataSiswaListResponse(
          students: studentList,
          stats: stats,
          kelas: kelas,
        );
      }
    }
    throw Exception(response.data?['message'] ?? 'Gagal memuat daftar siswa');
  }

  // =========================================================================
  // 2. DETAIL SISWA & EDIT BIODATA
  // =========================================================================

  /// Mengambil biodata lengkap siswa
  Future<StudentModel> getStudentDetail(dynamic id) async {
    final response = await dio.get(
      ApiEndpoints.guruDataSiswaDetail(id.toString()),
      queryParameters: {
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final res = response.data as Map<String, dynamic>;
      if (res['success'] == true && res['data'] != null) {
        return StudentModel.fromJson(res['data'] as Map<String, dynamic>);
      }
    }
    throw Exception(response.data?['message'] ?? 'Gagal memuat detail siswa');
  }

  /// Memperbarui biodata lengkap siswa
  Future<StudentModel> updateBiodata(dynamic id, Map<String, dynamic> data) async {
    final response = await dio.put(
      ApiEndpoints.guruDataSiswaUpdateBiodata(id.toString()),
      data: data,
      queryParameters: {
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final res = response.data as Map<String, dynamic>;
      if (res['success'] == true && res['data'] != null) {
        return StudentModel.fromJson(res['data'] as Map<String, dynamic>);
      }
    }
    throw Exception(response.data?['message'] ?? 'Gagal menyimpan biodata');
  }

  /// Update cepat nomor HP siswa & nomor HP orang tua
  Future<Map<String, dynamic>> updateNoHp(
    dynamic id, {
    String? noHp,
    String? noHpOrtu,
  }) async {
    final response = await dio.patch(
      ApiEndpoints.guruDataSiswaUpdateNoHp(id.toString()),
      data: {
        'no_hp': noHp,
        'no_hp_orang_tua': noHpOrtu,
      },
      queryParameters: {
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final res = response.data as Map<String, dynamic>;
      if (res['success'] == true) {
        return (res['data'] as Map<String, dynamic>?) ?? {};
      }
    }
    throw Exception(response.data?['message'] ?? 'Gagal mengupdate nomor telepon');
  }

  /// Ganti atau reset password akun siswa
  Future<void> gantiPassword(
    dynamic id, {
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await dio.post(
      ApiEndpoints.guruDataSiswaGantiPassword(id.toString()),
      data: {
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
      queryParameters: {
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final res = response.data as Map<String, dynamic>;
      if (res['success'] == true) {
        return;
      }
    }
    throw Exception(response.data?['message'] ?? 'Gagal mengubah password');
  }

  /// Upload foto siswa (Multipart)
  Future<String?> uploadFoto(
    dynamic id,
    List<int> bytes,
    String filename,
  ) async {
    final formData = FormData.fromMap({
      'foto': MultipartFile.fromBytes(bytes, filename: filename),
    });

    final response = await dio.post(
      ApiEndpoints.guruDataSiswaUploadFoto(id.toString()),
      data: formData,
      queryParameters: {
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final res = response.data as Map<String, dynamic>;
      if (res['success'] == true && res['data'] != null) {
        return res['data']['foto_url']?.toString();
      }
    }
    throw Exception(response.data?['message'] ?? 'Gagal mengunggah foto');
  }

  // =========================================================================
  // 3. GENERATE URL UNDUH PDF / CETAK
  // =========================================================================

  /// URL cetak kartu pelajar barcode individual
  String getCetakKartuUrl(dynamic id) {
    final base = AppConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final ep = ApiEndpoints.guruDataSiswaCetakKartu(id.toString()).replaceAll(RegExp(r'^/+'), '');
    final idParam = (identifier != null && identifier!.isNotEmpty) ? '?identifier=$identifier' : '';
    return '$base/$ep$idParam';
  }

  /// URL cetak biodata resmi siswa individual
  String getCetakBiodataUrl(dynamic id) {
    final base = AppConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final ep = ApiEndpoints.guruDataSiswaCetakBiodata(id.toString()).replaceAll(RegExp(r'^/+'), '');
    final idParam = (identifier != null && identifier!.isNotEmpty) ? '?identifier=$identifier' : '';
    return '$base/$ep$idParam';
  }

  /// URL cetak kartu massal 1 rombel
  String getCetakKartuMassalUrl(dynamic classId, dynamic academicYearId) {
    final base = AppConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final ep = ApiEndpoints.guruDataSiswaCetakKartuMassal.replaceAll(RegExp(r'^/+'), '');
    var url = '$base/$ep?class_id=$classId&academic_year_id=$academicYearId';
    if (identifier != null && identifier!.isNotEmpty) {
      url += '&identifier=$identifier';
    }
    return url;
  }

  /// URL cetak biodata massal 1 rombel
  String getCetakBiodataMassalUrl(dynamic classId, dynamic academicYearId) {
    final base = AppConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final ep = ApiEndpoints.guruDataSiswaCetakBiodataMassal.replaceAll(RegExp(r'^/+'), '');
    var url = '$base/$ep?class_id=$classId&academic_year_id=$academicYearId';
    if (identifier != null && identifier!.isNotEmpty) {
      url += '&identifier=$identifier';
    }
    return url;
  }
}

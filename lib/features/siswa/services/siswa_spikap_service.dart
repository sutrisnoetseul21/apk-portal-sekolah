import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/siswa_spikap_model.dart';

/// Service REST API untuk pengaduan & investigasi kasus SPIKAP Portal Siswa
class SiswaSpikapService {
  final Dio dio;

  SiswaSpikapService({required this.dio});

  /// Factory instansiasi dengan token otentikasi & identifier siswa
  factory SiswaSpikapService.create({String? token, String? identifier}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          if (identifier != null && identifier.isNotEmpty) 'X-User-Identifier': identifier,
        },
      ),
    );
    return SiswaSpikapService(dio: dio);
  }

  /// Mengambil data dashboard ringkasan SPIKAP (branding, statistik, 10 laporan terbaru)
  Future<SiswaSpikapDashboardResponse> getDashboard({String? identifier}) async {
    try {
      final response = await dio.get(
        ApiEndpoints.siswaSpikapDashboard,
        queryParameters: {
          if (identifier != null && identifier.isNotEmpty) 'identifier': identifier,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return SiswaSpikapDashboardResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat dashboard SPIKAP.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(serverMsg ?? 'Terjadi kesalahan jaringan saat memuat dashboard SPIKAP (${e.type.name}).');
    }
  }

  /// Mengambil riwayat pengaduan SPIKAP siswa dengan filter status, sifat, & pencarian
  Future<SiswaSpikapListResponse> getLaporanList({
    String status = 'all',
    String sifatLaporan = 'all',
    String jenisPerundungan = 'all',
    String? search,
    int page = 1,
    int perPage = 15,
    String? identifier,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.siswaSpikapList,
        queryParameters: {
          'status': status,
          'sifat_laporan': sifatLaporan,
          'jenis_perundungan': jenisPerundungan,
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
          'page': page,
          'per_page': perPage,
          if (identifier != null && identifier.isNotEmpty) 'identifier': identifier,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return SiswaSpikapListResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat daftar laporan SPIKAP.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(serverMsg ?? 'Terjadi kesalahan jaringan saat memuat daftar laporan (${e.type.name}).');
    }
  }

  /// Mengambil detail kasus laporan SPIKAP, berkas lampiran, dan alur tracking status timeline
  Future<SiswaSpikapDetailResponse> getLaporanDetail(int id, {String? identifier}) async {
    try {
      final response = await dio.get(
        ApiEndpoints.siswaSpikapDetail(id),
        queryParameters: {
          if (identifier != null && identifier.isNotEmpty) 'identifier': identifier,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return SiswaSpikapDetailResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat detail laporan SPIKAP.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(serverMsg ?? 'Terjadi kesalahan jaringan saat memuat detail kasus (${e.type.name}).');
    }
  }

  /// Mengirim pengaduan laporan SPIKAP baru dengan multipart upload foto/video bukti
  Future<Map<String, dynamic>> submitLaporan({
    required String sifatLaporan, // 'biasa' | 'darurat'
    required String jenisPerundungan, // 'fisik' | 'verbal' | 'sosial' | 'digital' | 'lainnya'
    required String uraianKejadian,
    String? lokasiKejadian,
    String? waktuKejadian, // 'YYYY-MM-DD HH:mm:ss'
    String? tujuanPenerima, // 'guru_bk' | 'wali_kelas'
    List<XFile>? fotoBukti,
    List<XFile>? videoBukti,
    String? identifier,
  }) async {
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('sifat_laporan', sifatLaporan));
      formData.fields.add(MapEntry('jenis_perundungan', jenisPerundungan));
      formData.fields.add(MapEntry('uraian_kejadian', uraianKejadian));

      if (lokasiKejadian != null && lokasiKejadian.trim().isNotEmpty) {
        formData.fields.add(MapEntry('lokasi_kejadian', lokasiKejadian.trim()));
      }
      if (waktuKejadian != null && waktuKejadian.trim().isNotEmpty) {
        formData.fields.add(MapEntry('waktu_kejadian', waktuKejadian.trim()));
      }
      if (sifatLaporan == 'biasa' && tujuanPenerima != null && tujuanPenerima.isNotEmpty) {
        formData.fields.add(MapEntry('tujuan_penerima', tujuanPenerima));
      }
      if (identifier != null && identifier.isNotEmpty) {
        formData.fields.add(MapEntry('identifier', identifier));
      }

      // Lampiran Foto
      if (fotoBukti != null && fotoBukti.isNotEmpty) {
        for (int i = 0; i < fotoBukti.length; i++) {
          final file = fotoBukti[i];
          final bytes = await file.readAsBytes();
          final filename = file.name.isNotEmpty ? file.name : 'bukti_foto_${i + 1}.jpg';
          final multipartFile = MultipartFile.fromBytes(
            bytes,
            filename: filename,
          );
          formData.files.add(MapEntry('foto_bukti[]', multipartFile));
        }
      }

      // Lampiran Video
      if (videoBukti != null && videoBukti.isNotEmpty) {
        for (int i = 0; i < videoBukti.length; i++) {
          final file = videoBukti[i];
          final bytes = await file.readAsBytes();
          final filename = file.name.isNotEmpty ? file.name : 'bukti_video_${i + 1}.mp4';
          final multipartFile = MultipartFile.fromBytes(
            bytes,
            filename: filename,
          );
          formData.files.add(MapEntry('video_bukti[]', multipartFile));
        }
      }

      final response = await dio.post(
        ApiEndpoints.siswaSpikapSubmit,
        data: formData,
      );

      if (response.statusCode == 201 || (response.statusCode == 200 && response.data['success'] == true)) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengirim laporan SPIKAP.');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message'];
      throw Exception(serverMsg ?? 'Terjadi kesalahan saat mengirim pengaduan (${e.type.name}).');
    }
  }
}


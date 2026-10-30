import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/spikap_models.dart';

/// Service untuk menangani komunikasi REST API Menu 7: SPIKAP (Anti-Perundungan)
class SpikapService {
  final Dio dio;
  final String? token;
  final String? identifier;

  SpikapService({
    required this.dio,
    this.token,
    this.identifier,
  });

  /// Factory untuk membuat instance service dengan token Sanctum dan identifier guru
  factory SpikapService.create({String? token, String? identifier}) {
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
    return SpikapService(
      dio: dio,
      token: token,
      identifier: identifier,
    );
  }

  // =========================================================================
  // 1. CEK HAK AKSES SPIKAP
  // =========================================================================

  /// Memverifikasi hak akses pengguna (BK, Wali Kelas, Kepala Sekolah, Admin)
  Future<SpikapAccessInfo> checkAccess() async {
    final response = await dio.get(
      ApiEndpoints.guruSpikapCheckAccess,
      queryParameters: {
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final json = response.data as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>? ?? {};
      return SpikapAccessInfo.fromJson(data);
    } else {
      throw Exception(
        response.data?['message'] ?? 'Gagal memeriksa hak akses SPIKAP.',
      );
    }
  }

  // =========================================================================
  // 2. KOTAK MASUK (INBOX) LAPORAN ADUAN
  // =========================================================================

  /// Mengambil daftar tiket laporan aduan terfilter
  Future<SpikapInboxResult> getInbox({
    String? search,
    String? status,
    String? sifat,
    String? jenis,
    int page = 1,
    int perPage = 15,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (status != null && status.isNotEmpty) 'status': status,
      if (sifat != null && sifat.isNotEmpty) 'sifat': sifat,
      if (jenis != null && jenis.isNotEmpty) 'jenis': jenis,
      if (identifier != null && identifier!.isNotEmpty)
        'identifier': identifier,
    };

    final response = await dio.get(
      ApiEndpoints.guruSpikapInbox,
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final json = response.data as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>? ?? {};

      final reportsRaw = data['reports'] as List<dynamic>? ?? [];
      final reports = reportsRaw
          .map((e) => SpikapLaporanItem.fromJson(e as Map<String, dynamic>))
          .toList();

      final statsRaw = data['stats'] as Map<String, dynamic>? ?? {};
      final stats = SpikapKpiStats.fromJson(statsRaw);

      final accessRaw = data['access'] as Map<String, dynamic>? ?? {};
      final access = SpikapAccessInfo.fromJson(accessRaw);

      final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
      final hasMore = pagination['has_more'] == true;
      final total = (pagination['total'] as num?)?.toInt() ?? reports.length;

      return SpikapInboxResult(
        reports: reports,
        stats: stats,
        access: access,
        hasMore: hasMore,
        total: total,
      );
    } else {
      throw Exception(
        response.data?['message'] ?? 'Gagal memuat kotak masuk SPIKAP.',
      );
    }
  }

  // =========================================================================
  // 3. DETAIL LAPORAN & INVESTIGASI
  // =========================================================================

  /// Mengambil detail lengkap 1 kasus pengaduan
  Future<SpikapDetailLaporan> getDetail(int id) async {
    final response = await dio.get(
      ApiEndpoints.guruSpikapDetail(id.toString()),
      queryParameters: {
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final json = response.data as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>? ?? {};
      return SpikapDetailLaporan.fromJson(data);
    } else {
      throw Exception(
        response.data?['message'] ?? 'Gagal memuat detail laporan SPIKAP.',
      );
    }
  }

  // =========================================================================
  // 4. PEMBARUAN STATUS KASUS & AUDIT TRAIL
  // =========================================================================

  /// Mengubah status investigasi kasus ('diterima', 'dalam_investigasi', 'selesai')
  Future<Map<String, dynamic>> updateStatus(
    int id, {
    required String statusBaru,
    String? catatan,
    bool notifyWa = true,
  }) async {
    final response = await dio.post(
      ApiEndpoints.guruSpikapUpdateStatus(id.toString()),
      queryParameters: {
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
      data: {
        'status_baru': statusBaru,
        if (catatan != null && catatan.trim().isNotEmpty)
          'catatan': catatan.trim(),
        'notify_wa': notifyWa,
      },
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception(
        response.data?['message'] ?? 'Gagal memperbarui status laporan.',
      );
    }
  }

  // =========================================================================
  // 5. DASBOR ANALITIK (KHUSUS KEPALA SEKOLAH & GURU BK)
  // =========================================================================

  /// Mengambil data statistik dan analitik tren kasus
  Future<SpikapAnalitikData> getAnalitik({String periode = '1_tahun'}) async {
    final response = await dio.get(
      ApiEndpoints.guruSpikapAnalitik,
      queryParameters: {
        'periode': periode,
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final json = response.data as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>? ?? {};
      return SpikapAnalitikData.fromJson(data);
    } else {
      throw Exception(
        response.data?['message'] ?? 'Gagal memuat analitik SPIKAP.',
      );
    }
  }
}

/// DTO Hasil Query Inbox SPIKAP
class SpikapInboxResult {
  final List<SpikapLaporanItem> reports;
  final SpikapKpiStats stats;
  final SpikapAccessInfo access;
  final bool hasMore;
  final int total;

  const SpikapInboxResult({
    required this.reports,
    required this.stats,
    required this.access,
    required this.hasMore,
    required this.total,
  });
}

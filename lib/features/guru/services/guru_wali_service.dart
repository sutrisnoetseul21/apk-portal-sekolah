import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/guru_wali_dashboard_model.dart';
import '../models/jurnal_guru_wali_model.dart';
import '../models/konsultasi_guru_wali_model.dart';
import '../models/pemantauan_bulanan_model.dart';

/// Service untuk menangani komunikasi REST API Menu 5: Guru Wali (SI-WALI)
class GuruWaliService {
  final Dio dio;
  final String? token;
  final String? identifier;

  GuruWaliService({
    required this.dio,
    this.token,
    this.identifier,
  });

  /// Factory untuk membuat instance service dengan token dan identifier guru
  factory GuruWaliService.create({String? token, String? identifier}) {
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
    return GuruWaliService(
      dio: dio,
      token: token,
      identifier: identifier,
    );
  }

  // =========================================================================
  // 1. DASHBOARD & SISWA ASUH
  // =========================================================================

  /// Mengambil data utama Command Center Guru Wali
  Future<GuruWaliDashboardResponse> getDashboard({String? search}) async {
    final response = await dio.get(
      ApiEndpoints.guruWaliDashboard,
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return GuruWaliDashboardResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        response.data['message'] ?? 'Gagal memuat dashboard Guru Wali.',
      );
    }
  }

  // =========================================================================
  // 2. JURNAL GURU WALI (INDIVIDU & KLASIKAL)
  // =========================================================================

  /// Mengambil riwayat jurnal bimbingan dengan filter & pagination
  Future<JurnalGuruWaliListResponse> getJurnalList({
    String? studentId,
    String? kategori,
    String? jenisPendampingan,
    String? statusSesi,
    String? bulan,
    String? search,
    int page = 1,
  }) async {
    final response = await dio.get(
      ApiEndpoints.guruWaliJurnalList,
      queryParameters: {
        if (studentId != null && studentId.isNotEmpty) 'student_id': studentId,
        if (kategori != null && kategori.isNotEmpty) 'kategori': kategori,
        if (jenisPendampingan != null && jenisPendampingan.isNotEmpty)
          'jenis_pendampingan': jenisPendampingan,
        if (statusSesi != null && statusSesi.isNotEmpty)
          'status_sesi': statusSesi,
        if (bulan != null && bulan.isNotEmpty) 'bulan': bulan,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return JurnalGuruWaliListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        response.data['message'] ?? 'Gagal memuat riwayat jurnal.',
      );
    }
  }

  /// Menyimpan jurnal bimbingan individual untuk 1 siswa
  Future<Map<String, dynamic>> storeIndividualJurnal({
    required String studentId,
    required DateTime tanggalWaktu,
    required String jenisPendampingan,
    required String kategoriPendampingan,
    required String uraianPembahasan,
    required String statusSesi,
    required String rujukanKolaborasi,
    String? rencanaTindakLanjut,
    bool isPublicNote = false,
    String kategoriSentimen = 'Netral',
    bool giveBadge = false,
    String? namaBadge,
    String? catatanApresiasi,
    String? konsultasiId,
  }) async {
    final response = await dio.post(
      ApiEndpoints.guruWaliJurnalIndividual,
      data: {
        'student_id': studentId,
        'tanggal_waktu': tanggalWaktu.toIso8601String(),
        'jenis_pendampingan': jenisPendampingan,
        'kategori_pendampingan': kategoriPendampingan,
        'uraian_pembahasan': uraianPembahasan,
        'status_sesi': statusSesi,
        'rujukan_kolaborasi': rujukanKolaborasi,
        if (rencanaTindakLanjut != null)
          'rencana_tindak_lanjut': rencanaTindakLanjut,
        'is_public_note': isPublicNote,
        'kategori_sentimen': kategoriSentimen,
        'give_badge': giveBadge,
        if (giveBadge && namaBadge != null) 'nama_badge': namaBadge,
        if (giveBadge && catatanApresiasi != null)
          'catatan_apresiasi': catatanApresiasi,
        if (konsultasiId != null) 'konsultasi_id': konsultasiId,
      },
      queryParameters: {
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data as Map);
    } else {
      throw Exception(
        response.data['message'] ?? 'Gagal menyimpan jurnal bimbingan.',
      );
    }
  }

  /// Menyimpan bimbingan kelompok massal (Klasikal)
  Future<Map<String, dynamic>> storeKlasikalJurnal({
    required DateTime tanggalWaktu,
    required String jenisPendampingan,
    required String kategoriPendampingan,
    required String uraianPembahasan,
    required String rujukanKolaborasi,
    required List<String> studentIds,
    String? rencanaTindakLanjut,
    bool isPublicNote = false,
    String statusSesi = 'Tuntas / Selesai',
  }) async {
    final response = await dio.post(
      ApiEndpoints.guruWaliJurnalKlasikal,
      data: {
        'tanggal_waktu': tanggalWaktu.toIso8601String(),
        'jenis_pendampingan': jenisPendampingan,
        'kategori_pendampingan': kategoriPendampingan,
        'uraian_pembahasan': uraianPembahasan,
        'rujukan_kolaborasi': rujukanKolaborasi,
        'student_ids': studentIds,
        if (rencanaTindakLanjut != null)
          'rencana_tindak_lanjut': rencanaTindakLanjut,
        'is_public_note': isPublicNote,
        'status_sesi': statusSesi,
      },
      queryParameters: {
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data as Map);
    } else {
      throw Exception(
        response.data['message'] ?? 'Gagal menyimpan bimbingan klasikal.',
      );
    }
  }

  /// Mengambil detail 1 jurnal bimbingan
  Future<JurnalGuruWaliItem> getJurnalDetail(String id) async {
    final response = await dio.get(
      ApiEndpoints.guruWaliJurnalDetail(id),
      queryParameters: {
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return JurnalGuruWaliItem.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        response.data['message'] ?? 'Gagal memuat detail jurnal.',
      );
    }
  }

  /// Update catatan jurnal
  Future<Map<String, dynamic>> updateJurnal({
    required String id,
    required DateTime tanggalWaktu,
    required String kategoriPendampingan,
    required String uraianPembahasan,
    required String statusSesi,
    required String rujukanKolaborasi,
    String? rencanaTindakLanjut,
    bool isPublicNote = false,
    String kategoriSentimen = 'Netral',
  }) async {
    final response = await dio.put(
      ApiEndpoints.guruWaliJurnalDetail(id),
      data: {
        'tanggal_waktu': tanggalWaktu.toIso8601String(),
        'kategori_pendampingan': kategoriPendampingan,
        'uraian_pembahasan': uraianPembahasan,
        'status_sesi': statusSesi,
        'rujukan_kolaborasi': rujukanKolaborasi,
        if (rencanaTindakLanjut != null)
          'rencana_tindak_lanjut': rencanaTindakLanjut,
        'is_public_note': isPublicNote,
        'kategori_sentimen': kategoriSentimen,
      },
      queryParameters: {
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data as Map);
    } else {
      throw Exception(
        response.data['message'] ?? 'Gagal memperbarui jurnal.',
      );
    }
  }

  /// Hapus catatan jurnal
  Future<Map<String, dynamic>> deleteJurnal(String id) async {
    final response = await dio.delete(
      ApiEndpoints.guruWaliJurnalDetail(id),
      queryParameters: {
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data as Map);
    } else {
      throw Exception(
        response.data['message'] ?? 'Gagal menghapus jurnal.',
      );
    }
  }

  /// Eskalasi catatan jurnal ke Guru BK
  Future<Map<String, dynamic>> rujukBk({
    required String jurnalId,
    required String alasanRujukan,
  }) async {
    final response = await dio.post(
      ApiEndpoints.guruWaliJurnalRujukBk(jurnalId),
      data: {
        'alasan_rujukan': alasanRujukan,
      },
      queryParameters: {
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data as Map);
    } else {
      throw Exception(
        response.data['message'] ?? 'Gagal merujuk kasus ke Guru BK.',
      );
    }
  }

  // =========================================================================
  // 3. RUANG AMAN CERITA & KONSULTASI SISWA
  // =========================================================================

  /// Mengambil daftar tiket konsultasi
  Future<KonsultasiGuruWaliListResponse> getKonsultasiList({
    String status = 'semua',
    String? search,
  }) async {
    final response = await dio.get(
      ApiEndpoints.guruWaliKonsultasiList,
      queryParameters: {
        'status': status,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return KonsultasiGuruWaliListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        response.data['message'] ?? 'Gagal memuat daftar konsultasi.',
      );
    }
  }

  /// Mengambil detail tiket konsultasi beserta untaian chat obrolan
  Future<KonsultasiGuruWaliItem> getKonsultasiDetail(String id) async {
    final response = await dio.get(
      ApiEndpoints.guruWaliKonsultasiDetail(id),
      queryParameters: {
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return KonsultasiGuruWaliItem.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        response.data['message'] ?? 'Gagal memuat detail percakapan.',
      );
    }
  }

  /// Kirim pesan obrolan dari guru ke siswa
  Future<PesanKonsultasiItem> kirimPesanKonsultasi({
    required String konsultasiId,
    required String pesan,
  }) async {
    final response = await dio.post(
      ApiEndpoints.guruWaliKonsultasiPesan(konsultasiId),
      data: {
        'pesan': pesan,
      },
      queryParameters: {
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return PesanKonsultasiItem.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        response.data['message'] ?? 'Gagal mengirim pesan obrolan.',
      );
    }
  }

  /// Tetapkan jadwal pasti pertemuan tatap muka
  Future<Map<String, dynamic>> jadwalkanKonsultasi({
    required String konsultasiId,
    required DateTime jadwalPasti,
    String? tanggapan,
  }) async {
    final response = await dio.post(
      ApiEndpoints.guruWaliKonsultasiJadwalkan(konsultasiId),
      data: {
        'jadwal_pasti': jadwalPasti.toIso8601String(),
        if (tanggapan != null) 'tanggapan_guru': tanggapan,
      },
      queryParameters: {
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data as Map);
    } else {
      throw Exception(
        response.data['message'] ?? 'Gagal menetapkan jadwal tatap muka.',
      );
    }
  }

  /// Balas pesan atau selesaikan konsultasi
  Future<Map<String, dynamic>> balasKonsultasi({
    required String konsultasiId,
    required String tanggapanPesan,
    bool markCompleted = false,
  }) async {
    final response = await dio.post(
      ApiEndpoints.guruWaliKonsultasiBalas(konsultasiId),
      data: {
        'tanggapan_pesan': tanggapanPesan,
        'mark_completed': markCompleted,
      },
      queryParameters: {
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data as Map);
    } else {
      throw Exception(
        response.data['message'] ?? 'Gagal menyimpan tanggapan.',
      );
    }
  }

  /// Tolak permohonan konsultasi
  Future<Map<String, dynamic>> tolakKonsultasi({
    required String konsultasiId,
    required String alasanPenolakan,
  }) async {
    final response = await dio.post(
      ApiEndpoints.guruWaliKonsultasiTolak(konsultasiId),
      data: {
        'alasan_penolakan': alasanPenolakan,
      },
      queryParameters: {
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data as Map);
    } else {
      throw Exception(
        response.data['message'] ?? 'Gagal menolak konsultasi.',
      );
    }
  }

  /// Konversi konsultasi menjadi jurnal Guru Wali (+1 Klik)
  Future<Map<String, dynamic>> konversiKonsultasiKeJurnal({
    required String konsultasiId,
    String jenisPendampingan = 'Individu',
    String statusSesi = 'Tuntas / Selesai',
    String rujukanKolaborasi = 'Mandiri',
    String? rencanaTindakLanjut,
  }) async {
    final response = await dio.post(
      ApiEndpoints.guruWaliKonsultasiKonversiJurnal(konsultasiId),
      data: {
        'jenis_pendampingan': jenisPendampingan,
        'status_sesi': statusSesi,
        'rujukan_kolaborasi': rujukanKolaborasi,
        if (rencanaTindakLanjut != null)
          'rencana_tindak_lanjut': rencanaTindakLanjut,
      },
      queryParameters: {
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data as Map);
    } else {
      throw Exception(
        response.data['message'] ?? 'Gagal mengonversi konsultasi ke jurnal.',
      );
    }
  }

  // =========================================================================
  // 4. PEMANTAUAN BULANAN (MATRIKS 12 BULAN & 4 PILAR)
  // =========================================================================

  /// Mengambil matriks pemantauan 12 bulan dan distribusi 4 pilar
  Future<PemantauanBulananResponse> getPemantauan() async {
    final response = await dio.get(
      ApiEndpoints.guruWaliPemantauan,
      queryParameters: {
        if (identifier != null && identifier!.isNotEmpty)
          'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return PemantauanBulananResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        response.data['message'] ?? 'Gagal memuat matriks pemantauan.',
      );
    }
  }

  // =========================================================================
  // 5. CETAK / DOWNLOAD PDF RESMI
  // =========================================================================

  /// Menghasilkan URL download PDF lengkap dengan parameter otentikasi
  String getPdfDownloadUrl({
    String type = 'rekap', // 'rekap' | 'individual'
    String? studentId,
    String periode = 'tahunan', // 'semester_1' | 'semester_2' | 'tahunan'
  }) {
    final buffer = StringBuffer('${AppConfig.baseUrl}${ApiEndpoints.guruWaliCetakPdf}');
    buffer.write('?type=$type');
    buffer.write('&periode=$periode');
    if (studentId != null && studentId.isNotEmpty) {
      buffer.write('&student_id=$studentId');
    }
    if (token != null && token!.isNotEmpty) {
      buffer.write('&token=$token');
    }
    if (identifier != null && identifier!.isNotEmpty) {
      buffer.write('&identifier=$identifier');
    }
    return buffer.toString();
  }
}


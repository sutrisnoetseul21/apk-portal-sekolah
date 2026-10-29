import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/leave_request_model.dart';

/// Service untuk menangani komunikasi REST API Menu 4 (Persetujuan Ijin)
class IjinKehadiranService {
  final Dio dio;

  IjinKehadiranService({required this.dio});

  /// Factory untuk membuat instance service dengan token dan identifier
  factory IjinKehadiranService.create({String? token, String? identifier}) {
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
    return IjinKehadiranService(dio: dio);
  }

  /// Mengambil daftar permohonan ijin siswa dengan filter dan paginasi
  Future<LeaveRequestListResponse> getLeaveRequests({
    String status = 'all',
    String? classId,
    String? month,
    String? search,
    int page = 1,
    String? identifier,
  }) async {
    final response = await dio.get(
      ApiEndpoints.guruIjinList,
      queryParameters: {
        'status': status,
        if (classId != null && classId.isNotEmpty) 'class_id': classId,
        if (month != null && month.isNotEmpty) 'month': month,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
        if (identifier != null && identifier.isNotEmpty) 'identifier': identifier,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return LeaveRequestListResponse.fromJson(data);
    } else {
      throw Exception(response.data['message'] ?? 'Gagal memuat daftar permohonan ijin.');
    }
  }

  /// Mengambil detail lengkap 1 permohonan ijin beserta profil ortu, lampiran & log
  Future<Map<String, dynamic>> getLeaveRequestDetail(String id) async {
    final response = await dio.get(ApiEndpoints.guruIjinDetail(id));

    if (response.statusCode == 200 && response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data['data'] as Map);
    } else {
      throw Exception(response.data['message'] ?? 'Gagal memuat detail permohonan ijin.');
    }
  }

  /// Menyetujui permohonan ijin & otomatis sinkronisasi ke presensi kelas
  Future<Map<String, dynamic>> approveLeaveRequest(String id) async {
    final response = await dio.post(ApiEndpoints.guruIjinApprove(id));

    if (response.statusCode == 200 && response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data as Map);
    } else {
      throw Exception(response.data['message'] ?? 'Gagal menyetujui permohonan ijin.');
    }
  }

  /// Menolak permohonan ijin dengan alasan penolakan
  Future<Map<String, dynamic>> rejectLeaveRequest(String id, String reason) async {
    final response = await dio.post(
      ApiEndpoints.guruIjinReject(id),
      data: {'reason': reason},
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data as Map);
    } else {
      throw Exception(response.data['message'] ?? 'Gagal menolak permohonan ijin.');
    }
  }

  /// Mengembalikan status permohonan ijin ke status 'pending'
  Future<Map<String, dynamic>> resetLeaveRequest(String id, [String? reason]) async {
    final response = await dio.post(
      ApiEndpoints.guruIjinReset(id),
      data: {
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data as Map);
    } else {
      throw Exception(response.data['message'] ?? 'Gagal mengembalikan status permohonan ijin.');
    }
  }

  /// Polling pengecekan permohonan pending baru untuk In-App Notification
  Future<Map<String, dynamic>> checkNotification() async {
    final response = await dio.get(ApiEndpoints.guruIjinNotifCheck);

    if (response.statusCode == 200 && response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data['data'] as Map);
    } else {
      throw Exception(response.data['message'] ?? 'Gagal mengecek notifikasi ijin.');
    }
  }
}

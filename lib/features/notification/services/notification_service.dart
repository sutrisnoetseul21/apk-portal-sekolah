import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/notification_item_model.dart';

class NotificationInboxResponse {
  final List<NotificationItemModel> items;
  final int unreadCount;
  final int currentPage;
  final int lastPage;

  NotificationInboxResponse({
    required this.items,
    required this.unreadCount,
    required this.currentPage,
    required this.lastPage,
  });
}

class NotificationService {
  final Dio dio;

  NotificationService({required this.dio});

  factory NotificationService.create({String? token}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 12),
        headers: {
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ),
    );
    return NotificationService(dio: dio);
  }

  /// Mengambil daftar notifikasi dari server
  Future<NotificationInboxResponse> getNotifications({int page = 1}) async {
    try {
      final response = await dio.get(
        ApiEndpoints.notifications,
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final rawList = response.data['data'] as List<dynamic>? ?? [];
        final items = rawList
            .map((e) => NotificationItemModel.fromJson(e as Map<String, dynamic>))
            .toList();

        final meta = (response.data['pagination'] ?? response.data['meta'])
                as Map<String, dynamic>? ??
            {};

        return NotificationInboxResponse(
          items: items,
          unreadCount: (response.data['unread_count'] as num?)?.toInt() ?? 0,
          currentPage: (meta['current_page'] as num?)?.toInt() ?? 1,
          lastPage: (meta['last_page'] as num?)?.toInt() ?? 1,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat daftar notifikasi.');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'];
      throw Exception(msg ?? 'Terjadi kesalahan saat memuat notifikasi.');
    }
  }

  /// Menandai satu notifikasi sebagai telah dibaca
  Future<bool> markAsRead(String id) async {
    try {
      final response = await dio.post(ApiEndpoints.notificationMarkAsRead(id));
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Menandai seluruh notifikasi sebagai telah dibaca
  Future<bool> markAllAsRead() async {
    try {
      final response = await dio.post(ApiEndpoints.notificationMarkAllAsRead);
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (_) {
      return false;
    }
  }
}

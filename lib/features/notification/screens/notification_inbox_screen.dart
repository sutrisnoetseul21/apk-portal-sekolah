import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/storage/session_storage.dart';
import '../../../core/utils/notification_router.dart';
import '../models/notification_item_model.dart';
import '../services/notification_service.dart';

/// Layar Pusat Notifikasi (In-App Notification Inbox)
class NotificationInboxScreen extends StatefulWidget {
  const NotificationInboxScreen({super.key});

  @override
  State<NotificationInboxScreen> createState() => _NotificationInboxScreenState();
}

class _NotificationInboxScreenState extends State<NotificationInboxScreen> {
  late NotificationService _service;
  bool _isLoading = true;
  String? _errorMessage;
  List<NotificationItemModel> _notifications = [];
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final session = await SessionStorage.getSession();
      _service = NotificationService.create(token: session?.token);

      final response = await _service.getNotifications();
      setState(() {
        _notifications = response.items;
        _unreadCount = response.unreadCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final success = await _service.markAllAsRead();
      if (success) {
        setState(() {
          _unreadCount = 0;
          _notifications = _notifications
              .map(
                (n) => NotificationItemModel(
                  id: n.id,
                  type: n.type,
                  eventStatus: n.eventStatus,
                  title: n.title,
                  body: n.body,
                  relatedId: n.relatedId,
                  url: n.url,
                  readAt: DateTime.now(),
                  createdAt: n.createdAt,
                ),
              )
              .toList();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Semua notifikasi ditandai telah dibaca'),
              backgroundColor: AppColors.hadir,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _handleItemTap(NotificationItemModel item) async {
    // 1. Tandai telah dibaca di backend jika belum dibaca
    if (!item.isRead) {
      _service.markAsRead(item.id);
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == item.id);
        if (index != -1) {
          _notifications[index] = NotificationItemModel(
            id: item.id,
            type: item.type,
            eventStatus: item.eventStatus,
            title: item.title,
            body: item.body,
            relatedId: item.relatedId,
            url: item.url,
            readAt: DateTime.now(),
            createdAt: item.createdAt,
          );
          if (_unreadCount > 0) _unreadCount--;
        }
      });
    }

    // 2. Arahkan ke modul terkait
    NotificationRouter.handlePayload({
      'type': item.type,
      'id': item.relatedId,
      'related_id': item.relatedId,
    });
  }

  Color _getIconBgColor(String type, String? eventStatus) {
    switch (type) {
      case 'attendance_status':
        return eventStatus == 'telat' ? Colors.orange.shade100 : Colors.red.shade100;
      case 'leave_approval':
      case 'leave_result':
        return Colors.green.shade100;
      case 'spikap':
        return Colors.amber.shade100;
      case 'consultation':
        return Colors.purple.shade100;
      default:
        return Colors.blue.shade100;
    }
  }

  IconData _getIcon(String type, String? eventStatus) {
    switch (type) {
      case 'attendance_status':
        return eventStatus == 'telat' ? Icons.access_time_filled : Icons.cancel;
      case 'leave_approval':
      case 'leave_result':
        return Icons.assignment_turned_in;
      case 'spikap':
        return Icons.shield_outlined;
      case 'consultation':
        return Icons.chat_bubble_outline;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(String type, String? eventStatus) {
    switch (type) {
      case 'attendance_status':
        return eventStatus == 'telat' ? Colors.orange.shade800 : Colors.red.shade800;
      case 'leave_approval':
      case 'leave_result':
        return Colors.green.shade800;
      case 'spikap':
        return Colors.amber.shade900;
      case 'consultation':
        return Colors.purple.shade800;
      default:
        return AppColors.primary;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pusat Notifikasi'),
        actions: [
          if (_unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Tandai semua dibaca',
              onPressed: _markAllAsRead,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        color: AppColors.primary,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadNotifications,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'Belum Ada Notifikasi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Pemberitahuan presensi dan izin akan muncul di sini.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _notifications.length,
      separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
      itemBuilder: (context, index) {
        final item = _notifications[index];
        return InkWell(
          onTap: () => _handleItemTap(item),
          child: Container(
            color: item.isRead ? Colors.transparent : AppColors.primary.withValues(alpha: 0.04),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: _getIconBgColor(item.type, item.eventStatus),
                  child: Icon(
                    _getIcon(item.type, item.eventStatus),
                    color: _getIconColor(item.type, item.eventStatus),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(item.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: item.isRead ? AppColors.textSecondary : AppColors.primary,
                              fontWeight: item.isRead ? FontWeight.normal : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: item.isRead ? AppColors.textSecondary : Colors.black87,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!item.isRead) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

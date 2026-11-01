/// Model Notifikasi In-App dari Database Laravel
class NotificationItemModel {
  final String id;
  final String type;
  final String? eventStatus;
  final String title;
  final String body;
  final String? relatedId;
  final String? url;
  final DateTime? readAt;
  final DateTime createdAt;

  NotificationItemModel({
    required this.id,
    required this.type,
    this.eventStatus,
    required this.title,
    required this.body,
    this.relatedId,
    this.url,
    this.readAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      eventStatus: json['event_status']?.toString(),
      title: json['title']?.toString() ?? 'Notifikasi',
      body: json['body']?.toString() ?? '',
      relatedId: json['related_id']?.toString(),
      url: json['url']?.toString(),
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

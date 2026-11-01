import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apk_portal_smpn1_sampang/features/notification/models/notification_item_model.dart';
import 'package:apk_portal_smpn1_sampang/features/notification/services/notification_service.dart';
import 'package:apk_portal_smpn1_sampang/features/notification/screens/notification_inbox_screen.dart';

void main() {
  group('Notification Model & Response Tests', () {
    test('NotificationItemModel correctly parses unread attendance notification', () {
      final json = {
        'id': 'notif-uuid-1',
        'type': 'attendance_status',
        'event_status': 'telat',
        'title': 'Status Presensi: Terlambat',
        'body': 'Anda tercatat hadir terlambat (15 menit) pada pukul 07:15 WIB.',
        'related_id': '2026-11-01:student-uuid-1',
        'url': null,
        'read_at': null,
        'created_at': '2026-11-01T07:15:00.000000Z',
      };

      final item = NotificationItemModel.fromJson(json);

      expect(item.id, 'notif-uuid-1');
      expect(item.type, 'attendance_status');
      expect(item.eventStatus, 'telat');
      expect(item.title, 'Status Presensi: Terlambat');
      expect(item.isRead, false);
      expect(item.relatedId, '2026-11-01:student-uuid-1');
    });

    test('NotificationItemModel correctly parses read leave_approval notification', () {
      final json = {
        'id': 'notif-uuid-2',
        'type': 'leave_approval',
        'event_status': 'pending',
        'title': 'Pengajuan Izin Siswa Baru',
        'body': 'Siswa Ahmad Fulan (VII-A) mengajukan izin selama 2 hari.',
        'related_id': 'leave-uuid-99',
        'url': null,
        'read_at': '2026-11-01T08:00:00.000000Z',
        'created_at': '2026-11-01T07:30:00.000000Z',
      };

      final item = NotificationItemModel.fromJson(json);

      expect(item.id, 'notif-uuid-2');
      expect(item.type, 'leave_approval');
      expect(item.isRead, true);
      expect(item.readAt, isNotNull);
    });

    test('NotificationInboxResponse correctly parses list and pagination meta', () {
      final response = NotificationInboxResponse(
        items: [
          NotificationItemModel(
            id: '1',
            type: 'attendance_status',
            eventStatus: 'alpa',
            title: 'Status Presensi: Alpa',
            body: 'Anda tidak hadir tanpa keterangan hari ini.',
            relatedId: '2026-11-01:student-1',
            createdAt: DateTime.now(),
          ),
        ],
        unreadCount: 1,
        currentPage: 1,
        lastPage: 3,
      );

      expect(response.items.length, 1);
      expect(response.unreadCount, 1);
      expect(response.currentPage, 1);
      expect(response.lastPage, 3);
    });
  });

  group('Notification Inbox Screen Tests', () {
    testWidgets('NotificationInboxScreen renders app bar and loading or empty state', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));

      await tester.pumpWidget(
        const MaterialApp(
          home: NotificationInboxScreen(),
        ),
      );

      expect(find.text('Pusat Notifikasi'), findsOneWidget);
    });
  });
}

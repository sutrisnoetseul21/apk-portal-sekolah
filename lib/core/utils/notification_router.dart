import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../storage/session_storage.dart';
import '../../features/guru/screens/ijin_kehadiran_screen.dart';
import '../../features/guru/screens/spikap_screen.dart';
import '../../features/guru/screens/guru_wali_screen.dart';
import '../../features/siswa/screens/presensi_siswa_screen.dart';
import '../../features/siswa/screens/ijin_kehadiran_siswa_screen.dart';
import '../../features/siswa/screens/spikap_siswa_screen.dart';
import '../../features/siswa/screens/guru_wali_siswa_screen.dart';
import '../../features/notification/screens/notification_inbox_screen.dart';

/// Router Penanganan Deep Link dari Tap Notifikasi Push FCM & Inbox
class NotificationRouter {
  /// Global navigator key untuk melakukan navigasi dari background / event callback
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Handle notifikasi dari Firebase RemoteMessage
  static void handleMessage(RemoteMessage message) {
    handlePayload(message.data);
  }

  /// Handle payload data notifikasi
  static Future<void> handlePayload(Map<String, dynamic> data) async {
    final type = data['type']?.toString();
    final id = data['id']?.toString() ?? data['related_id']?.toString();

    final session = await SessionStorage.getSession();
    if (session == null) {
      return; // Pengguna belum login, biarkan splash/login menangani
    }

    final context = navigatorKey.currentContext;
    if (context == null) return;

    final isGuru = session.role == 'guru' || session.role == 'admin' || session.role == 'wali_kelas';

    Widget targetScreen;

    switch (type) {
      case 'attendance_status':
        targetScreen = PresensiSiswaScreen(
          studentName: session.name,
          identifier: session.identifier,
          token: session.token,
        );
        break;

      case 'broadcast_school':
        targetScreen = const NotificationInboxScreen();
        break;

      case 'leave_approval':
      case 'leave_request':
        if (isGuru) {
          targetScreen = IjinKehadiranScreen(
            token: session.token,
            teacherName: session.name,
            schoolName: session.schoolName,
          );
        } else {
          targetScreen = IjinKehadiranSiswaScreen(
            token: session.token,
            studentName: session.name,
            identifier: session.identifier,
            schoolName: session.schoolName,
          );
        }
        break;

      case 'leave_result':
        targetScreen = IjinKehadiranSiswaScreen(
          token: session.token,
          studentName: session.name,
          identifier: session.identifier,
          schoolName: session.schoolName,
        );
        break;

      case 'spikap':
      case 'spikap_laporan':
      case 'spikap_status_update':
        if (isGuru) {
          targetScreen = SpikapScreen(
            token: session.token,
            teacherName: session.name,
            schoolName: session.schoolName,
          );
        } else {
          targetScreen = SpikapSiswaScreen(
            token: session.token,
            studentName: session.name,
            identifier: session.identifier,
            schoolName: session.schoolName,
          );
        }
        break;

      case 'consultation':
      case 'konsultasi_guru_wali':
        if (isGuru) {
          targetScreen = GuruWaliScreen(
            token: session.token,
            teacherName: session.name,
            schoolName: session.schoolName,
            initialKonsultasiId: id,
            initialTabIndex: 1, // Tab Konsultasi
          );
        } else {
          targetScreen = GuruWaliSiswaScreen(
            token: session.token,
            studentName: session.name,
            identifier: session.identifier,
            schoolName: session.schoolName,
          );
        }
        break;

      default:
        targetScreen = const NotificationInboxScreen();
        break;
    }

    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => targetScreen),
    );
  }
}

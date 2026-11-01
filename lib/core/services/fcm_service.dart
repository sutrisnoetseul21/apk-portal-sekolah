import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../config/app_config.dart';
import '../constants/api_endpoints.dart';
import '../storage/session_storage.dart';
import '../utils/notification_router.dart';

/// Top-level background message handler wajib bertipe @pragma('vm:entry-point')
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  if (kDebugMode) {
    debugPrint("FCM Background Message Received: ${message.messageId}");
  }

  // Jika payload data-only (tanpa notification block bawaan FCM), tampilkan notifikasi secara manual
  if (message.notification == null && message.data.isNotEmpty) {
    final title = message.data['title']?.toString();
    final body = message.data['body']?.toString();
    if (title != null && title.isNotEmpty) {
      final localNotifications = FlutterLocalNotificationsPlugin();
      const initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: initSettingsAndroid);
      await localNotifications.initialize(initSettings);

      await localNotifications.show(
        message.messageId.hashCode != 0
            ? message.messageId.hashCode
            : DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'Notifikasi Utama Sekolah',
            channelDescription:
                'Saluran notifikasi penting untuk presensi, izin siswa, dan informasi sekolah.',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }
}

/// Service Utama Manajemen Notifikasi Push Firebase Cloud Messaging (HTTP v1)
class FcmService {
  FcmService._internal();
  static final FcmService instance = FcmService._internal();

  FirebaseMessaging? _fcm;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'high_importance_channel';
  static const String _channelName = 'Notifikasi Utama Sekolah';
  static const String _channelDescription =
      'Saluran notifikasi penting untuk presensi, izin siswa, dan informasi sekolah.';

  String? _currentFcmToken;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Inisialisasi Firebase & Setup Notification Handler secara aman (Crash-Proof)
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Firebase.initializeApp();
      _fcm = FirebaseMessaging.instance;
      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint("FcmService: Firebase.initializeApp() error/credentials missing: $e");
      }
      // Jika Firebase belum siap atau kredensial invalid, aplikasi tetap berjalan normal
      return;
    }

    try {
      // Set background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 1. Request Permission (Android 13+ & iOS)
      final settings = await _fcm?.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      if (kDebugMode) {
        debugPrint("FcmService: AuthorizationStatus: ${settings?.authorizationStatus}");
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("FcmService: Gagal request permission: $e");
      }
    }

    // 2. Setup Android Notification Channel & Local Notifications
    try {
      const androidChannel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(androidChannel);
      }

      const initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: initSettingsAndroid);

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          if (response.payload != null && response.payload!.isNotEmpty) {
            try {
              final data = jsonDecode(response.payload!) as Map<String, dynamic>;
              NotificationRouter.handlePayload(data);
            } catch (e) {
              if (kDebugMode) {
                debugPrint("FcmService: Gagal parse payload local notification: $e");
              }
            }
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint("FcmService: Error local notifications init: $e");
      }
    }

    // 3. Foreground Message Presentation: Tampilkan Heads-Up Notification Lokal
    try {
      await _fcm?.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          debugPrint("FcmService: Foreground message received: ${message.notification?.title}");
        }

        final notification = message.notification;
        final title = notification?.title ?? message.data['title']?.toString();
        final body = notification?.body ?? message.data['body']?.toString();

        if (title != null && title.isNotEmpty) {
          _localNotifications.show(
            message.messageId.hashCode != 0
                ? message.messageId.hashCode
                : DateTime.now().millisecondsSinceEpoch ~/ 1000,
            title,
            body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                _channelId,
                _channelName,
                channelDescription: _channelDescription,
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
                enableVibration: true,
                icon: '@mipmap/ic_launcher',
              ),
            ),
            payload: jsonEncode(message.data),
          );
        }
      });

      // 4. On Notification Opened App Listener (Background -> Foreground via Tap)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          debugPrint("FcmService: Notification opened app: ${message.data}");
        }
        NotificationRouter.handleMessage(message);
      });

      // 5. Token Refresh Listener
      _fcm?.onTokenRefresh.listen((newToken) {
        _currentFcmToken = newToken;
        if (kDebugMode) {
          debugPrint("FcmService: Token refreshed: $newToken");
        }
        registerTokenWithBackend();
      });

      // Dapatkan token awal
      _currentFcmToken = await _fcm?.getToken();
      if (kDebugMode) {
        debugPrint("FcmService: Initial FCM Token: $_currentFcmToken");
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("FcmService: Error listeners/token setup: $e");
      }
    }
  }

  /// Memeriksa notifikasi saat Cold Start (Aplikasi dibuka dari kondisi mati lewat notifikasi)
  Future<void> checkInitialMessage() async {
    if (!_isInitialized || _fcm == null) return;
    try {
      final initialMessage = await _fcm?.getInitialMessage();
      if (initialMessage != null) {
        if (kDebugMode) {
          debugPrint("FcmService: Initial cold start message found: ${initialMessage.data}");
        }
        Future.delayed(const Duration(milliseconds: 600), () {
          NotificationRouter.handleMessage(initialMessage);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("FcmService: Error checkInitialMessage: $e");
      }
    }
  }

  /// Mendaftarkan token perangkat ke backend Laravel (POST /api/v1/auth/fcm-token)
  Future<void> registerTokenWithBackend({String? token}) async {
    if (!_isInitialized || _fcm == null) return;
    try {
      final session = await SessionStorage.getSession();
      final authToken = token ?? session?.token;

      if (authToken == null || authToken.isEmpty) {
        return;
      }

      final fcmToken = _currentFcmToken ?? await _fcm?.getToken();
      if (fcmToken == null || fcmToken.isEmpty) {
        return;
      }

      _currentFcmToken = fcmToken;

      final dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
        ),
      );

      final response = await dio.post(
        ApiEndpoints.fcmToken,
        data: {
          'token': fcmToken,
          'device_type': 'android',
          'app_version': AppConfig.appVersion,
        },
      );

      if (kDebugMode) {
        debugPrint("FcmService: Token registrasi ke backend berhasil (${response.statusCode})");
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("FcmService: Gagal registrasi token ke backend: $e");
      }
    }
  }

  /// Mencabut token perangkat saat Logout (DELETE /api/v1/auth/fcm-token)
  Future<void> unregisterTokenWithBackend() async {
    if (!_isInitialized || _fcm == null) return;
    try {
      final session = await SessionStorage.getSession();
      final authToken = session?.token;
      final fcmToken = _currentFcmToken ?? await _fcm?.getToken();

      if (authToken != null && authToken.isNotEmpty && fcmToken != null && fcmToken.isNotEmpty) {
        final dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.baseUrl,
            connectTimeout: const Duration(seconds: 8),
            receiveTimeout: const Duration(seconds: 8),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
          ),
        );

        await dio.delete(
          ApiEndpoints.fcmToken,
          data: {
            'token': fcmToken,
          },
        );

        if (kDebugMode) {
          debugPrint("FcmService: Token perangkat berhasil dicabut dari backend saat logout.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("FcmService: Gagal mencabut token saat logout: $e");
      }
    }
  }
}

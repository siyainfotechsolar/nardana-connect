import 'dart:async';
import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/router/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const String kNotificationChannelId = 'nardana_connect_alerts';
const String kNotificationChannelName = 'NARDANA CONNECT Notifications';
const String kNotificationChannelDesc = 'महत्वाच्या गाव सूचना, पाणी पुरवठा व आपत्कालीन संदेश';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  developer.log('Background FCM message received: ${message.messageId}');

  // If data-only message (message.notification is null), show local notification
  // so it reliably wakes the lock-screen. If notification payload is present,
  // Android system displays it automatically on nardana_connect_alerts channel (avoids duplicates).
  if (message.notification == null && message.data.isNotEmpty) {
    final title = message.data['title'] ?? 'NARDANA CONNECT';
    final body = message.data['body'] ?? 'नवीन गाव सूचना उपलब्ध आहे.';
    final id = message.messageId.hashCode;

    final androidDetails = AndroidNotificationDetails(
      kNotificationChannelId,
      kNotificationChannelName,
      channelDescription: kNotificationChannelDesc,
      importance: Importance.max,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
      enableVibration: true,
      enableLights: true,
      icon: '@mipmap/ic_launcher',
      color: AppColors.primaryBlue,
      playSound: true,
      styleInformation: BigTextStyleInformation(body),
    );

    await _localNotificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails),
      payload: message.data['route'] ?? '/notices',
    );
  }
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  bool _initialized = false;
  String? _fcmToken;
  final StreamController<Map<String, dynamic>> _notificationStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  String? get fcmToken => _fcmToken;
  Stream<Map<String, dynamic>> get onNotificationReceived =>
      _notificationStreamController.stream;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 1. Initialize Local Notifications Plugin with Lock Screen Channel
      await _initializeLocalNotifications();

      final messaging = FirebaseMessaging.instance;

      // 2. Request notification permissions (required on Android 13+)
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );

      developer.log('FCM Notification permission status: ${settings.authorizationStatus}');

      // Request local notification permission on Android 13+
      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      // 3. Set presentation options for foreground display
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 4. Get FCM Token & save to database
      // ignore: deprecated_member_use
      _fcmToken = await messaging.getToken();
      developer.log('FCM Registration Token: $_fcmToken');
      if (_fcmToken != null) {
        await _saveTokenToSupabase(_fcmToken!);
      }

      // 5. Listen for token refreshes
      // ignore: deprecated_member_use
      messaging.onTokenRefresh.listen((newToken) async {
        _fcmToken = newToken;
        developer.log('FCM Token refreshed: $_fcmToken');
        await _saveTokenToSupabase(newToken);
      });

      // 6. Subscribe to Nardana village topics
      await messaging.subscribeToTopic('nardana_community');
      await messaging.subscribeToTopic('emergency_alerts');
      await messaging.subscribeToTopic('village_nardana');

      // 7. Handle foreground notifications: Show high-priority lock-screen capable banner
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        developer.log('Foreground FCM notification: ${message.notification?.title} - ${message.notification?.body}');
        final title = message.notification?.title ?? message.data['title'] ?? 'NARDANA CONNECT';
        final body = message.notification?.body ?? message.data['body'] ?? '';
        final type = message.data['type'] ?? 'announcement';

        // Trigger local notification so it appears in notification shade & lock screen
        showLocalNotification(
          id: message.messageId.hashCode,
          title: title,
          body: body,
          payload: message.data['route'] ?? '/notices',
          type: type,
        );

        // Also broadcast to in-app stream for immediate UI banner
        _notificationStreamController.add({
          'title': title,
          'body': body,
          'type': type,
          'source': 'fcm',
          'received_at': DateTime.now().toIso8601String(),
        });
      });

      // 8. Handle notification tapped by user when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        developer.log('Notification tapped from background: ${message.data}');
        final route = message.data['route'] ?? '/notices';
        appRouter.push(route);
      });

      // 9. Check if app was launched by tapping a notification (terminated state)
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        developer.log('App launched from terminated state via notification: ${initialMessage.data}');
        final route = initialMessage.data['route'] ?? '/notices';
        Future.delayed(const Duration(milliseconds: 600), () {
          appRouter.push(route);
        });
      }

      // 10. Start Supabase Realtime Notification Listener
      _listenToSupabaseRealtime();

      _initialized = true;
    } catch (e, stack) {
      developer.log('Error initializing Firebase Messaging: $e', error: e, stackTrace: stack);
    }
  }

  /// Sets up Flutter Local Notifications and Android Notification Channel
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        developer.log('Local notification tapped, payload: ${response.payload}');
        final route = response.payload ?? '/notices';
        appRouter.push(route);
      },
    );

    // Create high-priority lock-screen channel
    final androidChannel = AndroidNotificationChannel(
      kNotificationChannelId,
      kNotificationChannelName,
      description: kNotificationChannelDesc,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      showBadge: true,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Shows a local notification with Lock Screen visibility (VISIBILITY_PUBLIC)
  Future<void> showLocalNotification({
    int? id,
    required String title,
    required String body,
    String? payload,
    String? type,
  }) async {
    final notifId = id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final androidDetails = AndroidNotificationDetails(
      kNotificationChannelId,
      kNotificationChannelName,
      channelDescription: kNotificationChannelDesc,
      importance: Importance.max,
      priority: Priority.high,
      visibility: NotificationVisibility.public, // Visible on Lock Screen!
      enableVibration: true,
      enableLights: true,
      icon: '@mipmap/ic_launcher',
      color: AppColors.primaryBlue,
      playSound: true,
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: 'NARDANA CONNECT',
      ),
      ticker: 'NARDANA CONNECT',
    );

    await _localNotificationsPlugin.show(
      notifId,
      title,
      body,
      NotificationDetails(android: androidDetails),
      payload: payload ?? '/notices',
    );
  }

  /// Triggers a test lock-screen notification after a 3-second delay
  Future<void> triggerLockScreenTestNotification({
    required String title,
    required String body,
  }) async {
    await Future.delayed(const Duration(seconds: 3));
    await showLocalNotification(
      id: 9999,
      title: title,
      body: body,
      payload: '/notices',
    );
  }

  /// Saves or updates the device FCM token in Supabase
  Future<void> _saveTokenToSupabase(String token) async {
    try {
      final supabase = SupabaseService.client;
      await supabase.from('device_fcm_tokens').upsert(
        {
          'fcm_token': token,
          'user_id': supabase.auth.currentUser?.id,
          'platform': 'android',
          'is_active': true,
          'last_seen': DateTime.now().toIso8601String(),
        },
        onConflict: 'fcm_token',
      );
      developer.log('Saved FCM Token to Supabase successfully: $token');
    } catch (e) {
      developer.log('Error saving FCM Token to Supabase: $e');
    }
  }

  /// Listens to Supabase Realtime broadcast notifications
  void _listenToSupabaseRealtime() {
    try {
      final supabase = SupabaseService.client;
      supabase
          .channel('public:notifications')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'notifications',
            callback: (payload) {
              final newRecord = payload.newRecord;
              developer.log('Supabase Realtime notification received: $newRecord');
              final title = newRecord['title_mr'] ?? newRecord['title_en'] ?? 'गाव सूचना';
              final body = newRecord['body_mr'] ?? newRecord['body_en'] ?? '';
              final type = newRecord['type'] ?? 'announcement';

              // Show local notification for Realtime events so it lights up lock screen
              showLocalNotification(
                id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                title: title,
                body: body,
                payload: '/notices',
                type: type,
              );

              _notificationStreamController.add({
                'id': newRecord['id'],
                'title': title,
                'body': body,
                'type': type,
                'source': 'realtime',
                'received_at': DateTime.now().toIso8601String(),
              });
            },
          )
          .subscribe();
    } catch (e) {
      developer.log('Error setting up Supabase Realtime notifications: $e');
    }
  }

  /// Displays an in-app banner for incoming notifications
  void showNotificationBanner(
    BuildContext context, {
    required String title,
    required String body,
    String? type,
  }) {
    Color badgeColor;
    IconData badgeIcon;
    switch (type) {
      case 'emergency':
        badgeColor = Colors.red.shade700;
        badgeIcon = Icons.warning_amber_rounded;
        break;
      case 'water':
        badgeColor = Colors.blue.shade700;
        badgeIcon = Icons.water_drop_rounded;
        break;
      case 'electricity':
        badgeColor = Colors.amber.shade800;
        badgeIcon = Icons.bolt_rounded;
        break;
      default:
        badgeColor = AppColors.primaryBlue;
        badgeIcon = Icons.notifications_active_rounded;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        backgroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: badgeColor.withValues(alpha: 0.3), width: 1.5),
        ),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(badgeIcon, color: badgeColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.mukta(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.mukta(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Subscribe to village-specific updates
  Future<void> subscribeToVillage(String villageCode) async {
    try {
      final sanitized = villageCode.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
      await FirebaseMessaging.instance.subscribeToTopic('village_$sanitized');
      developer.log('Subscribed to FCM topic: village_$sanitized');
    } catch (e) {
      developer.log('Failed to subscribe to village topic: $e');
    }
  }

  /// Unsubscribe from a village topic
  Future<void> unsubscribeFromVillage(String villageCode) async {
    try {
      final sanitized = villageCode.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
      await FirebaseMessaging.instance.unsubscribeFromTopic('village_$sanitized');
      developer.log('Unsubscribed from FCM topic: village_$sanitized');
    } catch (e) {
      developer.log('Failed to unsubscribe from village topic: $e');
    }
  }
}

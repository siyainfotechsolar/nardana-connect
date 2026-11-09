import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  developer.log('Background FCM message received: ${message.messageId}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  bool _initialized = false;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;

      // Request notification permissions (required on Android 13+)
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      developer.log('FCM Notification permission status: ${settings.authorizationStatus}');

      // Get FCM Token
      // ignore: deprecated_member_use
      _fcmToken = await messaging.getToken();
      developer.log('FCM Registration Token: $_fcmToken');

      // Listen for token refreshes
      // ignore: deprecated_member_use
      messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        developer.log('FCM Token refreshed: $_fcmToken');
      });

      // Always subscribe to general community updates
      await messaging.subscribeToTopic('all_villages');
      await messaging.subscribeToTopic('emergency_alerts');

      // Handle foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        developer.log('Foreground FCM notification: ${message.notification?.title} - ${message.notification?.body}');
      });

      // Handle notification tapped by user
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        developer.log('Notification tapped: ${message.data}');
      });

      _initialized = true;
    } catch (e, stack) {
      developer.log('Error initializing Firebase Messaging: $e', error: e, stackTrace: stack);
    }
  }

  /// Subscribe to village-specific updates (e.g. water supply, electricity, GP notices)
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

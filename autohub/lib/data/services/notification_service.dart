import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    try {
      // Request permission for iOS
      if (Platform.isIOS) {
        await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // Request permission for Android 13+
      if (Platform.isAndroid) {
        await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // Initialize local notifications
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(settings);

      // Create notification channel for Android
      if (Platform.isAndroid) {
        await _createNotificationChannel();
      }

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle notification tap when app is terminated
      final RemoteMessage? initialMessage = await _firebaseMessaging
          .getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      print('Notification service initialized successfully');
    } catch (e) {
      print('Error initializing notification service: $e');
    }
  }

  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // Show local notification when app is in foreground
    await _showLocalNotification(message);
  }

  static Future<void> _handleNotificationTap(RemoteMessage message) async {
    // Handle navigation based on notification data
    final data = message.data;
    if (data.containsKey('type')) {
      switch (data['type']) {
        case 'event':
          // Navigate to event details
          break;
        case 'comment':
          // Navigate to post with comments
          break;
        case 'like':
          // Navigate to post
          break;
        case 'follow':
          // Navigate to user profile
          break;
      }
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'autohub_notifications',
          'AutoHub Notifications',
          channelDescription: 'Notifications for AutoHub app',
          importance: Importance.high,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'AutoHub',
      message.notification?.body ?? '',
      details,
      payload: message.data.toString(),
    );
  }

  static Future<void> sendEventNotification({
    required String eventId,
    required String eventName,
    required String userId,
  }) async {
    // This would typically be called from your backend
    // For now, we'll just show a local notification as an example
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'event_notifications',
          'Event Notifications',
          channelDescription: 'Notifications for events',
          importance: Importance.high,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      eventId.hashCode,
      'New Event Available',
      'Check out the new event: $eventName',
      details,
      payload: 'event:$eventId',
    );
  }

  static Future<void> sendCommentNotification({
    required String postId,
    required String commenterName,
    required String userId,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'comment_notifications',
          'Comment Notifications',
          channelDescription: 'Notifications for comments',
          importance: Importance.high,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      postId.hashCode,
      'New Comment',
      '$commenterName commented on your post',
      details,
      payload: 'comment:$postId',
    );
  }

  static Future<void> sendLikeNotification({
    required String postId,
    required String likerName,
    required String userId,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'like_notifications',
          'Like Notifications',
          channelDescription: 'Notifications for likes',
          importance: Importance.high,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      postId.hashCode,
      'New Like',
      '$likerName liked your post',
      details,
      payload: 'like:$postId',
    );
  }

  static Future<void> sendFollowNotification({
    required String followerName,
    required String userId,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'follow_notifications',
          'Follow Notifications',
          channelDescription: 'Notifications for follows',
          importance: Importance.high,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      userId.hashCode,
      'New Follower',
      '$followerName started following you',
      details,
      payload: 'follow:$userId',
    );
  }
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
  print('Handling a background message: ${message.messageId}');
}

// Notification settings provider
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((
      ref,
    ) {
      return NotificationSettingsNotifier();
    });

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier() : super(const NotificationSettings());

  void toggleEventNotifications(bool enabled) {
    state = state.copyWith(eventNotifications: enabled);
  }

  void toggleCommentNotifications(bool enabled) {
    state = state.copyWith(commentNotifications: enabled);
  }

  void toggleLikeNotifications(bool enabled) {
    state = state.copyWith(likeNotifications: enabled);
  }

  void toggleFollowNotifications(bool enabled) {
    state = state.copyWith(followNotifications: enabled);
  }

  void togglePushNotifications(bool enabled) {
    state = state.copyWith(pushNotifications: enabled);
  }
}

class NotificationSettings {
  final bool pushNotifications;
  final bool eventNotifications;
  final bool commentNotifications;
  final bool likeNotifications;
  final bool followNotifications;

  const NotificationSettings({
    this.pushNotifications = true,
    this.eventNotifications = true,
    this.commentNotifications = true,
    this.likeNotifications = true,
    this.followNotifications = true,
  });

  NotificationSettings copyWith({
    bool? pushNotifications,
    bool? eventNotifications,
    bool? commentNotifications,
    bool? likeNotifications,
    bool? followNotifications,
  }) {
    return NotificationSettings(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      eventNotifications: eventNotifications ?? this.eventNotifications,
      commentNotifications: commentNotifications ?? this.commentNotifications,
      likeNotifications: likeNotifications ?? this.likeNotifications,
      followNotifications: followNotifications ?? this.followNotifications,
    );
  }
}

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive push notifications'),
            value: settings.pushNotifications,
            onChanged: notifier.togglePushNotifications,
          ),
          SwitchListTile(
            title: const Text('Event Notifications'),
            subtitle: const Text('Get notified about new events'),
            value: settings.eventNotifications,
            onChanged: settings.pushNotifications
                ? notifier.toggleEventNotifications
                : null,
          ),
          SwitchListTile(
            title: const Text('Comment Notifications'),
            subtitle: const Text('Get notified about comments on your posts'),
            value: settings.commentNotifications,
            onChanged: settings.pushNotifications
                ? notifier.toggleCommentNotifications
                : null,
          ),
          SwitchListTile(
            title: const Text('Like Notifications'),
            subtitle: const Text('Get notified when someone likes your posts'),
            value: settings.likeNotifications,
            onChanged: settings.pushNotifications
                ? notifier.toggleLikeNotifications
                : null,
          ),
          SwitchListTile(
            title: const Text('Follow Notifications'),
            subtitle: const Text('Get notified when someone follows you'),
            value: settings.followNotifications,
            onChanged: settings.pushNotifications
                ? notifier.toggleFollowNotifications
                : null,
          ),
        ],
      ),
    );
  }
}

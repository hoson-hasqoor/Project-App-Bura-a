import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Request permissions
    await _requestPermission();

    // 2. Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        debugPrint('Notification tapped: ${details.payload}');
      },
    );

    // 3. Configure FCM listeners
    FirebaseMessaging.onMessage.listen(handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // 4. Save token to Firestore
    await _saveTokenToFirestore();

    // 5. Listen to token refresh
    _firebaseMessaging.onTokenRefresh.listen(_saveTokenToFirestore);

    // 6. Listen to Firestore permissions for real-time alerts
    _listenToPermissions();

    // 7. Listen for Accepted Requests (Shared Profiles)
    _listenToSharedProfiles();

    _isInitialized = true;
    debugPrint('Notification Service Initialized');
  }

  StreamSubscription? _permissionSubscription;

  /// Listen to new permission requests in real-time
  void _listenToPermissions() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    debugPrint('Starting permission listener for user: ${user.uid}');

    _permissionSubscription?.cancel();
    _permissionSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('permissions')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              // New request came in!
              final data = change.doc.data();
              if (data != null) {
                // Check if it's a recent request (to avoid spamming on restart)
                final createdAt = (data['created_at'] as Timestamp?)?.toDate();
                if (createdAt != null &&
                    DateTime.now().difference(createdAt).inMinutes < 5) {
                  showNewRequestNotification(
                    data['requester_name'] ?? 'مستخدم',
                    data['requester_email'] ?? '',
                  );
                }
              }
            }
          }
        });
  }

  StreamSubscription? _sharedProfileSubscription;

  /// Listen to new shared profiles (when someone accepts your request)
  void _listenToSharedProfiles() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _sharedProfileSubscription?.cancel();
    _sharedProfileSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('shared_profiles')
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data();
              if (data != null) {
                final sharedAt = (data['shared_at'] as Timestamp?)?.toDate();
                if (sharedAt != null &&
                    DateTime.now().difference(sharedAt).inMinutes < 5) {
                  showAccessGrantedNotification(
                    data['target_user_name'] ?? 'مستخدم',
                  );
                }
              }
            }
          }
        });
  }

  void stopListening() {
    _permissionSubscription?.cancel();
    _sharedProfileSubscription?.cancel();
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');
  }

  /// Save FCM token to user's Firestore document
  Future<void> _saveTokenToFirestore([String? token]) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      String? fcmToken = token ?? await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
              'fcm_token': fcmToken,
              'last_token_update': FieldValue.serverTimestamp(),
            });
        debugPrint('FCM Token saved: $fcmToken');
      }
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  /// Handle messages received in foreground
  Future<void> handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Got a message whilst in the foreground!');
    debugPrint('Message data: ${message.data}');

    if (message.notification != null) {
      debugPrint(
        'Message also contained a notification: ${message.notification}',
      );

      // Show local notification
      showLocalNotification(message);
    }
  }

  /// Show notification for new permission request
  Future<void> showNewRequestNotification(String name, String email) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'permission_requests',
          'Permission Requests',
          channelDescription:
              'Notifications for new medical record access requests',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond, // Unique ID
      'طلب وصول جديد',
      'طلب $name ($email) الوصول إلى سجلك الطبي.',
      platformChannelSpecifics,
      payload: 'permission_request',
    );
  }

  /// Show notification when request is accepted
  Future<void> showAccessGrantedNotification(String targetName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'permission_updates',
          'Permission Updates',
          channelDescription: 'Notifications when your requests are accepted',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      'تم قبول الطلب ✅',
      'وافق $targetName على طلب الوصول الخاص بك.',
      platformChannelSpecifics,
      payload: 'access_granted',
    );
  }

  /// Show local notification
  Future<void> showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel', // channel Id
            'High Importance Notifications', // channel Name
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data['type'],
      );
    }
  }
}

// Top-level background handler
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  // If you are using other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp();

  debugPrint("Handling a background message: ${message.messageId}");
}

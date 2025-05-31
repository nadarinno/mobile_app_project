import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile_app_project/Logic/NotificationModel.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  await Firebase.initializeApp();

  final data = message.data;
  final notification = message.notification;

  final notificationModel = NotificationModel(
    id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    type: data['type'] ?? 'new_product',
    productName: notification?.title ?? data['productName'] ?? 'Unknown',
    message: notification?.body ?? data['message'] ?? 'Notification received',
    timestamp: DateTime.now(),
    read: false,
  );

  print('NotificationModel created: id=${notificationModel.id}, type=${notificationModel.type}, productName=${notificationModel.productName}');

  String? userId = data['userId'];
  if (userId != null && userId.isNotEmpty) {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationModel.id.toString())
          .set(notificationModel.toFirestore());
      print('Notification saved to Firestore at users/$userId/notifications/${notificationModel.id}');
    } catch (e, st) {
      print('Error saving notification to Firestore: $e');
      print(st);
    }
  } else {
    print('No valid userId provided in FCM data. Skipping Firestore save.');
  }

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

  try {
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    print('flutter_local_notifications initialized');
  } catch (e) {
    print('Initialization failed: $e');
    return;
  }

  // Create notification channel for Android
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Used for important notifications.',
    importance: Importance.max,
  );

  final androidPlugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  if (androidPlugin != null) {
    await androidPlugin.createNotificationChannel(channel);
    print('Notification channel created: ${channel.id}');
  } else {
    print('AndroidFlutterLocalNotificationsPlugin not available.');
    return;
  }

  final androidDetails = AndroidNotificationDetails(
    channel.id,
    channel.name,
    channelDescription: channel.description,
    importance: Importance.max,
    priority: Priority.high,
    styleInformation: const DefaultStyleInformation(true, true),
  );
  final platformDetails = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    notificationModel.id,
    notificationModel.type == 'order_update' ? 'Order Update' : 'New Product Added',
    notificationModel.message,
    platformDetails,
    payload: notificationModel.productName,
  );

  print('Local notification shown: id=${notificationModel.id}');
}


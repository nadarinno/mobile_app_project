import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile_app_project/Logic/NotificationModel.dart';

class NotificationController {
  final List<NotificationModel> notifications = [];
  final Map<int, AnimationController> animationControllers = {};
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Stream<QuerySnapshot>? _productsStream;
  Stream<QuerySnapshot>? _ordersStream;

  final TickerProvider vsync;
  bool _isNotificationsInitialized = false;
  String? _cachedUserId;

  NotificationController({required this.vsync}) {
    try {
      _productsStream = FirebaseFirestore.instance.collection('products').snapshots();
      _ordersStream = FirebaseFirestore.instance.collection('orders').snapshots();
    } catch (e, stackTrace) {
      print('Error initializing streams: $e');
      print(stackTrace);
    }
  }

  Future<void> initialize() async {
    try {
      print('Initializing NotificationController');
      _cachedUserId = FirebaseAuth.instance.currentUser?.uid;
      await _initializeLocalNotifications();
      await _setupFCM();
      _listenToFirestoreChanges();
      print('NotificationController initialized');
    } catch (e, stackTrace) {
      print('Error initializing NotificationController: $e');
      print(stackTrace);
    }
  }

  Future<void> _initializeLocalNotifications() async {
    try {
      const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('Foreground notification response: ${response.payload}');
        },
      );

      // Create notification channels once
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'order_update_channel',
            'Order Update Notifications',
            description: 'Notifications for order status updates',
            importance: Importance.max,
          ),
        );
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'new_product_channel',
            'New Product Notifications',
            description: 'Notifications for new products',
            importance: Importance.max,
          ),
        );
        print('Notification channels created');
      } else {
        print('AndroidFlutterLocalNotificationsPlugin not available for channel creation.');
      }

      _isNotificationsInitialized = true;
      print('Local notifications initialized successfully');
    } catch (e, stackTrace) {
      print('Error initializing local notifications: $e');
      print(stackTrace);
      throw e;
    }
  }

  Future<void> _showLocalNotification(NotificationModel notification) async {
    if (!_isNotificationsInitialized) {
      print('Local notifications not initialized yet, skipping show');
      return;
    }
    try {
      final channelId = notification.type == 'order_update'
          ? 'order_update_channel'
          : 'new_product_channel';
      final channelName = notification.type == 'order_update'
          ? 'Order Update Notifications'
          : 'New Product Notifications';
      final channelDescription = notification.type == 'order_update'
          ? 'Notifications for order status updates'
          : 'Notifications for new products';

      final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
      );
      final platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

      await _flutterLocalNotificationsPlugin.show(
        notification.id,
        notification.type == 'order_update' ? 'Order Update' : 'New Product Added',
        notification.message,
        platformChannelSpecifics,
        payload: notification.productName,
      );
      print('Local notification shown: id=${notification.id}, type=${notification.type}');
    } catch (e, stackTrace) {
      print('Error showing local notification: $e');
      print(stackTrace);
    }
  }

  Future<void> _setupFCM() async {
    try {
      await FirebaseMessaging.instance.requestPermission();

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        try {
          final notification = NotificationModel(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            type: message.data['type'] ?? 'new_product',
            productName: message.notification?.title ?? message.data['productName'] ?? 'Unknown',
            message: message.notification?.body ?? message.data['message'] ?? 'Notification received',
            timestamp: DateTime.now(),
            read: false,
          );
          notifications.insert(0, notification);
          _initAnimationController(notification.id);
          _showLocalNotification(notification);

          final userId = _cachedUserId;
          if (userId != null) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('notifications')
                .doc(notification.id.toString())
                .set(notification.toFirestore())
                .catchError((e) => print('Error saving FCM notification: $e'));
          }
        } catch (e, stackTrace) {
          print('Error handling FCM message: $e');
          print(stackTrace);
        }
      });

      final userId = _cachedUserId;
      if (userId != null) {
        await FirebaseMessaging.instance.subscribeToTopic('order_updates_$userId');
      }
      await FirebaseMessaging.instance.subscribeToTopic('new_products');
      print('FCM setup complete');
    } catch (e, stackTrace) {
      print('Error setting up FCM: $e');
      print(stackTrace);
    }
  }

  void _listenToFirestoreChanges() {
    final userId = _cachedUserId;
    if (userId == null) {
      print('No authenticated user, skipping Firestore listeners');
      return;
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .snapshots()
        .listen(
          (snapshot) {
        try {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final notification = NotificationModel.fromFirestore(
                  change.doc.data() as Map<String, dynamic>, change.doc.id);
              notifications.insert(0, notification);
              _initAnimationController(notification.id);
              _showLocalNotification(notification);
            }
          }
        } catch (e, stackTrace) {
          print('Error processing notifications snapshot: $e');
          print(stackTrace);
        }
      },
      onError: (error) {
        print('Error listening to notifications: $error');
      },
    );

    _productsStream?.listen(
          (snapshot) {
        try {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data() as Map<String, dynamic>;
              final notification = NotificationModel(
                id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                type: 'new_product',
                productName: data['name'] ?? 'New Product',
                message: 'New product added: ${data['name'] ?? 'Unknown'}',
                timestamp: DateTime.now(),
                read: false,
              );
              notifications.insert(0, notification);
              _initAnimationController(notification.id);
              _showLocalNotification(notification);

              FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('notifications')
                  .doc(notification.id.toString())
                  .set(notification.toFirestore())
                  .catchError((e) => print('Error saving product notification: $e'));
            }
          }
        } catch (e, stackTrace) {
          print('Error processing products snapshot: $e');
          print(stackTrace);
        }
      },
      onError: (error) {
        print('Error listening to products: $error');
      },
    );

    _ordersStream?.listen(
          (snapshot) {
        try {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.modified) {
              final data = change.doc.data() as Map<String, dynamic>;
              final orderId = change.doc.id;
              final status = data['status'] ?? 'unknown';
              final productName = data['productName'] ?? 'Order #$orderId';
              final customerId = data['customerId'];

              if (userId == customerId) {
                final notification = NotificationModel(
                  id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                  type: 'order_update',
                  productName: productName,
                  message: 'Your order #$orderId has been updated to: $status',
                  timestamp: DateTime.now(),
                  read: false,
                );

                notifications.insert(0, notification);
                _initAnimationController(notification.id);
                _showLocalNotification(notification);

                FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('notifications')
                    .doc(notification.id.toString())
                    .set(notification.toFirestore())
                    .catchError((e) => print('Error saving order notification: $e'));
              }
            }
          }
        } catch (e, stackTrace) {
          print('Error processing orders snapshot: $e');
          print(stackTrace);
        }
      },
      onError: (error) {
        print('Error listening to orders: $error');
      },
    );
  }

  void _initAnimationController(int id, {int delay = 0}) {
    try {
      if (animationControllers.containsKey(id)) return; // prevent duplicate controllers

      final controller = AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 300),
      );
      animationControllers[id] = controller;
      Future.delayed(Duration(milliseconds: delay), () {
        if (!controller.isAnimating && !controller.isCompleted) {
          controller.forward();
        }
      });
    } catch (e, stackTrace) {
      print('Error initializing animation controller: $e');
      print(stackTrace);
    }
  }

  void markAsRead(int id) {
    try {
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        notifications[index] = NotificationModel(
          id: notifications[index].id,
          type: notifications[index].type,
          productName: notifications[index].productName,
          message: notifications[index].message,
          timestamp: notifications[index].timestamp,
          read: true,
        );
        final userId = _cachedUserId;
        if (userId != null) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('notifications')
              .doc(id.toString())
              .update({'read': true}).catchError((e) {
            print('Error updating notification read status: $e');
          });
        }
      }
    } catch (e, stackTrace) {
      print('Error marking notification as read: $e');
      print(stackTrace);
    }
  }

  Future<void> markAllAsRead() async {
    final userId = _cachedUserId;
    if (userId == null) {
      print('No authenticated user, cannot mark all as read');
      return;
    }

    try {
      final batch = FirebaseFirestore.instance.batch();

      for (var notification in notifications) {
        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .doc(notification.id.toString());

        batch.update(docRef, {'read': true});
      }

      await batch.commit();

      for (int i = 0; i < notifications.length; i++) {
        notifications[i] = NotificationModel(
          id: notifications[i].id,
          type: notifications[i].type,
          productName: notifications[i].productName,
          message: notifications[i].message,
          timestamp: notifications[i].timestamp,
          read: true,
        );
      }
      print('All notifications marked as read');
    } catch (e, stackTrace) {
      print('Error marking all notifications as read: $e');
      print(stackTrace);
    }
  }

  String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void dispose() {
    for (var controller in animationControllers.values) {
      controller.dispose();
    }
    animationControllers.clear();
  }
}



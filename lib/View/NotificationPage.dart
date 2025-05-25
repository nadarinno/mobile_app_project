import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mobile_app_project/Controller/NotificationController.dart';
import 'package:mobile_app_project/Logic/NotificationModel.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with TickerProviderStateMixin {
  NotificationController? _controller;

  @override
  void initState() {
    super.initState();
    print('initState: Initializing _controller');
    _controller = NotificationController(vsync: this);
    _controller!.initialize().catchError((e) {
      print('initState: Error initializing _controller: $e');
    });
    print('initState: _controller initialized');
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _viewProduct(String productName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing $productName details'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: const Color(0xFF561C24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load notifications'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _controller = NotificationController(vsync: this);
                    _controller!.initialize();
                  });
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_controller!.notifications.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: const Center(child: Text('No notifications available')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: _controller!.notifications.length,
        itemBuilder: (context, index) {
          final notification = _controller!.notifications[index];
          final controller = _controller!.animationControllers[notification.id];

          return SlideTransition(
            position: controller != null
                ? Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeOutQuart,
            ))
                : const AlwaysStoppedAnimation(Offset.zero),
            child: Opacity(
              opacity: controller?.value ?? 1,
              child: _NotificationCard(
                notification: notification,
                onMarkAsRead: () {
                  setState(() {
                    _controller!.markAsRead(notification.id);
                    _controller!.animationControllers.remove(notification.id)?.dispose();
                  });
                },
                onViewProduct: () => _viewProduct(notification.productName),
                timeAgo: _controller!.formatTimestamp(notification.timestamp),
              ),
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Notifications',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF561C24),
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _controller!.markAllAsRead();
              _controller!.animationControllers.clear();
            });
          },
          child: const Text(
            'Mark all as read',
            style: TextStyle(color: Color(0xFF561C24)),
          ),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onMarkAsRead;
  final VoidCallback onViewProduct;
  final String timeAgo;

  const _NotificationCard({
    required this.notification,
    required this.onMarkAsRead,
    required this.onViewProduct,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = notification.read;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: !isRead ? onMarkAsRead : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF561C24).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_shipping_outlined,
                        color: Color(0xFF561C24),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.message,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.productName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF561C24),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF561C24),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    TextButton(
                      onPressed: onViewProduct,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'VIEW',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF561C24),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}










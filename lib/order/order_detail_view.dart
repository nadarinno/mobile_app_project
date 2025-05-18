import 'package:flutter/material.dart';

class OrderDetailView extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailView({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(order['name']),
        backgroundColor: const Color(0xFFE5E1DA),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${order['id']}',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Status: ${order['status']}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Date: ${order['date']}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Total Price: \$${order['price']}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text('Details:',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(order['details'], style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFE5E1DA),
    );
  }
}

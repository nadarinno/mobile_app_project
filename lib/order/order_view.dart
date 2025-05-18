// import 'package:flutter/material.dart';
// import 'order_management.dart';
// import "package:mobile_app_project/search/product_card.dart";
// import 'order_detail_view.dart';
//
// class OrderManagementPage extends StatefulWidget {
//   const OrderManagementPage({super.key});
//
//   @override
//   State<OrderManagementPage> createState() => _OrderManagementPageState();
// }
//
// class _OrderManagementPageState extends State<OrderManagementPage> {
//   static const Color burgundy = Color(0xFF561C24);
//   static const Color lightBurgundy = Color(0xFFFFFDF6);
//   static const Color beige = Color(0xFFE5E1DA);
//
//   final List<Map<String, dynamic>> orders = [
//     {
//       'id': '#1234',
//       'name': 'Order 1',
//       'status': 'Pending',
//       'date': '2025-05-17',
//       'price': 149.97,
//       'details': 'This order includes 3 products.',
//       'products': [
//         {
//           'productName': 'Product A',
//           'price': 49.99,
//           'imagePath': 'assets/images/product_a.png',
//           'isSaved': false,
//         },
//         {
//           'productName': 'Product B',
//           'price': 59.99,
//           'imagePath': 'assets/images/product_b.png',
//           'isSaved': true,
//         },
//       ],
//     },
//     {
//       'id': '#1235',
//       'name': 'Order 2',
//       'status': 'Delivered',
//       'date': '2025-05-16',
//       'price': 79.99,
//       'details': 'This is the detail of Order 2',
//       'products': [
//         {
//           'productName': 'Product C',
//           'price': 39.99,
//           'imagePath': 'assets/images/product_c.png',
//           'isSaved': false,
//         },
//       ],
//     },
//   ];
//
//   void _updateOrderStatus(int index, String newStatus) {
//     setState(() {
//       orders[index]['status'] = newStatus;
//     });
//   }
//
//   void _navigateToOrderDetails(Map<String, dynamic> order) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => OrderDetailView(order: order),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: beige,
//       appBar: AppBar(
//         backgroundColor: beige,
//         centerTitle: true,
//         title: const Text(
//           'Order Management',
//           style: TextStyle(color: burgundy, fontWeight: FontWeight.bold),
//         ),
//         iconTheme: const IconThemeData(color: burgundy),
//       ),
//       body: ListView.builder(
//         itemCount: orders.length,
//         itemBuilder: (context, index) {
//           final order = orders[index];
//           final products = order['products'] ?? [];
//
//           return GestureDetector(
//             onTap: () => _navigateToOrderDetails(order),
//             child: Card(
//               color: lightBurgundy,
//               margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 side: BorderSide(color: burgundy.withOpacity(0.3)),
//               ),
//               child: Column(
//                 children: [
//                   ListTile(
//                     title: Text(order['name'],
//                         style: TextStyle(
//                             color: burgundy, fontWeight: FontWeight.bold)),
//                     subtitle: Text('Status: ${order['status']} - ${order['date']}',
//                         style: TextStyle(color: burgundy)),
//                     trailing: Text('\$${order['price']}',
//                         style: TextStyle(
//                             color: burgundy, fontWeight: FontWeight.bold)),
//                   ),
//                   // عرض المنتجات داخل البطاقة:
//                   SizedBox(
//                     height: 180,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: products.length,
//                       itemBuilder: (context, productIndex) {
//                         final product = products[productIndex];
//                         return Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: ProductCard(
//                             productName: product['productName'],
//                             price: product['price'],
//                             imagePath: product['imagePath'],
//                             isSaved: product['isSaved'],
//                             onSavePressed: () {
//                               setState(() {
//                                 product['isSaved'] = !product['isSaved'];
//                               });
//                             },
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

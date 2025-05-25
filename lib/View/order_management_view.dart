// views/order_management_page.dart
import 'package:flutter/material.dart';
import 'package:mobile_app_project/Controller/order_management_controller.dart';
import 'package:mobile_app_project/View/product_cart_view.dart';


class OrderManagementPage extends StatefulWidget {
  const OrderManagementPage({super.key});

  @override
  State<OrderManagementPage> createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  static const Color burgundy = Color(0xFF561C24);
  static const Color lightBurgundy = Color(0xFFFFFDF6);
  static const Color beige = Color(0xFFE5E1DA);
  final OrderManagementController _controller = OrderManagementController();

  @override
  void initState() {
    super.initState();
    _controller.fetchOrders().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: beige,
        centerTitle: true,
        title: const Text(
          'Order Management',
          style: TextStyle(color: burgundy, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: burgundy),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: true,
                fillColor: lightBurgundy,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              value: _controller.selectedSort,
              items: _controller.sortOptions
                  .map((sortOption) => DropdownMenuItem<String>(
                value: sortOption,
                child: Text(sortOption, style: TextStyle(color: burgundy)),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _controller.setSortOption(value);
                  });
                }
              },
              dropdownColor: lightBurgundy,
              style: TextStyle(color: burgundy),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _controller.orders.length,
              itemBuilder: (context, index) {
                final order = _controller.orders[index];
                return Card(
                  color: lightBurgundy,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: burgundy.withOpacity(0.3)),
                  ),
                  child: ListTile(
                    title: Text(
                      'Order ${index + 1}',
                      style: TextStyle(
                          color: burgundy, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${order['date'].toString().split(' ')[0]}',
                            style: TextStyle(color: burgundy)),
                        DropdownButton<String>(
                          value: order['status'] != null &&
                              ['Pending', 'Delivered', 'Cancelled']
                                  .contains(order['status'])
                              ? order['status']
                              : 'Pending',
                          items: ['Pending', 'Delivered', 'Cancelled']
                              .map((status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status,
                                  style: TextStyle(color: burgundy)),
                            );
                          }).toList(),
                          onChanged: (newStatus) async {
                            if (newStatus != null) {
                              await _controller.updateOrderStatus(
                                  index, newStatus);
                              setState(() {});
                            }
                          },
                          dropdownColor: lightBurgundy,
                          style: TextStyle(color: burgundy),
                          underline: const SizedBox(),
                        ),
                      ],
                    ),
                    trailing: Text('\$${order['price']}',
                        style: TextStyle(
                            color: burgundy, fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailView(
                            order: order,
                            orderIndex: index,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class OrderDetailView extends StatefulWidget {
  final Map<String, dynamic> order;
  final int orderIndex;

  const OrderDetailView(
      {super.key, required this.order, required this.orderIndex});

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  static const Color burgundy = Color(0xFF561C24);
  static const Color lightBurgundy = Color(0xFFFFFDF6);
  static const Color beige = Color(0xFFE5E1DA);
  final OrderManagementController _controller = OrderManagementController();

  late Future<List<Map<String, dynamic>>> productsFuture;

  @override
  void initState() {
    super.initState();
    productsFuture = _controller
        .fetchProductDetails(List<String>.from(widget.order['productsIds'] ?? []));
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      color: lightBurgundy,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: burgundy),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 14, color: burgundy),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Order ${widget.orderIndex + 1}'),
        backgroundColor: beige,
        iconTheme: const IconThemeData(color: burgundy),
      ),
      backgroundColor: beige,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildInfoCard('Order ID', order['id']),
            _buildInfoCard('Status', order['status']),
            _buildInfoCard('Date', order['date'].toString().split(' ')[0]),
            _buildInfoCard('Price', '\$${order['price'].toString()}'),
            _buildInfoCard('Details', order['details']),
            const SizedBox(height: 16),
            const Text(
              'Ordered Products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: burgundy,
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('فشل في تحميل المنتجات'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('لا توجد منتجات'));
                } else {
                  final products = snapshot.data!;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.65,
                    ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCardView(
                        productName: product['productName'],
                        price: product['price'],
                        imageUrl: product['imageUrl'],
                        initialIsSaved: product['isSaved'] ?? false,
                        productId: product['id'],
                        showSaveButton: false,
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
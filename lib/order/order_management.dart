import 'package:flutter/material.dart';
import "package:mobile_app_project/search/product_card.dart";
class OrderManagementPage extends StatefulWidget {
  const OrderManagementPage({super.key});

  @override
  State<OrderManagementPage> createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  static const Color burgundy = Color(0xFF561C24);
  static const Color lightBurgundy = Color(0xFFFFFDF6);
  static const Color beige = Color(0xFFE5E1DA);

  final List<Map<String, dynamic>> orders = [
    {'id': '#1234', 'name': 'Order 1', 'status': 'Pending', 'date': '2025-05-17', 'price': 49.99, 'details': 'This is the detail of Order 1'},
    {'id': '#1235', 'name': 'Order 2', 'status': 'Delivered', 'date': '2025-05-16', 'price': 79.99, 'details': 'This is the detail of Order 2'},
    {'id': '#1236', 'name': 'Order 3', 'status': 'Delivered', 'date': '2025-05-15', 'price': 29.99, 'details': 'This is the detail of Order 3'},
    {'id': '#1237', 'name': 'Order 4', 'status': 'Cancelled', 'date': '2025-05-14', 'price': 99.99, 'details': 'This is the detail of Order 4'},
  ];

  List<String> sortOptions = [
    'Date (Oldest to Newest)',
    'Date (Newest to Oldest)',
    'Price (High to Low)',
    'Price (Low to High)',
    'Status',
  ];

  // هنا خليت القيمة الافتراضية تطابق القائمة
  String selectedSort = 'Date (Oldest to Newest)';

  void _sortOrders() {
    setState(() {
      switch (selectedSort) {
        case 'Date (Oldest to Newest)':
          orders.sort((a, b) => a['date'].compareTo(b['date']));
          break;
        case 'Date (Newest to Oldest)':
          orders.sort((a, b) => b['date'].compareTo(a['date']));
          break;
        case 'Price (High to Low)':
          orders.sort((a, b) => b['price'].compareTo(a['price']));
          break;
        case 'Price (Low to High)':
          orders.sort((a, b) => a['price'].compareTo(b['price']));
          break;
        case 'Status':
          orders.sort((a, b) => a['status'].compareTo(b['status']));
          break;
      }
    });
  }

  void _updateOrderStatus(int index, String newStatus) {
    setState(() {
      orders[index]['status'] = newStatus;
    });
  }

  void _navigateToOrderDetails(Map<String, dynamic> order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailView(order: order),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _sortOrders();
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
              value: selectedSort,
              items: sortOptions
                  .map((sortOption) => DropdownMenuItem<String>(
                value: sortOption,
                child: Text(sortOption, style: TextStyle(color: burgundy)),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedSort = value!;
                  _sortOrders();
                });
              },
              dropdownColor: lightBurgundy,
              style: TextStyle(color: burgundy),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  color: lightBurgundy,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: burgundy.withOpacity(0.3)),
                  ),
                  child: ListTile(
                    title: Text(order['name'], style: TextStyle(color: burgundy, fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${order['date']}', style: TextStyle(color: burgundy)),
                        DropdownButton<String>(
                          value: order['status'],
                          items: ['Pending', 'Delivered', 'Cancelled']
                              .map((status) => DropdownMenuItem<String>(
                            value: status,
                            child: Text(status, style: TextStyle(color: burgundy)),
                          ))
                              .toList(),
                          onChanged: (newStatus) {
                            if (newStatus != null) {
                              _updateOrderStatus(index, newStatus);
                            }
                          },
                          dropdownColor: lightBurgundy,
                          style: TextStyle(color: burgundy),
                          underline: const SizedBox(),
                        ),
                      ],
                    ),
                    trailing: Text('\$${order['price']}', style: TextStyle(color: burgundy, fontWeight: FontWeight.bold)),
                    onTap: () {
                      _navigateToOrderDetails(order);
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

class OrderDetailView extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailView({super.key, required this.order});

  Widget _buildInfoCard(String title, String content) {
    return Card(
      color: const Color(0xFFFFFDF6),
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
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF561C24))),
            const SizedBox(height: 8),
            Text(content,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF561C24))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List products = order['products'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(order['name']),
        backgroundColor: const Color(0xFFE5E1DA),
      ),
      backgroundColor: const Color(0xFFE5E1DA),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildInfoCard('Order ID', order['id']),
            _buildInfoCard('Status', order['status']),
            _buildInfoCard('Date', order['date']),
            _buildInfoCard('Price', '\$${order['price'].toStringAsFixed(2)}'),
            _buildInfoCard('Details', order['details']),
            const SizedBox(height: 16),

            Text(
              'Ordered Products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF561C24),
              ),
            ),
            const SizedBox(height: 12),

            // عرض قائمة المنتجات
            ...products.map((product) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ProductCard(
                  productName: product['productName'],
                  price: product['price'],
                  imagePath: product['imagePath'],
                  isSaved: product['isSaved'] ?? false,
                  onSavePressed: () {
                    // منطق حفظ أو إزالة المنتج من المفضلة
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
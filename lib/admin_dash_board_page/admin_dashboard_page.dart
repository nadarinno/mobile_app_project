import 'package:flutter/material.dart';
import 'seller_detail_page.dart';

class AdminDashboardPage extends StatelessWidget {


  final List<Map<String, String>> sellers = [
    {
      'name': 'Rahaf Zawyani',
      'email': 'rahafzaw@gmail.com',
      'phone': '0592195413',
      'location': 'Nablus, Rafidia',
      'business': 'Clothing, Shoes, Accessories'
    },
    {
      'name': 'Kareem Ahmad',
      'email': 'kareem@gmail.com',
      'phone': '0592123456',
      'location': 'Tulkarm, Main Street',
      'business': 'Clothing, Shoes, Accessories'
    },
  ];

  static const Color beige = Color(0xFFE5E1DA);
  static const Color burgundy = Color(0xFF561C24);
  static const Color lightBurgundy = Color(0xFFFFFDF6);

  AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: beige,
        title: const Text(
          'Admin Dashboard',

          style: TextStyle( color:Color(0xFF561C24), fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        itemCount: sellers.length,
        itemBuilder: (context, index) {
          final seller = sellers[index];
          return Card(
            color: const Color(0xFFFFFDF6),
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: burgundy,
                child: Icon(Icons.store, color: Colors.white),
              ),
              title: Text(
                seller['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF561C24)),
              ),
              subtitle: Text(
                seller['business']!,
                style: const TextStyle(color: Color(0xFF561C24)),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SellerDetailPage(seller: seller),
                  ),
                );
              },

            ),
          );
        },
      ),
    );
  }
}
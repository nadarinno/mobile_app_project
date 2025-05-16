// searched_page.dart
import 'package:flutter/material.dart';
import 'product_card.dart'; // تأكد من استيراد ملف الـ `ProductCard` الصحيح

class SearchedPage extends StatelessWidget {
  final String searchQuery;
  static const Color burgundy = Color(0xFF561C24);
  static const Color lightBurgundy = Color(0xFFD9B6A3);
  static const Color beige = Color(0xFFE5E1DA);

  const SearchedPage({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: burgundy,
        title: Text(

          ' $searchQuery',
          style: const TextStyle(color: Color(0xFFFFFDF6), fontWeight: FontWeight.bold),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8, // عدد مؤقت لعرض النتائج
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (context, index) {
          return ProductCard(
            productName: '$searchQuery Item ${index + 1}',
            price: 29.99,
            imagePath: 'assets/images/cozyshoplogo.png',
            isSaved: false,
            onSavePressed: () {

            },
          );
        },
      ),
    );
  }
}

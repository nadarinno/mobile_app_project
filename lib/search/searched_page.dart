// searched_page.dart
import 'package:flutter/material.dart';
import 'product_card.dart';

class SearchedPage extends StatefulWidget {
  final String searchQuery;

  const SearchedPage({super.key, required this.searchQuery});

  @override
  State<SearchedPage> createState() => _SearchedPageState();
}

class _SearchedPageState extends State<SearchedPage> {
  static const Color burgundy = Color(0xFF561C24);
  static const Color beige = Color(0xFFE5E1DA);


  List<bool> savedStatus = List<bool>.filled(8, false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: beige,
        title: Text(
          ' ${widget.searchQuery}',
          style: const TextStyle(
              color: Color(0xFF561C24), fontWeight: FontWeight.bold),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (context, index) {
          return ProductCard(
            productName: '${widget.searchQuery} Item ${index + 1}',
            price: 29.99,
            imagePath: 'assets/images/cozyshoplogo.png',
            isSaved: savedStatus[index],
            priceColor: burgundy,
            favoriteActiveColor: burgundy,
            onSavePressed: () {
              setState(() {
                savedStatus[index] = !savedStatus[index];
              });
            },
          );
        },
      ),
    );
  }
}

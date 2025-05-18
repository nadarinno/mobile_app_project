// product_card.dart
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String productName;
  final double price;
  final String imagePath;
  final bool isSaved;
  final VoidCallback onSavePressed;
  final Color priceColor;
  final Color favoriteActiveColor;

  const ProductCard({
    super.key,
    required this.productName,
    required this.price,
    required this.imagePath,
    required this.isSaved,
    required this.onSavePressed,
    this.priceColor = const Color(0xFF561C24),
    this.favoriteActiveColor = const Color(0xFF561C24),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFFDF6),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) =>
                const Center(child: Icon(Icons.error)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              productName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '\$${price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                color: priceColor,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              icon: Icon(
                isSaved ? Icons.favorite : Icons.favorite_border,
                color: isSaved ? favoriteActiveColor : Colors.grey,
              ),
              onPressed: onSavePressed,
            ),
          ),
        ],
      ),
    );
  }
}

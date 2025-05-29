// views/product_card_view.dart
import 'package:flutter/material.dart';
import '../Controller/product_card_controller.dart';
import 'package:mobile_app_project/View/product_details_page.dart';

class ProductCardView extends StatefulWidget {
  final String productName;
  final double price;
  final String imageUrl;
  final bool initialIsSaved;
  final String productId;
  final Color priceColor;
  final Color favoriteActiveColor;
  final bool showSaveButton;

  const ProductCardView({
    super.key,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.initialIsSaved,
    required this.productId,
    this.priceColor = const Color(0xFF561C24),
    this.favoriteActiveColor = const Color(0xFF561C24),
    this.showSaveButton = true,
  });

  @override
  State<ProductCardView> createState() => _ProductCardViewState();
}

class _ProductCardViewState extends State<ProductCardView> {
  final ProductController _controller = ProductController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailsPage(productId: widget.productId),
        ),
      );
     },
     child: SizedBox(
     width: 180,
      child: Card(
        color: const Color(0xFFFFFDF6),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Text('Image upload failed',
                        style: TextStyle(color: Color(0xFF561C24))),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${widget.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.priceColor,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (widget.showSaveButton)
              Align(
                alignment: Alignment.bottomRight,
                child: StreamBuilder<bool>(
                  stream: _controller.isSaved(widget.productId),
                  initialData: widget.initialIsSaved,
                  builder: (context, snapshot) {
                    final isSaved = snapshot.data ?? false;
                    return IconButton(
                      icon: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        color: isSaved ? widget.favoriteActiveColor : Colors.grey,
                      ),
                      onPressed: () async {
                        await _controller.toggleSaved(
                          widget.productId,
                          isSaved,
                          context,
                          name: widget.productName,
                          price: widget.price,
                          imageUrl: widget.imageUrl,
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),

     ),
    );
  }

}

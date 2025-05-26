// views/products_view.dart
import 'package:flutter/material.dart';
import 'package:mobile_app_project/Controller/product_page_controller.dart';
import 'package:mobile_app_project/View/product_cart_view.dart';
import '../logic/product_logic.dart';

class ProductsView extends StatefulWidget {
  final String searchQuery;
  final String? categoryFilter;

  const ProductsView({
    Key? key,
    required this.searchQuery,
    this.categoryFilter,
  }) : super(key: key);

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  static const Color burgundy = Color(0xFF561C24);
  static const Color lightBurgundy = Color(0xFFFFFDF6);
  static const Color beige = Color(0xFFE5E1DA);
  final ProductsController _controller = ProductsController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: beige,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Products',
          style: TextStyle(
            color: burgundy,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(color: burgundy),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: StreamBuilder<List<Product>>(
          stream: _controller.getProducts(
            category: widget.categoryFilter,
            searchQuery: widget.searchQuery,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Failed to load products'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No products found'));
            }

            final products = snapshot.data!;

            return GridView.builder(
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return StreamBuilder<bool>(
                  stream: _controller.isSaved(product.id),
                  initialData: false,
                  builder: (context, savedSnapshot) {
                    final isSaved = savedSnapshot.data ?? false;
                    return ProductCardView(
                      productName: product.name,
                      price: product.price,
                      imageUrl: product.imageUrl,
                      initialIsSaved: isSaved,
                      productId: product.id,
                      showSaveButton: true,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
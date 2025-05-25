import 'package:flutter/material.dart';
import 'package:mobile_app_project/Controller/CartController.dart';

class CartPage extends StatelessWidget {
  final CartController controller;

  const CartPage({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.isLoading) {
          return Scaffold(
            backgroundColor: const Color(0xFFFFFDF6),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFFFDF6),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFFFDF6),
            elevation: 0,
            leading: const BackButton(color: Color(0xFF561C24)),
            title: const Text('Cart', style: TextStyle(color: Color(0xFF561C24))),
            actions: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Color(0xFF561C24)),
                onPressed: () {},
              ),
            ],
          ),
          body: SafeArea(
            child: StreamBuilder<List<CartItem>>(
              stream: controller.getCartItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Your cart is empty'),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF561C24),
                          ),
                          onPressed: () {},
                          child: const Text('Browse Products',
                              style: TextStyle(color: Color(0xFFFFFDF6))),
                        ),
                      ],
                    ),
                  );
                }

                final cartItems = snapshot.data!;

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            color: const Color(0xFFD0B8A8),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: screenWidth * 0.15,
                                    height: screenWidth * 0.15,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey[200],
                                    ),
                                    child: item.imagePath.isNotEmpty
                                        ? Image.network(
                                      item.imagePath,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                      const Icon(Icons.image,
                                          size: 30),
                                    )
                                        : const Icon(Icons.broken_image),
                                  ),
                                  SizedBox(width: screenWidth * 0.03),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                            '\$${item.price.toStringAsFixed(2)}'),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                            Icons.remove_circle_outline,
                                            color: Color(0xFF561C24),
                                            size: 20),
                                        onPressed: () => controller.updateQuantity(
                                            item.id, item.quantity - 1),
                                      ),
                                      Container(
                                        width: 24,
                                        alignment: Alignment.center,
                                        child: Text('${item.quantity}'),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline,
                                            color: Color(0xFF561C24), size: 20),
                                        onPressed: () => controller.updateQuantity(
                                            item.id, item.quantity + 1),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Color(0xFF561C24), size: 20),
                                    onPressed: () =>
                                        controller.removeItem(item.id),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD0B8A8),
                        border: Border(top: BorderSide(color: Colors.grey)),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: controller.selectAll,
                            onChanged: (value) =>
                                controller.toggleSelectAll(value),
                          ),
                          const Text('All'),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Total: \$${controller.calculateTotalPrice(cartItems).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${controller.calculateTotalItems(cartItems)} items',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          controller.isLoading
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(screenWidth * 0.25, 48),
                              backgroundColor: const Color(0xFF561C24),
                            ),
                            onPressed: () =>
                                controller.checkout(cartItems, context),
                            child: const Text(
                              'Checkout',
                              style: TextStyle(color: Color(0xFFFFFDF6)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:mobile_app_project/Controller/cart_controller.dart';
import 'package:mobile_app_project/Logic/cart_item_model.dart';
import 'package:provider/provider.dart';
import 'checkout_view.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final controller = Provider.of<CartController>(context);

    if (controller.isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFFFFFDF6),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFFFFDF6),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFDF6),
        elevation: 0,
        leading: BackButton(color: Color(0xFF561C24)),
        title: Text('Cart', style: TextStyle(color: Color(0xFF561C24))),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Color(0xFF561C24)),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<CartItem>>(
          stream: controller.cartItems,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Your cart is empty'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF561C24),
                      ),
                      onPressed: () {
                        // Navigate to Home tab in MainPage
                        // Assuming MainPage uses a Navigator or tab controller
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      child: Text(
                        'Browse Products',
                        style: TextStyle(color: Color(0xFFFFFDF6)),
                      ),
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
                        margin: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        color: Color(0xFFD0B8A8),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
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
                                      Icon(Icons.image, size: 30),
                                )
                                    : Icon(Icons.broken_image),
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(
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
                                    icon: Icon(
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
                                    icon: Icon(Icons.add_circle_outline,
                                        color: Color(0xFF561C24), size: 20),
                                    onPressed: () => controller.updateQuantity(
                                        item.id, item.quantity + 1),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.delete,
                                    color: Color(0xFF561C24), size: 20),
                                onPressed: () => controller.removeItem(item.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
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
                      Text('All'),
                      Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Total: \$${controller.getTotalPrice(cartItems).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${controller.getTotalItems(cartItems)} items',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(screenWidth * 0.25, 48),
                          backgroundColor: Color(0xFF561C24),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CheckoutView()),
                          );
                        },
                        child: Text(
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
      // Removed bottomNavigationBar to rely on MainPage's navigation
      // MainPage should handle tab navigation (Home, Search, Saved, Cart, Account)
    );
  }
}
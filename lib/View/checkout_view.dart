import 'package:flutter/material.dart';
import 'package:mobile_app_project/Controller/cart_controller.dart';
import 'package:mobile_app_project/Controller/checkout_controller.dart';
import 'package:mobile_app_project/Logic/cart_item_model.dart';
import 'package:provider/provider.dart';

class CheckoutView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final checkoutController = Provider.of<CheckoutController>(context);
    final cartController = Provider.of<CartController>(context);

    return Scaffold(
      backgroundColor: Color(0xFFFFFDF6),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFDF6),
        elevation: 0,
        leading: BackButton(color: Color(0xFF561C24)),
        title: Text('Checkout', style: TextStyle(color: Color(0xFF561C24))),
      ),
      body: SafeArea(
        child: StreamBuilder<List<CartItem>>(
          stream: cartController.cartItems,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('No items to checkout'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF561C24),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Back to Cart',
                        style: TextStyle(color: Color(0xFFFFFDF6)),
                      ),
                    ),
                  ],
                ),
              );
            }

            final cartItems = snapshot.data!;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shipping Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF561C24),
                      ),
                    ),
                    SizedBox(height: 16),
                    Form(
                      key: checkoutController.formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: checkoutController.nameController,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF561C24)),
                              ),
                              labelStyle: TextStyle(color: Color(0xFF561C24)),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            controller: checkoutController.addressController,
                            decoration: InputDecoration(
                              labelText: 'Shipping Address',
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF561C24)),
                              ),
                              labelStyle: TextStyle(color: Color(0xFF561C24)),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your address';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            controller: checkoutController.phoneController,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF561C24)),
                              ),
                              labelStyle: TextStyle(color: Color(0xFF561C24)),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF561C24),
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFD0B8A8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return ListTile(
                            leading: Container(
                              width: screenWidth * 0.1,
                              height: screenWidth * 0.1,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[200],
                              ),
                              child: item.imagePath.isNotEmpty &&
                                  (item.imagePath.startsWith('http') ||
                                      item.imagePath.startsWith('https'))
                                  ? Image.network(
                                item.imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                      'assets/images/cozyshoplogo.png',
                                      fit: BoxFit.cover,
                                    ),
                              )
                                  : Image.asset(
                                'assets/images/cozyshoplogo.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(item.name),
                            subtitle: Text(
                                '\$${item.price.toStringAsFixed(2)} x ${item.quantity}'),
                            trailing: Text(
                              '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFFD0B8A8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total (${cartController.getTotalItems(cartItems)} items)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\$${cartController.getTotalPrice(cartItems).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF561C24),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    checkoutController.isLoading
                        ? Center(child: CircularProgressIndicator())
                        : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(screenWidth, 48),
                          backgroundColor: Color(0xFF561C24),
                        ),
                        onPressed: () => checkoutController.confirmOrder(
                            context, cartItems),
                        child: Text(
                          'Confirm Order',
                          style: TextStyle(
                            color: Color(0xFFFFFDF6),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
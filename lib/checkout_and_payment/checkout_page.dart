import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CartPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CartItem {
  final String title;
  final double price;
  final String imagePath;
  int quantity;

  CartItem({
    required this.title,
    required this.price,
    required this.imagePath,
    this.quantity = 1,
  });
}

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> cartItems = List.generate(
    5,
        (index) => CartItem(
      title: 'Item ${index + 1}',
      price: (10 + index * 5).toDouble(),
      imagePath: 'assets/item${index + 1}.png',
    ),
  );

  bool selectAll = false;

  double get totalPrice {
    return cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);
  }

  int get totalItems {
    return cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  void incrementQuantity(int index) {
    setState(() {
      cartItems[index].quantity++;
    });
  }

  void decrementQuantity(int index) {
    setState(() {
      if (cartItems[index].quantity > 0) {
        cartItems[index].quantity--;
      }
    });
  }

  void removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  void toggleSelectAll(bool? value) {
    setState(() {
      selectAll = value ?? false;
      for (var item in cartItems) {
        item.quantity = selectAll ? 1 : 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFFFFDF6),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFDF6),
        elevation: 0,
        leading: BackButton(color:  Color(0xFF561C24)),
        title: Text('Cart', style: TextStyle(color: Color(0xFF561C24))),
        actions: [
          IconButton(
              icon: Icon(Icons.shopping_cart, color: Color(0xFF561C24)),
              onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: Color(0xFFD0B8A8),                    child: Padding(
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
                            child: Image.asset(
                              item.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.image, size: 30),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text('\$${item.price.toStringAsFixed(2)}'),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                Icon(Icons.remove_circle_outline, color: Color(0xFF561C24),size: 20),
                                onPressed: () => decrementQuantity(index),
                              ),
                              Container(
                                width: 24,
                                alignment: Alignment.center,
                                child: Text('${item.quantity}'),
                              ),
                              IconButton(
                                icon:
                                Icon(Icons.add_circle_outline, color: Color(0xFF561C24),size: 20),
                                onPressed: () => incrementQuantity(index),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.delete,
                                color: Color(0xFF561C24), size: 20),
                            onPressed: () => removeItem(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Color(0xFFD0B8A8),
                border: Border(top: BorderSide(color: Colors.grey)),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: selectAll,
                    onChanged: toggleSelectAll,
                  ),
                  Text('All'),
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total: \$${totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (totalItems > 0)
                        Text(
                          '$totalItems items',
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
                    onPressed: totalItems > 0 ? () {} : null,
                    child: Text(
                      'Checkout',
                      style: TextStyle(
                        color:Color(0xFFFFFDF6)
                      ),
                    ),
                  )
               ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFFFFFDF6),
        selectedItemColor: Color(0xFF561C24),
        unselectedItemColor: Color(0xFFD0B8A8),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home',backgroundColor: Color(0xFFFFFDF6)),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: 'Saved'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'Account'),
        ],
      ),
    );
  }
}

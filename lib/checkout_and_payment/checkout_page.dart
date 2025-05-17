import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
  final String id;
  final String name;
  final double price;
  final String imagePath;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    this.quantity = 1,
  });

  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return CartItem(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imagePath: data['images'] ?? '', // ✅ Firebase image URL (String)
      quantity: data['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'images': imagePath,
      'quantity': quantity,
    };
  }
}

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool selectAll = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  Stream<List<CartItem>> getCartItems() {
    return _firestore.collection('cart').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => CartItem.fromFirestore(doc)).toList());
  }

  Future<void> updateQuantity(String itemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await _firestore.collection('cart').doc(itemId).delete();
    } else {
      await _firestore
          .collection('cart')
          .doc(itemId)
          .update({'quantity': newQuantity});
    }
  }

  Future<void> removeItem(String itemId) async {
    await _firestore.collection('cart').doc(itemId).delete();
  }

  Future<void> toggleSelectAll(bool? value) async {
    setState(() {
      selectAll = value ?? false;
    });

    final snapshot = await _firestore.collection('cart').get();
    if (selectAll) {
      for (var doc in snapshot.docs) {
        await doc.reference.update({'quantity': 1});
      }
    } else {
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }
  }

  double calculateTotalPrice(List<CartItem> items) {
    return items.fold(0, (sum, item) => sum + item.price * item.quantity);
  }

  int calculateTotalItems(List<CartItem> items) {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  Future<void> checkout(List<CartItem> items) async {
    if (items.isEmpty) return;

    final batch = _firestore.batch();
    final ordersRef = _firestore.collection('orders').doc();

    batch.set(ordersRef, {
      'date': DateTime.now(),
      'items': items.map((item) => item.toMap()).toList(),
      'total': calculateTotalPrice(items),
    });

    for (var item in items) {
      batch.delete(_firestore.collection('cart').doc(item.id));
    }

    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order placed successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (isLoading) {
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
          stream: getCartItems(),
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
                      onPressed: () {},
                      child: Text('Browse Products',
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
                        margin:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text('\$${item.price.toStringAsFixed(2)}'),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove_circle_outline,
                                        color: Color(0xFF561C24), size: 20),
                                    onPressed: () => updateQuantity(
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
                                    onPressed: () => updateQuantity(
                                        item.id, item.quantity + 1),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.delete,
                                    color: Color(0xFF561C24), size: 20),
                                onPressed: () => removeItem(item.id),
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
                        onChanged: (value) => toggleSelectAll(value),
                      ),
                      Text('All'),
                      Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Total: \$${calculateTotalPrice(cartItems).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${calculateTotalItems(cartItems)} items',
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
                        onPressed: () => checkout(cartItems),
                        child: Text(
                          'Checkout',
                          style: TextStyle(color: Color(0xFFFFFDF6)),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFFFFFDF6),
        selectedItemColor: Color(0xFF561C24),
        unselectedItemColor: Color(0xFFD0B8A8),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
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

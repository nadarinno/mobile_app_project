import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProductDetailApp());
}

class ProductDetailApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProductDetailsPage(productId: '1'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProductDetailsPage extends StatefulWidget {
  final String productId;

  const ProductDetailsPage({required this.productId, Key? key}) : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int currentImageIndex = 0;
  bool isFavorite = false;
  bool isAddedToCart = false;
  bool showDescription = false;
  bool showReviews = false;
  String selectedColor = 'Black';
  String selectedSize = 'M';

  List<String> imagePaths = [];
  String productName = '';
  double productPrice = 0.0;
  String productDescription = '';
  List<String> productReviews = [];
  List<String> availableColors = [];
  List<String> availableSizes = [];
  String productId = '';

  bool isLoading = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchProductData();
  }

  Future<void> fetchProductData() async {
    try {
      print("Fetching product data...");
      DocumentSnapshot doc = await _firestore
          .collection('products')
          .doc('product${widget.productId}')
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print("Raw data from Firestore: $data");

        // Handle colors with better error checking
        List<String> colors = [];
        if (data['colors'] != null) {
          try {
            colors = (data['colors'] as List).map((item) => item.toString().trim()).toList();
          } catch (e) {
            print("Error parsing colors: $e");
            colors = ['Black', 'White']; // Default fallback
          }
        } else {
          colors = ['Black', 'White']; // Default fallback
        }

        setState(() {
          imagePaths = List<String>.from(data['images'] ?? []);
          productName = data['name'] ?? '';
          productPrice = (data['price'] ?? 0).toDouble();
          productDescription = data['description'] ?? '';
          productReviews = List<String>.from(data['reviews'] ?? []);
          availableColors = colors;
          availableSizes = List<String>.from(data['sizes'] ?? []);
          productId = doc.id;

          // Set initial selections only if lists are not empty
          if (availableColors.isNotEmpty) {
            selectedColor = availableColors[0];
          }
          if (availableSizes.isNotEmpty) {
            selectedSize = availableSizes[0];
          }

          isLoading = false;
          print("Available colors after setState: $availableColors");
        });
      } else {
        print("Document doesn't exist");
        setState(() {
          isLoading = false;
          availableColors = ['Black', 'White']; // Default fallback
        });
      }
    } catch (e) {
      print("Error fetching product data: $e");
      setState(() {
        isLoading = false;
        availableColors = ['Black', 'White']; // Default fallback
      });
    }
  }

  Future<void> addToCart() async {
    try {
      // Check if this product is already in the cart
      final querySnapshot = await _firestore
          .collection('cart')
          .where('productId', isEqualTo: productId)
          .where('color', isEqualTo: selectedColor)
          .where('size', isEqualTo: selectedSize)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Product exists in cart, update quantity
        final doc = querySnapshot.docs.first;
        await doc.reference.update({
          'quantity': FieldValue.increment(1),
        });
      } else {
        // Product doesn't exist in cart, add new item
        await _firestore.collection('cart').add({
          'productId': productId,
          'name': productName,
          'price': productPrice,
          'image': imagePaths.isNotEmpty ? imagePaths[0] : '',
          'color': selectedColor,
          'size': selectedSize,
          'quantity': 1,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      setState(() {
        isAddedToCart = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to cart!'),
          duration: Duration(seconds: 2),
        ),
      );

      // Reset after 2 seconds
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          isAddedToCart = false;
        });
      });
    } catch (e) {
      print("Error adding to cart: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add to cart'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color getColorFromName(String colorName) {
    try {
      String normalized = colorName.replaceAll('"', '').trim().toLowerCase();
      print("Converting color: $normalized");

      switch (normalized) {
        case 'white': return Colors.white;
        case 'black': return Colors.black;
        case 'red': return Colors.red;
        case 'blue': return Colors.blue;
        case 'green': return Colors.green;
        case 'pink': return Colors.pink;
        default:
          print("Unknown color: $normalized, using grey");
          return Colors.grey;
      }
    } catch (e) {
      print("Error in getColorFromName: $e");
      return Colors.grey;
    }
  }

  Widget buildColorOption(Color color, String colorName, double size) {
    bool isSelected = selectedColor.toLowerCase() == colorName.toLowerCase();
    return GestureDetector(
      onTap: () {
        setState(() => selectedColor = colorName);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: size * 0.01, vertical: size * 0.02),
        width: size * 0.08,
        height: size * 0.08,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Color(0xFFD0B8A8),
            width: 2,
          ),
        ),
        child: isSelected ? Icon(Icons.check, size: size * 0.05, color: Colors.white) : null,
      ),
    );
  }

  Widget buildSizeOption(String sizeText, double width) {
    return GestureDetector(
      onTap: () {
        setState(() => selectedSize = sizeText);
      },
      child: Container(
        margin: EdgeInsets.only(right: width * 0.02, top: width * 0.02),
        padding: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: width * 0.02),
        decoration: BoxDecoration(
          color: selectedSize == sizeText ? Color(0xFF561C24) : Color(0xFFD0B8A8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          sizeText,
          style: TextStyle(
            color: selectedSize == sizeText ? Colors.white : Colors.black,
            fontSize: width * 0.035,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: PageView.builder(
                          itemCount: imagePaths.length,
                          onPageChanged: (index) {
                            setState(() => currentImageIndex = index);
                          },
                          itemBuilder: (context, index) {
                            return Image.asset(
                              imagePaths[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: height * 0.02,
                        left: width * 0.04,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.arrow_back_ios, color: Color(0xFF561C24), size: width * 0.05),
                          ),
                        ),
                      ),
                      Positioned(
                        top: height * 0.02,
                        right: width * 0.04,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => isFavorite = !isFavorite);
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.black,
                              size: width * 0.05,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: height * 0.01,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: imagePaths.asMap().entries.map((entry) {
                            return Container(
                              width: width * 0.02,
                              height: width * 0.02,
                              margin: EdgeInsets.symmetric(horizontal: width * 0.01),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: currentImageIndex == entry.key
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.3),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(width * 0.04, height * 0.02, 0, height * 0.1),
                    color: Color(0xFFFFFDF6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(productName, style: TextStyle(fontSize: width * 0.05, fontWeight: FontWeight.bold)),
                            Padding(
                              padding: EdgeInsets.only(right: width * 0.04),
                              child: Text('\$ ${productPrice.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: width * 0.05, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.02),
                        Text('Color', style: TextStyle(fontSize: width * 0.04, fontWeight: FontWeight.w500)),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: availableColors.map((colorName) {
                              print("Building color option for: $colorName");
                              return buildColorOption(getColorFromName(colorName), colorName, width);
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: height * 0.02),
                        Text('Size', style: TextStyle(fontSize: width * 0.04, fontWeight: FontWeight.w500)),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: availableSizes.map((size) => buildSizeOption(size, width)).toList(),
                          ),
                        ),
                        SizedBox(height: height * 0.02),
                        ListTile(
                          title: Text('Description', style: TextStyle(fontSize: width * 0.04)),
                          trailing: Icon(showDescription ? Icons.expand_less : Icons.arrow_forward_ios,
                              size: width * 0.05),
                          onTap: () => setState(() => showDescription = !showDescription),
                        ),
                        if (showDescription)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                            child: Text(productDescription, style: TextStyle(fontSize: width * 0.035)),
                          ),
                        SizedBox(height: height * 0.01),
                        ListTile(
                          title: Text('Reviews', style: TextStyle(fontSize: width * 0.04)),
                          trailing: Icon(showReviews ? Icons.expand_less : Icons.arrow_forward_ios,
                              size: width * 0.05),
                          onTap: () => setState(() => showReviews = !showReviews),
                        ),
                        if (showReviews)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: productReviews
                                  .map((review) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text("- $review", style: TextStyle(fontSize: width * 0.035)),
                              ))
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: height * 0.08,
                decoration: BoxDecoration(
                  color: Color(0xFF561C24),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Center(
                  child: TextButton.icon(
                    onPressed: addToCart,
                    icon: Icon(
                      isAddedToCart ? Icons.check_circle : Icons.shopping_cart,
                      color: Color(0xFFD0B8A8),
                      size: width * 0.06,
                    ),
                    label: Text(
                      isAddedToCart ? "Added to Cart" : "Add to Cart",
                      style: TextStyle(
                        color: Color(0xFFD0B8A8),
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
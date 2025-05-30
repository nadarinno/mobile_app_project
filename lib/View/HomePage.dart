
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:http/http.dart'; // http.dart was imported but not used, can be removed if still unused
import 'package:provider/provider.dart'; // Import Provider for context.read
import 'package:mobile_app_project/View/Login.dart';
import 'package:mobile_app_project/Controller/HomePageController.dart';
import 'package:mobile_app_project/View/product_details_page.dart';
import 'package:mobile_app_project/View/NotificationPage.dart';
import 'package:mobile_app_project/View/SavedPage.dart';
import 'package:mobile_app_project/View/cart_page.dart';
import '../Controller/cart_controller.dart';
import '../widgets/bottom_nav_bar.dart'; // Corrected import path if needed

class HomePage extends StatefulWidget {
  final Function(int)? onNavigate;

  const HomePage({super.key, this.onNavigate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomePageController controller = HomePageController();
  final int notificationCount = 5; // Example notification count
  int _currentIndex = 0; // Local index for BottomNavigationBar when standalone

  // Pages for standalone navigation
  // CORRECTED: Use 'late final' and initialize in initState
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Initialize _pages here where context is available
    // and use HomePageContent for the first page.
    _pages = [
      HomePageContent(
        controller: controller, // Pass the HomePageState's controller
        notificationCount: notificationCount, // Pass the HomePageState's notificationCount
        onNavigate: _onItemTapped, // Pass the HomePageState's navigation handler
      ),
      const NotificationPage(),
      const SavedPage(),
      CartPage(controller: context.read<CartController>()), // Now this is correct
    ];
  }

  void _onItemTapped(int index) {
    if (widget.onNavigate != null) {
      // If used within MainPage, delegate to MainPage's navigation
      widget.onNavigate!(index);
    } else {
      // Handle navigation locally when standalone
      // Ensure we don't try to navigate to an index out of bounds for _pages
      if (index >= 0 && index < _pages.length) {
        setState(() {
          _currentIndex = index;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // It's generally safer to not call Navigator methods directly during build
    // unless guarded properly. addPostFrameCallback is a good way.
    if (!controller.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) { // Check if the widget is still in the tree
          Navigator.pushAndRemoveUntil( // Use pushAndRemoveUntil to prevent going back
            context,
            MaterialPageRoute(builder: (context) => const Login()),
                (Route<dynamic> route) => false, // Removes all previous routes
          );
        }
      });
      // Return a placeholder while redirecting to avoid build errors
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // If onNavigate is provided, return just the content (used in MainPage)
    if (widget.onNavigate != null) {
      return HomePageContent(
        controller: controller,
        notificationCount: notificationCount,
        onNavigate: widget.onNavigate!, // Use the onNavigate from the widget parameters
      );
    }

    // If standalone, include BottomNavigationBar
    return Scaffold(
      body: (_currentIndex >= 0 && _currentIndex < _pages.length)
          ? _pages[_currentIndex]
          : const Center(child: Text("Page not found")), // Fallback for safety
      bottomNavigationBar: CustomBottomNavBar(currentIndex: _currentIndex, onTap: _onItemTapped,),
    );
  }
}

// Extracted HomePage content to a separate widget for reusability
class HomePageContent extends StatelessWidget {
  final HomePageController controller;
  final int notificationCount;
  final Function(int) onNavigate; // Callback to navigate to a specific index

  const HomePageContent({
    super.key,
    required this.controller,
    required this.notificationCount,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/smalllogo.png', // Ensure this asset exists
            fit: BoxFit.contain,
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Cozy Shop',
          style: TextStyle(
            color: Color(0xFF561C24),
          ),
        ),
        backgroundColor: const Color(0xFFFFFDF6),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications,
                  color: Color(0xFF561C24),
                ),
                onPressed: () {
                  onNavigate(1); // Navigate to Notifications page (index 1)
                },
              ),
              if (notificationCount > 0)
                Positioned( // Adjusted position for better visibility
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Center( // Center the text
                      child: Text(
                        notificationCount.toString(), // Display actual count
                        style: const TextStyle(
                          fontSize: 10, // Adjusted size
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: controller.productsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error loading products: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No products found.'));
            }

            final products = snapshot.data!.docs;

            return GridView.builder(
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.65, // Adjusted for more content
              ),
              itemBuilder: (context, index) {
                final productId = products[index].id;
                final productData = products[index].data() as Map<String, dynamic>;
                final String productName = productData['name'] as String? ?? 'Unnamed Product';
                final String? imageUrl = productData['image'] as String?;
                final double productPrice = (productData['price'] is num) ? (productData['price'] as num).toDouble() : 0.0;

                return StreamBuilder<bool>(
                  stream: controller.isSaved(productId),
                  builder: (context, savedSnapshot) {
                    final isSaved = savedSnapshot.data ?? false;
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsPage(productId: productId),
                          ),
                        );
                      },
                      child: Card(
                        color: const Color(0xFFF5F3ED),
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children horizontally
                          children: [
                            Expanded(
                              flex: 3, // Give more space to image
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: (imageUrl != null && imageUrl.startsWith('http'))
                                    ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/cozyshoplogo.png', // Ensure this placeholder exists
                                      fit: BoxFit.contain, // Use contain for placeholder
                                      width: double.infinity,
                                    );
                                  },
                                )
                                    : Image.asset(
                                  'assets/images/cozyshoplogo.png', // Ensure this placeholder exists
                                  fit: BoxFit.contain, // Use contain for placeholder
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
                              child: Text(
                                productName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                '\$${productPrice.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF561C24)),
                              ),
                            ),
                            Align( // Keep save button at the bottom
                              alignment: Alignment.bottomRight,
                              child: savedSnapshot.connectionState == ConnectionState.waiting
                                  ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                              )
                                  : IconButton(
                                icon: Icon(
                                  isSaved ? Icons.favorite : Icons.favorite_border,
                                  color: isSaved ? Colors.red : Colors.grey[600],
                                ),
                                onPressed: () async {
                                  if (isSaved) {
                                    await controller.deleteSavedItem(productId, context);
                                  } else {
                                    await controller.saveItem(productId, context);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 4), // Spacing at the bottom


                          ],
                        ),
                      ),
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
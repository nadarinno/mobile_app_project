import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app_project/View/Login.dart';
import 'package:mobile_app_project/Controller/HomePageController.dart';
import 'package:mobile_app_project/View/product_details_page.dart';
import 'package:mobile_app_project/View/NotificationPage.dart';
import 'package:mobile_app_project/View/SavedPage.dart';
import 'package:mobile_app_project/View/cart_page.dart';
import '../Controller/cart_controller.dart';
import '../widgets/bottom_nav_bar.dart';

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

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePageContent(
        controller: controller,
        notificationCount: notificationCount,
        onNavigate: _onItemTapped,
      ),
      const NotificationPage(),
      const SavedPage(),
      const CartPage(), // Remove controller parameter
    ];
  }

  void _onItemTapped(int index) {
    if (widget.onNavigate != null) {
      widget.onNavigate!(index);
    } else {
      if (index >= 0 && index < _pages.length) {
        setState(() {
          _currentIndex = index;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
                (Route<dynamic> route) => false,
          );
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (widget.onNavigate != null) {
      return HomePageContent(
        controller: controller,
        notificationCount: notificationCount,
        onNavigate: widget.onNavigate!,
      );
    }

    return Scaffold(
      body: (_currentIndex >= 0 && _currentIndex < _pages.length)
          ? _pages[_currentIndex]
          : const Center(child: Text("Page not found")),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  final HomePageController controller;
  final int notificationCount;
  final Function(int) onNavigate;

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
            'assets/images/smalllogo.png',
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
                  onNavigate(1);
                },
              ),
              if (notificationCount > 0)
                Positioned(
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
                    child: Center(
                      child: Text(
                        notificationCount.toString(),
                        style: const TextStyle(
                          fontSize: 10,
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
                childAspectRatio: 0.65,
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: (imageUrl != null && imageUrl.startsWith('http'))
                                    ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/cozyshoplogo.png',
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                    );
                                  },
                                )
                                    : Image.asset(
                                  'assets/images/cozyshoplogo.png',
                                  fit: BoxFit.contain,
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
                            Align(
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
                            const SizedBox(height: 4),
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
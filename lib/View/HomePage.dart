import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_project/View/Login.dart';
import 'package:mobile_app_project/View/NotificationPage.dart';
import 'package:mobile_app_project/Controller/HomePageController.dart';
import 'package:mobile_app_project/View/product_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomePageController controller = HomePageController();
  final int notificationCount = 5; // Example notification count

  @override
  Widget build(BuildContext context) {
    if (!controller.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      });
      return const Center(child: Text('Redirecting to login...'));
    }

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
                onPressed: () async {
                  try {
                    await Future.delayed(const Duration(milliseconds: 500));
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationPage()),
                    );
                  } catch (e) {
                    print('Error navigating to NotificationPage: $e');
                  }
                },
              ),
              if (notificationCount > 0)
                const Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Text(
                      '!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
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
              return const Center(child: Text('Error loading products'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final products = snapshot.data!.docs;

            return GridView.builder(
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final product = products[index].data() as Map<String, dynamic>;
                final productId = products[index].id;
                print("Rendering product $productId with image: ${product['image']} at ${DateTime.now()}");

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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: product['image'] != null && product['image'].startsWith('http')
                                    ? Image.network(
                                  product['image'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    print("Error loading network image for product $productId: ${product['image']} - $error at ${DateTime.now()}");
                                    return Image.asset(
                                      'assets/images/cozyshoplogo.png',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    );
                                  },
                                )
                                    : Image.asset(
                                  'assets/images/cozyshoplogo.png',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                product['name'] ?? 'Unnamed Item',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('\$${product['price']?.toStringAsFixed(2) ?? '0.00'}'),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: savedSnapshot.connectionState == ConnectionState.waiting
                                  ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(strokeWidth: 2),
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
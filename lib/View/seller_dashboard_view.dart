import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_project/View/add_product_view.dart';
import 'package:mobile_app_project/Controller/seller_dashboard_controller.dart';
import 'package:mobile_app_project/View/Login.dart';
import 'package:mobile_app_project/View/product_search_view.dart';
import '../Controller/add_product_controller.dart';
import '../Controller/product_search_controller.dart';
import '../Logic/add_product_logic.dart';
import '../Logic/product_search_logic.dart';
import 'package:mobile_app_project/view/edit_product_view.dart';
import 'package:mobile_app_project/Logic/delete_product_logic.dart';
import '../Logic/seller_dashboard_logic.dart';
import '../utils.dart';
import 'package:mobile_app_project/Controller/delete_product_controller.dart';
import 'package:mobile_app_project/view/delete_product_view.dart';
import 'package:mobile_app_project/Controller/edit_product_controller.dart';
import 'package:mobile_app_project/Logic/edit_product_logic.dart';
import 'package:mobile_app_project/View/order_management_view.dart';

class SellerDashboardView extends StatefulWidget {
  final SellerDashboardController controller;
  final SellerDashboardLogic logic;

  const SellerDashboardView({
    super.key,
    required this.controller,
    required this.logic,
  });

  @override
  _SellerDashboardViewState createState() => _SellerDashboardViewState();
}

class _SellerDashboardViewState extends State<SellerDashboardView> {
  Widget _buildStatCard(String title, String value) {
    return Card(
      elevation: 4,
      color: const Color(0xFFD0B8A8),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF561C24),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16, color: Color(0xFF561C24)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStats(Stream<QuerySnapshot> productsStream) {
    return StreamBuilder<QuerySnapshot>(
      stream: productsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = widget.logic.calculateStats(snapshot.data!.docs);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildStatCard(
                "Total Inventory Value",
                "\$${stats['totalSales'].toStringAsFixed(2)}",
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrderManagementPage(),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  color: const Color(0xFFD0B8A8),
                  child: Container(
                    width: 140,
                    padding: const EdgeInsets.all(12),
                    child: const Column(
                      children: [
                        Text(
                          "View Orders",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF561C24),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Manage",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF561C24),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildStatCard("Products", "${stats['productCount']}"),
              const SizedBox(width: 8),
              _buildStatCard("Total Items", "${stats['totalInventory']}"),
            ],
          ),
        );
      },
    );
  }

  Widget buildProductList(
    BuildContext context,
    Stream<QuerySnapshot> productsStream,
    VoidCallback updateTotals,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: productsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No products available"));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final p = doc.data() as Map<String, dynamic>;
            final imageUrls = p['images'] as List<dynamic>? ?? [];
            final firstImage =
                imageUrls.isNotEmpty ? imageUrls[0] as String : null;

            final price =
                (p['price'] is num) ? (p['price'] as num).toDouble() : 0.0;
            final quantity =
                (p['quantity'] is num) ? (p['quantity'] as num).toInt() : 0;
            final inventoryValue = price * quantity;

            return Card(
              elevation: 4,
              color: const Color(0xFFD0B8A8),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (firstImage != null)
                    Image.network(
                      firstImage,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            height: 150,
                            color: const Color(0xFFD0B8A8),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Color(0xFF561C24),
                              ),
                            ),
                          ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                p['name']?.toString() ?? 'Unnamed Product',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF561C24),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              "\$${price.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF561C24),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (p['description'] != null &&
                            p['description'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              p['description'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Color(0xFF561C24)),
                            ),
                          ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Quantity: $quantity",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF561C24),
                              ),
                            ),
                            Text(
                              "Value: \$${inventoryValue.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF561C24),
                              ),
                            ),
                            Text(
                              "Images: ${imageUrls.length}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF561C24),
                              ),
                            ),
                          ],
                        ),
                        if (p['colors'] != null &&
                            p['colors'] is List &&
                            (p['colors'] as List).isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  "Colors: ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF561C24),
                                  ),
                                ),
                                Wrap(
                                  spacing: 4,
                                  children:
                                      (p['colors'] as List<dynamic>)
                                          .map<Widget>((color) {
                                            return CircleAvatar(
                                              radius: 8,
                                              backgroundColor: getColorFromName(
                                                color.toString(),
                                              ),
                                            );
                                          })
                                          .toList(),
                                ),
                              ],
                            ),
                          ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Color(0xFFF5F3ED),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => EditProductView(
                                            product: p,
                                            docId: doc.id,
                                            updateTotals: updateTotals,
                                            controller: EditProductController(
                                              FirebaseFirestore.instance,
                                            ),
                                            logic: EditProductLogic(
                                              initialName:
                                                  p['name']?.toString() ?? '',
                                              initialPrice:
                                                  (p['price'] is num)
                                                      ? p['price'].toString()
                                                      : '0.0',
                                              initialQuantity:
                                                  (p['quantity'] is num)
                                                      ? p['quantity'].toString()
                                                      : '0',
                                              initialDescription:
                                                  p['description']
                                                      ?.toString() ??
                                                  '',
                                              initialColors:
                                                  (p['colors']
                                                          as List<dynamic>?)
                                                      ?.map((e) => e.toString())
                                                      .toList() ??
                                                  [],
                                            ),
                                          ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Color(0xFF561C24),
                                ),
                                onPressed:
                                    () => DeleteProductView.showConfirmDialog(
                                      context,
                                      doc.id,
                                      updateTotals,
                                      DeleteProductLogic(
                                        DeleteProductController(
                                          FirebaseFirestore.instance,
                                        ),
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Seller Dashboard',
          style: TextStyle(color: Color(0xFFD0B8A8)),
        ),
        backgroundColor: const Color(0xFF561C24),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFFD0B8A8)),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchView(
                  ProductSearchLogic(
                    ProductSearchController(FirebaseFirestore.instance),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFD0B8A8)),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildStats(widget.controller.getProductsStream()),
            const SizedBox(height: 16),
            Expanded(
              child: buildProductList(
                context,
                widget.controller.getProductsStream(),
                () => setState(() {}),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF561C24),
        foregroundColor: const Color(0xFFD0B8A8),
        child: const Icon(Icons.add),
        onPressed:
            () => showDialog(
              context: context,
              builder:
                  (context) => AddProductView(
                    updateTotals: () => setState(() {}),
                    parentContext: context,
                    controller: AddProductController(
                      FirebaseFirestore.instance,
                      FirebaseStorage.instance,
                    ),
                    logic: AddProductLogic(),
                  ),
            ),
      ),
    );
  }
}

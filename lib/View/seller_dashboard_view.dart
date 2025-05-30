import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_project/Logic/add_product_logic.dart';
import 'package:mobile_app_project/view/add_product_view.dart';
import 'package:mobile_app_project/view/product_search_view.dart';
import 'package:mobile_app_project/Controller/seller_dashboard_controller.dart';
import 'package:mobile_app_project/Logic/seller_dashboard_logic.dart';
import '../Controller/add_product_controller.dart';
import '../Controller/product_search_controller.dart';
import '../Logic/product_search_logic.dart';
import 'package:mobile_app_project/view/edit_product_view.dart';
import 'package:mobile_app_project/Logic/delete_product_logic.dart';
import '../utils.dart';
import 'package:mobile_app_project/Controller/delete_product_controller.dart';
import 'package:mobile_app_project/view/delete_product_view.dart';
import 'package:mobile_app_project/Controller/edit_product_controller.dart';
import 'package:mobile_app_project/Logic/edit_product_logic.dart';

import 'package:mobile_app_project/View/order_management_view.dart';
class SellerDashboardView extends StatefulWidget {
  final SellerDashboardController controller;
  final SellerDashboardLogic logic;

  const SellerDashboardView({super.key, required this.controller, required this.logic});

  @override
  _SellerDashboardViewState createState() => _SellerDashboardViewState();
}

class _SellerDashboardViewState extends State<SellerDashboardView> {
  Widget _buildStatCard(String title, String value) {
    return Card(
      elevation: 4,
      color: Color(0xFFD0B8A8),
      child: Container(
        width: 140,
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF561C24),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 16, color: Color(0xFF561C24)),
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
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        final stats = widget.logic.calculateStats(snapshot.data!.docs);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildStatCard(
                "Total Inventory Value",
                "\$${stats['totalSales'].toStringAsFixed(2)}",
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderManagementPage(),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  color: Color(0xFFD0B8A8),
                  child: Container(
                    width: 140,
                    padding: EdgeInsets.all(12),
                    child: Column(
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
              SizedBox(width: 8),
              _buildStatCard("Products", "${stats['productCount']}"),
              SizedBox(width: 8),
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
        if (snapshot.hasError)
          return Center(child: Text('Error: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.docs.isEmpty)
          return Center(child: Text("No products available"));

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
              color: Color(0xFFD0B8A8),
              margin: EdgeInsets.symmetric(vertical: 8),
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
                            color: Color(0xFFD0B8A8),
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Color(0xFF561C24),
                              ),
                            ),
                          ),
                    ),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                p['name']?.toString() ?? 'Unnamed Product',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF561C24),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              "\$${price.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF561C24),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        if (p['description'] != null &&
                            p['description'].toString().isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              p['description'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Color(0xFF561C24)),
                            ),
                          ),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Quantity: $quantity",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF561C24),
                                  ),
                                ),
                                Text(
                                  "Value: \$${inventoryValue.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF561C24),
                                  ),
                                ),
                                Text(
                                  "Images: ${imageUrls.length}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF561C24),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 8),
                            if (p['colors'] != null && p['colors'] is List)
                              Flexible(
                                child: Wrap(
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
                              ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
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
                                icon: Icon(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Seller Dashboard',
          style: TextStyle(color: Color(0xFFD0B8A8)),
        ),

        backgroundColor: Color(0xFF561C24),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Color(0xFFD0B8A8)),
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
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildStats(widget.controller.getProductsStream()),
            SizedBox(height: 16),
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
        backgroundColor: Color(0xFF561C24),
        foregroundColor: Color(0xFFD0B8A8),
        child: Icon(Icons.add),
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

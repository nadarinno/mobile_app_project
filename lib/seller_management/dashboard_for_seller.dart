import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_product.dart';
import 'edit_product.dart';
import 'delete_product.dart';
import 'product_search.dart';
import 'utils.dart';

class SellerDashboard extends StatefulWidget {
  @override
  _SellerDashboardState createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seller Dashboard'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(_firestore),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStats(),
            SizedBox(height: 16),
            Expanded(child: _buildProductList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AddProductDialog(
            updateTotals: () => setState(() {}),
            parentContext: context,
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        double totalSales = 0.0;
        int totalInventory = 0;

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final price = data['price'];
          final quantity = data['quantity'];

          if (price is num && quantity is num) {
            totalSales += price.toDouble() * quantity.toInt();
            totalInventory += quantity.toInt();
          }
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildStatCard("Total Inventory Value", "\$${totalSales.toStringAsFixed(2)}"),
              SizedBox(width: 8),
              _buildStatCard("Products", "${docs.length}"),
              SizedBox(width: 8),
              _buildStatCard("Total Items", "$totalInventory"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      elevation: 4,
      child: Container(
        width: 140,
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) return Center(child: Text("No products available"));

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final p = doc.data() as Map<String, dynamic>;

            final price = (p['price'] is num) ? (p['price'] as num).toDouble() : 0.0;
            final quantity = (p['quantity'] is num) ? (p['quantity'] as num).toInt() : 0;
            final inventoryValue = price * quantity;

            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (p['image'] != null)
                    Image.network(
                      p['image'],
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        color: Colors.grey[200],
                        child: Center(child: Icon(Icons.image_not_supported)),
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
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              "\$${price.toStringAsFixed(2)}",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        if (p['description'] != null && p['description'].toString().isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              p['description'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Quantity: $quantity", style: TextStyle(fontWeight: FontWeight.bold)),
                                Text("Value: \$${inventoryValue.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(width: 8),
                            if (p['colors'] != null && p['colors'] is List)
                              Flexible(
                                child: Wrap(
                                  spacing: 4,
                                  children: (p['colors'] as List<dynamic>).map<Widget>((color) {
                                    return CircleAvatar(
                                      radius: 8,
                                      backgroundColor: getColorFromName(color.toString()),
                                    );
                                  }).toList(),
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
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => showEditProductForm(context, p, doc.id, () => setState(() {})),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => confirmDelete(context, doc.id, () => setState(() {})),
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
}
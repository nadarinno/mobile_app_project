import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'utils.dart';

class ProductSearchDelegate extends SearchDelegate {
  final FirebaseFirestore firestore;

  ProductSearchDelegate(this.firestore);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('products')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No products found"));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final p = doc.data() as Map<String, dynamic>;
            final price = p['price'] is num ? (p['price'] as num).toDouble() : 0.0;
            final quantity = p['quantity'] is num ? (p['quantity'] as num).toInt() : 0;
            final inventoryValue = price * quantity;

            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: p['image'] != null ? Image.network(
                  p['image'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[200],
                    child: Center(child: Icon(Icons.image_not_supported)),
                  ),
                ) : null,
                title: Text(p['name']?.toString() ?? 'Unnamed Product'),
                subtitle: Text("\$${price.toStringAsFixed(2)} - Qty: $quantity"),
                trailing: Text("\$${inventoryValue.toStringAsFixed(2)}"),
                onTap: () {
                  close(context, null);
                },
              ),
            );
          },
        );
      },
    );
  }
}
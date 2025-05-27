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

class SellerDashboardView extends StatefulWidget {
  final SellerDashboardController controller;
  final SellerDashboardLogic logic;

  SellerDashboardView({required this.controller, required this.logic});

  @override
  _SellerDashboardViewState createState() => _SellerDashboardViewState();
}

class _SellerDashboardViewState extends State<SellerDashboardView> {
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
            widget.logic.buildStats(widget.controller.getProductsStream()),
            SizedBox(height: 16),
            Expanded(
              child: widget.logic.buildProductList(
                context,
                widget.controller.getProductsStream(),
                    () => setState(() {}),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AddProductView(
            updateTotals: () => setState(() {}),
            parentContext: context,
            controller: AddProductController(FirebaseFirestore.instance, FirebaseStorage.instance),
            logic: AddProductLogic(),
          ),
        ),
      ),
    );
  }
}
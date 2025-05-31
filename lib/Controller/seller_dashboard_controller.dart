import 'package:cloud_firestore/cloud_firestore.dart';

class SellerDashboardController {
  final FirebaseFirestore firestore;

  SellerDashboardController(this.firestore);

  Stream<QuerySnapshot> getProductsStream() {
    return firestore.collection('products').snapshots();
  }
}

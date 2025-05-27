import 'package:cloud_firestore/cloud_firestore.dart';

class ProductSearchController {
  final FirebaseFirestore firestore;

  ProductSearchController(this.firestore);

  Stream<QuerySnapshot> getSearchStream(String query) {
    return firestore
        .collection('products')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .snapshots();
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchPaymentMethods() async {
    try {
      print('Fetching payment methods from Firestore...');
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc('bOg0j7qfl2Xyb7p5AwRCtafhXQd2')
          .collection('payments')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print('Documents found: ${querySnapshot.docs.length}');
        return querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          return {
            'paymentId': doc.id,
            'number': data['cardNumber'],
            'name': data.containsKey('cardHolderName')
                ? data['cardHolderName']
                : (data.containsKey('cardHolder') ? data['cardHolder'] : 'Unknown'),
            'expiry': data['expiryDate'],
          };
        }).toList();
      } else {
        print('No payment methods found.');
        return [];
      }
    } catch (e) {
      print('Error fetching payment methods: $e');
      return [];
    }
  }

  Future<void> deletePaymentMethod(String paymentId) async {
    try {
      await _firestore
          .collection('users')
          .doc('bOg0j7qfl2Xyb7p5AwRCtafhXQd2')
          .collection('payments')
          .doc(paymentId)
          .delete();
      print('Payment method deleted: $paymentId');
    } catch (e) {
      print('Error deleting payment method: $e');
      throw e;
    }
  }
}
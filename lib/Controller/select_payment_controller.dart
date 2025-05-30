import 'package:cloud_firestore/cloud_firestore.dart';
import '../logic/select_payment_logic.dart';


class PaymentController {
  final PaymentService _paymentService = PaymentService();

  Future<List<Map<String, dynamic>>> fetchCards() async {
    return await _paymentService.fetchPaymentMethods();
  }

  Future<void> deleteCard(String paymentId) async {
    await _paymentService.deletePaymentMethod(paymentId);
  }

  void addNewCard() {
    // Logic to navigate to a new card addition screen
  }

  void continuePayment(Map<String, dynamic> selectedCard) {
    print('Proceeding with payment using card: ${selectedCard['number']}');
    // Add your purchase logic here
  }
}
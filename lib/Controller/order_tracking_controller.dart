import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_project/Logic/order_step_model.dart';
class OrderTrackingController {
  int currentStep = 0;
  List<OrderStep> steps = [];
  late DocumentReference orderRef;
  final String orderId;

  OrderTrackingController({required this.orderId}) {
    orderRef = FirebaseFirestore.instance.collection('orders').doc(orderId);
  }

  Future<void> fetchSteps() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final orderSnapshot = await orderRef.get();
      final data = orderSnapshot.data() as Map<String, dynamic>?;
      currentStep = data?['currentStep'] ?? 0;

      final stepsSnapshot = await firestore.collection('order_steps').get();
      final stepDocs = stepsSnapshot.docs
          .where((doc) => doc.id.startsWith('step'))
          .toList()
        ..sort((a, b) => a.id.compareTo(b.id));

      steps = stepDocs.map((doc) => OrderStep.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching steps: $e');
    }
  }

  Future<void> updateOrderStep(int index) async {
    try {
      currentStep = index;
      await orderRef.update({'currentStep': index});
    } catch (e) {
      print('Error updating order step: $e');
    }
  }
}
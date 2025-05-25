import 'package:flutter/material.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:mobile_app_project/Logic/order_step_model.dart';
import 'package:mobile_app_project/Controllers/order_tracking_controller.dart';

class OrderTrackingPage extends StatefulWidget {
  final String orderId;

  OrderTrackingPage({required this.orderId});

  @override
  _OrderTrackingPageState createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  late OrderTrackingController controller;

  @override
  void initState() {
    super.initState();
    controller = OrderTrackingController(orderId: widget.orderId);
    controller.fetchSteps().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final circleSize = screenWidth * 0.08;
    final iconSize = screenWidth * 0.1;
    final dottedLineHeight = screenHeight * 0.08;
    final paddingHorizontal = screenWidth * 0.05;

    return Scaffold(
      backgroundColor: Color(0xFFFFFDF6),
      appBar: AppBar(
        backgroundColor: Color(0xFF561C24),
        centerTitle: true,
        title: Text('Order Tracking', style: TextStyle(color: Color(0xFFD0B8A8))),
      ),
      body: controller.steps.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.symmetric(
            horizontal: paddingHorizontal, vertical: screenHeight * 0.01),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.05),
            Expanded(
              child: ListView.builder(
                itemCount: controller.steps.length,
                itemBuilder: (context, index) {
                  final step = controller.steps[index];
                  final isCompleted = index <= controller.currentStep;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              controller.updateOrderStep(index).then((_) => setState(() {}));
                            },
                            child: Container(
                              width: circleSize,
                              height: circleSize,
                              decoration: BoxDecoration(
                                color: isCompleted ? Color(0xFF561C24) : Color(0xFFD0B8A8),
                                border: Border.all(color: Color(0xFF561C24), width: 2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: isCompleted
                                    ? Icon(Icons.check,
                                    color: Colors.white, size: circleSize * 0.6)
                                    : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: Color(0xFF561C24),
                                    fontSize: circleSize * 0.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (index != controller.steps.length - 1)
                            Container(
                              height: dottedLineHeight,
                              child: DottedLine(
                                  direction: Axis.vertical, dashColor: Color(0xFFD0B8A8)),
                            ),
                        ],
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Icon(step.icon, color: Color(0xFF561C24), size: iconSize),
                      SizedBox(width: screenWidth * 0.03),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(step.title,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.04)),
                            SizedBox(height: 4),
                            Text(step.description,
                                style: TextStyle(
                                    color: Color(0xFFD0B8A8),
                                    fontSize: screenWidth * 0.035)),
                            if (step.estimate.isNotEmpty) ...[
                              SizedBox(height: 4),
                              Text(
                                step.estimate,
                                style: TextStyle(
                                    color: Color(0xFF561C24),
                                    fontStyle: FontStyle.italic,
                                    fontSize: screenWidth * 0.03),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text('Help Line: 810 855 281 1012',
                style: TextStyle(
                    color: Color(0xFFD0B8A8), fontSize: screenWidth * 0.03)),
            SizedBox(height: screenHeight * 0.01),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFFFFFDF6),
        selectedItemColor: Color(0xFF561C24),
        unselectedItemColor: Color(0xFFD0B8A8),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
        ],
      ),
    );
  }
}
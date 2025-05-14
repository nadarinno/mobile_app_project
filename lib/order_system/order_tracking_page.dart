import 'package:flutter/material.dart';
import "package:dotted_line/dotted_line.dart";

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order Tracking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.pink),
      home: OrderTrackingPage(),
    );
  }
}

class OrderTrackingPage extends StatefulWidget {
  @override
  _OrderTrackingPageState createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  final List<OrderStep> steps = [
    OrderStep(
      title: 'ORDER PLACED',
      description: 'Your order_system is placed successfully.',
      estimate: 'Estimated time: 6 Days',
      icon: Icons.card_giftcard,
    ),
    OrderStep(
      title: 'ORDER PREPARING',
      description: 'Your order_system is now being prepared in the warehouse.',
      estimate: 'Estimated time: 4 Days',
      icon: Icons.inventory,
    ),

    OrderStep(
      title: 'ON THE WAY',
      description: 'Your order_system is placed successfully. Our agent will soon deliver the products.',
      estimate: 'Estimated time: 3 Days',
      icon: Icons.local_shipping,
    ),
    OrderStep(
      title: 'PRODUCT DELIVERED',
      description: 'Our agent will deliver your product on 20 July, 2017 at 11:00AM',
      estimate: '',
      icon: Icons.favorite_border,
    ),
  ];

  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final circleSize = screenWidth * 0.08; // 8% of screen width
    final iconSize = screenWidth * 0.1; // 10% of screen width
    final dottedLineHeight = screenHeight * 0.08; // 8% of screen height
    final paddingHorizontal = screenWidth * 0.05; // 5% padding

    return Scaffold(
      backgroundColor: Color(0xFFFFFDF6),
      appBar: AppBar(
        backgroundColor: Color(0xFF561C24),
        centerTitle: true,
        title: Column(
          children: [
            Text('Order Tracking', style: TextStyle(color: Color(0xFFD0B8A8), fontSize: screenWidth * 0.045)),
            SizedBox(height: 4),
            Text('#825791537', style: TextStyle(color: Color(0xFFD0B8A8), fontSize: screenWidth * 0.03)),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: screenHeight * 0.01),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.2),
            Expanded(
              child: ListView.builder(
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  final step = steps[index];
                  final isCompleted = index <= currentStep;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Circle number / check icon
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                currentStep = index;
                              });
                            },
                            child: Container(
                              width: circleSize,
                              height: circleSize,
                              decoration: BoxDecoration(
                                color: isCompleted ? Color(0xFF561C24) : Color(0xFFD0B8A8),
                                border: Border.all(color:Color(0xFF561C24), width: 2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: isCompleted
                                    ? Icon(Icons.check, color: Colors.white, size: circleSize * 0.6)
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
                          if (index != steps.length - 1)
                            Container(
                              height: dottedLineHeight,
                              child: DottedLine(
                                direction: Axis.vertical,
                                dashColor: Color(0xFFD0B8A8),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(width: screenWidth * 0.03),

                      // Icon
                      Icon(step.icon, color: Color(0xFF561C24), size: iconSize),

                      SizedBox(width: screenWidth * 0.03),

                      // Texts
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.04,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              step.description,
                              style: TextStyle(color:Color(0xFFD0B8A8), fontSize: screenWidth * 0.035),
                            ),
                            if (step.estimate.isNotEmpty) ...[
                              SizedBox(height: 4),
                              Text(
                                step.estimate,
                                style: TextStyle(
                                  color: Color(0xFF561C24),
                                  fontStyle: FontStyle.italic,
                                  fontSize: screenWidth * 0.03,
                                ),
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
            Text(
              'Help Line: 810 855 281 1012',
              style: TextStyle(color: Color(0xFFD0B8A8), fontSize: screenWidth * 0.03),
            ),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home',backgroundColor: Color(0xFFFFFDF6)),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: 'Saved'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'Account'),
        ],
      ),
    );
  }
}
class OrderStep {
  final String title;
  final String description;
  final String estimate;
  final IconData icon;
  OrderStep({
    required this.title,
    required this.description,
    required this.estimate,
    required this.icon,
  });
}

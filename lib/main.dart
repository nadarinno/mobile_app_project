import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'Logic/notification_handler.dart';
import 'Controller/cart_controller.dart';
import 'Controller/checkout_controller.dart';
import 'View/Login.dart';
import 'View/MainPage.dart';
import 'View/HomePage.dart';
import 'View/NotificationPage.dart';
import 'View/SavedPage.dart';
import 'View/cart_page.dart';
import 'View/product_details_page.dart';
import 'View/reviews_page.dart';
import 'View/checkout_view.dart';
import 'View/splash_screen.dart';

// Utility class for responsive design
class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
          MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static double getWidth(BuildContext context, {double mobile = 0.9, double tablet = 0.7, double desktop = 0.5}) {
    if (isDesktop(context)) return MediaQuery.of(context).size.width * desktop;
    if (isTablet(context)) return MediaQuery.of(context).size.width * tablet;
    return MediaQuery.of(context).size.width * mobile;
  }

  static double getPadding(BuildContext context, {double mobile = 16.0, double tablet = 32.0, double desktop = 64.0}) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartController()),
        ChangeNotifierProvider(create: (context) => CheckoutController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        // Define text styles for responsiveness
        textTheme: Theme.of(context).textTheme.apply(
          fontSizeFactor: Responsive.isDesktop(context)
              ? 1.2
              : Responsive.isTablet(context)
              ? 1.1
              : 1.0,
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const Login(),
        '/main': (context) => const MainPage(),
        '/home': (context) => const HomePage(),
        '/notifications': (context) => const NotificationPage(),
        '/saved': (context) => const SavedPage(),
        '/cart': (context) => const CartPage(),
        '/product_details': (context) {
          final Object? args = ModalRoute.of(context)?.settings.arguments;
          final String productId = (args is String) ? args : '';
          return ProductDetailsPage(productId: productId);
        },
        '/reviews': (context) {
          final Object? args = ModalRoute.of(context)?.settings.arguments;
          final String productId = (args is String) ? args : '';
          return ReviewsPage(productId: productId);
        },
        '/checkout': (context) => CheckoutView(),
      },
    );
  }
}

// Example of an adaptive HomePage
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: Responsive.isMobile(context),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(Responsive.getPadding(context)),
              child: Center(
                child: Container(
                  width: Responsive.getWidth(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Adaptive grid for products
                      OrientationBuilder(
                        builder: (context, orientation) {
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: Responsive.isDesktop(context)
                                  ? 4
                                  : Responsive.isTablet(context)
                                  ? 3
                                  : 2,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 16.0,
                              childAspectRatio: orientation == Orientation.portrait ? 0.7 : 1.0,
                            ),
                            itemCount: 8, // Example item count
                            itemBuilder: (context, index) {
                              return Card(
                                elevation: 2,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        color: Colors.grey[300],
                                        child: const Center(child: Text('Product Image')),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Product $index',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
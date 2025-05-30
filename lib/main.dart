import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'Logic/notification_handler.dart';
import 'Controller/cart_controller.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartController()),
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const Login(),
        '/main': (context) => const MainPage(),
        '/home': (context) => const HomePage(),
        '/notifications': (context) => const NotificationPage(),
        '/saved': (context) => const SavedPage(),
        '/cart': (context) => const CartPage(), // Updated to remove controller
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
        '/checkout': (context) =>  CheckoutView(),
      },
    );
  }
}
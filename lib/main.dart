import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_project/View/cart_page.dart';
import 'package:mobile_app_project/View/product_details_page.dart';
import 'package:mobile_app_project/View/reviews_page.dart';
import 'package:mobile_app_project/View/HomePage.dart';
import 'package:mobile_app_project/View/MainPage.dart';
import 'package:mobile_app_project/View/NotificationPage.dart';
import 'package:mobile_app_project/View/SavedPage.dart';
import 'package:mobile_app_project/View/checkout_view.dart';
import 'package:provider/provider.dart';

import 'Controller/cart_controller.dart';
import 'View/Login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      title: 'My App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/main',
      routes: {
        '/login': (context) => const Login(),
        '/main': (context) => const MainPage(),
        '/home': (context) => const HomePage(),
        '/notifications': (context) => const NotificationPage(),
        '/saved': (context) => const SavedPage(),

        '/cart':
            (context) =>
                CartPage(controller: Provider.of<CartController>(context)),
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

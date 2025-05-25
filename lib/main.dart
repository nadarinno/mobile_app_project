import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_app_project/firebase_options.dart';
import 'package:mobile_app_project/View/product_details_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile App Project',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProductDetailsPage(productId: 'product1'),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_app_project/view/seller_dashboard_view.dart';
import 'package:mobile_app_project/Controller/seller_dashboard_controller.dart';
import 'package:mobile_app_project/Logic/seller_dashboard_logic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
options: DefaultFirebaseOptions.currentPlatform,
);
runApp(MyApp());
}

class MyApp extends StatelessWidget {
@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'Seller Dashboard',
theme: ThemeData(
primarySwatch: Colors.deepPurple,
visualDensity: VisualDensity.adaptivePlatformDensity,
),
home: SellerDashboardView(
controller: SellerDashboardController(FirebaseFirestore.instance),
logic: SellerDashboardLogic(),
),
debugShowCheckedModeBanner: false,
);
}
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'order/order_management.dart';
//
// import 'search/product_page.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'admin_dash_board_page/admin_dashboard_page.dart';
// import 'search/search_page.dart';
// import 'order/order_management.dart';
// import 'package:mobile_app_project/View/search_page_view.dart';
import 'package:mobile_app_project/View/settings_view.dart';
import 'package:mobile_app_project/logic/seller_detail_logic.dart';
import 'package:mobile_app_project/view/seller_detail_view.dart';
import 'package:mobile_app_project/View/admin_dashboard_view.dart';
import 'package:mobile_app_project/view/order_management_view.dart';
import 'package:mobile_app_project/View/select_payment_view.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,

  );
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {
 Locale _locale = const Locale('en');

  void _changeLanguage(String languageCode) {
    setState(() {
      _locale = Locale(languageCode);
    });
  }

 @override
 Widget build(BuildContext context) {

   return MaterialApp(

      debugShowCheckedModeBanner: false,
      //home: const OrderManagementPage(),
    //home: const SearchPageView(),
    //  home:  AdminDashboardPage(),
     locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
     home: SelectPaymentMethod(),
     //home: AdminDashboardView(),
     //home: const OrderManagementPage(),
     //home: SellerDetailPage(seller: dummySeller),
      // home: SettingPage(
      //   onLanguageChange: _changeLanguage,
      //   currentLocale: _locale,
      // ),
    );
  }
}
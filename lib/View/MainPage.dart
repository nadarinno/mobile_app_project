import 'package:flutter/material.dart';
import 'package:mobile_app_project/Controller/CartController.dart';
import 'package:mobile_app_project/View/HomePage.dart';
import 'package:mobile_app_project/View/Login.dart';
import 'package:mobile_app_project/View/NotificationPage.dart';
import 'package:mobile_app_project/View/SavedPage.dart';
import 'package:mobile_app_project/View/CartPage.dart';
 import 'package:mobile_app_project/View/search_page_view.dart';
import 'package:mobile_app_project/View/settings_view.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  // List of pages for the bottom nav
  final List<Widget> _pages = [
    HomePage(),
    SearchPageView(),
    SavedPage(),
    CartPage(controller: CartController(),),
    SettingPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Show selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFFFFDF6),
        selectedItemColor: const Color(0xFF561C24),
        unselectedItemColor: const Color(0xFFD0B8A8),
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
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
// class _MyAppState extends State<MyApp> {
//   Locale _locale = const Locale('en');
//
//   void _changeLanguage(String languageCode) {
//     setState(() {
//        class _MyAppState extends State<MyApp> {
//       @override
//       Widget build(BuildContext context) {
//       return MaterialApp(
//
//
//       debugShowCheckedModeBanner: false,
//       locale: _locale,
//
//
//
//       supportedLocales: const [
//       Locale('en'),
//       Locale('ar'),
//       class _MyAppState extends State<MyApp> {
//       GlobalWidgetsLocalizations.delegate,
//       GlobalCupertinoLocalizations.delegate,
//       ],
//
//       home: SettingPage(
//       onLanguageChange: _changeLanguage,
//       currentLocale: _locale,
//       ),
//       );
//       }
//       }
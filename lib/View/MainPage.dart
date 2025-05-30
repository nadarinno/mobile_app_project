import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app_project/Controller/CartController.dart'; // Choose one import
import 'package:mobile_app_project/View/HomePage.dart';
import 'package:mobile_app_project/View/Login.dart';
import 'package:mobile_app_project/View/NotificationPage.dart';
import 'package:mobile_app_project/View/SavedPage.dart';
import 'package:mobile_app_project/View/CartPage.dart';
import '../widgets/bottom_nav_bar.dart';
import 'package:mobile_app_project/View/search_page_view.dart';
import 'package:mobile_app_project/View/settings_view.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}



class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;


   late List<Widget> _pages = [
    HomePage(),
    SearchPageView(),
    SavedPage(),
    CartPage(controller: CartController(),),
    SettingPage(),
  ];
  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(onNavigate: _onItemTapped),
      const NotificationPage(),
      SavedPage(),
      CartPage(controller: context.read<CartController>()),
    ];
  }

  void _onItemTapped(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
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

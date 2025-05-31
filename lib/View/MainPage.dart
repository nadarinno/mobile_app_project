import 'package:flutter/material.dart';
import 'package:mobile_app_project/View/search_page_view.dart';
import 'package:mobile_app_project/View/HomePage.dart';
import 'package:mobile_app_project/View/NotificationPage.dart';
import 'package:mobile_app_project/View/SavedPage.dart';
import 'package:mobile_app_project/View/cart_page.dart';
import '../widgets/bottom_nav_bar.dart';
import 'package:mobile_app_project/View/settings_view.dart';
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(onNavigate: _onItemTapped),
      SearchPageView(),
      const CartPage(),
      const SavedPage(),
      const SettingPage(),
    ];
  }

  // Handler for search input
  void _handleSearch(String query) {

    print('Search query: $query');

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
        onTap: _onItemTapped,
      ),
    );
  }
}//mainPage
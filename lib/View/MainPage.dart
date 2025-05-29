import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app_project/Controller/cart_controller.dart';
import 'package:mobile_app_project/View/HomePage.dart';
import 'package:mobile_app_project/View/NotificationPage.dart';
import 'package:mobile_app_project/View/SavedPage.dart';
import 'package:mobile_app_project/View/cart_page.dart';
import 'package:mobile_app_project/widgets/bottom_nav_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

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
      const NotificationPage(),
      CartPage(controller: context.read<CartController>()),
      const SavedPage(),
      const NotificationPage(),
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
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mobile_app_project/View/Login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _logoAnimation =
        CurvedAnimation(parent: _logoController, curve: Curves.easeIn);
    _textAnimation =
        CurvedAnimation(parent: _textController, curve: Curves.easeIn);

    _logoController.forward();

    // Show text after logo
    Future.delayed(const Duration(milliseconds: 1000), () {
      _textController.forward();
    });

    // Navigate after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (context, animation, secondaryAnimation) => const Login(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );

    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E1DA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _logoAnimation,
              child: Image.asset(
                'assets/images/smalllogo.png',
                width: 200,
                height: 200,
              ),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _textAnimation,
              child: const Text(
                'Cozyshop',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF561C24),
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_project/View/ForgotPasswordPage.dart';
import 'package:mobile_app_project/View/MainPage.dart';
import 'package:mobile_app_project/View/SellerSignUp.dart';
import 'package:mobile_app_project/View/SignUp.dart';
import 'package:mobile_app_project/View//HomePage.dart';
import 'package:mobile_app_project/View/SavedPage.dart';
import 'package:mobile_app_project/View/Login.dart';
import 'package:mobile_app_project/View/PaymentPage.dart';
import 'package:mobile_app_project/View/NotificationPage.dart';
import 'Logic/notification_handler.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mobile_app_project/View/CartPage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile_app_project/View/search_page_view.dart';
import 'package:mobile_app_project/View/splash_screen.dart';
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //Stripe.publishableKey = 'pk_test_51REziwRu9mJNce3BovFk0FriBdHQrZwKiPPqvX4cp39OdMDfAInn6BwmG5LZrJM31Rj75jii51Cqmrd1r0ScKtgS0078Zzd8op';
  //await Stripe.instance.applySettings();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher'); // <- make sure this exists

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);


  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(),

    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart'; /

// import 'user_settings/settings.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @overridegit status
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   Locale _locale = const Locale('en');
//
//   void _changeLanguage(String languageCode) {
//     setState(() {
//       _locale = Locale(languageCode);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       locale: _locale,
//       supportedLocales: const [
//         Locale('en'),
//         Locale('ar'),
//       ],
//       localizationsDelegates: const [
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       home: SettingPage(
//         onLanguageChange: _changeLanguage,
//         currentLocale: _locale,
//       ),
//     );
//   }
// }

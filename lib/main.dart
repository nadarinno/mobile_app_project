import 'package:flutter/material.dart';
import 'search/search_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SearchPage(),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart'; // ← ضروري
//
// import 'user_settings/settings.dart'; // بدلها حسب اسم ملفك
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
//   Locale _locale = const Locale('en'); // اللغة الافتراضية إنجليزي
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
//         onLanguageChange: _changeLanguage, // تمرير الدالة للصفحة
//         currentLocale: _locale,
//       ),
//     );
//   }
// }

import 'package:benaa_pro/core/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ستحتاج لإضافة flutter_localizations في pubspec.yaml
import 'package:shared_preferences/shared_preferences.dart';
import 'views/home_screen.dart';
import 'views/main_layout.dart';
import 'views/login_screen.dart';

// في lib/main.dart
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // تهيئة Interceptor للتوكن (الذي أنشأناه في ApiClient)
  ApiClient.initInterceptor();

  // التحقق من وجود توكن
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');

  runApp(ProviderScope(child: MyApp(isLoggedIn: token != null)));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: isLoggedIn ? const MainLayout() : LoginScreen(),
      routes: {
        '/login': (context) =>
            LoginScreen(), // هذا السطر هو الحل للخطأ الذي ظهر في الـ Log
        '/main': (context) => const MainLayout(),
      },
    );
  }
}

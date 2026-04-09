import 'package:benaa_pro/core/api_client.dart';
import 'package:benaa_pro/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/home_screen.dart';
import 'views/main_layout.dart';
import 'views/login_screen.dart';

// في lib/main.dart
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ApiClient.initInterceptor();

  
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');
  final container = ProviderContainer();
  if (token != null) {
    await container.read(settingsProvider.notifier).loadProfile();
  }
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
        '/login': (context) => LoginScreen(),
        '/main': (context) => const MainLayout(),
      },
    );
  }
}

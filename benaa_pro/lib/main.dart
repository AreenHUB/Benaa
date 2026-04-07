import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ستحتاج لإضافة flutter_localizations في pubspec.yaml
import 'views/home_screen.dart';
import 'views/main_layout.dart';

void main() {
  runApp(
    // ProviderScope ضروري جداً لتشغيل Riverpod
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Benaa Pro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
        useMaterial3: true,
        fontFamily: 'Cairo', // يفضل إضافة خط عربي جميل مثل Cairo لاحقاً
      ),
      // إعدادات اللغة العربية من اليمين لليسار
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar', 'AE')],
      home: const MainLayout(),
    );
  }
}

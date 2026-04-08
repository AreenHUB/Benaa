import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'main_layout.dart';
import 'register_screen.dart'; // سنقوم بإنشاء هذا الملف

class LoginScreen extends ConsumerWidget {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.engineering, size: 80, color: Color(0xFF1E3A8A)),
              const SizedBox(height: 20),
              const Text(
                "Benaa Pro",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const Text(
                "مرحباً بك مجدداً",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  labelText: "البريد الإلكتروني",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "كلمة المرور",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 25),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async {
                  // إخفاء لوحة المفاتيح
                  FocusScope.of(context).unfocus();

                  // استدعاء دالة الدخول التي ترجع الآن رسالة خطأ أو null
                  String? errorMessage = await ref
                      .read(authProvider.notifier)
                      .login(emailCtrl.text, passCtrl.text);

                  if (errorMessage == null) {
                    // نجاح: الانتقال للشاشة الرئيسية
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainLayout()),
                    );
                  } else {
                    // فشل: عرض رسالة الخطأ الدقيقة (شاملة حظر الـ 429)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          errorMessage,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: errorMessage.contains("حظر")
                            ? Colors.orange[800]
                            : Colors.red, // لون برتقالي للحظر، أحمر للخطأ
                        behavior: SnackBarBehavior.floating, // شكل أنيق للإشعار
                      ),
                    );
                  }
                },
                child: const Text(
                  "تسجيل الدخول",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  // الانتقال لشاشة التسجيل
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegisterScreen()),
                  );
                },
                child: const Text(
                  "ليس لديك حساب؟ سجل الآن",
                  style: TextStyle(color: Color(0xFF1E3A8A)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

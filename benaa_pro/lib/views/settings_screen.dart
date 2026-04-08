import 'package:benaa_pro/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

// حولناها إلى ConsumerStatefulWidget لنتمكن من استخدام ref
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController companyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCompanyName();
  }

  Future<void> _loadCompanyName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      companyCtrl.text = prefs.getString('company_name') ?? '';
    });
  }

  Future<void> _saveCompanyName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('company_name', name);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تم حفظ إعدادات الشركة بنجاح!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyName = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    companyCtrl.text = companyName;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "الإعدادات",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // لجعل الأزرار تأخذ العرض كاملاً
          children: [
            const Text(
              "إعدادات التقارير الرسمية",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "سيظهر هذا الاسم كترويسة (Header) في ملفات الـ PDF التي يتم تصديرها للعملاء.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: companyCtrl,
              decoration: InputDecoration(
                labelText: "اسم الشركة",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                FocusScope.of(context).unfocus();
                notifier.updateCompanyName(companyCtrl.text);
              },
              child: const Text(
                "حفظ الإعدادات",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Spacer(), // لدفع زر تسجيل الخروج لأسفل الشاشة
            const Divider(),

            // زر تسجيل الخروج
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red,
                elevation: 0,
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.red),
              ),
              icon: const Icon(Icons.logout),
              label: const Text(
                "تسجيل الخروج",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onPressed: () {
                // 1. مسح التوكن وتسجيل الخروج
                ref.read(authProvider.notifier).logout();
                // 2. الانتقال لشاشة الدخول ومسح الشاشات السابقة من الذاكرة
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

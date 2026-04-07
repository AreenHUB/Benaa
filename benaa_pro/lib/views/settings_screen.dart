import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController companyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCompanyName();
  }

  // دالة لجلب اسم الشركة المحفوظ سابقاً
  Future<void> _loadCompanyName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      companyCtrl.text = prefs.getString('company_name') ?? '';
    });
  }

  // دالة لحفظ اسم الشركة
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                labelText: "اسم الشركة (مثال: شركة النخبة للمقاولات)",
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
                _saveCompanyName(companyCtrl.text);
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
          ],
        ),
      ),
    );
  }
}

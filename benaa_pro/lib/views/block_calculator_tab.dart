import 'package:flutter/material.dart';
import '../core/api_client.dart';

class BlockCalculatorTab extends StatefulWidget {
  @override
  _BlockCalculatorTabState createState() => _BlockCalculatorTabState();
}

class _BlockCalculatorTabState extends State<BlockCalculatorTab> {
  final lengthCtrl = TextEditingController();
  final heightCtrl = TextEditingController();
  dynamic result;
  bool isLoading = false;

  Future<void> _calculate() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiClient.instance.post(
        '/calculations/blocks',
        data: {
          "length": double.parse(lengthCtrl.text),
          "height": double.parse(heightCtrl.text),
          "block_type": "Standard",
        },
      );
      setState(() => result = response.data['data']);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("خطأ في الاتصال بالسيرفر")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    "حاسبة الطابوق والمونة",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: lengthCtrl,
                    decoration: const InputDecoration(
                      labelText: "طول الجدار (م)",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: heightCtrl,
                    decoration: const InputDecoration(
                      labelText: "ارتفاع الجدار (م)",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isLoading ? null : _calculate,
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text("احسب الطابوق"),
                  ),
                ],
              ),
            ),
          ),
          if (result != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    "عدد الطابوق: ${result['blocks']}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("الأسمنت (أكياس): ${result['cement_bags']}"),
                  Text("الرمل (م³): ${result['sand_m3']}"),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/calculator_provider.dart';
import '../providers/history_provider.dart';
import '../services/report_service.dart';
import 'package:share_plus/share_plus.dart';

class ConcreteCalculatorTab extends ConsumerStatefulWidget {
  const ConcreteCalculatorTab({super.key});

  @override
  ConsumerState<ConcreteCalculatorTab> createState() =>
      _ConcreteCalculatorTabState();
}

class _ConcreteCalculatorTabState extends ConsumerState<ConcreteCalculatorTab> {
  final lengthCtrl = TextEditingController();
  final widthCtrl = TextEditingController();
  final thicknessCtrl = TextEditingController();
  final countCtrl = TextEditingController(text: "1");
  final customCityCtrl = TextEditingController();
  String selectedElement = "سقف";

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final notifier = ref.read(appProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    "حاسبة الكميات والتكلفة",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: selectedElement,
                          decoration: const InputDecoration(
                            labelText: "نوع العنصر",
                            border: OutlineInputBorder(),
                          ),
                          items: ["سقف", "عمود", "قاعدة"]
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => selectedElement = val!),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: countCtrl,
                          decoration: const InputDecoration(
                            labelText: "العدد",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: lengthCtrl,
                          decoration: const InputDecoration(
                            labelText: "الطول",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: widthCtrl,
                          decoration: const InputDecoration(
                            labelText: "العرض",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: thicknessCtrl,
                    decoration: InputDecoration(
                      labelText: selectedElement == "سقف"
                          ? "السماكة (م)"
                          : "الارتفاع (م)",
                      border: const OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () async {
                      if (lengthCtrl.text.isNotEmpty &&
                          widthCtrl.text.isNotEmpty &&
                          thicknessCtrl.text.isNotEmpty) {
                        await notifier.calculateElement(
                          elementType: selectedElement,
                          count: int.parse(countCtrl.text),
                          length: double.parse(lengthCtrl.text),
                          width: double.parse(widthCtrl.text),
                          heightOrThickness: double.parse(thicknessCtrl.text),
                        );
                        ref.invalidate(historyProvider);
                      }
                    },
                    child: const Text(
                      "احسب",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (state.calculationResult != null) ...[
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFF1E3A8A), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    "نتائج الحساب التقديرية",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const Divider(),
                  _buildResultRow(
                    "حجم الخرسانة:",
                    "${state.calculationResult!['concrete_m3']} m³",
                  ),
                  _buildResultRow(
                    "وزن الحديد:",
                    "${state.calculationResult!['steel_tons']} طن",
                  ),
                  const Divider(),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "التكلفة التقديرية المبدئية",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          "${state.calculationResult!['total_cost']} AED",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text("مشاركة تقرير PDF"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final file = await ReportService.generateMaterialReport(
                        concrete: state.calculationResult!['concrete_m3']
                            .toString(),
                        steel: state.calculationResult!['steel_tons']
                            .toString(),
                      );
                      await Share.shareXFiles([
                        XFile(file.path),
                      ], text: 'تقرير الكميات من Benaa Pro');
                    },
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text("مستشار الصب"),
                  Wrap(
                    spacing: 10,
                    children: ["Dubai", "Abu Dhabi", "Sharjah"]
                        .map(
                          (c) => ActionChip(
                            label: Text(c),
                            onPressed: () => notifier.getWeatherAdvice(c),
                          ),
                        )
                        .toList(),
                  ),
                  if (state.weatherAdvice != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      state.weatherAdvice!['advice'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: state.weatherAdvice!['is_safe']
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildResultRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 15)),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

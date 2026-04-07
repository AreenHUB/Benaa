import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/calculator_provider.dart';
import '../services/report_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController lengthCtrl = TextEditingController();
  final TextEditingController widthCtrl = TextEditingController();
  final TextEditingController thicknessCtrl = TextEditingController();
  final TextEditingController countCtrl = TextEditingController(text: "1");
  final TextEditingController customCityCtrl = TextEditingController();

  String selectedElement = "سقف";

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final notifier = ref.read(appProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Benaa Pro - مساعد المهندس",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF59E0B)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ==========================================
                  // 1. بطاقة حاسبة الكميات والتكلفة
                  // ==========================================
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    labelText: "نوع العنصر",
                                  ),
                                  items: ["سقف", "عمود", "قاعدة"]
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) =>
                                      setState(() => selectedElement = val!),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: _buildTextField(countCtrl, "العدد"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(lengthCtrl, "الطول (م)"),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(widthCtrl, "العرض (م)"),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(
                                  thicknessCtrl,
                                  selectedElement == "سقف"
                                      ? "السماكة (م)"
                                      : "الارتفاع (م)",
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF59E0B),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              if (lengthCtrl.text.isNotEmpty &&
                                  widthCtrl.text.isNotEmpty &&
                                  thicknessCtrl.text.isNotEmpty &&
                                  countCtrl.text.isNotEmpty) {
                                notifier.calculateElement(
                                  elementType: selectedElement,
                                  count: int.parse(countCtrl.text),
                                  length: double.parse(lengthCtrl.text),
                                  width: double.parse(widthCtrl.text),
                                  heightOrThickness: double.parse(
                                    thicknessCtrl.text,
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              "احسب الكميات والتكلفة",
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
                  ),

                  // ==========================================
                  // 2. عرض نتائج الحساب والفاتورة
                  // ==========================================
                  if (state.calculationResult != null) ...[
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF1E3A8A),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "ملخص (${state.calculationResult!['count']} ${state.calculationResult!['element_type']})",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("حجم الخرسانة:"),
                              Text(
                                "${state.calculationResult!['concrete_m3']} m³",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("وزن الحديد:"),
                              Text(
                                "${state.calculationResult!['steel_tons']} Tons",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "التكلفة التقديرية (السوق الإماراتي)",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  "${state.calculationResult!['financials_aed']['total_cost']} AED",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.share),
                            label: const Text("إرسال التقرير (WhatsApp)"),
                            onPressed: () async {
                              final file =
                                  await ReportService.generateMaterialReport(
                                    concrete: state
                                        .calculationResult!['concrete_m3']
                                        .toString(),
                                    steel: state
                                        .calculationResult!['steel_tons']
                                        .toString(),
                                    city: state.weatherAdvice?['city'],
                                    weatherAdvice: state.weatherAdvice != null
                                        ? "Temp: ${state.weatherAdvice!['temperature']}C, Wind: ${state.weatherAdvice!['wind_speed']}m/s"
                                        : null,
                                  );
                              await Share.shareXFiles(
                                [XFile(file.path)],
                                text:
                                    'مرحباً، إليك التقرير والتكلفة المبدئية من Benaa Pro.',
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  // ==========================================
                  // 3. بطاقة مستشار الطقس (التي اختفت وعادت!)
                  // ==========================================
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "مستشار الصب الذكي (الإمارات)",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          const SizedBox(height: 10),

                          Wrap(
                            spacing: 10,
                            children: ["Dubai", "Abu Dhabi", "Sharjah"].map((
                              city,
                            ) {
                              return ActionChip(
                                label: Text(city),
                                backgroundColor: Colors.blue[50],
                                onPressed: () =>
                                    notifier.getWeatherAdvice(city),
                              );
                            }).toList(),
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Divider(),
                          ),

                          TextField(
                            controller: customCityCtrl,
                            decoration: InputDecoration(
                              hintText: "أدخل اسم مدينة أخرى (مثال: Al Ain)",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.search,
                                  color: Color(0xFF1E3A8A),
                                ),
                                onPressed: () {
                                  if (customCityCtrl.text.isNotEmpty) {
                                    FocusScope.of(context).unfocus();
                                    notifier.getWeatherAdvice(
                                      customCityCtrl.text.trim(),
                                    );
                                  }
                                },
                              ),
                            ),
                            onSubmitted: (value) {
                              if (value.isNotEmpty)
                                notifier.getWeatherAdvice(value.trim());
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ==========================================
                  // 4. عرض نتائج مستشار الطقس
                  // ==========================================
                  if (state.weatherAdvice != null) ...[
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: state.weatherAdvice!['is_safe']
                            ? Colors.green[50]
                            : Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: state.weatherAdvice!['is_safe']
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "المدينة: ${state.weatherAdvice!['city']} | الحرارة: ${state.weatherAdvice!['temperature']}°C",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            state.weatherAdvice!['advice'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: state.weatherAdvice!['is_safe']
                                  ? Colors.green[800]
                                  : Colors.red[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ==========================================
                  // 5. عرض الأخطاء (إن وجدت)
                  // ==========================================
                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 20),
                      child: Text(
                        state.error!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

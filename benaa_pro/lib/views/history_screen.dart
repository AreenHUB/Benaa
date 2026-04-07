import 'package:flutter/material.dart';
import '../models/calculation_record.dart';
import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<CalculationRecord> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await HistoryService.getHistory();
    setState(() {
      _history = data;
      _isLoading = false;
    });
  }

  Future<void> _clearAll() async {
    await HistoryService.clearHistory();
    _loadHistory(); // إعادة التحميل لتحديث الشاشة
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "سجل الحسابات",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'مسح السجل',
            onPressed: () {
              // نافذة تأكيد قبل المسح
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("تأكيد المسح"),
                  content: const Text(
                    "هل أنت متأكد من مسح جميع الحسابات السابقة؟",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("إلغاء"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _clearAll();
                      },
                      child: const Text(
                        "نعم، امسح",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
          ? const Center(
              child: Text(
                "لا توجد حسابات سابقة مسجلة.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[50],
                      child: Icon(
                        item.elementType == "سقف"
                            ? Icons.roofing
                            : (item.elementType == "عمود"
                                  ? Icons.view_column
                                  : Icons.foundation),
                        color: const Color(0xFF1E3A8A),
                      ),
                    ),
                    title: Text(
                      "${item.count} ${item.elementType}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          "التاريخ: ${item.date}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "الخرسانة: ${item.concrete} m³ | الحديد: ${item.steel} طن",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    trailing: Text(
                      "${item.totalCost} AED",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

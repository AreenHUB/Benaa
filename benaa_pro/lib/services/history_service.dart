import 'package:shared_preferences/shared_preferences.dart';
import '../models/calculation_record.dart';

class HistoryService {
  static const String _storageKey = 'calculations_history';

  // دالة لحفظ عملية حسابية جديدة
  static Future<void> saveRecord(CalculationRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> historyList = prefs.getStringList(_storageKey) ?? [];

    historyList.insert(0, record.toJson());

    await prefs.setStringList(_storageKey, historyList);
  }

  // دالة لجلب كل السجل
  static Future<List<CalculationRecord>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> historyList = prefs.getStringList(_storageKey) ?? [];

    return historyList.map((item) => CalculationRecord.fromJson(item)).toList();
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}

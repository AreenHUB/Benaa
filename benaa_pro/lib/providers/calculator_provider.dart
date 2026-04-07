import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../core/api_client.dart';
import '../models/calculation_record.dart';
import '../services/history_service.dart';

// حالة الشاشة (هل هي تحمل؟ هل هناك خطأ؟ أم هناك بيانات؟)
class AppState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? calculationResult;
  final Map<String, dynamic>? weatherAdvice;

  AppState({
    this.isLoading = false,
    this.error,
    this.calculationResult,
    this.weatherAdvice,
  });

  AppState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? calculationResult,
    Map<String, dynamic>? weatherAdvice,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      calculationResult: calculationResult ?? this.calculationResult,
      weatherAdvice: weatherAdvice ?? this.weatherAdvice,
    );
  }
}

class AppNotifier extends StateNotifier<AppState> {
  AppNotifier() : super(AppState());

  // دالة حساب السقف
  Future<void> calculateElement({
    required String elementType,
    required int count,
    required double length,
    required double width,
    required double heightOrThickness,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await ApiClient.instance.post(
        '/calculations/structural',
        data: {
          "element_type": elementType,
          "count": count,
          "length": length,
          "width": width,
          "height_or_thickness": heightOrThickness,
          // أرسلنا نسبة حديد تقريبية تعتمد على نوع العنصر
          "steel_ratio": elementType == "سقف"
              ? 120
              : (elementType == "عمود" ? 200 : 90),
        },
      );
      final resultData = response.data['data'];

      // ==========================================
      // الحفظ التلقائي في السجل (الجديد هنا)
      // ==========================================
      final record = CalculationRecord(
        date: DateTime.now().toString().split('.')[0], // لحفظ الوقت والتاريخ
        elementType: resultData['element_type'],
        count: resultData['count'],
        concrete: resultData['concrete_m3'],
        steel: resultData['steel_tons'],
        totalCost: resultData['financials_aed']['total_cost'],
      );
      await HistoryService.saveRecord(record);
      // ==========================================

      state = state.copyWith(isLoading: false, calculationResult: resultData);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "بيانات غير صالحة، يرجى التأكد من الأرقام.",
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "حدث خطأ في الاتصال.");
    }
  }

  // دالة مستشار الطقس
  Future<void> getWeatherAdvice(String city) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await ApiClient.instance.get('/advisor/weather/$city');
      state = state.copyWith(
        isLoading: false,
        weatherAdvice: response.data['data'],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "لم نتمكن من جلب بيانات الطقس.",
      );
    }
  }
}

// الـ Provider الذي سيستخدمه الـ UI للوصول للبيانات
final appProvider = StateNotifierProvider<AppNotifier, AppState>(
  (ref) => AppNotifier(),
);

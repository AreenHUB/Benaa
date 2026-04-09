import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../core/api_client.dart';
import '../models/calculation_record.dart';
import '../services/history_service.dart';

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
        },
      );

      final resultData = response.data['data'];

      print("Received Result: $resultData");

      state = state.copyWith(isLoading: false, calculationResult: resultData);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['error']['message'] ?? "خطأ في الحساب",
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "حدث خطأ غير متوقع");
    }
  }

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
        error: "فشل في جلب بيانات الطقس",
      );
    }
  }
}

final appProvider = StateNotifierProvider<AppNotifier, AppState>(
  (ref) => AppNotifier(),
);

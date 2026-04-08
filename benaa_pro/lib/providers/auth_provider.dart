import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import 'package:dio/dio.dart';

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false);

  Future<String?> login(String email, String password) async {
    try {
      final response = await ApiClient.instance.post(
        '/auth/login',
        data: FormData.fromMap({'username': email, 'password': password}),
      );

      final token = response.data['access_token'];
      final refreshToken = response.data['refresh_token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
      await prefs.setString('refresh_token', refreshToken);
      print("Token Saved: $token");
      state = true;
      return null; // يعني لا يوجد خطأ (نجاح)
    } on DioException catch (e) {
      // السحر هنا: التفريق بين أنواع الأخطاء القادمة من السيرفر
      if (e.response?.statusCode == 429) {
        return "تم حظر محاولات الدخول مؤقتاً (تجاوزت 5 محاولات). يرجى الانتظار دقيقة.";
      } else if (e.response?.statusCode == 400) {
        return "البريد الإلكتروني أو كلمة المرور غير صحيحة.";
      }
      return "حدث خطأ في الاتصال بالخادم.";
    } catch (e) {
      return "حدث خطأ غير متوقع.";
    }
  }

  // أضف هذه الدالة داخل AuthNotifier
  Future<bool> register(String email, String password) async {
    try {
      final response = await ApiClient.instance.post(
        '/auth/register', // الرابط الذي برمجناه في FastAPI
        data: {'email': email, 'password': password},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    state = false;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, bool>(
  (ref) => AuthNotifier(),
);

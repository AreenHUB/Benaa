import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../core/api_client.dart';

class SettingsNotifier extends StateNotifier<String> {
  SettingsNotifier() : super('BENAA PRO');

  Future<void> loadProfile() async {
    try {
      final response = await ApiClient.instance.get('/auth/profile');
      state = response.data['company_name'] ?? 'BENAA PRO';
    } catch (e) {
      state = 'BENAA PRO';
    }
  }

  Future<void> updateCompanyName(String name) async {
    try {
      await ApiClient.instance.put(
        '/auth/profile',
        data: {'company_name': name},
      );
      state = name;
    } catch (e) {
      throw Exception('فشل في حفظ اسم الشركة سحابياً');
    }
  }

  void reset() {
    state = 'BENAA PRO';
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, String>(
  (ref) => SettingsNotifier(),
);

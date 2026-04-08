import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsNotifier extends StateNotifier<String> {
  SettingsNotifier() : super('BENAA PRO') {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('company_name') ?? 'BENAA PRO';
  }

  Future<void> updateCompanyName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('company_name', name);
    state = name;
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, String>(
  (ref) => SettingsNotifier(),
);

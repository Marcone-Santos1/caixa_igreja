import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_preferences_provider.dart';

const _kThemeModePref = 'theme_mode';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._prefs) : super(_readFromPrefs(_prefs));

  final SharedPreferences _prefs;

  static ThemeMode _readFromPrefs(SharedPreferences p) {
    switch (p.getInt(_kThemeModePref) ?? 0) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final v = switch (mode) {
      ThemeMode.light => 1,
      ThemeMode.dark => 2,
      _ => 0,
    };
    await _prefs.setInt(_kThemeModePref, v);
    state = mode;
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.watch(sharedPreferencesProvider));
});

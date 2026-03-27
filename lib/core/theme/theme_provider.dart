import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

/// Shared preferences key for theme mode persistence.
const _kThemeModeKey = 'qdex_theme_mode';

/// User's theme preference: system, light, or dark.
///
/// Defaults to [ThemeMode.system] which follows the OS setting.
/// Persists the user's choice to shared_preferences so it survives restarts.
@Riverpod(keepAlive: true)
class ThemePreference extends _$ThemePreference {
  @override
  ThemeMode build() {
    _loadPersistedTheme();
    return ThemeMode.system;
  }

  /// Loads the persisted theme preference from shared_preferences.
  Future<void> _loadPersistedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kThemeModeKey);
    if (stored != null) {
      final mode = _themeModeFromString(stored);
      if (mode != state) {
        state = mode;
      }
    }
  }

  /// Cycles through System -> Light -> Dark -> System.
  void cycle() {
    final next = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    setThemeMode(next);
  }

  /// Sets the theme mode and persists it.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, _themeModeToString(mode));
  }
}

String _themeModeToString(ThemeMode mode) => switch (mode) {
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
    };

ThemeMode _themeModeFromString(String value) => switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

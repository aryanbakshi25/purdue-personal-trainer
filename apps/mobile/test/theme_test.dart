import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purdue_personal_trainer/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeNotifier', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('initial state is system when no preference saved', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final mode = container.read(themeNotifierProvider);
      expect(mode, ThemeMode.system);
    });

    test('loads saved preference on build', () async {
      await prefs.setString('theme_mode', ThemeMode.dark.name);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final mode = container.read(themeNotifierProvider);
      expect(mode, ThemeMode.dark);
    });

    test('updates state and persists to SharedPreferences', () async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(themeNotifierProvider.notifier);
      await notifier.setThemeMode(ThemeMode.light);

      expect(container.read(themeNotifierProvider), ThemeMode.light);
      expect(prefs.getString('theme_mode'), ThemeMode.light.name);
    });
  });
}

import 'package:flutter/material.dart';

/// Tema terpusat (ThemeData) agar tampilan seluruh layar konsisten.
class AppTheme {
  AppTheme._();

  /// Warna dasar aplikasi.
  static const Color seedColor = Color(0xFF3F51B5);

  /// Jarak standar antar elemen UI.
  static const double spacing = 16;

  /// Tema terang yang dipakai oleh [MaterialApp].
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
      appBarTheme: const AppBarTheme(centerTitle: true),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Konfigurasi aplikasi yang dimuat dari file `.env`.
///
/// Tidak ada kredensial yang ditulis langsung (hardcoded) di kode sumber.
class AppConfig {
  AppConfig._();

  static bool _loaded = false;

  /// Memuat file `.env` dari asset. Aman dipanggil walau file tidak ada:
  /// nilai konfigurasi akan kosong dan [isConfigured] bernilai `false`.
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
      _loaded = true;
    } catch (e) {
      // Hanya jenis error yang dicatat, tidak ada isi konfigurasi.
      debugPrint('Gagal memuat .env (${e.runtimeType}).');
      _loaded = false;
    }
  }

  /// URL dasar API publik, mis. `https://jsonplaceholder.typicode.com`.
  static String get baseUrl => _read('BASE_URL');

  /// API key (dummy) yang dikirim sebagai header. Jangan pernah dicetak ke log.
  static String get apiKey => _read('API_KEY');

  /// `true` jika [baseUrl] sudah terisi.
  static bool get isConfigured => baseUrl.isNotEmpty;

  static String _read(String key) {
    if (!_loaded) return '';
    return (dotenv.maybeGet(key) ?? '').trim();
  }
}

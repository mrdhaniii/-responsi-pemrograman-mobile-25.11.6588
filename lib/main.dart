import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';

/// Titik masuk aplikasi: memuat format tanggal Indonesia dan file `.env`.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  await AppConfig.load();
  runApp(const MyApp());
}

/// Widget akar. [AppProviderWrapper] berada di atas [MaterialApp] sehingga
/// semua layar (termasuk yang di-push lewat Navigator) dapat mengakses state.
class MyApp extends StatelessWidget {
  /// Membuat widget akar aplikasi.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviderWrapper(
      child: MaterialApp(
        title: 'Profil Mahasiswa',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeScreen(),
      ),
    );
  }
}

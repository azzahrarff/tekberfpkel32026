import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';
import 'screens/navigation/bottom_navbar.dart';

Future<void> main() async {
  // Memastikan Flutter siap sebelum menjalankan aplikasi.
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi koneksi Supabase.
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    publishableKey: SupabaseConfig.publishableKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnggaranTerbuka',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const BottomNavbar(),
    );
  }
}

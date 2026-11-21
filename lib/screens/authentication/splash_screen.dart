
import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../navigation/bottom_navbar.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Color navy = Color(0xFF102A43);
  static const Color turquoise = Color(0xFF47C9BD);

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Menampilkan splash selama 2 detik.
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Mengecek apakah pengguna sudah login melalui Supabase.
    final bool isLoggedIn = SupabaseService.isLoggedIn;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => isLoggedIn
            ? const BottomNavbar()
            : const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo sesuai desain Figma.
                Image.asset(
                  'assets/images/logo_light.png',
                  width: 115,
                  height: 115,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 24),

                // Nama aplikasi.
                const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Anggaran',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: 'Terbuka',
                        style: TextStyle(color: turquoise),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 12),

                // Tagline aplikasi.
                const Text(
                  'Uang Publik, Hasilnya Harus Terlihat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

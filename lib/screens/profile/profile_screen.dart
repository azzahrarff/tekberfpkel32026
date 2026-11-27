
import 'package:flutter/material.dart';

import '../../core/services/supabase_service.dart';
import '../authentication/login_screen.dart';
import 'notification_screen.dart';
import 'saved_project_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color navy = Color(0xFF102A43);
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color backgroundColor = Color(0xFFF4F7FB);

  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  // Mengambil data profil dari Supabase.
  Future<Map<String, dynamic>> _loadProfile() async {
    final user = SupabaseService.currentUser;

    if (user == null) {
      return {
        'full_name': 'Pengguna',
        'email': '',
        'phone_number': '',
        'user_role': 'Masyarakat',
        'error': 'Pengguna belum login.',
      };
    }

    try {
      final response = await SupabaseService.client
          .from('profiles')
          .select('full_name, email, phone_number, user_role')
          .eq('auth_user_id', user.id)
          .maybeSingle();

      return {
        'full_name': response?['full_name'] ??
            user.userMetadata?['full_name'] ??
            'Pengguna',
        'email': response?['email'] ?? user.email ?? '',
        'phone_number': response?['phone_number'] ?? '',
        'user_role': response?['user_role'] ?? 'Masyarakat',
        'error': null,
      };
    } catch (error) {
      return {
        'full_name':
            user.userMetadata?['full_name'] ?? 'Pengguna',
        'email': user.email ?? '',
        'phone_number': '',
        'user_role': 'Masyarakat',
        'error': error.toString(),
      };
    }
  }

  // Memuat ulang data profil.
  void _refreshProfile() {
    setState(() {
      _profileFuture = _loadProfile();
    });
  }

  // Keluar dari akun.
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Masuk dengan akun lain'),
        content: const Text(
          'Apakah kamu yakin ingin keluar dari akun ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await SupabaseService.client.auth.signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal keluar dari akun: $error'),
        ),
      );
    }
  }

  // Header aplikasi.
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      color: Colors.white,
      child: Row(
        children: [
          Image.asset(
            'assets/images/logo_dark.png',
            width: 32,
            height: 32,
          ),
          const SizedBox(width: 8),
          const Text(
            'AnggaranTerbuka',
            style: TextStyle(
              color: navy,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const NotificationScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_none,
              color: navy,
            ),
          ),
        ],
      ),
    );
  }

  // Tampilan utama profil.
  Widget _buildProfileContent(
    Map<String, dynamic> profile,
  ) {
    final String fullName = profile['full_name'] ?? 'Pengguna';
    final String? error = profile['error'];

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FC),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.person_outline,
                size: 38,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'PROFIL WARGA',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Halo, $fullName',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: navy,
                fontSize: 23,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Kelola proyek tersimpan, wilayah yang diikuti, '
              'dan pengaturan akun.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF718096),
                fontSize: 13,
                height: 1.6,
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              const Text(
                'Sebagian data profil belum dapat dimuat '
                'dari database.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFB45309),
                  fontSize: 11,
                ),
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: 210,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const SavedProjectScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2860A5),
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Lihat proyek tersimpan',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 13,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _logout,
              child: const Text(
                'Masuk dengan akun lain',
                style: TextStyle(
                  color: Color(0xFF2860A5),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _profileFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: primaryBlue,
                      ),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Gagal memuat profil.',
                            style: TextStyle(color: navy),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _refreshProfile,
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    );
                  }

                  return _buildProfileContent(snapshot.data!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

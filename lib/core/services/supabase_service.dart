import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Mengambil instance Supabase yang sudah diinisialisasi.
  static SupabaseClient get client => Supabase.instance.client;

  // Mengambil informasi user yang sedang login.
  static User? get currentUser => client.auth.currentUser;

  // Mengecek apakah user sudah login.
  static bool get isLoggedIn => currentUser != null;

  // Mengambil ID user yang sedang login.
  static String? get currentUserId => currentUser?.id;
}

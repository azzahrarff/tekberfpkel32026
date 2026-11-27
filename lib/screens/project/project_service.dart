import 'package:supabase_flutter/supabase_flutter.dart';

import 'project_model.dart';

class ProjectService {
  final SupabaseClient _client = Supabase.instance.client;

  // ID profil (tabel profiles) milik user yang sedang login
  Future<int?> _profileId() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final row = await _client
        .from('profiles')
        .select('id')
        .eq('auth_user_id', user.id)
        .maybeSingle();

    return row?['id'] as int?;
  }

  // PROYEK TERSIMPAN
  Future<Set<int>> getSavedProjectIds() async {
    final profileId = await _profileId();
    if (profileId == null) return {};

    final rows = await _client
        .from('saved_projects')
        .select('project_id')
        .eq('profile_id', profileId);

    return rows.map((e) => e['project_id'] as int).toSet();
  }

  Future<void> setSaved(int projectId, bool saved) async {
    final profileId = await _profileId();
    if (profileId == null) {
      throw Exception('Masuk ke akun terlebih dahulu.');
    }

    if (saved) {
      await _client.from('saved_projects').insert({
        'profile_id': profileId,
        'project_id': projectId,
      });
    } else {
      await _client
          .from('saved_projects')
          .delete()
          .eq('profile_id', profileId)
          .eq('project_id', projectId);
    }
  }
  // KATEGORI (id -> nama), dipakai untuk nama kategori di kartu & filter
  Future<Map<int, String>> getCategories() async {
    final rows = await _client
        .from('budget_categories')
        .select('id, category_name')
        .order('category_name');

    return {
      for (final r in rows)
        r['id'] as int: r['category_name'].toString(),
    };
  }

  Future<List<int>> getYears() async {
    final rows = await _client.from('projects').select('fiscal_year');
    final years = rows.map((e) => e['fiscal_year'] as int).toSet().toList()
      ..sort();
    return years;
  }

  Future<List<String>> getDistricts() async {
    final rows = await _client.from('projects').select('district');
    final list = rows
        .map((e) => e['district'])
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
    return list;
  }

  // MENGAMBIL PROYEK
  // Filter tahun, kecamatan, kategori, dan pencarian dijalankan di server.
  // Filter status & rentang anggaran dijalankan di aplikasi supaya tetap
  // aman walau nama kolomnya belum sesuai.
  Future<List<Project>> getProjects(
    ProjectFilter filter, {
    String search = '',
  }) async {
    final categories = await getCategories();

    var query = _client
        .from('projects')
        .select()
        .eq('fiscal_year', filter.year);

    if (filter.district != null) {
      query = query.eq('district', filter.district!);
    }
    if (filter.categoryId != null) {
      query = query.eq('category_id', filter.categoryId!);
    }

    if (search.isNotEmpty) {
      // Karakter khusus dibuang agar tidak merusak sintaks filter or().
      final q = search.replaceAll(RegExp(r'[,()%]'), ' ').trim();
      if (q.isNotEmpty) {
        query = query.or('project_name.ilike.%$q%,district.ilike.%$q%');
      }
    }

    final rows = await query.order('id');

    var projects =
        rows.map((r) => Project.fromMap(r, categories)).toList();

    if (filter.status != null) {
      projects = projects.where((p) => p.status == filter.status).toList();
    }
    if (filter.maxBudget != null) {
      projects = projects
          .where((p) => p.budget != null && p.budget! <= filter.maxBudget!)
          .toList();
    }

    return projects;
  }
}
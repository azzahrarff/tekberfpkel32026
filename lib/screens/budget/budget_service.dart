
import 'package:supabase_flutter/supabase_flutter.dart';

class BudgetService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Mengambil daftar wilayah
  Future<List<Map<String, dynamic>>> getRegions() async {
    final response = await _supabase
        .from('regions')
        .select('id, region_name, region_type')
        .order('region_name');

    return List<Map<String, dynamic>>.from(response);
  }

  // Mengambil daftar kategori anggaran
  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _supabase
        .from('budget_categories')
        .select('id, category_name')
        .order('category_name');

    return List<Map<String, dynamic>>.from(response);
  }

  // Mengambil pilihan tahun dan tingkat pemerintahan
  Future<List<Map<String, dynamic>>> getOptions() async {
    final response = await _supabase
        .from('budgets')
        .select('fiscal_year, government_level');

    return List<Map<String, dynamic>>.from(response);
  }

  // Mengambil data anggaran berdasarkan filter
  Future<List<Map<String, dynamic>>> getBudgets({
    required int year,
    required int regionId,
    String? governmentLevel,
    int? categoryId,
  }) async {
    var query = _supabase
        .from('budgets')
        .select('''
          id,
          fiscal_year,
          government_level,
          total_allocation,
          realized_amount,
          reporting_period,
          region_id,
          category_id,
          dataset_id,
          category:budget_categories(category_name)
        ''')
        .eq('fiscal_year', year)
        .eq('region_id', regionId);

    if (governmentLevel != null) {
      query = query.eq(
        'government_level',
        governmentLevel,
      );
    }

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }

    final response = await query;

    return List<Map<String, dynamic>>.from(response);
  }

  // Mengambil metadata sumber informasi
  Future<List<Map<String, dynamic>>> getDatasets() async {
    final response = await _supabase
        .from('budget_datasets')
        .select()
        .order('last_updated', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Mengambil istilah untuk Pusat Edukasi
  Future<List<Map<String, dynamic>>> getGlossary() async {
    final response = await _supabase
        .from('glossary_terms')
        .select('term_name, definition')
        .order('id');

    return List<Map<String, dynamic>>.from(response);
  }

  // Mengambil data realisasi bulanan berdasarkan filter
  Future<List<Map<String, dynamic>>> getMonthlyRealizations({
    required int year,
    required int regionId,
    String? governmentLevel,
    int? categoryId,
  }) async {
    var query = _supabase
        .from('monthly_realizations')
        .select('''
          realization_month,
          realized_amount,
          budget:budgets!inner(
            fiscal_year,
            region_id,
            government_level,
            category_id
          )
        ''')
        .eq('budget.fiscal_year', year)
        .eq('budget.region_id', regionId);

    if (governmentLevel != null) {
      query = query.eq(
        'budget.government_level',
        governmentLevel,
      );
    }

    if (categoryId != null) {
      query = query.eq(
        'budget.category_id',
        categoryId,
      );
    }

    final response = await query.order(
      'realization_month',
    );

    return List<Map<String, dynamic>>.from(response);
  }

  // Mengonversi nilai numerik dan menangani nilai null
  static double number(dynamic value) {
    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  // Menghitung ringkasan anggaran
  Map<String, double> calculateSummary(
    List<Map<String, dynamic>> budgets,
  ) {
    double allocation = 0;
    double realization = 0;

    for (final budget in budgets) {
      allocation += number(
        budget['total_allocation'],
      );

      realization += number(
        budget['realized_amount'],
      );
    }

    return {
      'allocation': allocation,
      'realization': realization,
      'remaining': allocation - realization,
      'percentage': allocation > 0
          ? (realization / allocation) * 100
          : 0.0,
    };
  }
}
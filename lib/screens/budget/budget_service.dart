
import '../../core/services/supabase_service.dart';

class BudgetService {
  final _supabase = SupabaseService.client;

  Future<List<Map<String, dynamic>>> _pages(
    Future<List<Map<String, dynamic>>> Function(int, int) fetch,
  ) async {
    final rows = <Map<String, dynamic>>[];
    while (true) {
      final page = await fetch(rows.length, rows.length + 199);
      rows.addAll(page);
      if (page.length < 200) return rows;
    }
  }

  Future<List<Map<String, dynamic>>> getProjectDatasets(
    Map<String, dynamic> project,
  ) async {
    final region = project['region_id'];
    final category = project['category_id'];
    final year = project['fiscal_year'];
    if (region == null || category == null || year == null) return [];

    final budgets = await _pages((start, end) => _supabase
        .from('budgets')
        .select('id, dataset:budget_datasets(*)')
        .eq('region_id', region)
        .eq('category_id', category)
        .eq('fiscal_year', year)
        .order('id')
        .range(start, end));
    final datasets = <Object, Map<String, dynamic>>{};
    for (final budget in budgets) {
      final dataset = budget['dataset'];
      if (dataset is Map<String, dynamic> && dataset['id'] != null) {
        datasets[dataset['id']] = dataset;
      }
    }
    return datasets.values.toList();
  }

  // Mengambil daftar wilayah
  Future<List<Map<String, dynamic>>> getRegions() async {
    return _pages((start, end) => _supabase
        .from('regions')
        .select('id, region_name, region_type')
        .order('region_name').order('id').range(start, end));
  }

  // Mengambil daftar kategori anggaran
  Future<List<Map<String, dynamic>>> getCategories() async {
    return _pages((start, end) => _supabase
        .from('budget_categories')
        .select('id, category_name')
        .order('category_name').order('id').range(start, end));
  }

  // Mengambil pilihan tahun dan tingkat pemerintahan
  Future<List<Map<String, dynamic>>> getOptions() async {
    return _pages((start, end) => _supabase
        .from('budgets')
        .select('fiscal_year, government_level, region_id').order('id').range(start, end));
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

    return _pages((start, end) => query.order('id').range(start, end));
  }

  // Mengambil metadata sumber informasi
  Future<List<Map<String, dynamic>>> getDatasets() async {
    return _pages((start, end) => _supabase
        .from('budget_datasets')
        .select()
        .order('last_updated', ascending: false).order('id').range(start, end));
  }

  // Mengambil istilah untuk Pusat Edukasi
  Future<List<Map<String, dynamic>>> getGlossary() async {
    return _pages((start, end) => _supabase
        .from('glossary_terms')
        .select('term_name, definition')
        .order('id').range(start, end));
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

    return _pages((start, end) => query.order('id').range(start, end));
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
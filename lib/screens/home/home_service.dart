import 'package:flutter/foundation.dart';

import '../../core/services/supabase_service.dart';
import '../budget/budget_service.dart';
import '../project/project_model.dart';
import '../project/project_service.dart';

// ============================================================
// MODEL: WILAYAH & PERIODE
// ============================================================

/// Wilayah (baris dari tabel regions).
class Region {
  final int id;
  final String name;
  final String type; // 'Kota' atau 'Kecamatan'
  final String? province; // kolom regions.province, contoh 'Jawa Timur'

  const Region({
    required this.id,
    required this.name,
    required this.type,
    this.province,
  });

  /// Teks lengkap, contoh "Kota Surabaya, Jawa Timur".
  String get fullName =>
      (province == null || province!.isEmpty) ? name : '$name, $province';

  factory Region.fromMap(Map<String, dynamic> map) {
    return Region(
      id: BudgetService.number(map['id']).toInt(),
      name: map['region_name']?.toString() ?? '-',
      type: map['region_type']?.toString() ?? '',
      province: map['province']?.toString(),
    );
  }
}

/// Pilihan wilayah dan tahun anggaran yang sedang aktif.
class RegionPeriod {
  final Region region;
  final int year;

  const RegionPeriod({required this.region, required this.year});
}

/// Pilihan dari halaman Pilih Wilayah & Periode, dipakai di Beranda.
///
/// Disimpan sebagai variabel static supaya pilihan tidak hilang ketika
/// pengguna pindah tab di navigasi bawah lalu kembali ke Beranda.
/// Halaman lain (misalnya Anggaran atau Proyek) juga bisa membacanya
/// nanti kalau kelompok setuju.
final ValueNotifier<RegionPeriod?> selectedRegionPeriod =
    ValueNotifier<RegionPeriod?>(null);

// ============================================================
// MODEL: DATA BERANDA
// ============================================================

/// Alokasi anggaran untuk satu kategori.
class CategoryAllocation {
  final int categoryId;
  final String name;
  final double allocation;

  /// Persentase terhadap total pagu (0.0 sampai 1.0).
  final double share;

  const CategoryAllocation({
    required this.categoryId,
    required this.name,
    required this.allocation,
    required this.share,
  });
}

/// Kategori dengan kenaikan pagu terbesar dibanding tahun sebelumnya.
class BudgetInsight {
  final String categoryName;
  final int previousYear;
  final double previousAllocation;
  final double currentAllocation;

  /// Perubahan dalam persen, misalnya 11.4 berarti naik 11,4%.
  final double changePercent;

  const BudgetInsight({
    required this.categoryName,
    required this.previousYear,
    required this.previousAllocation,
    required this.currentAllocation,
    required this.changePercent,
  });
}

/// Ringkasan anggaran untuk wilayah + tahun terpilih.
class BudgetOverview {
  final double totalAllocation; // pagu anggaran
  final double realized; // realisasi keuangan
  final List<CategoryAllocation> categories;
  final String? reportingPeriod; // contoh: Januari-Desember 2026
  final DateTime? lastUpdated; // dari budget_datasets.last_updated
  final String? dataStatus; // contoh: Simulasi
  final BudgetInsight? insight;

  const BudgetOverview({
    required this.totalAllocation,
    required this.realized,
    required this.categories,
    required this.reportingPeriod,
    required this.lastUpdated,
    required this.dataStatus,
    required this.insight,
  });

  /// Sisa pagu yang belum terealisasi (tidak pernah negatif).
  double get remaining =>
      (totalAllocation - realized).clamp(0, double.infinity).toDouble();

  /// Realisasi terhadap pagu (0.0 sampai 1.0). Aman dari pembagian nol.
  double get realizationRatio =>
      totalAllocation > 0 ? (realized / totalAllocation).clamp(0.0, 1.0) : 0.0;

  bool get isEmpty => totalAllocation <= 0 && categories.isEmpty;
}

/// Identitas pengguna untuk sapaan dan avatar di header.
class HomeUser {
  final String? fullName;
  final bool hasUnreadNotification;

  const HomeUser({required this.fullName, required this.hasUnreadNotification});

  /// Nama depan untuk sapaan "Selamat datang, ...".
  String? get firstName {
    final name = fullName?.trim() ?? '';
    if (name.isEmpty) return null;
    return name.split(RegExp(r'\s+')).first;
  }

  /// Dua huruf inisial untuk avatar, contoh "Ayu Rahma" -> "AR".
  String get initials {
    final parts = (fullName ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

// ============================================================
// SERVICE
// ============================================================

/// Mengambil data untuk Halaman Beranda dan halaman Pilih Wilayah & Periode.
///
/// Memakai BudgetService dan ProjectService buatan kelompok supaya cara
/// mengambil datanya sama dengan halaman Anggaran dan Proyek.
class HomeService {
  final _supabase = SupabaseService.client;
  final BudgetService _budgetService = BudgetService();
  final ProjectService _projectService = ProjectService();

  // ---------------------------------------------------------------
  // WILAYAH & TAHUN
  // ---------------------------------------------------------------

  /// Daftar wilayah bertipe Kota beserta provinsinya (sesuai keputusan:
  /// kecamatan tidak ditampilkan karena data anggaran ada di level kota).
  /// Diurutkan berdasarkan id supaya urutannya sama dengan Figma:
  /// Kota Surabaya, Kota Malang, Kota Semarang.
  Future<List<Region>> getCityRegions() async {
    final rows = await _supabase
        .from('regions')
        .select('id, region_name, region_type, province')
        .eq('region_type', 'Kota')
        .order('id');

    return rows.map(Region.fromMap).toList();
  }

  /// Daftar tahun anggaran yang tersedia di tabel budgets, terbaru dulu.
  Future<List<int>> getBudgetYears() async {
    final rows = await _budgetService.getOptions();

    final years =
        rows
            .map((row) => BudgetService.number(row['fiscal_year']).toInt())
            .where((year) => year > 0)
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    return years;
  }

  /// Pilihan awal ketika Beranda pertama kali dibuka:
  /// wilayah Kota pertama (Kota Surabaya) dan tahun anggaran terbaru.
  Future<RegionPeriod> getDefaultRegionPeriod() async {
    final results = await Future.wait([getCityRegions(), getBudgetYears()]);

    final regions = results[0] as List<Region>;
    final years = results[1] as List<int>;

    if (regions.isEmpty) {
      throw Exception('Data wilayah bertipe Kota belum tersedia.');
    }

    return RegionPeriod(
      region: regions.first,
      year: years.isNotEmpty ? years.first : DateTime.now().year,
    );
  }

  // ---------------------------------------------------------------
  // RINGKASAN ANGGARAN
  // ---------------------------------------------------------------

  /// Pagu, realisasi, distribusi kategori, periode, dan insight
  /// untuk wilayah dan tahun yang dipilih.
  Future<BudgetOverview> getBudgetOverview(RegionPeriod selection) async {
    final results = await Future.wait([
      _budgetService.getBudgets(
        year: selection.year,
        regionId: selection.region.id,
        governmentLevel: selection.region.type,
      ),
      _budgetService.getBudgets(
        year: selection.year - 1,
        regionId: selection.region.id,
        governmentLevel: selection.region.type,
      ),
      _budgetService.getDatasets(),
    ]);

    final budgets = results[0];
    final previousBudgets = results[1];
    final datasets = results[2];

    // Jumlahkan per kategori dulu supaya satu kategori tidak dihitung ganda.
    final allocations = _sumByCategory(budgets, 'total_allocation');
    final previousAllocations = _sumByCategory(
      previousBudgets,
      'total_allocation',
    );
    final categoryNames = _categoryNames(budgets);

    final double totalAllocation = allocations.values.fold(
      0.0,
      (sum, value) => sum + value,
    );
    final double realized = budgets.fold(
      0.0,
      (sum, budget) => sum + BudgetService.number(budget['realized_amount']),
    );

    final categories =
        allocations.entries
            .map(
              (entry) => CategoryAllocation(
                categoryId: entry.key,
                name: categoryNames[entry.key] ?? 'Lainnya',
                allocation: entry.value,
                share: totalAllocation > 0
                    ? entry.value / totalAllocation
                    : 0.0,
              ),
            )
            .toList()
          ..sort((a, b) => b.allocation.compareTo(a.allocation));

    // Periode pelaporan diambil dari baris anggaran pertama yang terisi.
    final String? reportingPeriod = budgets
        .map((budget) => budget['reporting_period']?.toString())
        .firstWhere(
          (period) => period != null && period.trim().isNotEmpty,
          orElse: () => null,
        );

    // Dataset yang dipakai oleh baris-baris anggaran tahun ini.
    final datasetIds = budgets
        .map((budget) => budget['dataset_id'])
        .where((id) => id != null)
        .toSet();
    final usedDatasets = datasets
        .where((dataset) => datasetIds.contains(dataset['id']))
        .toList();

    DateTime? lastUpdated;
    String? dataStatus;
    for (final dataset in usedDatasets) {
      final date = DateTime.tryParse(dataset['last_updated']?.toString() ?? '');
      if (date != null && (lastUpdated == null || date.isAfter(lastUpdated))) {
        lastUpdated = date;
      }
      dataStatus ??= dataset['data_status']?.toString();
    }

    return BudgetOverview(
      totalAllocation: totalAllocation,
      realized: realized,
      categories: categories,
      reportingPeriod: reportingPeriod,
      lastUpdated: lastUpdated,
      dataStatus: dataStatus,
      insight: _buildInsight(
        current: allocations,
        previous: previousAllocations,
        names: categoryNames,
        previousYear: selection.year - 1,
      ),
    );
  }

  Map<int, double> _sumByCategory(
    List<Map<String, dynamic>> budgets,
    String column,
  ) {
    final result = <int, double>{};
    for (final budget in budgets) {
      final categoryId = BudgetService.number(budget['category_id']).toInt();
      result[categoryId] =
          (result[categoryId] ?? 0) + BudgetService.number(budget[column]);
    }
    return result;
  }

  Map<int, String> _categoryNames(List<Map<String, dynamic>> budgets) {
    final result = <int, String>{};
    for (final budget in budgets) {
      final categoryId = BudgetService.number(budget['category_id']).toInt();
      final category = budget['category'];
      if (category is Map && category['category_name'] != null) {
        result[categoryId] = category['category_name'].toString();
      }
    }
    return result;
  }

  /// Mencari kategori dengan kenaikan pagu terbesar.
  /// Hasilnya null kalau tahun sebelumnya tidak punya data pembanding.
  BudgetInsight? _buildInsight({
    required Map<int, double> current,
    required Map<int, double> previous,
    required Map<int, String> names,
    required int previousYear,
  }) {
    BudgetInsight? best;

    for (final entry in current.entries) {
      final double before = previous[entry.key] ?? 0;
      if (before <= 0) continue; // hindari pembagian dengan nol

      final double change = (entry.value - before) / before * 100;
      if (best == null || change > best.changePercent) {
        best = BudgetInsight(
          categoryName: names[entry.key] ?? 'Lainnya',
          previousYear: previousYear,
          previousAllocation: before,
          currentAllocation: entry.value,
          changePercent: change,
        );
      }
    }

    return best;
  }

  // ---------------------------------------------------------------
  // PROYEK DI SEKITAR WILAYAH
  // ---------------------------------------------------------------

  /// Proyek terbaru di wilayah terpilih (termasuk kecamatan di dalamnya).
  /// Proyek di database tercatat di level kecamatan, jadi kita cari dulu
  /// kecamatan yang parent_region_id-nya sama dengan kota terpilih.
  Future<List<Project>> getNearbyProjects(
    RegionPeriod selection, {
    int limit = 3,
  }) async {
    final children = await _supabase
        .from('regions')
        .select('id')
        .eq('parent_region_id', selection.region.id);

    final regionIds = <int>{
      selection.region.id,
      for (final row in children) BudgetService.number(row['id']).toInt(),
    }.toList();

    // Kedua query dijalankan bersamaan supaya lebih cepat.
    final categoriesFuture = _projectService.getCategories();
    final rowsFuture = _supabase
        .from('projects')
        .select()
        .eq('fiscal_year', selection.year)
        .inFilter('region_id', regionIds)
        .order('last_updated', ascending: false)
        .order('id')
        .limit(limit);

    final categories = await categoriesFuture;
    final rows = await rowsFuture;

    return rows.map((row) => Project.fromMap(row, categories)).toList();
  }

  /// ID proyek yang sudah disimpan pengguna (kosong kalau belum login).
  Future<Set<int>> getSavedProjectIds() {
    return _projectService.getSavedProjectIds();
  }

  /// Menyimpan atau menghapus proyek dari daftar Proyek Tersimpan.
  Future<void> setProjectSaved(int projectId, bool saved) {
    return _projectService.setSaved(projectId, saved);
  }

  // ---------------------------------------------------------------
  // PENGGUNA
  // ---------------------------------------------------------------

  /// Nama pengguna dan status notifikasi belum dibaca.
  ///
  /// currentUser.id (UUID) dicocokkan ke profiles.auth_user_id,
  /// lalu profiles.id (BIGINT) dipakai untuk tabel notifications.
  Future<HomeUser> getCurrentUser() async {
    final user = SupabaseService.currentUser;
    if (user == null) {
      return const HomeUser(fullName: null, hasUnreadNotification: false);
    }

    final profile = await _supabase
        .from('profiles')
        .select('id, full_name')
        .eq('auth_user_id', user.id)
        .maybeSingle();

    final String? fullName =
        profile?['full_name']?.toString() ??
        user.userMetadata?['full_name']?.toString();

    bool hasUnread = false;
    if (profile?['id'] != null) {
      final unread = await _supabase
          .from('notifications')
          .select('id')
          .eq('profile_id', profile!['id'])
          .eq('is_read', false)
          .limit(1);
      hasUnread = unread.isNotEmpty;
    }

    return HomeUser(fullName: fullName, hasUnreadNotification: hasUnread);
  }
}

// ============================================================
// FORMAT ANGKA
// ============================================================

/// Memecah nominal menjadi angka dan satuan untuk kartu ringkasan,
/// contoh 5200000000000 -> ('Rp5,20', 'triliun').
(String, String) splitRupiah(double value) {
  String fixed(double number) => number.toStringAsFixed(2).replaceAll('.', ',');

  if (value >= 1e12) return ('Rp${fixed(value / 1e12)}', 'triliun');
  if (value >= 1e9) return ('Rp${fixed(value / 1e9)}', 'miliar');
  if (value >= 1e6) return ('Rp${fixed(value / 1e6)}', 'juta');
  return ('Rp${value.toStringAsFixed(0)}', '');
}

/// Persen dengan koma, contoh 0.654 -> "65,4%".
String formatPercent(double ratio) {
  return '${(ratio * 100).toStringAsFixed(1).replaceAll('.', ',')}%';
}

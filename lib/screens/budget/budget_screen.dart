
import 'package:flutter/material.dart';
import 'budget_service.dart';
import 'education_screen.dart';
import 'information_source_screen.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  static const Color navy = Color(0xFF172F52);
  static const Color blue = Color(0xFF2861A0);
  static const Color teal = Color(0xFF18A394);
  static const Color background = Color(0xFFF5F7FA);
  static const Color grey = Color(0xFF8190A5);

  final BudgetService service = BudgetService();

  String selectedYear = '2026';
  String selectedLevel = 'Kota';
  String selectedRegion = 'Kota Surabaya';
  String selectedCategory = 'Semua kategori';

  List<String> years = [];
  List<String> levels = [];

  List<Map<String, dynamic>> regions = [];
  List<Map<String, dynamic>> categoryRows = [];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> budgets = [];

  List<double> trend = [];
  Map<String, double> summary = {};

  double? previous;
  double? current;

  bool loading = true;
  String? error;
  int request = 0;

  // FORMAT NOMINAL RUPIAH
  String money(double n) {
    if (n.abs() >= 1e12) {
      return 'Rp${(n / 1e12).toStringAsFixed(2).replaceAll('.', ',')} T';
    }

    if (n.abs() >= 1e9) {
      return 'Rp${(n / 1e9).toStringAsFixed(2).replaceAll('.', ',')} M';
    }

    if (n.abs() >= 1e6) {
      return 'Rp${(n / 1e6).toStringAsFixed(2).replaceAll('.', ',')} jt';
    }

    return 'Rp${n.toStringAsFixed(0)}';
  }

  String pct(double n) {
    return '${n.toStringAsFixed(1).replaceAll('.', ',')}%';
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  // MENGAMBIL DATA AWAL SUPABASE
  Future<void> initialize() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final r = await service.getRegions();
      final c = await service.getCategories();
      final o = await service.getOptions();

      if (!mounted) return;

      setState(() {
        regions = r;
        categoryRows = c;

        years = o
            .map((e) => e['fiscal_year'].toString())
            .toSet()
            .toList()
          ..sort();

        levels = o
            .map((e) => e['government_level'])
            .whereType<String>()
            .toSet()
            .toList()
          ..sort();

        if (years.isNotEmpty &&
            !years.contains(selectedYear)) {
          selectedYear = years.last;
        }

        if (levels.isNotEmpty &&
            !levels.contains(selectedLevel)) {
          selectedLevel = levels.first;
        }

        if (regions.isNotEmpty &&
            !regions.any(
              (e) => e['region_name'] == selectedRegion,
            )) {
          selectedRegion =
              regions.first['region_name'].toString();
        }
      });

      await load();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = 'Gagal memuat data: $e';
        loading = false;
      });
    }
  }

  // MENGAMBIL ANGGARAN BERDASARKAN FILTER
  Future<void> load() async {
    final token = ++request;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      if (years.isEmpty ||
          regions.isEmpty ||
          levels.isEmpty) {
        if (mounted) {
          setState(() {
            budgets = [];
            loading = false;
          });
        }
        return;
      }

      final year = int.parse(selectedYear);

      final region = regions.firstWhere(
        (e) => e['region_name'] == selectedRegion,
      )['id'] as int;

      final level = selectedLevel;

      final category =
          selectedCategory == 'Semua kategori'
              ? null
              : categoryRows.firstWhere(
                  (e) =>
                      e['category_name'] ==
                      selectedCategory,
                )['id'] as int;

      final rows = await service.getBudgets(
        year: year,
        regionId: region,
        governmentLevel: level,
        categoryId: category,
      );

      final monthly =
          await service.getMonthlyRealizations(
        year: year,
        regionId: region,
        governmentLevel: level,
        categoryId: category,
      );

      final comparisonRows = await service.getBudgets(
        year: year - 1,
        regionId: region,
        governmentLevel: level,
        categoryId: category,
      );

      final totals = service.calculateSummary(rows);

      // DISTRIBUSI KATEGORI
      final grouped = <String, double>{};

      for (final row in rows) {
        final name =
            row['category']?['category_name']
                    ?.toString() ??
                'Lainnya';

        grouped[name] = (grouped[name] ?? 0) +
            BudgetService.number(
              row['total_allocation'],
            );
      }

      final palette = [
        teal,
        blue,
        const Color(0xFF78C5BF),
        const Color(0xFF8DA4BF),
        const Color(0xFFB4C5D8),
        navy,
      ];

      final distribution = grouped.entries.toList()
        ..sort(
          (a, b) => b.value.compareTo(a.value),
        );

      final max = grouped.values.fold<double>(
        0,
        (a, b) => a > b ? a : b,
      );

      // REALISASI BULANAN
      final months = <int, double>{};

      for (final row in monthly) {
        final rawMonth =
            row['realization_month'].toString();

        final date = DateTime.tryParse(rawMonth);

        final month =
            date?.month ?? int.tryParse(rawMonth);

        if (month != null &&
            month >= 1 &&
            month <= 12) {
          months[month] = (months[month] ?? 0) +
              BudgetService.number(
                row['realized_amount'],
              );
        }
      }

      double cumulative = 0;
      final points = <double>[];

      if (months.isNotEmpty &&
          totals['allocation']! > 0) {
        final last = months.keys.reduce(
          (a, b) => a > b ? a : b,
        );

        for (int m = 1; m <= last; m++) {
          cumulative += months[m] ?? 0;

          points.add(
            cumulative /
                totals['allocation']! *
                100,
          );
        }
      }

      if (!mounted || token != request) return;

      setState(() {
        budgets = rows;
        summary = totals;
        trend = points;

        categories = List.generate(
          distribution.length,
          (i) => {
            'name': distribution[i].key,
            'amount': money(distribution[i].value),
            'value': max > 0
                ? distribution[i].value / max
                : 0.0,
            'color': palette[i % palette.length],
          },
        );

        previous = comparisonRows.isEmpty
            ? null
            : service.calculateSummary(
                comparisonRows,
              )['allocation'];

        current =
            rows.isEmpty ? null : totals['allocation'];

        loading = false;
      });
    } catch (e) {
      if (!mounted || token != request) return;

      setState(() {
        error = 'Gagal memuat anggaran: $e';
        loading = false;
      });
    }
  }

  void change(VoidCallback update) {
    setState(update);
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'education',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const EducationScreen(),
                ),
              );
            },
            label: const Text('Pusat Edukasi'),
            icon: const Icon(Icons.school_outlined),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'information',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      InformationSourceScreen(
  year: int.tryParse(selectedYear),
),
                ),
              );
            },
            label: const Text('Dasar Informasi'),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  18, 18, 18, 120,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _buildSimulationLabel(),
                    const SizedBox(height: 24),
                    _buildTitle(),
                    const SizedBox(height: 26),
                    _buildFilters(),
                    const SizedBox(height: 18),

                    if (loading)
                      const Padding(
                        padding: EdgeInsets.all(30),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: teal,
                          ),
                        ),
                      )
                    else if (error != null)
                      _whiteCard(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 35,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              error!,
                              textAlign: TextAlign.center,
                            ),
                            TextButton(
                              onPressed: initialize,
                              child: const Text('Coba lagi'),
                            ),
                          ],
                        ),
                      )
                    else if (budgets.isEmpty)
                      _whiteCard(
                        child: const Column(
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              color: grey,
                              size: 40,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Data anggaran belum tersedia',
                              style: TextStyle(
                                color: navy,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Coba pilih tahun, wilayah, atau kategori lainnya.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: grey),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      _buildSummaryCard(
                        'Total anggaran',
                        money(summary['allocation']!),
                        'Pagu tahun $selectedYear',
                        navy,
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryCard(
                        'Realisasi keuangan',
                        money(summary['realization']!),
                        '${pct(summary['percentage']!)} terhadap pagu',
                        blue,
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryCard(
                        'Belum terealisasi',
                        money(summary['remaining']!),
                        budgets.first['reporting_period']
                                ?.toString() ??
                            'Periode tidak tersedia',
                        Colors.white,
                        darkText: true,
                      ),
                      const SizedBox(height: 22),
                      _buildDistribution(),
                      const SizedBox(height: 22),
                      _buildTrend(),
                      const SizedBox(height: 22),
                      _buildComparison(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader() {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE4EAF1),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: navy,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 10),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.7,
              ),
              children: [
                TextSpan(
                  text: 'Anggaran',
                  style: TextStyle(color: navy),
                ),
                TextSpan(
                  text: 'Terbuka',
                  style: TextStyle(color: blue),
                ),
              ],
            ),
          ),
          const Spacer(),
          Stack(
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                size: 27,
                color: navy,
              ),
              Positioned(
                right: 1,
                top: 1,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          const CircleAvatar(
            radius: 19,
            backgroundColor: Color(0xFFDCEAF7),
            child: Text(
              'AR',
              style: TextStyle(
                color: blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // LABEL SIMULASI
  Widget _buildSimulationLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E9),
        border: Border.all(
          color: const Color(0xFFF2D49B),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 15,
            color: Color(0xFF956329),
          ),
          SizedBox(width: 7),
          Flexible(
            child: Text(
              'DATA SIMULASI — BUKAN DATA RESMI',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Color(0xFF956329),
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // JUDUL HALAMAN
  Widget _buildTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'JELAJAHI ANGGARAN',
                style: TextStyle(
                  color: grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.3,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Pahami anggaran kotamu',
                style: TextStyle(
                  color: navy,
                  fontSize: 27,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -1,
                ),
              ),
              SizedBox(height: 9),
              Text(
                'Telusuri alokasi dan realisasi anggaran berdasarkan kategori.',
                style: TextStyle(
                  color: grey,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 55,
          height: 49,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFFD8E2ED),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.download_outlined,
            color: navy,
            size: 25,
          ),
        ),
      ],
    );
  }

  // FILTER ANGGARAN
  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFDCE5EF),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _filterDropdown(
                  'Tahun',
                  selectedYear,
                  years,
                  (value) => change(
                    () => selectedYear = value!,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _filterDropdown(
                  'Tingkat pemerintahan',
                  selectedLevel,
                  levels,
                  (value) => change(
                    () => selectedLevel = value!,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _filterDropdown(
                  'Wilayah',
                  selectedRegion,
                  regions
                      .map(
                        (e) =>
                            e['region_name'].toString(),
                      )
                      .toSet()
                      .toList(),
                  (value) => change(
                    () => selectedRegion = value!,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _filterDropdown(
                  'Kategori',
                  selectedCategory,
                  {
                    'Semua kategori',
                    ...categoryRows.map(
                      (e) =>
                          e['category_name'].toString(),
                    ),
                  }.toList(),
                  (value) => change(
                    () => selectedCategory = value!,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: grey,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFBFD),
            border: Border.all(
              color: const Color(0xFFDCE5EF),
            ),
            borderRadius: BorderRadius.circular(9),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value)
                  ? value
                  : null,
              hint: const Text('Pilih'),
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                size: 19,
              ),
              style: const TextStyle(
                color: navy,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: loading || items.isEmpty
                  ? null
                  : (value) {
                      if (value != null) {
                        onChanged(value);
                      }
                    },
            ),
          ),
        ),
      ],
    );
  }

  // KARTU RINGKASAN
  Widget _buildSummaryCard(
    String title,
    String amount,
    String description,
    Color color, {
    bool darkText = false,
  }) {
    final textColor =
        darkText ? navy : Colors.white;

    final secondaryColor = darkText
        ? grey
        : Colors.white.withValues(alpha: 0.7);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        border: darkText
            ? Border.all(
                color: const Color(0xFFDCE5EF),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: secondaryColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: TextStyle(
              color: textColor,
              fontSize: 29,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            description,
            style: TextStyle(
              color: secondaryColor,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // DISTRIBUSI ANGGARAN
  Widget _buildDistribution() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribusi anggaran',
            style: TextStyle(
              color: navy,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Menurut kategori · dalam Rupiah',
            style: TextStyle(
              color: grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 27),
          ...categories.map((item) {
            return Padding(
              padding: const EdgeInsets.only(
                bottom: 20,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      item['name'].toString(),
                      style: const TextStyle(
                        color: grey,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: (item['value'] as num)
                            .toDouble()
                            .clamp(0.0, 1.0)
                            .toDouble(),
                        minHeight: 12,
                        backgroundColor:
                            const Color(0xFFE9EEF3),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(
                          item['color'] as Color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 75,
                    child: Text(
                      item['amount'].toString(),
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // GRAFIK TREN REALISASI
  Widget _buildTrend() {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr',
      'Mei', 'Jun', 'Jul', 'Agu',
      'Sep', 'Okt', 'Nov', 'Des',
    ];

    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tren realisasi $selectedYear',
            style: const TextStyle(
              color: navy,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Persentase kumulatif terhadap pagu',
            style: TextStyle(
              color: grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 28),

          if (trend.isEmpty)
            const Text(
              'Data realisasi bulanan belum tersedia.',
              style: TextStyle(color: grey),
            )
          else ...[
            SizedBox(
              height: 160,
              width: double.infinity,
              child: CustomPaint(
                painter: TrendChartPainter(trend),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: List.generate(
                trend.length,
                (i) => Expanded(
                  child: Text(
                    i.isEven ||
                            i == trend.length - 1
                        ? monthNames[i]
                        : '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: grey,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  pct(trend.last),
                  style: const TextStyle(
                    color: teal,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Realisasi sampai ${monthNames[trend.length - 1]}',
                    style: const TextStyle(
                      color: grey,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // PERBANDINGAN TAHUNAN
  Widget _buildComparison() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PERBANDINGAN TAHUNAN',
            style: TextStyle(
              color: grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            selectedCategory == 'Semua kategori'
                ? 'Total alokasi'
                : 'Alokasi $selectedCategory',
            style: const TextStyle(
              color: navy,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cakupan wilayah dan kategori yang sebanding.',
            style: TextStyle(
              color: grey,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${int.parse(selectedYear) - 1}',
                      style: const TextStyle(
                        color: grey,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      previous == null
                          ? 'Tidak tersedia'
                          : money(previous!),
                      style: const TextStyle(
                        color: navy,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: navy,
                size: 25,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedYear,
                      style: const TextStyle(
                        color: grey,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      current == null
                          ? 'Tidak tersedia'
                          : money(current!),
                      style: const TextStyle(
                        color: navy,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              _GrowthBadge(
                previous == null ||
                        previous == 0 ||
                        current == null
                    ? null
                    : (current! - previous!) /
                        previous! *
                        100,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // KOMPONEN KARTU PUTIH
  Widget _whiteCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFDCE5EF),
        ),
        borderRadius: BorderRadius.circular(17),
      ),
      child: child,
    );
  }
}

// BADGE PERTUMBUHAN ANGGARAN
class _GrowthBadge extends StatelessWidget {
  final double? growth;

  const _GrowthBadge(this.growth);

  @override
  Widget build(BuildContext context) {
    final negative = growth != null && growth! < 0;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: negative
            ? const Color(0xFFFFEBEE)
            : const Color(0xFFE7F5ED),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        growth == null
            ? 'N/A'
            : '${negative ? '↓' : '↑'} ${growth!.abs().toStringAsFixed(1).replaceAll('.', ',')}%',
        style: TextStyle(
          color: negative
              ? Colors.red
              : const Color(0xFF218A5D),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// CUSTOM PAINTER GRAFIK REALISASI
class TrendChartPainter extends CustomPainter {
  final List<double> values;

  TrendChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final max = values.fold<double>(
      100,
      (a, b) => a > b ? a : b,
    );

    final points = List.generate(
      values.length,
      (i) => Offset(
        values.length == 1
            ? size.width / 2
            : size.width * i / (values.length - 1),
        size.height * (1 - values[i] / max),
      ),
    );

    final path = Path()
      ..moveTo(
        points.first.dx,
        points.first.dy,
      );

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      final controlPoint1 = Offset(
        p1.dx + (p2.dx - p1.dx) / 2,
        p1.dy,
      );

      final controlPoint2 = Offset(
        p1.dx + (p2.dx - p1.dx) / 2,
        p2.dy,
      );

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p2.dx,
        p2.dy,
      );
    }

    final fillPath = Path.from(path)
      ..lineTo(
        points.last.dx,
        size.height,
      )
      ..lineTo(
        points.first.dx,
        size.height,
      )
      ..close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x5578CFC4),
          Color(0x00FFFFFF),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF169E91)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    if (points.length == 1) {
      canvas.drawCircle(
        points.first,
        4,
        Paint()..color = const Color(0xFF169E91),
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant TrendChartPainter oldDelegate,
  ) {
    return oldDelegate.values != values;
  }
}
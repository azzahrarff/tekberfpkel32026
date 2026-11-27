import 'package:flutter/material.dart';

import 'project_model.dart';
import 'project_service.dart';

class ProjectFilterScreen extends StatefulWidget {
  final ProjectFilter initial;

  const ProjectFilterScreen({super.key, required this.initial});

  @override
  State<ProjectFilterScreen> createState() => _ProjectFilterScreenState();
}

class _ProjectFilterScreenState extends State<ProjectFilterScreen> {
  static const Color navy = Color(0xFF172F52);
  static const Color blue = Color(0xFF2861A0);
  static const Color background = Color(0xFFF5F7FA);
  static const Color grey = Color(0xFF8190A5);
  static const Color border = Color(0xFFDCE5EF);

  static const String allDistricts = 'Semua kecamatan';
  static const String allCategories = 'Semua kategori';
  static const String allStatus = 'Semua status';

  // Slider anggaran: 0 - 5 miliar. Posisi maksimum berarti tanpa batas.
  static const double maxSlider = 5e9;

  final ProjectService _service = ProjectService();

  List<String> _districts = [];
  List<int> _years = [];
  Map<int, String> _categories = {};

  late int _year;
  late String _district;
  late String _category;
  late String _status;
  late double _budget;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final f = widget.initial;
    _year = f.year;
    _district = f.district ?? allDistricts;
    _category = f.categoryName ?? allCategories;
    _status = f.status ?? allStatus;
    _budget = f.maxBudget ?? maxSlider;
    _loadOptions();
  }

  // MENGAMBIL PILIHAN FILTER DARI SUPABASE
  Future<void> _loadOptions() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final districts = await _service.getDistricts();
      final years = await _service.getYears();
      final categories = await _service.getCategories();

      if (!mounted) return;

      setState(() {
        _districts = districts;
        _years = years;
        _categories = categories;

        if (!_years.contains(_year) && _years.isNotEmpty) {
          _year = _years.last;
        }
        if (_district != allDistricts && !_districts.contains(_district)) {
          _district = allDistricts;
        }
        if (_category != allCategories &&
            !_categories.containsValue(_category)) {
          _category = allCategories;
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat pilihan filter: $e';
        _loading = false;
      });
    }
  }

  void _reset() {
    setState(() {
      _district = allDistricts;
      _category = allCategories;
      _status = allStatus;
      _budget = maxSlider;
    });
  }

  void _apply() {
    int? categoryId;
    if (_category != allCategories) {
      categoryId = _categories.entries
          .firstWhere((e) => e.value == _category)
          .key;
    }

    Navigator.pop(
      context,
      ProjectFilter(
        year: _year,
        district: _district == allDistricts ? null : _district,
        categoryId: categoryId,
        categoryName: _category == allCategories ? null : _category,
        status: _status == allStatus ? null : _status,
        maxBudget: _budget >= maxSlider ? null : _budget,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.chevron_left, color: blue),
                      label: const Text('Kembali',
                          style: TextStyle(color: blue)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'FILTER PROYEK',
                      style: TextStyle(
                        color: grey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Saring proyek',
                      style: TextStyle(
                        color: navy,
                        fontSize: 27,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Persempit hasil berdasarkan wilayah, kategori, instansi, dan status.',
                      style:
                          TextStyle(color: grey, fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 22),
                    _buildCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Column(
        children: [
          Text(_error!, textAlign: TextAlign.center),
          TextButton(
              onPressed: _loadOptions, child: const Text('Coba lagi')),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dropdown(
            'Kecamatan',
            _district,
            [allDistricts, ..._districts],
            (v) => setState(() => _district = v),
          ),
          _dropdown(
            'Tahun',
            _year.toString(),
            _years.map((e) => e.toString()).toList(),
            (v) => setState(() => _year = int.parse(v)),
          ),
          _dropdown(
            'Kategori',
            _category,
            [allCategories, ..._categories.values],
            (v) => setState(() => _category = v),
          ),
          _dropdown(
            'Status',
            _status,
            [allStatus, ...ProjectStatus.all],
            (v) => setState(() => _status = v),
          ),

          // Rentang anggaran
          const Text(
            'Rentang anggaran',
            style: TextStyle(
              color: Color(0xFF52627A),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Slider(
            value: _budget,
            min: 0,
            max: maxSlider,
            divisions: 50,
            activeColor: blue,
            onChanged: (v) => setState(() => _budget = v),
          ),
          Text(
            _budget >= maxSlider
                ? 'Tanpa batas anggaran'
                : 'Hingga ${formatRupiah(_budget)}',
            style: const TextStyle(color: grey, fontSize: 11),
          ),
          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F6EF),
              border: Border.all(color: const Color(0xFFBFE3CE)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Filter siap diterapkan pada daftar proyek.',
              style: TextStyle(
                color: Color(0xFF218A5D),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0xFFE9EEF3)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: _reset,
                style: OutlinedButton.styleFrom(
                  foregroundColor: navy,
                  minimumSize: const Size(100, 52),
                  side: const BorderSide(color: border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Reset'),
              ),
              const SizedBox(width: 14),
              ElevatedButton(
                onPressed: _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(160, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Terapkan filter'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF52627A),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: items.contains(value) ? value : null,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                style: const TextStyle(
                  color: navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                items: items
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE4EAF1))),
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
            child: const Icon(Icons.bar_chart_rounded,
                color: Colors.white, size: 25),
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
                TextSpan(text: 'Anggaran', style: TextStyle(color: navy)),
                TextSpan(text: 'Terbuka', style: TextStyle(color: blue)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
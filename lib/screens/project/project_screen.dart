import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'project_detail_screen.dart';
import 'project_filter_screen.dart';
import 'project_model.dart';
import 'project_service.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  static const Color navy = Color(0xFF172F52);
  static const Color blue = Color(0xFF2861A0);
  static const Color teal = Color(0xFF18A394);
  static const Color background = Color(0xFFF5F7FA);
  static const Color grey = Color(0xFF8190A5);
  static const Color border = Color(0xFFDCE5EF);

  // Pusat peta default: Kota Surabaya
  static const LatLng surabaya = LatLng(-7.2575, 112.7521);

  final ProjectService _service = ProjectService();
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;
  int _request = 0;

  ProjectFilter _filter = const ProjectFilter();
  List<Project> _projects = [];
  final Set<int> _favorites = {};
  Project? _selected;

  bool _loading = true;
  bool _mapMode = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // MENGAMBIL DATA PROYEK DARI SUPABASE
  Future<void> _load() async {
    final token = ++_request;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _service.getProjects(
        _filter,
        search: _searchController.text.trim(),
      );

      // Proyek tersimpan (kosong jika belum login atau gagal dimuat).
      final saved = await _service
          .getSavedProjectIds()
          .catchError((_) => <int>{});

      if (!mounted || token != _request) return;

      setState(() {
        _projects = result;
        _favorites
          ..clear()
          ..addAll(saved);
        _selected = result.where((p) => p.hasLocation).isEmpty
            ? null
            : result.firstWhere((p) => p.hasLocation);
        _loading = false;
      });
    } catch (e) {
      if (!mounted || token != _request) return;

      setState(() {
        _error = 'Gagal memuat proyek: $e';
        _loading = false;
      });
    }
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), _load);
  }

  Future<void> _openFilter() async {
    final result = await Navigator.push<ProjectFilter>(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectFilterScreen(initial: _filter),
      ),
    );

    if (result != null) {
      setState(() => _filter = result);
      _load();
    }
  }

  void _updateFilter(ProjectFilter f) {
    setState(() => _filter = f);
    _load();
  }

  void _openDetail(Project p) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectDetailScreen(projectId: p.id),
      ),
    );
  }

  Future<void> _toggleFavorite(Project p) async {
    final wasSaved = _favorites.contains(p.id);

    // Perbarui tampilan dulu, batalkan jika gagal disimpan.
    setState(() {
      if (wasSaved) {
        _favorites.remove(p.id);
      } else {
        _favorites.add(p.id);
      }
    });

    try {
      await _service.setSaved(p.id, !wasSaved);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (wasSaved) {
          _favorites.add(p.id);
        } else {
          _favorites.remove(p.id);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan proyek.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    // Mode peta: bagian atas tetap, peta mengisi sisa layar.
    if (_mapMode) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: _buildTop(),
          ),
          Expanded(child: _buildMap()),
        ],
      );
    }

    // Mode daftar
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
      children: [
        _buildTop(),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator(color: teal)),
          )
        else if (_error != null)
          _buildError()
        else if (_projects.isEmpty)
          _buildEmpty()
        else
          ..._projects.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _projectCard(p),
            ),
          ),
      ],
    );
  }

  // BAGIAN ATAS: label, judul, pencarian, filter, chip, jumlah hasil
  Widget _buildTop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSimulationLabel(),
        const SizedBox(height: 22),
        const Text(
          'EKSPLORASI PROYEK',
          style: TextStyle(
            color: grey,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Proyek pembangunan publik',
          style: TextStyle(
            color: navy,
            fontSize: 27,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Cari dan pantau proyek di Kota Surabaya pada ${_filter.year}.',
          style: const TextStyle(color: grey, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 18),
        _buildSearch(),
        const SizedBox(height: 12),
        _buildFilterRow(),
        if (_filter.activeCount > 0) ...[
          const SizedBox(height: 12),
          _buildChips(),
        ],
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _loading ? 'Memuat...' : '${_projects.length} proyek ditemukan',
              style: const TextStyle(
                color: navy,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const Text(
              'Diurutkan: Paling relevan',
              style: TextStyle(color: grey, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Cari nama proyek atau wilayah...',
        hintStyle: const TextStyle(color: grey, fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: navy),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: blue),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: InkWell(
            onTap: _openFilter,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: border),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, color: navy, size: 20),
                  const SizedBox(width: 10),
                  const Text(
                    'Filter',
                    style: TextStyle(
                      color: navy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_filter.activeCount > 0) ...[
                    const SizedBox(width: 10),
                    CircleAvatar(
                      radius: 11,
                      backgroundColor: blue,
                      child: Text(
                        '${_filter.activeCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 6,
          child: Container(
            height: 52,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFE9EEF3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _toggle('Daftar', Icons.menu, !_mapMode),
                _toggle('Peta', Icons.location_on_outlined, _mapMode),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _toggle(String label, IconData icon, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mapMode = label == 'Peta'),
        child: Container(
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: active ? blue : grey),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active ? blue : grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // CHIP FILTER AKTIF
  Widget _buildChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (_filter.district != null)
          _chip(_filter.district!,
              () => _updateFilter(_filter.clear(district: true))),
        if (_filter.categoryName != null)
          _chip(_filter.categoryName!,
              () => _updateFilter(_filter.clear(category: true))),
        if (_filter.status != null)
          _chip(_filter.status!,
              () => _updateFilter(_filter.clear(status: true))),
        if (_filter.maxBudget != null)
          _chip('≤ ${formatRupiah(_filter.maxBudget!)}',
              () => _updateFilter(_filter.clear(budget: true))),
        TextButton(
          onPressed: () => _updateFilter(_filter.reset()),
          child: const Text(
            'Reset semua',
            style: TextStyle(color: grey, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, VoidCallback onRemove) {
    return InkWell(
      onTap: onRemove,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE6EFF9),
          border: Border.all(color: const Color(0xFFBFD3EA)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: const TextStyle(color: blue, fontSize: 12)),
            const SizedBox(width: 4),
            const Icon(Icons.close, size: 13, color: blue),
          ],
        ),
      ),
    );
  }

  // KARTU PROYEK
  Widget _projectCard(Project p, {bool withImage = true}) {
    final color = ProjectStatus.color(p.status);
    final fav = _favorites.contains(p.id);

    return InkWell(
      onTap: () => _openDetail(p),
      borderRadius: BorderRadius.circular(17),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (withImage &&
                p.imageUrl != null &&
                p.imageUrl!.isNotEmpty)
              Image.network(
                p.imageUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 7, color: color),
                            const SizedBox(width: 6),
                            Text(
                              p.status,
                              style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _toggleFavorite(p),
                        child: Icon(
                          fav ? Icons.favorite : Icons.favorite_border,
                          color: blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    p.name,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 18,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          [
                            if (p.district != null) p.district!,
                            if (p.categoryName != null) p.categoryName!,
                          ].join(' · '),
                          style: const TextStyle(color: grey, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _metric(
                        'Pagu anggaran',
                        p.budget == null
                            ? 'Belum tersedia'
                            : formatRupiah(p.budget!),
                      ),
                      const SizedBox(width: 28),
                      _metric(
                        'Progres fisik',
                        p.progress == null
                            ? 'Belum tersedia'
                            : '${p.progress!.toStringAsFixed(0)}%',
                      ),
                    ],
                  ),
                  if (p.progress != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: (p.progress! / 100).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: const Color(0xFFE9EEF3),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(teal),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFE9EEF3)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        p.updatedAt == null
                            ? 'Belum ada pembaruan'
                            : 'Diperbarui ${formatDate(p.updatedAt!)}',
                        style: const TextStyle(color: grey, fontSize: 11),
                      ),
                      const Icon(Icons.chevron_right,
                          size: 20, color: grey),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: grey, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: navy,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // TAMPILAN PETA
  Widget _buildMap() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: teal));
    }
    if (_error != null) return _buildError();

    final located = _projects.where((p) => p.hasLocation).toList();
    final points =
        located.map((p) => LatLng(p.latitude!, p.longitude!)).toList();

    final options = points.length > 1 && points.toSet().length > 1
        ? MapOptions(
            initialCameraFit: CameraFit.coordinates(
              coordinates: points,
              padding: const EdgeInsets.all(70),
              maxZoom: 16,
            ),
          )
        : MapOptions(
            initialCenter: points.isEmpty ? surabaya : points.first,
            initialZoom: points.isEmpty ? 11.5 : 15,
          );

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Stack(
          children: [
            FlutterMap(
              // Key berubah saat hasil berubah agar kamera ikut menyesuaikan.
              key: ValueKey(located.map((e) => e.id).join(',')),
              options: options,
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.tekberkel3',
                ),
                MarkerLayer(
                  markers: located.map((p) {
                    final selected = _selected?.id == p.id;
                    return Marker(
                      point: LatLng(p.latitude!, p.longitude!),
                      width: 48,
                      height: 48,
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () => setState(() => _selected = p),
                        child: Icon(
                          Icons.location_on,
                          size: selected ? 48 : 38,
                          color: ProjectStatus.color(p.status),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            // Legenda status
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Color(0x22000000), blurRadius: 8),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: ProjectStatus.all.map((s) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle,
                              size: 9, color: ProjectStatus.color(s)),
                          const SizedBox(width: 8),
                          Text(
                            s == ProjectStatus.procurement
                                ? 'Pengadaan'
                                : s,
                            style: const TextStyle(
                                fontSize: 11, color: navy),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Pesan jika tidak ada proyek bertitik lokasi
            if (located.isEmpty)
              const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Tidak ada proyek dengan titik lokasi.'),
                  ),
                ),
              ),

            // Kartu proyek terpilih
            if (_selected != null)
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: _projectCard(_selected!, withImage: false),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 35),
          const SizedBox(height: 12),
          Text(_error!, textAlign: TextAlign.center),
          TextButton(onPressed: _load, child: const Text('Coba lagi')),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(17),
      ),
      child: const Column(
        children: [
          Icon(Icons.inbox_outlined, color: grey, size: 40),
          SizedBox(height: 12),
          Text(
            'Proyek tidak ditemukan',
            style: TextStyle(color: navy, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Coba ubah kata kunci atau filter pencarian.',
            textAlign: TextAlign.center,
            style: TextStyle(color: grey),
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
          const Spacer(),
          Stack(
            children: [
              const Icon(Icons.notifications_none_rounded,
                  size: 27, color: navy),
              Positioned(
                right: 1,
                top: 1,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          const CircleAvatar(
            radius: 19,
            backgroundColor: Color(0xFFDCEAF7),
            child: Text('AR',
                style: TextStyle(color: blue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E9),
        border: Border.all(color: const Color(0xFFF2D49B)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 15, color: Color(0xFF956329)),
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
}
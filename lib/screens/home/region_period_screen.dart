import 'package:flutter/material.dart';

import '../profile/notification_screen.dart';
import '../profile/profile_screen.dart';
import 'home_service.dart';

/// Halaman Pilih Wilayah & Periode.
/// Desain mengikuti frame "Pilih Wilayah & Periode" di Figma.
///
/// Daftar wilayah (bertipe Kota) dan daftar tahun anggaran diambil dari
/// Supabase. Saat tombol "Terapkan pilihan" ditekan, pilihan disimpan ke
/// [selectedRegionPeriod] lalu halaman ditutup dan Beranda memuat ulang data.
class RegionPeriodScreen extends StatefulWidget {
  const RegionPeriodScreen({
    super.key,
    this.initialSelection,
    this.userInitials = '?',
    this.hasUnreadNotification = false,
  });

  /// Pilihan yang sedang aktif di Beranda (diberi tanda centang).
  final RegionPeriod? initialSelection;

  /// Inisial pengguna untuk avatar di header.
  final String userInitials;

  /// Menampilkan titik merah di ikon notifikasi.
  final bool hasUnreadNotification;

  @override
  State<RegionPeriodScreen> createState() => _RegionPeriodScreenState();
}

class _RegionPeriodScreenState extends State<RegionPeriodScreen> {
  // Warna utama aplikasi (sama dengan Beranda)
  static const Color navy = Color(0xFF142C4E);
  static const Color blue = Color(0xFF245B9E);
  static const Color teal = Color(0xFF159A91);
  static const Color background = Color(0xFFF6F8FB);
  static const Color grey = Color(0xFF687586);
  static const Color border = Color(0xFFDFE6EE);

  final HomeService _service = HomeService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;

  List<Region> _regions = [];
  List<int> _years = [];

  Region? _selectedRegion;
  int? _selectedYear;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _selectedRegion = widget.initialSelection?.region;
    _selectedYear = widget.initialSelection?.year;
    _loadOptions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Mengambil daftar wilayah dan tahun dari Supabase.
  Future<void> _loadOptions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final regions = await _service.getCityRegions();
      final years = await _service.getBudgetYears();

      if (!mounted) return;

      setState(() {
        _regions = regions;
        _years = years;

        // Cocokkan pilihan awal dengan data terbaru (berdasarkan id).
        final currentId = _selectedRegion?.id;
        _selectedRegion = regions.cast<Region?>().firstWhere(
          (region) => region!.id == currentId,
          orElse: () => regions.isNotEmpty ? regions.first : null,
        );

        if (_selectedYear == null || !years.contains(_selectedYear)) {
          _selectedYear = years.isNotEmpty ? years.first : null;
        }

        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat pilihan wilayah. Periksa koneksi internet lalu coba lagi.';
      });
      debugPrint('RegionPeriodScreen error: $error');
    }
  }

  /// Wilayah yang cocok dengan teks pencarian.
  List<Region> get _filteredRegions {
    final query = _searchText.trim().toLowerCase();
    if (query.isEmpty) return _regions;
    return _regions
        .where((region) => region.name.toLowerCase().contains(query))
        .toList();
  }

  bool get _canApply => _selectedRegion != null && _selectedYear != null;

  /// Menyimpan pilihan dan kembali ke Beranda.
  void _apply() {
    if (!_canApply) return;

    final selection = RegionPeriod(
      region: _selectedRegion!,
      year: _selectedYear!,
    );

    selectedRegionPeriod.value = selection;
    Navigator.pop(context, selection);
  }

  void _open(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  // ============================================================
  // BUILD
  // ============================================================

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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBackButton(),
                    const SizedBox(height: 22),
                    _buildTitle(),
                    const SizedBox(height: 28),
                    _buildFormCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER (sama dengan header Beranda)
  // ============================================================

  Widget _buildHeader() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            padding: const EdgeInsets.fromLTRB(7, 8, 7, 6),
            decoration: BoxDecoration(
              color: navy,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _logoBar(10, Colors.white),
                _logoBar(17, const Color(0xFF63C8C1)),
                _logoBar(13, Colors.white),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
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
          GestureDetector(
            onTap: () => _open(const NotificationScreen()),
            child: Stack(
              children: [
                const SizedBox(
                  width: 38,
                  height: 38,
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: 22,
                    color: navy,
                  ),
                ),
                if (widget.hasUnreadNotification)
                  Positioned(
                    left: 22,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC94C4C),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.6),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => _open(const ProfileScreen()),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: const Color(0xFFD9E8F5),
              child: Text(
                widget.userInitials,
                style: const TextStyle(
                  color: blue,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoBar(double height, Color color) {
    return Container(
      width: 4.7,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
      ),
    );
  }

  // ============================================================
  // TOMBOL KEMBALI & JUDUL
  // ============================================================

  Widget _buildBackButton() {
    return InkWell(
      // Kembali tanpa menyimpan perubahan.
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(8),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chevron_left_rounded, size: 22, color: blue),
            SizedBox(width: 4),
            Text(
              'Kembali',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PILIH WILAYAH & PERIODE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: grey,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Atur konteks data',
          style: TextStyle(fontSize: 27, letterSpacing: -1.2, color: navy),
        ),
        SizedBox(height: 10),
        Text(
          'Pilihan ini digunakan secara konsisten pada halaman anggaran dan proyek.',
          style: TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF53657A)),
        ),
      ],
    );
  }

  // ============================================================
  // KARTU FORMULIR
  // ============================================================

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: _buildFormContent(),
    );
  }

  Widget _buildFormContent() {
    // Loading state
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator(color: teal)),
      );
    }

    // Error state
    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            const Icon(Icons.wifi_off_rounded, size: 32, color: grey),
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: grey),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: _loadOptions,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchField(),
        const SizedBox(height: 16),
        _buildRegionList(),
        const SizedBox(height: 22),
        const Text(
          'Tahun anggaran',
          style: TextStyle(fontSize: 11, color: Color(0xFF1B2735)),
        ),
        const SizedBox(height: 8),
        _buildYearDropdown(),
        const SizedBox(height: 24),
        const Divider(height: 1, thickness: 0.8, color: border),
        const SizedBox(height: 20),
        Align(alignment: Alignment.centerRight, child: _buildApplyButton()),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchText = value),
      style: const TextStyle(fontSize: 13, color: navy),
      decoration: InputDecoration(
        hintText: 'Cari kota atau kabupaten...',
        hintStyle: const TextStyle(fontSize: 12, color: grey),
        prefixIcon: const Icon(Icons.search, size: 20, color: grey),
        suffixIcon: _searchText.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close, size: 18, color: grey),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchText = '');
                },
              ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: blue),
        ),
      ),
    );
  }

  Widget _buildRegionList() {
    if (_regions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Belum ada data wilayah.',
          style: TextStyle(fontSize: 12, color: grey),
        ),
      );
    }

    final regions = _filteredRegions;
    if (regions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Wilayah "$_searchText" tidak ditemukan.',
          style: const TextStyle(fontSize: 12, color: grey),
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < regions.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _regionCard(regions[i]),
        ],
      ],
    );
  }

  Widget _regionCard(Region region) {
    final bool isSelected = region.id == _selectedRegion?.id;

    return InkWell(
      onTap: () => setState(() => _selectedRegion = region),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? blue : border,
            width: isSelected ? 1.4 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                size: 20,
                color: blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    region.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Provinsi dari kolom regions.province.
                  // Kalau kosong, tampilkan tipe wilayah (region_type).
                  Text(
                    (region.province == null || region.province!.isEmpty)
                        ? region.type
                        : region.province!,
                    style: const TextStyle(fontSize: 10, color: grey),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_rounded, size: 20, color: teal),
          ],
        ),
      ),
    );
  }

  Widget _buildYearDropdown() {
    if (_years.isEmpty) {
      return const Text(
        'Belum ada data tahun anggaran.',
        style: TextStyle(fontSize: 12, color: grey),
      );
    }

    return DropdownButtonFormField<int>(
      initialValue: _selectedYear,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: navy),
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: navy,
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: blue),
        ),
      ),
      items: [
        for (final year in _years)
          DropdownMenuItem<int>(value: year, child: Text('$year')),
      ],
      onChanged: (value) => setState(() => _selectedYear = value),
    );
  }

  Widget _buildApplyButton() {
    return ElevatedButton(
      onPressed: _canApply ? _apply : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFB9C7D5),
        elevation: 4,
        shadowColor: const Color(0x40245B9E),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text(
        'Terapkan pilihan',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

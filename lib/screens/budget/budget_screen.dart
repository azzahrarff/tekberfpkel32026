
import 'package:flutter/material.dart';
import 'education_screen.dart';
import 'information_source_screen.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  // Warna utama aplikasi
  static const Color navy = Color(0xFF172F52);
  static const Color blue = Color(0xFF2861A0);
  static const Color teal = Color(0xFF18A394);
  static const Color background = Color(0xFFF5F7FA);
  static const Color grey = Color(0xFF8190A5);

  String selectedYear = '2026';
  String selectedLevel = 'Kota/Kabupaten';
  String selectedRegion = 'Kota Surabaya';
  String selectedCategory = 'Semua kategori';

  final List<Map<String, dynamic>> categories = [
    {'name': 'Infrastruktur', 'amount': 'Rp1,30 T', 'value': 25.0, 'color': Color(0xFF159F91)},
    {'name': 'Kesehatan', 'amount': 'Rp1,04 T', 'value': 20.0, 'color': Color(0xFF5687C5)},
    {'name': 'Transportasi', 'amount': 'Rp520 M', 'value': 10.0, 'color': Color(0xFF78C5BF)},
    {'name': 'Perlindungan sosial', 'amount': 'Rp520 M', 'value': 10.0, 'color': Color(0xFF8DA4BF)},
    {'name': 'Lingkungan', 'amount': 'Rp260 M', 'value': 5.0, 'color': Color(0xFFB4C5D8)},
  ];

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
            builder: (context) => const EducationScreen(),
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
            builder: (context) => const InformationSourceScreen(),
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
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSimulationLabel(),
                    const SizedBox(height: 24),
                    _buildTitle(),
                    const SizedBox(height: 26),
                    _buildFilters(),
                    const SizedBox(height: 18),
                    _buildSummaryCard(
                      'Total anggaran',
                      'Rp5,20 T',
                      'Pagu tahun $selectedYear',
                      navy,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCard(
                      'Realisasi keuangan',
                      'Rp3,40 T',
                      '65,4% terhadap pagu',
                      blue,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCard(
                      'Belum terealisasi',
                      'Rp1,80 T',
                      'per 31 Oktober $selectedYear',
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
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE4EAF1)),
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
        border: Border.all(color: const Color(0xFFF2D49B)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 15, color: Color(0xFF956329)),
          SizedBox(width: 7),
          Text(
            'DATA SIMULASI — BUKAN DATA RESMI',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Color(0xFF956329),
              letterSpacing: 0.4,
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
            border: Border.all(color: const Color(0xFFD8E2ED)),
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
        border: Border.all(color: const Color(0xFFDCE5EF)),
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
                  ['2025', '2026', '2027'],
                  (value) => setState(() => selectedYear = value!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _filterDropdown(
                  'Tingkat pemerintahan',
                  selectedLevel,
                  ['Kota/Kabupaten', 'Provinsi', 'Nasional'],
                  (value) => setState(() => selectedLevel = value!),
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
                  ['Kota Surabaya', 'Kota Malang', 'Kota Semarang'],
                  (value) => setState(() => selectedRegion = value!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _filterDropdown(
                  'Kategori',
                  selectedCategory,
                  [
                    'Semua kategori',
                    'Infrastruktur',
                    'Kesehatan',
                    'Transportasi',
                    'Perlindungan sosial',
                    'Lingkungan',
                  ],
                  (value) => setState(() => selectedCategory = value!),
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
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFBFD),
            border: Border.all(color: const Color(0xFFDCE5EF)),
            borderRadius: BorderRadius.circular(9),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 19),
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
              onChanged: onChanged,
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
    final textColor = darkText ? navy : Colors.white;
    final secondaryColor =
        darkText ? grey : Colors.white.withValues(alpha: 0.7);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        border: darkText
            ? Border.all(color: const Color(0xFFDCE5EF))
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
    final visibleCategories = selectedCategory == 'Semua kategori'
        ? categories
        : categories
            .where((item) => item['name'] == selectedCategory)
            .toList();

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
            'Menurut kategori · dalam triliun Rupiah',
            style: TextStyle(color: grey, fontSize: 12),
          ),
          const SizedBox(height: 27),
          ...visibleCategories.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      item['name'],
                      style: const TextStyle(
                        color: grey,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: item['value'] / 25,
                        minHeight: 12,
                        backgroundColor: const Color(0xFFE9EEF3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          item['color'],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 65,
                    child: Text(
                      item['amount'],
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
            style: TextStyle(color: grey, fontSize: 12),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: TrendChartPainter(),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Jan', style: TextStyle(color: grey, fontSize: 10)),
              Text('Mar', style: TextStyle(color: grey, fontSize: 10)),
              Text('Mei', style: TextStyle(color: grey, fontSize: 10)),
              Text('Jul', style: TextStyle(color: grey, fontSize: 10)),
              Text('Sep', style: TextStyle(color: grey, fontSize: 10)),
              Text('Okt', style: TextStyle(color: grey, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Text(
                '65,4%',
                style: TextStyle(
                  color: teal,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Realisasi sampai Oktober',
                style: TextStyle(color: grey, fontSize: 11),
              ),
            ],
          ),
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
          const Text(
            'Alokasi Pendidikan',
            style: TextStyle(
              color: navy,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cakupan wilayah dan kategori yang sebanding.',
            style: TextStyle(color: grey, fontSize: 11),
          ),
          const SizedBox(height: 25),
          const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('2025', style: TextStyle(color: grey, fontSize: 11)),
                    SizedBox(height: 6),
                    Text(
                      'Rp1,40 T',
                      style: TextStyle(
                        color: navy,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: navy, size: 25),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('2026', style: TextStyle(color: grey, fontSize: 11)),
                    SizedBox(height: 6),
                    Text(
                      'Rp1,56 T',
                      style: TextStyle(
                        color: navy,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 5),
              _GrowthBadge(),
            ],
          ),
        ],
      ),
    );
  }

  // KOMPONEN KARTU PUTIH
  Widget _whiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE5EF)),
        borderRadius: BorderRadius.circular(17),
      ),
      child: child,
    );
  }
}

class _GrowthBadge extends StatelessWidget {
  const _GrowthBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F5ED),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        '↑ 11,4%',
        style: TextStyle(
          color: Color(0xFF218A5D),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// CUSTOM PAINTER UNTUK GRAFIK
class TrendChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      Offset(0, size.height * 0.92),
      Offset(size.width * 0.16, size.height * 0.82),
      Offset(size.width * 0.32, size.height * 0.60),
      Offset(size.width * 0.48, size.height * 0.48),
      Offset(size.width * 0.64, size.height * 0.32),
      Offset(size.width * 0.80, size.height * 0.20),
      Offset(size.width, size.height * 0.08),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);

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
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
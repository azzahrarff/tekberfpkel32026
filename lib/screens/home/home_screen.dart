import 'package:flutter/material.dart';

import '../budget/budget_screen.dart';
import '../budget/information_source_screen.dart';
import '../profile/notification_screen.dart';
import '../profile/profile_screen.dart';
import '../project/project_detail_screen.dart';
import '../project/project_screen.dart';
import 'region_period_screen.dart';

/// Halaman Beranda (Home).
/// Desain mengikuti frame "Landign Page" di halaman Figma "Vasya".
/// Semua angka di halaman ini adalah data simulasi (bukan data resmi).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Warna utama aplikasi (sama dengan halaman Anggaran)
  static const Color navy = Color(0xFF142C4E);
  static const Color blue = Color(0xFF245B9E);
  static const Color teal = Color(0xFF159A91);
  static const Color background = Color(0xFFF6F8FB);
  static const Color grey = Color(0xFF687586);
  static const Color border = Color(0xFFDFE6EE);

  // Data simulasi: alokasi anggaran per kategori
  static const List<Map<String, dynamic>> categories = [
    {
      'name': 'Pendidikan',
      'amount': 'Rp1,56 T',
      'value': 0.30,
      'color': Color(0xFF245B9E),
    },
    {
      'name': 'Infrastruktur',
      'amount': 'Rp1,30 T',
      'value': 0.25,
      'color': Color(0xFF159A91),
    },
    {
      'name': 'Kesehatan',
      'amount': 'Rp1,04 T',
      'value': 0.20,
      'color': Color(0xFF5B89C2),
    },
    {
      'name': 'Transportasi',
      'amount': 'Rp520 M',
      'value': 0.10,
      'color': Color(0xFF7EC7C1),
    },
    {
      'name': 'Perlindungan sosial',
      'amount': 'Rp520 M',
      'value': 0.10,
      'color': Color(0xFF8AA0BB),
    },
    {
      'name': 'Lingkungan',
      'amount': 'Rp260 M',
      'value': 0.05,
      'color': Color(0xFFB7C6D8),
    },
  ];

  // Data simulasi: proyek di sekitar wilayah
  static const List<Map<String, dynamic>> projects = [
    {
      'title': 'Pembangunan Jalan Raya Kecamatan Sukolilo',
      'location': 'Sukolilo · Jalan dan jembatan',
      'budget': 'Rp2 miliar',
      'progress': 0.58,
      'done': false,
      'hasImage': true,
    },
    {
      'title': 'Renovasi Puskesmas Kecamatan Wonokromo',
      'location': 'Wonokromo · Kesehatan',
      'budget': 'Rp1,5 miliar',
      'progress': 0.70,
      'done': false,
      'hasImage': false,
    },
    {
      'title': 'Peningkatan Fasilitas Sekolah Dasar',
      'location': 'Tambaksari · Pendidikan',
      'budget': 'Rp850 juta',
      'progress': 1.0,
      'done': true,
      'hasImage': false,
    },
  ];

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcome(context),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSimulationLabel(),
                          const SizedBox(height: 20),
                          _buildSummaryCard(context),
                          const SizedBox(height: 38),
                          _buildCategories(context),
                          const SizedBox(height: 38),
                          _buildProjects(context),
                          const SizedBox(height: 38),
                          _buildInsight(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HEADER: logo, nama aplikasi, notifikasi, profil
  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: Row(
        children: [
          // Logo: tiga batang grafik di kotak navy
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
            onTap: () => _open(context, const NotificationScreen()),
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
            onTap: () => _open(context, const ProfileScreen()),
            child: const CircleAvatar(
              radius: 17,
              backgroundColor: Color(0xFFD9E8F5),
              child: Text(
                'AR',
                style: TextStyle(
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

  // SAMBUTAN + PILIHAN WILAYAH & TAHUN
  Widget _buildWelcome(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 30, 16, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAF2FA), Color(0xFFF6F9FC), Color(0xFFE8F6F4)],
        ),
        border: Border(bottom: BorderSide(color: Color(0xFFDAE6EF))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              border: Border.all(color: const Color(0xFFD1E2F1)),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Text(
              'Transparansi dimulai dari informasi yang mudah dipahami',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
                color: blue,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Selamat datang, Ayu.',
            style: TextStyle(fontSize: 27, letterSpacing: -1.2, color: navy),
          ),
          const SizedBox(height: 5),
          const Text(
            'Pantau bagaimana anggaran publik bekerja untuk kotamu.',
            style: TextStyle(fontSize: 13, color: Color(0xFF53657A)),
          ),
          const SizedBox(height: 28),
          // Kartu pilihan wilayah dan tahun anggaran
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFD9E4EE)),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14142C4E),
                  blurRadius: 15,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                _selectorRow(
                  context,
                  label: 'Wilayah pilihan',
                  value: 'Kota Surabaya, Jawa Timur',
                  showIcon: true,
                ),
                const Divider(height: 1, thickness: 0.8, color: border),
                _selectorRow(
                  context,
                  label: 'Tahun anggaran',
                  value: '2026',
                  showIcon: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectorRow(
    BuildContext context, {
    required String label,
    required String value,
    required bool showIcon,
  }) {
    return InkWell(
      onTap: () => _open(context, const RegionPeriodScreen()),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        child: Row(
          children: [
            if (showIcon) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: blue,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: grey),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: grey,
            ),
          ],
        ),
      ),
    );
  }

  // LABEL DATA SIMULASI
  Widget _buildSimulationLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E9),
        border: Border.all(color: const Color(0xFFEDD8A7)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 14, color: Color(0xFF755022)),
          SizedBox(width: 6),
          Text(
            'DATA SIMULASI — BUKAN DATA RESMI',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.45,
              color: Color(0xFF755022),
            ),
          ),
        ],
      ),
    );
  }

  // KARTU RINGKASAN ANGGARAN WILAYAH
  Widget _buildSummaryCard(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29142C4E),
            blurRadius: 40,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'RINGKASAN ANGGARAN WILAYAH',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: Color(0xFFAABBD0),
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Color(0xFFAABBD0),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total anggaran 2026',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFC6D2DF),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text.rich(
                            TextSpan(
                              style: TextStyle(color: Colors.white),
                              children: [
                                TextSpan(
                                  text: 'Rp5,20 ',
                                  style: TextStyle(
                                    fontSize: 31,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -2,
                                  ),
                                ),
                                TextSpan(
                                  text: 'triliun',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildRealizationRing(0.654),
                  ],
                ),
                const SizedBox(height: 18),
                _progressBar(
                  0.654,
                  teal,
                  Colors.white.withValues(alpha: 0.13),
                  7,
                ),
                const SizedBox(height: 19),
                Row(
                  children: [
                    _legendItem(
                      const Color(0xFF58C4BA),
                      'Realisasi terhadap pagu',
                      'Rp3,40 triliun',
                    ),
                    const SizedBox(width: 18),
                    _legendItem(
                      const Color(0xFFD4DDE7),
                      'Belum terealisasi',
                      'Rp1,80 triliun',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Color(0xFFAEBDCB),
                    ),
                    SizedBox(width: 7),
                    Text(
                      'Periode pelaporan sampai 31 Oktober 2026',
                      style: TextStyle(fontSize: 10, color: Color(0xFFAEBDCB)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Bagian bawah kartu: dasar informasi
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: teal.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    size: 20,
                    color: Color(0xFF76D6CE),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dasar informasi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Ringkasan kompilasi data simulasi untuk Kota Surabaya.',
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.7,
                          color: Color(0xFFB7C4D1),
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            _open(context, const InformationSourceScreen()),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Lihat sumber & definisi',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF76D6CE),
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(
                              Icons.open_in_new,
                              size: 13,
                              color: Color(0xFF76D6CE),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Lingkaran persentase realisasi (65,4% terealisasi)
  Widget _buildRealizationRing(double value) {
    return SizedBox(
      width: 74,
      height: 74,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 74,
            height: 74,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 8,
              color: teal,
              backgroundColor: Colors.white.withValues(alpha: 0.13),
            ),
          ),
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '65,4%',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                'terealisasi',
                style: TextStyle(fontSize: 8, color: Color(0xFFB9C7D5)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, String value) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 9),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFFAEBDCB)),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Bar progres yang dipakai berulang kali
  Widget _progressBar(
    double value,
    Color color,
    Color trackColor,
    double height,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: LinearProgressIndicator(
        value: value,
        minHeight: height,
        color: color,
        backgroundColor: trackColor,
      ),
    );
  }

  // Judul tiap bagian + tombol di kanan
  Widget _sectionTitle(
    String title,
    String actionText,
    VoidCallback onTap,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  letterSpacing: -0.5,
                  color: navy,
                ),
              ),
            ),
            GestureDetector(
              onTap: onTap,
              child: Row(
                children: [
                  Text(
                    actionText,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: blue,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.chevron_right, size: 16, color: blue),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: grey)),
      ],
    );
  }

  // KE MANA ANGGARAN DIALOKASIKAN?
  Widget _buildCategories(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'Ke mana anggaran dialokasikan?',
          'Jelajahi anggaran',
          // Membuka halaman Anggaran buatan tim
          () => _open(context, const BudgetScreen()),
          'Distribusi anggaran per kategori pada tahun 2026',
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A18304C),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              for (final category in categories) _categoryItem(category),
            ],
          ),
        ),
      ],
    );
  }

  Widget _categoryItem(Map<String, dynamic> category) {
    final double value = category['value'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  category['name'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1B2735),
                  ),
                ),
              ),
              Text(
                category['amount'],
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _progressBar(
                  value,
                  category['color'],
                  const Color(0xFFEDF0F4),
                  7,
                ),
              ),
              SizedBox(
                width: 46,
                child: Text(
                  '${(value * 100).round()}%',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // PROYEK DI SEKITAR WILAYAHMU
  Widget _buildProjects(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'Proyek di sekitar wilayahmu',
          'Lihat semua proyek',
          () => _open(context, const ProjectScreen()),
          'Cuplikan proyek publik di Kota Surabaya',
        ),
        const SizedBox(height: 22),
        for (int i = 0; i < projects.length; i++) ...[
          if (i > 0) const SizedBox(height: 18),
          _projectCard(context, projects[i]),
        ],
      ],
    );
  }

  Widget _projectCard(BuildContext context, Map<String, dynamic> project) {
    final double progress = project['progress'];
    final bool done = project['done'];
    final Color statusColor = done
        ? const Color(0xFF21865A)
        : const Color(0xFF106F69);
    final Color statusBg = done
        ? const Color(0xFFE7F5ED)
        : const Color(0xFFE7F5F3);

    return GestureDetector(
      onTap: () => _open(context, const ProjectDetailScreen()),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Di Figma kartu pertama memakai foto pekerja konstruksi.
            // Sementara diganti kotak berwarna + ikon sampai fotonya
            // diekspor dari Figma ke folder assets/images/.
            if (project['hasImage'])
              Container(
                height: 165,
                width: double.infinity,
                color: const Color(0xFFEAF2FA),
                child: const Icon(
                  Icons.construction,
                  size: 56,
                  color: Color(0xFF8AA0BB),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              done ? 'Selesai' : 'Dalam pengerjaan',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Tombol simpan proyek (belum ada fungsinya)
                      const Icon(Icons.favorite_border, size: 24, color: blue),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    project['title'],
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        project['location'],
                        style: const TextStyle(fontSize: 10, color: grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _smallStat('Pagu anggaran', project['budget']),
                      const SizedBox(width: 52),
                      _smallStat(
                        'Progres fisik',
                        '${(progress * 100).round()}%',
                      ),
                    ],
                  ),
                  const SizedBox(height: 11),
                  _progressBar(progress, teal, const Color(0xFFE6EBF0), 8),
                  const SizedBox(height: 15),
                  const Divider(
                    height: 1,
                    thickness: 0.8,
                    color: Color(0xFFEDF0F3),
                  ),
                  const SizedBox(height: 13),
                  const Row(
                    children: [
                      Text(
                        'Diperbarui 31 Oktober 2026',
                        style: TextStyle(fontSize: 9, color: Color(0xFF7A8797)),
                      ),
                      Spacer(),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: Color(0xFF7A8797),
                      ),
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

  Widget _smallStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: grey)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: navy,
          ),
        ),
      ],
    );
  }

  // INSIGHT ANGGARAN
  Widget _buildInsight(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAF2FA), Color(0xFFEDF8F6)],
        ),
        border: Border.all(color: const Color(0xFFD6E5ED)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14142C4E),
                  blurRadius: 7,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(Icons.trending_up_rounded, size: 26, color: teal),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'INSIGHT ANGGARAN',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: blue,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Alokasi pendidikan naik 11,4% dibanding 2025',
                  style: TextStyle(fontSize: 15, color: navy),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Dari Rp1,40 triliun menjadi Rp1,56 triliun pada cakupan tahunan yang sebanding.',
                  style: TextStyle(fontSize: 11, height: 1.5, color: grey),
                ),
                const SizedBox(height: 15),
                Center(
                  child: GestureDetector(
                    // Grafik perbandingan ada di bawah halaman Anggaran
                    onTap: () => _open(context, const BudgetScreen()),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lihat perbandingan',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: blue,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right, size: 16, color: blue),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

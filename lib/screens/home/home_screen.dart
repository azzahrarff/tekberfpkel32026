import 'package:flutter/material.dart';

import '../contribution/contribution_screen.dart';
import '../profile/notification_screen.dart';
import '../profile/profile_screen.dart';
import '../project/project_detail_screen.dart';
import '../project/project_screen.dart';
import 'region_period_screen.dart';

/// Halaman Beranda (Home).
/// Desain mengikuti frame "Beranda AnggaranTerbuka" di Figma.
/// Semua angka di halaman ini adalah data simulasi (bukan data resmi).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Warna dari desain Figma (halaman Beranda)
  static const Color background = Color(0xFFFBF9F1);
  static const Color surface = Color(0xFFFFFEFA);
  static const Color darkGreen = Color(0xFF09251C);
  static const Color forest = Color(0xFF203B31);
  static const Color green = Color(0xFF365340);
  static const Color mint = Color(0xFFAFCDBF);
  static const Color lightMint = Color(0xFFCBEADB);
  static const Color textDark = Color(0xFF202722);
  static const Color textGrey = Color(0xFF61685F);
  static const Color track = Color(0xFFECEAE2);
  static const Color softBeige = Color(0xFFEAE8E0);
  static const Color chipGreen = Color(0xFFE4EBDD);

  // Data simulasi: alokasi anggaran per sektor
  static const List<Map<String, dynamic>> sectors = [
    {
      'name': 'Pendidikan & Riset',
      'amount': 'Rp1,56 T',
      'percent': 0.30,
      'label': '(30,0%)',
      'desc': 'BOSDA, beasiswa pemuda tangguh, dan renovasi sekolah',
      'color': Color(0xFF09251C),
    },
    {
      'name': 'Infrastruktur & Tata Air',
      'amount': 'Rp1,40 T',
      'percent': 0.27,
      'label': '(27,0%)',
      'desc': 'Normalisasi saluran box culvert & perbaikan jalan lingkungan',
      'color': Color(0xFF4A6B5D),
    },
    {
      'name': 'Kesehatan Masyarakat',
      'amount': 'Rp1,04 T',
      'percent': 0.20,
      'label': '(20,0%)',
      'desc': 'Puskesmas 24 jam kelurahan, UHC BPJS, dan pencegahan stunting',
      'color': Color(0xFF345665),
    },
    {
      'name': 'Pelayanan Publik & Sosial',
      'amount': 'Rp1,20 T',
      'percent': 0.23,
      'label': '(23,0%)',
      'desc': 'Digitalisasi kelurahan, permakanan lansia, padat karya',
      'color': Color(0xFF74551D),
    },
  ];

  // Data simulasi: proyek prioritas
  static const List<Map<String, dynamic>> projects = [
    {
      'title': 'Pembangunan RSUD Surabaya Timur Tahap II',
      'location': 'Rungkut, Surabaya • Dinas Kesehatan',
      'status': 'Konstruksi Fisik',
      'statusBg': Color(0xFFE7EEF1),
      'statusColor': Color(0xFF345665),
      'statusIcon': null,
      'updated': '2 hari lalu',
      'budget': 'Rp148,5 Miliar',
      'progress': 0.78,
      'progressColor': Color(0xFF09251C),
      'deadline': 'Tenggat: November 2026',
      'icon': Icons.local_hospital_outlined,
    },
    {
      'title': 'Revitalisasi Koridor Hijau & Jalur Pedestrian Kalimas',
      'location': 'Genteng, Surabaya • DKRTH Surabaya',
      'status': 'Tahap Penyelesaian',
      'statusBg': Color(0xFFE4EBDD),
      'statusColor': Color(0xFF365340),
      'statusIcon': Icons.check_circle_outline,
      'updated': 'Kemarin',
      'budget': 'Rp42,0 Miliar',
      'progress': 0.92,
      'progressColor': Color(0xFF365340),
      'deadline': 'Tenggat: April 2026',
      'icon': Icons.park_outlined,
    },
  ];

  void _open(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntro(context),
                    const SizedBox(height: 24),
                    _buildBudgetCard(context),
                    const SizedBox(height: 24),
                    _buildSectors(),
                    const SizedBox(height: 24),
                    _buildProjects(context),
                    const SizedBox(height: 24),
                    _buildUpdates(),
                    const SizedBox(height: 24),
                    _buildParticipation(context),
                    const SizedBox(height: 24),
                    _buildDataSource(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 0. HEADER (logo, nama aplikasi, notifikasi, foto profil)
  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: background.withValues(alpha: 0.9),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: darkGreen,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.bar_chart_rounded, color: surface, size: 20),
          ),
          const SizedBox(width: 8),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AnggaranTerbuka',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: darkGreen,
                ),
              ),
              Text('Beranda', style: TextStyle(fontSize: 12, color: textGrey)),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => _open(context, const NotificationScreen()),
            icon: const Icon(Icons.notifications_none_rounded, color: darkGreen),
          ),
          GestureDetector(
            onTap: () => _open(context, const ProfileScreen()),
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: chipGreen,
              child: Icon(Icons.person, size: 20, color: green),
            ),
          ),
        ],
      ),
    );
  }

  // 1. PEMILIH WILAYAH, PERIODE & STATUS SIMULASI
  Widget _buildIntro(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: chipGreen,
                borderRadius: BorderRadius.circular(99),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, size: 12, color: green),
                  SizedBox(width: 6),
                  Text(
                    'Data Simulasi — Bukan Data Resmi',
                    style: TextStyle(fontSize: 12, color: green),
                  ),
                ],
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () => _open(context, const RegionPeriodScreen()),
              child: const Row(
                children: [
                  Text('Ganti Filter', style: TextStyle(fontSize: 12, color: darkGreen)),
                  SizedBox(width: 4),
                  Icon(Icons.tune, size: 12, color: darkGreen),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Pantau pembangunan di Surabaya',
          style: TextStyle(
            fontSize: 24,
            height: 1.25,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.6,
            color: textDark,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Akses informasi keterbukaan dana publik dan partisipasi sipil kota Anda.',
          style: TextStyle(fontSize: 14, height: 1.43, color: textGrey),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterPill(context, Icons.location_on_outlined, 'Kota Surabaya'),
              const SizedBox(width: 8),
              _filterPill(context, Icons.calendar_today_outlined, 'TA 2026'),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: track,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(color: green, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    const Text('Aktif', style: TextStyle(fontSize: 12, color: textGrey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterPill(BuildContext context, IconData icon, String label) {
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: () => _open(context, const RegionPeriodScreen()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: darkGreen),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textDark,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: textDark),
          ],
        ),
      ),
    );
  }

  // 2. KARTU RINGKASAN ANGGARAN
  Widget _buildBudgetCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xF209251C), Color(0xF2203B31), darkGreen],
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'APBD KOTA SURABAYA • TA 2026',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: mint,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'Rp5,2',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.8,
                            color: surface,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Triliun',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: mint,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Alokasi Pagu Total Disetujui',
                      style: TextStyle(fontSize: 12, color: Color(0xBFFFFEFA)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x1AFFFEFA),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text(
                  'Semester I',
                  style: TextStyle(fontSize: 12, color: surface),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Kotak realisasi anggaran
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0x1AFFFEFA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Text(
                      'Realisasi Anggaran',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xE6FFFEFA),
                      ),
                    ),
                    Spacer(),
                    Text.rich(
                      TextSpan(
                        text: 'Rp3,4 Triliun ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: surface,
                        ),
                        children: [
                          TextSpan(
                            text: '(65,4%)',
                            style: TextStyle(fontWeight: FontWeight.w400, color: mint),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _progressBar(0.654, lightMint, const Color(0x33FFFEFA), 6),
                const SizedBox(height: 6),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Sisa Pagu: Rp1,8 Triliun',
                        style: TextStyle(fontSize: 12, color: Color(0xB3FFFEFA)),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Target Q2: 60% (Melampaui)',
                        style: TextStyle(fontSize: 12, color: Color(0xB3FFFEFA)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(Icons.schedule, size: 13, color: Color(0xB3FFFEFA)),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Per 24 Feb 2026 • Sumber: BPKAD (Simulasi)',
                  style: TextStyle(fontSize: 12, color: Color(0xB3FFFEFA)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            // Tab Anggaran ada di navbar bawah. Untuk sementara tombol ini
            // belum diarahkan ke mana-mana.
            onTap: () {},
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Lihat Rincian Anggaran',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: surface,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 12, color: surface),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Bar progres sederhana yang dipakai berulang kali
  Widget _progressBar(double value, Color color, Color trackColor, double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(
        value: value,
        minHeight: height,
        color: color,
        backgroundColor: trackColor,
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            color: textDark,
          ),
        ),
        Text(subtitle, style: const TextStyle(fontSize: 14, color: textGrey)),
      ],
    );
  }

  // 3. ALOKASI MENURUT SEKTOR
  Widget _buildSectors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'Alokasi Menurut Sektor',
          'Distribusi 4 prioritas belanja utama warga kota',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Color(0x0D000000), blurRadius: 1, offset: Offset(0, 1)),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < sectors.length; i++) ...[
                if (i > 0) const SizedBox(height: 16),
                _sectorItem(sectors[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectorItem(Map<String, dynamic> sector) {
    final Color color = sector['color'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                sector['name'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              sector['amount'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              sector['label'],
              style: const TextStyle(fontSize: 12, color: textGrey),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _progressBar(sector['percent'], color, track, 8),
        const SizedBox(height: 6),
        Text(
          sector['desc'],
          style: const TextStyle(fontSize: 12, color: textGrey),
        ),
      ],
    );
  }

  // 4. PROYEK PRIORITAS DI SEKITARMU
  Widget _buildProjects(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _sectionTitle(
                'Proyek Prioritas di Sekitarmu',
                'Pekerjaan strategis tahun berjalan yang sedang berjalan',
              ),
            ),
            TextButton(
              onPressed: () => _open(context, const ProjectScreen()),
              child: const Text(
                'Semua (48)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: darkGreen,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < projects.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          _projectCard(context, projects[i]),
        ],
      ],
    );
  }

  Widget _projectCard(BuildContext context, Map<String, dynamic> project) {
    final double progress = project['progress'];
    final Color progressColor = project['progressColor'];
    final IconData? statusIcon = project['statusIcon'];

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto proyek. Di Figma ini berupa foto asli.
          // Sementara diganti kotak berwarna + ikon sampai fotonya
          // diekspor dari Figma ke folder assets/images/.
          SizedBox(
            height: 176,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: track,
                    child: Icon(project['icon'], size: 56, color: textGrey),
                  ),
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: project['statusBg'],
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      children: [
                        if (statusIcon != null)
                          Icon(statusIcon, size: 12, color: project['statusColor'])
                        else
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: project['statusColor'],
                              shape: BoxShape.circle,
                            ),
                          ),
                        const SizedBox(width: 4),
                        Text(
                          project['status'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: project['statusColor'],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xCC30312C),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      project['updated'],
                      style: const TextStyle(fontSize: 12, color: Color(0xFFF3F1E9)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 13, color: textGrey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        project['location'],
                        style: const TextStyle(fontSize: 12, color: textGrey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F4EC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Alokasi Kontrak',
                            style: TextStyle(fontSize: 14, color: textGrey),
                          ),
                          const Spacer(),
                          Text(
                            project['budget'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            'Progres Lapangan',
                            style: TextStyle(fontSize: 12, color: textGrey),
                          ),
                          const Spacer(),
                          Text(
                            '${(progress * 100).round()}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: progressColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _progressBar(progress, progressColor, track, 6),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      project['deadline'],
                      style: const TextStyle(fontSize: 12, color: textGrey),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => _open(context, const ProjectDetailScreen()),
                      child: const Row(
                        children: [
                          Text(
                            'Rincian',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: darkGreen,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.chevron_right, size: 16, color: darkGreen),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 5. PEMBARUAN & TINDAK LANJUT
  Widget _buildUpdates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'Pembaruan & Tindak Lanjut',
          'Respon keterbukaan dari Organisasi Perangkat Daerah (OPD)',
        ),
        const SizedBox(height: 12),
        _updateItem(
          background: const Color(0xFFE4E8DA),
          iconBackground: forest,
          icon: Icons.engineering_outlined,
          iconColor: surface,
          category: 'TINDAK LANJUT LAPANGAN',
          categoryColor: green,
          date: '23 Feb 2026',
          message:
              'Dinas PU Bina Marga merespons laporan warga mengenai saluran air di '
              'Wonokromo — Tindak lanjut perbaikan dan pembersihan endapan sedimen '
              'dimulai hari ini.',
          footer: 'ID Laporan: #SBY-2026-0819 • Status Terverifikasi',
          footerStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: darkGreen,
          ),
        ),
        const SizedBox(height: 8),
        _updateItem(
          background: surface,
          iconBackground: softBeige,
          icon: Icons.description_outlined,
          iconColor: const Color(0xFF345665),
          category: 'PENGADAAN & LELANG',
          categoryColor: const Color(0xFF345665),
          date: '21 Feb 2026',
          message:
              'Publikasi berkas pengadaan lelang pengawasan jembatan Joyoboyo telah '
              'diunggah ke portal keterbukaan dokumen kota.',
          footer: 'LPSE Surabaya • Tahap Evaluasi Kualifikasi',
          footerStyle: const TextStyle(fontSize: 12, color: textGrey),
        ),
      ],
    );
  }

  Widget _updateItem({
    required Color background,
    required Color iconBackground,
    required IconData icon,
    required Color iconColor,
    required String category,
    required Color categoryColor,
    required String date,
    required String message,
    required String footer,
    required TextStyle footerStyle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(color: iconBackground, shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          color: categoryColor,
                        ),
                      ),
                    ),
                    Text(date, style: const TextStyle(fontSize: 12, color: textGrey)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(fontSize: 14, height: 1.375, color: textDark),
                ),
                const SizedBox(height: 10),
                Text(footer, style: footerStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 6. AJAKAN PARTISIPASI WARGA
  Widget _buildParticipation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: softBeige,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.photo_camera_outlined, color: darkGreen),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lihat kejanggalan atau punya aspirasi?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textDark,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Kirimkan foto dokumentasi lapangan untuk membantu memverifikasi '
                      'perkembangan proyek bersama warga lain.',
                      style: TextStyle(fontSize: 14, color: textGrey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _open(context, const ContributionScreen()),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkGreen,
                foregroundColor: surface,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: const StadiumBorder(),
                elevation: 1,
              ),
              child: const Text(
                'Kirim Dokumentasi',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 7. SUMBER & KONTEKS DATA
  Widget _buildDataSource() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: track,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storage_outlined, size: 16, color: textDark),
              SizedBox(width: 8),
              Text(
                'Sumber & Konteks Data',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Data yang disajikan pada antarmuka ini dirancang untuk edukasi publik, '
            'keterbukaan informasi, dan dorongan partisipasi sipil. Seluruh rincian '
            'berupa simulasi berbasis kerangka APBD Surabaya dan bukan dokumen resmi '
            'pengganti warta keuangan pemerintah daerah.',
            style: TextStyle(fontSize: 14, height: 1.625, color: textGrey),
          ),
          SizedBox(height: 16),
          Text(
            'Model Terbuka v2.4 • Standar Data: Open Contracting',
            style: TextStyle(fontSize: 12, height: 1.6, color: textGrey),
          ),
          SizedBox(height: 4),
          Text(
            'Metodologi & Kebijakan Privasi',
            style: TextStyle(
              fontSize: 12,
              color: textGrey,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'education_screen.dart';

class InformationSourceScreen extends StatelessWidget {
  const InformationSourceScreen({super.key});

  static const Color navy = Color(0xFF172F52);
  static const Color blue = Color(0xFF2861A0);
  static const Color teal = Color(0xFF18A394);
  static const Color background = Color(0xFFF5F7FA);
  static const Color grey = Color(0xFF8190A5);

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
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSimulationLabel(),

                    const SizedBox(height: 22),

                    _buildBackButton(context),

                    const SizedBox(height: 25),

                    const Text(
                      'SUMBER & METADATA',
                      style: TextStyle(
                        color: grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.3,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Dasar informasi',
                      style: TextStyle(
                        color: navy,
                        fontSize: 29,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -1,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Telusuri konteks, definisi, dan keterbatasan data yang ditampilkan.',
                      style: TextStyle(
                        color: grey,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    _buildDatasetCard(),

                    const SizedBox(height: 22),

                    _buildDefinitionsCard(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          const Icon(
            Icons.notifications_none_rounded,
            size: 27,
            color: navy,
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

  Widget _buildSimulationLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E9),
        border: Border.all(color: const Color(0xFFF2D49B)),
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Color(0xFF956329),
          ),
          SizedBox(width: 8),
          Text(
            'DATA SIMULASI — BUKAN DATA RESMI',
            style: TextStyle(
              color: Color(0xFF956329),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: const Row(
        children: [
          Icon(Icons.chevron_left, color: blue, size: 25),
          SizedBox(width: 5),
          Text(
            'Kembali',
            style: TextStyle(
              color: blue,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatasetCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE5EF)),
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6F0ED),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: teal,
                  size: 27,
                ),
              ),

              const SizedBox(width: 15),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DATASET SIMULASI',
                      style: TextStyle(
                        color: grey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      'Ringkasan anggaran dan proyek Kota Surabaya',
                      style: TextStyle(
                        color: navy,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          const Divider(color: Color(0xFFDCE5EF)),

          _metadataItem(
            'Cakupan',
            'Kota Surabaya · Tahun anggaran 2026',
          ),

          _metadataItem(
            'Periode pelaporan',
            'Sampai 31 Oktober 2026',
          ),

          _metadataItem(
            'Tanggal pembaruan',
            '31 Oktober 2026',
          ),

          _metadataItem(
            'Status',
            'Data simulasi · belum diverifikasi sebagai data resmi',
            last: true,
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Color(0xFF956329),
                  size: 19,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Seluruh angka dan nama instansi pada prototipe ini adalah ilustrasi. Tidak ada tautan dokumen resmi fiktif yang disediakan.',
                    style: TextStyle(
                      color: Color(0xFF956329),
                      fontSize: 12,
                      height: 1.5,
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

  Widget _metadataItem(
    String title,
    String value, {
    bool last = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 17),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFDCE5EF)),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: grey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: navy,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefinitionsCard(BuildContext context) {
    final definitions = [
      {
        'title': 'Pagu anggaran',
        'description':
            'Anggaran yang ditetapkan untuk cakupan dan versi tertentu.',
      },
      {
        'title': 'Realisasi keuangan',
        'description':
            'Pengeluaran yang telah dilaporkan pada periode tertentu.',
      },
      {
        'title': 'Nilai kontrak',
        'description':
            'Nilai pekerjaan yang tercantum dalam kontrak yang tersedia.',
      },
      {
        'title': 'Progres fisik',
        'description':
            'Persentase kemajuan pekerjaan dengan tanggal pengukuran.',
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE5EF)),
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Definisi indikator',
            style: TextStyle(
              color: navy,
              fontSize: 21,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 25),

          ...definitions.asMap().entries.map((entry) {
            final item = entry.value;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 17),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFDCE5EF)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title']!,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 9),

                  Text(
                    item['description']!,
                    style: const TextStyle(
                      color: grey,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 22),

          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EducationScreen(),
                ),
              );
            },
            child: const Row(
              children: [
                Text(
                  'Baca semua istilah',
                  style: TextStyle(
                    color: blue,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: blue,
                  size: 21,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
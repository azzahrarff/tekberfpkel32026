
import 'package:flutter/material.dart';
import 'budget_service.dart';
import 'education_screen.dart';

class InformationSourceScreen extends StatefulWidget {
  final int? year;

  const InformationSourceScreen({
    super.key,
    this.year,
  });

  @override
  State<InformationSourceScreen> createState() =>
      _InformationSourceScreenState();
}

class _InformationSourceScreenState
    extends State<InformationSourceScreen> {
  static const Color navy = Color(0xFF172F52);
  static const Color blue = Color(0xFF2861A0);
  static const Color teal = Color(0xFF18A394);
  static const Color background = Color(0xFFF5F7FA);
  static const Color grey = Color(0xFF8190A5);

  final BudgetService service = BudgetService();

  List<Map<String, dynamic>> datasets = [];
  List<Map<String, dynamic>> definitions = [];

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadInformation();
  }

  // MENGAMBIL METADATA DAN DEFINISI DARI SUPABASE
  Future<void> loadInformation() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final datasetResponse = await service.getDatasets();
      final glossaryResponse = await service.getGlossary();

      final filteredDatasets = widget.year == null
          ? datasetResponse
          : datasetResponse.where((item) {
              final year = widget.year.toString();

              return item['fiscal_year']?.toString() == year ||
                  (item['dataset_name']?.toString() ?? '')
                      .contains(year) ||
                  (item['data_scope']?.toString() ?? '')
                      .contains(year) ||
                  (item['reporting_period']?.toString() ?? '')
                      .contains(year);
            }).toList();

      final indicatorTerms = [
        'pagu anggaran',
        'realisasi keuangan',
        'nilai kontrak',
        'progres fisik',
      ];

      final filteredDefinitions =
          glossaryResponse.where((item) {
        final term = item['term_name']
                ?.toString()
                .trim()
                .toLowerCase() ??
            '';

        return indicatorTerms.contains(term);
      }).toList();

      if (!mounted) return;

      setState(() {
        datasets = filteredDatasets;

        definitions = filteredDefinitions.isNotEmpty
            ? filteredDefinitions
            : glossaryResponse;

        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = 'Gagal memuat informasi: $e';
        loading = false;
      });
    }
  }

  // MENANGANI DATA KOSONG
  String displayValue(dynamic value) {
    if (value == null ||
        value.toString().trim().isEmpty) {
      return 'Belum tersedia';
    }

    return value.toString();
  }

  // FORMAT TANGGAL INDONESIA
  String formatDate(dynamic value) {
    if (value == null) {
      return 'Belum tersedia';
    }

    final date = DateTime.tryParse(
      value.toString(),
    );

    if (date == null) {
      return value.toString();
    }

    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
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
                padding: const EdgeInsets.fromLTRB(
                  20, 20, 20, 30,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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

                    if (loading)
                      _buildLoading()
                    else if (error != null)
                      _buildError()
                    else ...[
                      if (datasets.isEmpty)
                        _buildEmptyData(
                          'Metadata dataset belum tersedia.',
                        )
                      else
                        ...datasets.map(
                          (dataset) => Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom: 22,
                            ),
                            child:
                                _buildDatasetCard(dataset),
                          ),
                        ),

                      const SizedBox(height: 10),

                      _buildDefinitionsCard(context),
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

  // HEADER APLIKASI
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

  // LABEL DATA SIMULASI
  Widget _buildSimulationLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E9),
        border: Border.all(
          color: const Color(0xFFF2D49B),
        ),
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

          Flexible(
            child: Text(
              'DATA SIMULASI - BUKAN DATA RESMI',
              style: TextStyle(
                color: Color(0xFF956329),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TOMBOL KEMBALI
  Widget _buildBackButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: const Row(
        children: [
          Icon(
            Icons.chevron_left,
            color: blue,
            size: 25,
          ),

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

  // KARTU METADATA DATASET
  Widget _buildDatasetCard(
    Map<String, dynamic> dataset,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFDCE5EF),
        ),
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6F0ED),
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: teal,
                  size: 27,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DATASET SIMULASI',
                      style: TextStyle(
                        color: grey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      displayValue(
                        dataset['dataset_name'],
                      ),
                      style: const TextStyle(
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

          const Divider(
            color: Color(0xFFDCE5EF),
          ),

          _metadataItem(
            'Cakupan',
            displayValue(dataset['data_scope']),
          ),

          _metadataItem(
            'Periode pelaporan',
            displayValue(dataset['reporting_period']),
          ),

          _metadataItem(
            'Tanggal pembaruan',
            formatDate(dataset['last_updated']),
          ),

          _metadataItem(
            'Status',
            displayValue(dataset['data_status']),
          ),

          _metadataItem(
            'Sumber data',
            displayValue(dataset['source_name']),
          ),

          _metadataItem(
            'Tautan sumber',
            dataset['source_url'] == null ||
                    dataset['source_url']
                        .toString()
                        .trim()
                        .isEmpty
                ? 'Tidak ada tautan sumber resmi'
                : dataset['source_url'].toString(),
            last: true,
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E9),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: const Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Color(0xFF956329),
                  size: 19,
                ),

                SizedBox(width: 12),

                Expanded(
                  child: Text(
                    'Data anggaran pada prototipe ini merupakan data simulasi dan tidak dapat dijadikan sebagai sumber informasi resmi pemerintah.',
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

  // KOMPONEN INFORMASI METADATA
  Widget _metadataItem(
    String title,
    String value, {
    bool last = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 17,
      ),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(
                bottom: BorderSide(
                  color: Color(0xFFDCE5EF),
                ),
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

          SelectableText(
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

  // KARTU DEFINISI INDIKATOR
  Widget _buildDefinitionsCard(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFDCE5EF),
        ),
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

          if (definitions.isEmpty)
            const Text(
              'Definisi indikator belum tersedia.',
              style: TextStyle(
                color: grey,
                fontSize: 13,
              ),
            )
          else
            ...definitions.map((item) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 17,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFDCE5EF),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayValue(item['term_name']),
                      style: const TextStyle(
                        color: navy,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Text(
                      displayValue(item['definition']),
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
                  builder: (_) =>
                      const EducationScreen(),
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

  // LOADING STATE
  Widget _buildLoading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(35),
        child: Column(
          children: [
            CircularProgressIndicator(
              color: teal,
            ),

            SizedBox(height: 18),

            Text(
              'Memuat metadata dan definisi...',
              style: TextStyle(
                color: grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ERROR STATE
  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFDCE5EF),
        ),
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 40,
          ),

          const SizedBox(height: 14),

          const Text(
            'Gagal memuat informasi',
            style: TextStyle(
              color: navy,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            error ?? 'Terjadi kesalahan.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: grey,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 15),

          ElevatedButton.icon(
            onPressed: loadInformation,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // EMPTY STATE
  Widget _buildEmptyData(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFDCE5EF),
        ),
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.folder_open_outlined,
            color: grey,
            size: 45,
          ),

          const SizedBox(height: 12),

          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: navy,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
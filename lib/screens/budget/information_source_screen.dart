import 'package:flutter/material.dart';

import 'budget_service.dart';
import 'education_screen.dart';

class InformationSourceScreen extends StatefulWidget {
  final Map<String, dynamic>? project;
  final bool fromEducation;

  const InformationSourceScreen({
    super.key,
    this.project,
    this.fromEducation = false,
  });

  @override
  State<InformationSourceScreen> createState() =>
      _InformationSourceScreenState();
}

class _InformationSourceScreenState extends State<InformationSourceScreen> {
  static const Color navy = Color(0xFF172F52);
  static const Color blue = Color(0xFF2861A0);
  static const Color teal = Color(0xFF18A394);
  static const Color background = Color(0xFFF5F7FA);
  static const Color grey = Color(0xFF8190A5);
  static const Color border = Color(0xFFDCE5EF);

  static const indicatorTerms = {
    'pagu anggaran',
    'nilai kontrak',
    'realisasi keuangan',
    'realisasi fisik',
    'progres fisik',
  };

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

  Future<void> loadInformation() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final project = widget.project;

      final results = await Future.wait<List<Map<String, dynamic>>>([
        project == null
            ? service.getDatasets()
            : service.getProjectDatasets(project),
        service.getGlossary(),
      ]);

      final indicators = results[1].where((item) {
        final name = item['term_name']?.toString().trim().toLowerCase();
        return indicatorTerms.contains(name);
      }).toList();

      if (!mounted) return;

      setState(() {
        datasets = results[0];
        definitions = indicators;
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

  String displayValue(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? 'Belum tersedia' : text;
  }

  String formatDate(dynamic value) {
    final text = displayValue(value);
    final date = DateTime.tryParse(text);

    if (date == null) return text;

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

  void openEducation() {
    // Jika pengguna datang dari Pusat Edukasi, kembali ke halaman yang sama.
    if (widget.fromEducation) {
      Navigator.pop(context);
      return;
    }

    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => EducationScreen(
          project: widget.project,
          fromMetadata: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasProject = widget.project != null;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (!loading) {
                    await loadInformation();
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSimulationLabel(),
                      const SizedBox(height: 22),
                      _buildBackButton(),
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
                      Text(
                        hasProject
                            ? 'Telusuri dataset anggaran terkait dan definisi '
                                'indikator untuk proyek ini.'
                            : 'Telusuri konteks, definisi, dan keterbatasan '
                                'data yang ditampilkan.',
                        style: const TextStyle(
                          color: grey,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (loading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(30),
                            child: CircularProgressIndicator(color: teal),
                          ),
                        )
                      else if (error != null)
                        _buildError()
                      else ...[
                        if (datasets.isEmpty)
                          _buildEmptyData(
                            hasProject
                                ? 'Belum ada metadata anggaran yang sesuai '
                                    'untuk wilayah proyek maupun wilayah '
                                    'induk pada kategori dan tahun ini.'
                                : 'Metadata dataset belum tersedia.',
                          )
                        else
                          for (final dataset in datasets)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 22),
                              child: _buildDatasetCard(dataset),
                            ),
                        const SizedBox(height: 10),
                        _buildDefinitionsCard(),
                      ],
                    ],
                  ),
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
                TextSpan(text: 'Anggaran', style: TextStyle(color: navy)),
                TextSpan(text: 'Terbuka', style: TextStyle(color: blue)),
              ],
            ),
          ),
          const Spacer(),
          const Icon(Icons.notifications_none_rounded, size: 27, color: navy),
          const SizedBox(width: 18),
          const CircleAvatar(
            radius: 19,
            backgroundColor: Color(0xFFDCEAF7),
            child: Text(
              'AR',
              style: TextStyle(color: blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E9),
        border: Border.all(color: const Color(0xFFF2D49B)),
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 16, color: Color(0xFF956329)),
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

  Widget _buildBackButton() {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
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

  Widget _buildDatasetCard(Map<String, dynamic> dataset) {
    final isParentRegion = dataset['is_parent_region'] == true;
    final sourceUrl = dataset['source_url']?.toString().trim() ?? '';

    return _whiteCard(
      Column(
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isParentRegion
                          ? 'DATASET SIMULASI · WILAYAH INDUK'
                          : 'DATASET SIMULASI',
                      style: const TextStyle(
                        color: grey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      displayValue(dataset['dataset_name']),
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
          const Divider(color: border),
          _metadataItem('Cakupan', displayValue(dataset['data_scope'])),
          _metadataItem(
            'Periode pelaporan',
            displayValue(dataset['reporting_period']),
          ),
          _metadataItem('Tanggal pembaruan', formatDate(dataset['last_updated'])),
          _metadataItem('Status', displayValue(dataset['data_status'])),
          _metadataItem('Sumber data', displayValue(dataset['source_name'])),
          _metadataItem(
            'Tautan sumber',
            sourceUrl.isEmpty ? 'Tidak ada tautan sumber resmi' : sourceUrl,
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
                Icon(Icons.info_outline, color: Color(0xFF956329), size: 19),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Data anggaran pada prototipe ini merupakan data simulasi '
                    'dan tidak dapat dijadikan sebagai sumber informasi resmi '
                    'pemerintah.',
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

  Widget _metadataItem(String title, String value, {bool last = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: grey, fontSize: 12)),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: navy,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          if (!last) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: border),
          ],
        ],
      ),
    );
  }

  Widget _buildDefinitionsCard() {
    return _whiteCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Definisi indikator',
            style: TextStyle(
              color: navy,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20),
          if (definitions.isEmpty)
            const Text(
              'Definisi indikator belum tersedia.',
              style: TextStyle(color: grey, fontSize: 14),
            )
          else
            for (var i = 0; i < definitions.length; i++) ...[
              if (i > 0) const Divider(height: 28, color: border),
              Text(
                displayValue(definitions[i]['term_name']),
                style: const TextStyle(
                  color: navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                displayValue(definitions[i]['definition']),
                style: const TextStyle(color: grey, fontSize: 13, height: 1.5),
              ),
            ],
          const SizedBox(height: 22),
          InkWell(
            onTap: openEducation,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
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
                Icon(Icons.chevron_right, color: blue, size: 21),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _whiteCard(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(19),
      ),
      child: child,
    );
  }

  Widget _buildEmptyData(String message) {
    return _whiteCard(
      Column(
        children: [
          const Icon(Icons.folder_open_outlined, color: grey, size: 45),
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

  Widget _buildError() {
    return _whiteCard(
      Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 36),
          const SizedBox(height: 12),
          Text(
            error ?? 'Gagal memuat informasi.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: navy, fontSize: 14),
          ),
          TextButton(
            onPressed: loadInformation,
            child: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }
}
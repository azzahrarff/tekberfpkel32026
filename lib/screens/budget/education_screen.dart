
import 'package:flutter/material.dart';
import 'budget_service.dart';
import 'information_source_screen.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() =>
      _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  static const Color navy = Color(0xFF172F52);
  static const Color blue = Color(0xFF2861A0);
  static const Color background = Color(0xFFF5F7FA);
  static const Color grey = Color(0xFF8190A5);

  final BudgetService service = BudgetService();

  final TextEditingController searchController =
      TextEditingController();

  String searchQuery = '';

  List<Map<String, String>> terms = [];

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadTerms();
  }

  // MENGAMBIL ISTILAH DARI SUPABASE
  Future<void> loadTerms() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final response = await service.getGlossary();

      final result = List.generate(
        response.length,
        (index) {
          final item = response[index];

          return <String, String>{
            'number': (index + 1)
                .toString()
                .padLeft(2, '0'),
            'title':
                item['term_name']?.toString() ??
                    'Istilah tidak tersedia',
            'description':
                item['definition']?.toString() ??
                    'Definisi belum tersedia.',
          };
        },
      );

      if (!mounted) return;

      setState(() {
        terms = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = 'Gagal memuat istilah anggaran: $e';
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTerms = terms.where((term) {
      final query = searchQuery.trim().toLowerCase();

      return term['title']!
              .toLowerCase()
              .contains(query) ||
          term['description']!
              .toLowerCase()
              .contains(query);
    }).toList();

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
                    _buildBackButton(),

                    const SizedBox(height: 24),

                    const Text(
                      'PUSAT EDUKASI',
                      style: TextStyle(
                        color: grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.3,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Pahami istilah anggaran',
                      style: TextStyle(
                        color: navy,
                        fontSize: 29,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -1,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Penjelasan sederhana untuk membantu membaca data publik dengan tepat.',
                      style: TextStyle(
                        color: grey,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    _buildSearch(),

                    const SizedBox(height: 22),

                    if (loading)
                      _buildLoading()
                    else if (error != null)
                      _buildError()
                    else if (terms.isEmpty)
                      _buildEmptyData()
                    else if (filteredTerms.isEmpty)
                      _buildEmptySearch()
                    else
                      ...filteredTerms.map(
                        (term) => _buildTermCard(term),
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

  // TOMBOL KEMBALI
  Widget _buildBackButton() {
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

  // KOLOM PENCARIAN
  Widget _buildSearch() {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFDCE5EF),
        ),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: grey,
            size: 24,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                hintText:
                    'Cari istilah seperti pagu atau realisasi...',
                hintStyle: TextStyle(
                  color: Color(0xFF9AA4B2),
                  fontSize: 13,
                ),
                border: InputBorder.none,
              ),
            ),
          ),

          if (searchQuery.isNotEmpty)
            IconButton(
              onPressed: () {
                searchController.clear();

                setState(() {
                  searchQuery = '';
                });
              },
              icon: const Icon(
                Icons.close,
                color: grey,
              ),
            ),
        ],
      ),
    );
  }

  // KARTU ISTILAH ANGGARAN
  Widget _buildTermCard(
    Map<String, String> term,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
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
          Text(
            term['number']!,
            style: const TextStyle(
              color: Color(0xFFB3C0CE),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            term['title']!,
            style: const TextStyle(
              color: navy,
              fontSize: 21,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            term['description']!,
            style: const TextStyle(
              color: grey,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 22),

          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const InformationSourceScreen(),
                ),
              );
            },
            child: const Row(
              children: [
                Text(
                  'Lihat dalam metadata',
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
              color: blue,
            ),

            SizedBox(height: 18),

            Text(
              'Memuat istilah anggaran...',
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
            'Gagal memuat data',
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
            onPressed: loadTerms,
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

  // EMPTY STATE DATABASE
  Widget _buildEmptyData() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            Icon(
              Icons.menu_book_outlined,
              color: grey,
              size: 45,
            ),

            SizedBox(height: 12),

            Text(
              'Istilah anggaran belum tersedia',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: navy,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),

            SizedBox(height: 5),

            Text(
              'Belum ada data istilah dalam database.',
              textAlign: TextAlign.center,
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

  // HASIL PENCARIAN KOSONG
  Widget _buildEmptySearch() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              color: grey,
              size: 45,
            ),

            SizedBox(height: 12),

            Text(
              'Istilah tidak ditemukan',
              style: TextStyle(
                color: navy,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),

            SizedBox(height: 5),

            Text(
              'Coba gunakan kata kunci lainnya.',
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
}
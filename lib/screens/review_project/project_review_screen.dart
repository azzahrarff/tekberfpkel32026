import '../budget/education_screen.dart';
import '../budget/information_source_screen.dart';
import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../contribution/contribution_widgets.dart';
import '../contribution/contribution_service.dart';
import '../contribution/contribution_project_screen.dart';
import '../contribution/contribution_evidence_screen.dart';
import '../contribution/contribution_review_screen.dart';
import '../contribution/contribution_success_screen.dart';
import 'project_review_service.dart';
import 'project_review_widgets.dart';

class ProjectReviewScreen extends StatefulWidget {
  final int? projectId;
  final VoidCallback? onBack;
  final String? heroAsset;
  const ProjectReviewScreen({super.key, this.projectId, this.onBack, this.heroAsset});

  @override
  State<ProjectReviewScreen> createState() => _ProjectReviewScreenState();
}

class _ProjectReviewScreenState extends State<ProjectReviewScreen> {
  int? _id;
  int _tab = 0;
  bool? _saved;
  bool _saving = false;
  Future<ProjectReviewData>? _data;
  late Future<List<Map<String, dynamic>>> _list;
  static const tabs = ['Ringkasan', 'Keuangan', 'Timeline', 'Pengadaan'];

  @override
  void initState() {
    super.initState();
    _id = widget.projectId;
    _list = _id == null ? ProjectReviewService.projects() : Future.value(<Map<String, dynamic>>[]);
    if (_id != null) {
      _data = ProjectReviewService.load(_id!);
      _loadSaved(_id!);
    }
  }

  Future<void> _loadSaved(int id) async {
    try {
      final saved = await ProjectReviewService.isSaved(id);
      if (mounted && _id == id) setState(() => _saved = saved);
    } catch (_) {
      if (mounted && _id == id) setState(() => _saved = null);
    }
  }

  void _select(int id) {
    setState(() {
      _id = id;
      _tab = 0;
      _saved = null;
      _data = ProjectReviewService.load(id);
    });
    _loadSaved(id);
  }

  void _back() {
    if (_saving) return;
    if (widget.projectId != null) {
      if (widget.onBack != null) { widget.onBack!(); } else { Navigator.maybePop(context); }
    } else {
      setState(() { _id = null; _data = null; _tab = 0; _saved = null; _list = ProjectReviewService.projects(); });
    }
  }

  Future<void> _toggle() async {
    final id = _id;
    if (_saving || id == null) return;
    if (!SupabaseService.isLoggedIn) { contributionMessage(context, 'Silakan login untuk mengikuti proyek.'); return; }
    setState(() => _saving = true);
    try {
      final saved = await ProjectReviewService.toggleSaved(id);
      if (mounted && _id == id) {
        setState(() => _saved = saved);
        contributionMessage(context, saved ? 'Proyek berhasil diikuti.' : 'Proyek dihapus dari daftar simpan.');
      }
    } catch (_) {
      if (mounted) contributionMessage(context, 'Gagal mengubah proyek tersimpan. Coba lagi.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _contribute(Map<String, dynamic> project) {
    if (!SupabaseService.isLoggedIn) { contributionMessage(context, 'Silakan login untuk mengirim dokumentasi.'); return; }
    Navigator.push(context, MaterialPageRoute(builder: (_) => _ProjectContributionFlow(project: project)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: background,
    body: SafeArea(child: Column(children: [
      const ContributionHeader(),
      Expanded(child: _id == null ? _projectList() : FutureBuilder<ProjectReviewData>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError || !snapshot.hasData) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Gagal memuat rincian proyek.'), TextButton(onPressed: () => _select(_id!), child: const Text('Coba lagi')), TextButton(onPressed: _back, child: const Text('Kembali')),
          ]));
          final data = snapshot.data!;
          return SingleChildScrollView(key: ValueKey(_id), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _hero(data.project), _tabBar(),
            Padding(padding: const EdgeInsets.fromLTRB(16, 18, 16, 40), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              simulationBadge(), const SizedBox(height: 16),
              switch (_tab) {
                1 => _Finance(project: data.project, onGlossary: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute(builder: (_) => EducationScreen(project: data.project)),
                )),
                2 => _Timeline(data: data),
                3 => _Procurement(data: data, onMetadata: () => _openInformation(data.project)),
                _ => _Summary(data: data, onFinance: () => setState(() => _tab = 1), onMetadata: () => _openInformation(data.project)),
              },
            ])),
          ]))));
        },
      )),
    ])),
  );

  Widget _projectList() => FutureBuilder<List<Map<String, dynamic>>>(future: _list, builder: (context, snapshot) {
    if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
    if (snapshot.hasError) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('Gagal memuat daftar proyek.'), TextButton(onPressed: () => setState(() => _list = ProjectReviewService.projects()), child: const Text('Coba lagi'))]));
    final rows = snapshot.data ?? [];
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Daftar Proyek', style: TextStyle(color: navy, fontSize: 26, fontWeight: FontWeight.w600)), const SizedBox(height: 12), simulationBadge(), const SizedBox(height: 18),
      if (rows.isEmpty) const Text('Belum ada proyek tersedia.'),
      for (final p in rows) Card(color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: border)), child: ListTile(contentPadding: const EdgeInsets.all(14), leading: const Icon(Icons.folder_outlined, color: blue), title: Text(display(p['project_name']), style: const TextStyle(color: navy, fontWeight: FontWeight.w600)), subtitle: Text('${display(p['project_code'])}\n${display(p['project_status'])} · ${percent(number(p['physical_progress']))}'), trailing: const Icon(Icons.chevron_right, color: blue), onTap: () => _select((p['id'] as num).toInt()))),
    ]);
  });

  Widget _hero(Map<String, dynamic> p) => Container(
    color: navy,
    child: Stack(children: [
      if (widget.heroAsset != null) Positioned.fill(child: Image.asset(widget.heroAsset!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink())),
      Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [navy.withValues(alpha: .45), navy.withValues(alpha: .98)])))),
      if (widget.heroAsset == null) const Positioned(right: -18, top: 55, child: Icon(Icons.construction_rounded, size: 230, color: Color(0xFF254362))),
      Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 54), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextButton.icon(onPressed: _saving ? null : _back, icon: const Icon(Icons.chevron_left, color: Colors.white), label: const Text('Kembali ke daftar proyek', style: TextStyle(color: Colors.white70))), const SizedBox(height: 32),
        Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [statusBadge(display(p['project_status'])), Text('${display(p['project_code'])} · Tahun ${display(p['fiscal_year'])}', style: const TextStyle(color: Colors.white70, fontSize: 12))]), const SizedBox(height: 14),
        Text(display(p['project_name']), style: const TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.w500, height: 1.2)), const SizedBox(height: 12),
        Row(children: [const Icon(Icons.location_on_outlined, size: 18, color: Colors.white70), const SizedBox(width: 6), Expanded(child: Text(display(p['project_location'] ?? p['district']), style: const TextStyle(color: Colors.white70, fontSize: 13)))]), const SizedBox(height: 22),
        LayoutBuilder(builder: (context, c) {
          final buttons = <Widget>[
            OutlinedButton.icon(onPressed: _saving ? null : _toggle, style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54), padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), icon: Icon(_saved == true ? Icons.favorite : Icons.favorite_border, size: 18), label: Text(_saving ? 'Memproses...' : _saved == true ? 'Diikuti' : 'Ikuti proyek')),
            FilledButton.icon(onPressed: () => _contribute(p), style: FilledButton.styleFrom(backgroundColor: blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), icon: const Icon(Icons.camera_alt_outlined, size: 18), label: const Text('Kirim dokumentasi')),
          ];
          if (c.maxWidth < 320) return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [buttons[0], const SizedBox(height: 8), buttons[1]]);
          return Row(children: [Expanded(child: buttons[0]), const SizedBox(width: 8), Expanded(child: buttons[1])]);
        }),
      ])),
    ]),
  );

  Widget _tabBar() => Container(color: Colors.white, child: Row(children: [for (int i = 0; i < tabs.length; i++) Expanded(child: InkWell(onTap: () => setState(() => _tab = i), child: Container(height: 54, alignment: Alignment.center, decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _tab == i ? blue : border, width: _tab == i ? 3 : 1))), child: Text(tabs[i], style: TextStyle(color: _tab == i ? blue : grey, fontSize: 12, fontWeight: _tab == i ? FontWeight.w700 : FontWeight.w400))))) ]));


  void _openInformation(Map<String, dynamic> project) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => InformationSourceScreen(project: project),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final ProjectReviewData data;
  final VoidCallback onFinance, onMetadata;
  const _Summary({required this.data, required this.onFinance, required this.onMetadata});
  @override
  Widget build(BuildContext context) {
    final p = data.project;
    final physical = number(p['physical_progress']);
    final target = number(p['target_progress']);
    final delta = physical == null || target == null ? null : physical - target;
    final active = data.timeline.where((t) => t['stage_status'] == 'Sedang berlangsung').toList();
    final done = data.timeline.where((t) => t['stage_status'] == 'Selesai').toList();
    final latest = active.isNotEmpty ? active.last : done.isNotEmpty ? done.last : null;
    return Column(children: [
      ReviewCard(children: [reviewLabel('PROGRES FISIK'), const SizedBox(height: 12), Row(children: [Expanded(child: Text(percent(physical), style: const TextStyle(color: navy, fontSize: 38, fontWeight: FontWeight.w800))), if (target != null) Chip(label: Text('Target ${percent(target)}', style: const TextStyle(fontSize: 11)))]), reviewBody('per ${dateLabel(p['last_updated'])}'), const SizedBox(height: 15), progressBar(physical, reviewTeal), const SizedBox(height: 10), if (delta != null) reviewBody(delta < 0 ? 'Progres ${decimal(delta.abs())} poin persentase di bawah target pada tanggal pelaporan.' : delta > 0 ? 'Progres ${decimal(delta)} poin persentase di atas target.' : 'Progres sesuai target.')]),
      ReviewCard(children: [reviewTitle('Tentang proyek'), reviewBody(display(p['description'])), const SizedBox(height: 16), detailRow('Kategori pembangunan', display(p['budget_categories']?['category_name'])), detailRow('Wilayah', display(p['regions']?['region_name']))]),
      ReviewCard(children: [reviewLabel('PEMBARUAN TERBARU'), const SizedBox(height: 12), reviewTitle(latest == null ? 'Belum ada pembaruan tahapan' : display(latest['stage_name'])), if (latest != null) reviewBody(display(latest['stage_description'])), const SizedBox(height: 8), reviewBody('Data simulasi · ${dateLabel(p['last_updated'])}')]),
      ReviewCard(children: [reviewTitle('Informasi utama'), detailRow('Instansi', 'Belum tersedia dalam database'), detailRow('Penyedia', display(p['provider_name'])), detailRow('Mulai pekerjaan', dateLabel(p['start_date'])), detailRow('Target selesai', dateLabel(p['target_completion_date'])), detailRow('Nilai kontrak', rupiah(p['contract_value'])), TextButton(onPressed: onFinance, child: const Row(children: [Expanded(child: Text('Lihat rincian keuangan')), Icon(Icons.chevron_right, size: 18)]))]),
      ReviewCard(color: const Color(0xFFE8F1FA), children: [reviewTitle('Sumber & metadata'), reviewBody('Data simulasi · diperbarui ${dateLabel(p['last_updated'])}'), TextButton.icon(onPressed: onMetadata, icon: const Icon(Icons.description_outlined, size: 17), label: const Text('Buka rincian sumber'))]),
    ]);
  }
}

class _Finance extends StatelessWidget {
  final Map<String, dynamic> project;
  final VoidCallback onGlossary;
  const _Finance({required this.project, required this.onGlossary});
  @override
  Widget build(BuildContext context) {
    final allocation = number(project['budget_ceiling']);
    final contract = number(project['contract_value']);
    final realized = number(project['realized_amount']);
    final p = ratio(realized, allocation);
    final c = ratio(realized, contract);
    final cards = [
      ('Pagu anggaran', rupiah(allocation), 'Anggaran ditetapkan'),
      ('Nilai kontrak', rupiah(contract), '${percent(ratio(contract, allocation))} dari pagu'),
      ('Belum terealisasi', rupiah(allocation == null || realized == null ? null : allocation - realized), 'Terhadap pagu'),
      ('Sisa nilai kontrak', rupiah(contract == null || realized == null ? null : contract - realized), 'Belum terealisasi'),
    ];
    return Column(children: [
      ReviewCard(children: [reviewLabel('REALISASI KEUANGAN'), const SizedBox(height: 12), Text(rupiah(realized), style: const TextStyle(color: navy, fontSize: 29, fontWeight: FontWeight.w800)), const SizedBox(height: 18), Text(percent(p), style: const TextStyle(color: blue, fontSize: 25, fontWeight: FontWeight.bold)), reviewBody('terhadap pagu'), const SizedBox(height: 16), progressBar(p, blue), const SizedBox(height: 7), reviewBody('Periode pelaporan sampai ${dateLabel(project['last_updated'])}')]),
      LayoutBuilder(builder: (context, constraints) => Wrap(spacing: 10, runSpacing: 10, children: [for (final card in cards) SizedBox(width: constraints.maxWidth < 300 ? constraints.maxWidth : (constraints.maxWidth - 10) / 2, child: ReviewCard(children: [reviewBody(card.$1), const SizedBox(height: 10), Text(card.$2, style: const TextStyle(color: navy, fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 6), reviewBody(card.$3)]))])),
      ReviewCard(color: const Color(0xFFFFF9EA), children: [reviewTitle('Mengapa progres fisik dan keuangan berbeda?'), reviewBody('Progres fisik proyek adalah ${percent(number(project['physical_progress']))}, sedangkan realisasi keuangan terhadap pagu ${percent(p)}. Perbedaan dapat terjadi karena jadwal pembayaran bertahap dan dasar pengukuran yang berbeda.')]),
      ReviewCard(children: [reviewTitle('Basis perhitungan'), detailRow('Terhadap pagu', '${rupiah(realized)} ÷ ${rupiah(allocation)} = ${percent(p)}'), detailRow('Terhadap kontrak', '${rupiah(realized)} ÷ ${rupiah(contract)} = ${percent(c)}'), if (p == null || c == null) reviewBody('Persentase tidak tersedia ketika nilai pembagi nol atau belum tersedia.')]),
      ReviewCard(color: const Color(0xFFE8F1FA), children: [reviewTitle('Definisi indikator'), reviewBody('Persentase selalu menyebutkan pembagi dan periode.'), TextButton.icon(onPressed: onGlossary, icon: const Icon(Icons.description_outlined), label: const Text('Pelajari istilah'))]),
    ]);
  }
}

class _Timeline extends StatelessWidget {
  final ProjectReviewData data;
  const _Timeline({required this.data});
  @override
  Widget build(BuildContext context) {
    final p = data.project;
    // Jadwal revisi tingkat proyek tidak ada; revisi per tahap ditampilkan pada setiap tahap.
    return Column(children: [
      ReviewCard(children: [reviewTitle('Perjalanan proyek'), reviewBody('Tahap dan dokumen publik sepanjang proyek.'), const SizedBox(height: 20), if (data.timeline.isEmpty) reviewBody('Belum ada tahapan proyek.'), for (int i = 0; i < data.timeline.length; i++) _stage(context, data.timeline[i], i, i == data.timeline.length - 1)]),
      ReviewCard(children: [reviewTitle('Jadwal proyek'), detailRow('Target awal', dateLabel(p['target_completion_date'])), detailRow('Target revisi proyek', 'Belum tersedia'), detailRow('Penyelesaian aktual', dateLabel(p['actual_completion_date']))]),
    ]);
  }

  Widget _stage(BuildContext context, Map<String, dynamic> stage, int index, bool last) {
    final status = display(stage['stage_status']);
    final complete = status == 'Selesai';
    final active = status == 'Sedang berlangsung';
    final color = complete ? const Color(0xFF218568) : active ? reviewTeal : grey;
    return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SizedBox(width: 30, child: Column(children: [Container(width: 30, height: 30, alignment: Alignment.center, decoration: BoxDecoration(color: complete || active ? color : Colors.white, shape: BoxShape.circle, border: Border.all(color: color)), child: complete ? const Icon(Icons.check, color: Colors.white, size: 17) : Text('${index + 1}', style: TextStyle(color: active ? Colors.white : grey, fontWeight: FontWeight.w600))), if (!last) Expanded(child: Container(width: 2, color: border))])), const SizedBox(width: 13),
      Expanded(child: Padding(padding: EdgeInsets.only(bottom: last ? 2 : 25), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [Text(display(stage['stage_name']), style: const TextStyle(color: navy, fontSize: 16, fontWeight: FontWeight.w500)), statusBadge(status)]), const SizedBox(height: 7), Text('${dateLabel(stage['start_date'])} – ${dateLabel(stage['target_date'])}', style: const TextStyle(color: navy, fontSize: 12, fontWeight: FontWeight.w600)), const SizedBox(height: 8), reviewBody(display(stage['stage_description'])), if (stage['revised_target_date'] != null) reviewBody('Target revisi tahap: ${dateLabel(stage['revised_target_date'])}'), if (stage['actual_completion_date'] != null) reviewBody('Selesai aktual: ${dateLabel(stage['actual_completion_date'])}'), if (stage['supporting_document'] != null) TextButton.icon(onPressed: () => showReviewInfo(context, 'Metadata dokumen', 'Tahap: ${display(stage['stage_name'])}\nDokumen: ${display(stage['supporting_document'])}\nData simulasi; tautan contoh bukan dokumen resmi.'), icon: const Icon(Icons.description_outlined, size: 16), label: const Text('Lihat metadata dokumen'))]))),
    ]));
  }
}

class _Procurement extends StatelessWidget {
  final ProjectReviewData data;
  final VoidCallback onMetadata;
  const _Procurement({required this.data, required this.onMetadata});
  @override
  Widget build(BuildContext context) => Column(children: [
    if (data.procurement.isEmpty) ReviewCard(children: [reviewTitle('Paket pengadaan'), reviewBody('Belum tersedia informasi pengadaan.')]),
    for (final p in data.procurement) ...[
      ReviewCard(children: [reviewLabel('PAKET PENGADAAN'), const SizedBox(height: 10), reviewTitle(display(p['package_name'])), reviewBody('Kode paket simulasi: ${display(p['package_code'])}'), const SizedBox(height: 15),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [detailRow('Metode pengadaan', display(p['procurement_method'])), detailRow('Status', display(p['procurement_status'])), detailRow('Pagu anggaran', rupiah(p['budget_ceiling'])), detailRow('Nilai kontrak', rupiah(p['contract_value'])), detailRow('Penyedia', display(p['provider_name'])), detailRow('Tanggal kontrak', dateLabel(p['contract_date']))])), const SizedBox(height: 14),
        Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: const Color(0xFFE8F1FA), borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.info_outline, color: blue), const SizedBox(width: 9), Expanded(child: reviewBody('Informasi paket merupakan simulasi. Tidak ada tautan dokumen resmi fiktif yang dibuka.'))])), const SizedBox(height: 12), OutlinedButton.icon(onPressed: onMetadata, icon: const Icon(Icons.open_in_new, size: 17), label: const Text('Lihat metadata sumber'))]),
      ReviewCard(children: [reviewTitle('Dokumen pengadaan'), _doc(context, 'Rencana umum', p['general_plan_document']), _doc(context, 'Pengumuman tender', p['tender_document']), _doc(context, 'Kontrak', p['contract_document'])]),
    ],
  ]);

  Widget _doc(BuildContext context, String label, dynamic value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [detailRow(label, value == null || value.toString().isEmpty ? 'Belum tersedia' : 'Metadata tersedia (simulasi)'), if (value != null && value.toString().isNotEmpty) TextButton(onPressed: () => showReviewInfo(context, label, '${display(value)}\n\nTautan contoh data simulasi, bukan dokumen resmi.'), child: const Text('Lihat metadata'))]);
}

// Alur dokumentasi memakai screen kontribusi yang sudah dipasang sebelumnya.
class _ProjectContributionFlow extends StatefulWidget {
  final Map<String, dynamic> project;
  const _ProjectContributionFlow({required this.project});
  @override
  State<_ProjectContributionFlow> createState() => _ProjectContributionFlowState();
}

class _ProjectContributionFlowState extends State<_ProjectContributionFlow> {
  final _draft = ContributionDraft();
  int _step = 1;
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    _draft.project = widget.project;
    _draft.location = (widget.project['project_location'] ?? widget.project['district'] ?? '').toString();
  }
  void _go(int step) => setState(() => _step = step);
  void _exit() => Navigator.pop(context);
  void _reports() {
    final future = ContributionService.reports();
    showDialog<void>(context: context, builder: (context) => AlertDialog(title: const Text('Laporan saya'), content: SizedBox(width: 450, child: FutureBuilder<List<Map<String, dynamic>>>(future: future, builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) return const Center(heightFactor: 2, child: CircularProgressIndicator());
      if (snapshot.hasError) return const Text('Gagal memuat laporan.');
      final rows = snapshot.data ?? [];
      return SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [if (rows.isEmpty) const Text('Belum ada laporan.'), for (final r in rows) ListTile(title: Text(display(r['reference_code'])), subtitle: Text('${display(r['contribution_status'])}\n${display(r['description'])}'))]));
    })), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))]));
  }
  @override
  Widget build(BuildContext context) {
    final screen = switch (_step) {
      1 => ContributionProjectScreen(draft: _draft, onNext: () => _go(2), onBack: _exit),
      2 => ContributionEvidenceScreen(draft: _draft, onNext: () => _go(3), onBack: () => _go(1)),
      3 => ContributionReviewScreen(draft: _draft, onBack: () => _go(2), onBusy: (busy) { if (mounted) setState(() => _busy = busy); }, onSuccess: () { setState(() { _busy = false; _step = 4; }); }),
      _ => ContributionSuccessScreen(referenceCode: display(_draft.savedReport?['reference_code']), onProjects: _exit, onReports: _reports),
    };
    return PopScope(canPop: !_busy, child: Scaffold(backgroundColor: background, body: SafeArea(child: Column(children: [IgnorePointer(ignoring: _busy, child: const ContributionHeader()), Expanded(child: screen)]))));
  }
}
import 'package:flutter/material.dart';

import '../../core/services/supabase_service.dart';
import 'contribution_service.dart';
import 'contribution_widgets.dart';
import 'contribution_project_screen.dart';
import 'contribution_evidence_screen.dart';
import 'contribution_review_screen.dart';
import 'contribution_success_screen.dart';
import '../project/project_screen.dart';

class ContributionScreen extends StatefulWidget {
  final VoidCallback? onProjects;
  final ValueChanged<bool>? onBusy;
  const ContributionScreen({super.key, this.onProjects, this.onBusy});
  @override
  State<ContributionScreen> createState() => _ContributionScreenState();
}

class _ContributionScreenState extends State<ContributionScreen> {
  int _step = 0;
  bool _busy = false;
  ContributionDraft _draft = ContributionDraft();
  void _go(int step) => setState(() => _step = step);
  void _reset() => setState(() {
    _draft = ContributionDraft();
    _step = 0;
  });
  void _setBusy(bool value) {
    if (!mounted) return;
    setState(() => _busy = value);
    widget.onBusy?.call(value);
  }

  void _start() {
    if (!SupabaseService.isLoggedIn) {
      contributionMessage(
        context,
        'Silakan login sebelum mengirim dokumentasi.',
      );
      return;
    }
    _draft = ContributionDraft();
    _go(1);
  }

  void _projects() {
    _reset();
    if (widget.onProjects != null) {
      widget.onProjects!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProjectScreen()),
      );
    }
  }

  void _showReports() {
    if (!SupabaseService.isLoggedIn) {
      contributionMessage(context, 'Silakan login untuk melihat laporan.');
      return;
    }
    final future = ContributionService.reports();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Laporan saya'),
        content: SizedBox(
          width: 500,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done)
                return const Center(
                  heightFactor: 2,
                  child: CircularProgressIndicator(),
                );
              if (snap.hasError)
                return const Text('Gagal memuat laporan. Silakan coba lagi.');
              final rows = snap.data ?? [];
              if (rows.isEmpty) return const Text('Belum ada laporan.');
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final row in rows)
                      Card(
                        child: ListTile(
                          title: Text(
                            row['reference_code'].toString(),
                            style: const TextStyle(
                              color: blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${row['projects']?['project_name'] ?? row['title']}\n${row['contribution_status']} · ${row['documented_at']}\n${row['description']}',
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _home() => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 660),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9EA),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: const Color(0xFFE9D8A8)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFF79571C),
                        size: 15,
                      ),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'DATA SIMULASI — BUKAN DATA RESMI',
                          style: TextStyle(
                            color: Color(0xFF79571C),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: (constraints.maxHeight * .17)
                    .clamp(30.0, 150.0)
                    .toDouble(),
              ),
              Center(
                child: Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F1FA),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: blue,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'PUSAT KONTRIBUSI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: grey,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Bantu pantau pembangunan di sekitarmu',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: navy,
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Kirim dokumentasi kondisi proyek atau ikuti tindak lanjut laporanmu.',
                textAlign: TextAlign.center,
                style: TextStyle(color: grey, fontSize: 14),
              ),
              const SizedBox(height: 26),
              Center(
                child: ContributionButton(
                  label: 'Kirim dokumentasi',
                  onPressed: _start,
                ),
              ),
              const SizedBox(height: 9),
              Center(
                child: TextButton(
                  onPressed: _showReports,
                  child: const Text(
                    'Lihat laporan saya',
                    style: TextStyle(color: blue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final Widget screen = switch (_step) {
      1 => ContributionProjectScreen(
        draft: _draft,
        onNext: () => _go(2),
        onBack: _reset,
      ),
      2 => ContributionEvidenceScreen(
        draft: _draft,
        onNext: () => _go(3),
        onBack: () => _go(1),
      ),
      3 => ContributionReviewScreen(
        draft: _draft,
        onBack: () => _go(2),
        onBusy: _setBusy,
        onSuccess: () {
          _setBusy(false);
          _go(4);
        },
      ),
      4 => ContributionSuccessScreen(
        referenceCode: _draft.savedReport!['reference_code'].toString(),
        onProjects: _projects,
        onReports: _showReports,
      ),
      _ => _home(),
    };
    return PopScope(
      canPop: !_busy && _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_busy) {
          if (_step == 4 || _step == 1)
            _reset();
          else if (_step == 3 &&
              (_draft.savedReport != null || _draft.uploadedPath != null)) {
            contributionMessage(
              context,
              'Selesaikan pengiriman sebelum kembali.',
            );
          } else if (_step > 1)
            _go(_step - 1);
        }
      },
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Column(
            children: [
              if (_busy)
                const IgnorePointer(child: ContributionHeader())
              else
                const ContributionHeader(),
              Expanded(child: screen),
            ],
          ),
        ),
      ),
    );
  }
}

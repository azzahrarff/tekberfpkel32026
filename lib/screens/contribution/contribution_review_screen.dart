import 'package:flutter/material.dart';

import 'contribution_service.dart';
import 'contribution_widgets.dart';

class ContributionReviewScreen extends StatefulWidget {
  final ContributionDraft draft;
  final VoidCallback onBack, onSuccess;
  final ValueChanged<bool> onBusy;
  const ContributionReviewScreen({
    super.key,
    required this.draft,
    required this.onBack,
    required this.onSuccess,
    required this.onBusy,
  });
  @override
  State<ContributionReviewScreen> createState() =>
      _ContributionReviewScreenState();
}

class _ContributionReviewScreenState extends State<ContributionReviewScreen> {
  bool _sending = false;
  String? _error;
  ContributionDraft get d => widget.draft;
  Future<void> _send() async {
    if (_sending || !d.consent) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    widget.onBusy(true);
    try {
      await ContributionService.submit(d);
      if (mounted) widget.onSuccess();
    } catch (_) {
      if (mounted)
        setState(
          () => _error = d.savedReport != null
              ? 'Laporan sudah tersimpan, tetapi lampiran belum tercatat. Coba kirim lagi untuk menyelesaikannya.'
              : 'Dokumentasi belum berhasil dikirim. Periksa koneksi, login, dan konfigurasi Storage, lalu coba lagi.',
        );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
        widget.onBusy(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = _sending || d.savedReport != null || d.uploadedPath != null;
    return ContributionFormShell(
      step: 3,
      title: 'Tinjau dokumentasi',
      onBack: locked ? null : widget.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5EFED),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.folder_outlined,
                    color: Color(0xFF159A91),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${d.project?['project_code']} · ${d.project?['project_name']}',
                        style: const TextStyle(
                          color: navy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${d.category} · ${d.date == null ? '-' : MaterialLocalizations.of(context).formatMediumDate(d.date!)}',
                        style: const TextStyle(color: grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(d.location, style: const TextStyle(color: grey)),
          const SizedBox(height: 6),
          Text(d.description, style: const TextStyle(color: navy)),
          if (d.file != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'Lampiran: ${d.file!.name}',
                style: const TextStyle(color: blue),
              ),
            ),
          const SizedBox(height: 12),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: blue,
            value: d.consent,
            onChanged: locked
                ? null
                : (v) => setState(() => d.consent = v ?? false),
            title: const Text(
              'Saya menyetujui penggunaan dokumentasi untuk kepentingan informasi publik dan memahami proses moderasi.',
              style: TextStyle(color: grey, fontSize: 13),
            ),
          ),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),
          if (_sending)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: LinearProgressIndicator(),
            ),
          formActions([
            ContributionButton(
              label: 'Kembali',
              secondary: true,
              arrow: false,
              onPressed: locked ? null : widget.onBack,
            ),
            ContributionButton(
              label: _sending ? 'Mengirim...' : 'Kirim dokumentasi',
              onPressed: _sending || !d.consent ? null : _send,
            ),
          ]),
        ],
      ),
    );
  }
}

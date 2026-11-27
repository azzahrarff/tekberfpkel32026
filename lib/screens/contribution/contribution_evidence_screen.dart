import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'contribution_service.dart';
import 'contribution_widgets.dart';

class ContributionEvidenceScreen extends StatefulWidget {
  final ContributionDraft draft;
  final VoidCallback onNext, onBack;
  const ContributionEvidenceScreen({
    super.key,
    required this.draft,
    required this.onNext,
    required this.onBack,
  });
  @override
  State<ContributionEvidenceScreen> createState() =>
      _ContributionEvidenceScreenState();
}

class _ContributionEvidenceScreenState
    extends State<ContributionEvidenceScreen> {
  bool _picking = false;
  ContributionDraft get d => widget.draft;
  Future<void> _pick() async {
    setState(() => _picking = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4'],
        allowMultiple: false,
        withData: true,
      );
      if (!mounted || result == null) return;
      final file = result.files.single;
      final ext = file.extension?.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'mp4'].contains(ext) ||
          file.bytes == null ||
          file.size == 0 ||
          file.size > (ext == 'mp4' ? 50 : 10) * 1024 * 1024) {
        contributionMessage(
          context,
          'Berkas tidak valid atau melebihi batas ukuran.',
        );
        return;
      }
      setState(() => d.file = file);
    } catch (_) {
      if (mounted)
        contributionMessage(context, 'Gagal memilih berkas. Coba lagi.');
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) => ContributionFormShell(
    step: 2,
    title: 'Deskripsi dan bukti',
    onBack: _picking ? null : widget.onBack,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fieldLabel('Ceritakan kondisi yang kamu lihat'),
        TextFormField(
          initialValue: d.description,
          minLines: 5,
          maxLines: 7,
          decoration: contributionInput('Jelaskan kondisi proyek di lokasi...'),
          onChanged: (v) => d.description = v,
        ),
        const SizedBox(height: 10),
        const Text(
          'Jelaskan fakta yang terlihat tanpa membuat tuduhan.',
          style: TextStyle(color: grey, fontSize: 11),
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: _picking ? null : _pick,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFB3C6D9)),
            ),
            child: Column(
              children: [
                if (_picking)
                  const CircularProgressIndicator()
                else
                  const Icon(
                    Icons.photo_camera_outlined,
                    size: 32,
                    color: blue,
                  ),
                const SizedBox(height: 12),
                Text(
                  d.file == null ? 'Pilih foto atau video' : d.file!.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: blue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'JPG/PNG maksimal 10 MB · MP4 maksimal 50 MB',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: grey, fontSize: 11),
                ),
                if (d.file != null)
                  TextButton(
                    onPressed: _picking
                        ? null
                        : () => setState(() => d.file = null),
                    child: const Text('Hapus lampiran'),
                  ),
              ],
            ),
          ),
        ),
        formActions([
          ContributionButton(
            label: 'Kembali',
            onPressed: _picking ? null : widget.onBack,
            secondary: true,
            arrow: false,
          ),
          ContributionButton(
            label: 'Lanjut',
            onPressed: _picking
                ? null
                : () {
                    if (d.description.trim().isEmpty) {
                      contributionMessage(
                        context,
                        'Isi deskripsi terlebih dahulu.',
                      );
                      return;
                    }
                    widget.onNext();
                  },
          ),
        ]),
      ],
    ),
  );
}

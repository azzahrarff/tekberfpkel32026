import 'package:flutter/material.dart';

import 'contribution_widgets.dart';

class ContributionSuccessScreen extends StatelessWidget {
  final String referenceCode;
  final VoidCallback onProjects, onReports;
  const ContributionSuccessScreen({
    super.key,
    required this.referenceCode,
    required this.onProjects,
    required this.onReports,
  });
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 660),
          child: Column(
            children: [
              SizedBox(
                height: (constraints.maxHeight * .17)
                    .clamp(26.0, 150.0)
                    .toDouble(),
              ),
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F3EC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Color(0xFF218568),
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'DOKUMENTASI TERKIRIM',
                style: TextStyle(
                  color: grey,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Terima kasih atas kontribusimu',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: navy,
                  fontSize: 27,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Dokumentasi disimpan sebagai simulasi dengan nomor laporan berikut.',
                textAlign: TextAlign.center,
                style: TextStyle(color: grey),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SelectableText(
                  referenceCode,
                  style: const TextStyle(
                    color: blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  ContributionButton(
                    label: 'Kembali ke proyek',
                    secondary: true,
                    arrow: false,
                    onPressed: onProjects,
                  ),
                  ContributionButton(
                    label: 'Lihat laporan',
                    onPressed: onReports,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

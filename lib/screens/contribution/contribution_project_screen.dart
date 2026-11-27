import 'package:flutter/material.dart';

import 'contribution_service.dart';
import 'contribution_widgets.dart';

class ContributionProjectScreen extends StatefulWidget {
  final ContributionDraft draft;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const ContributionProjectScreen({
    super.key,
    required this.draft,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<ContributionProjectScreen> createState() =>
      _ContributionProjectScreenState();
}

class _ContributionProjectScreenState extends State<ContributionProjectScreen> {
  late Future<List<Map<String, dynamic>>> _projects;
  late TextEditingController _location;

  final _form = GlobalKey<FormState>();

  static const categories = [
    'Progres proyek',
    'Kondisi proyek',
    'Kendala proyek',
    'Lainnya',
  ];

  ContributionDraft get d => widget.draft;

  @override
  void initState() {
    super.initState();

    _projects = ContributionService.projects();

    _location = TextEditingController(text: d.location);
  }

  @override
  void dispose() {
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContributionFormShell(
      step: 1,
      title: 'Proyek dan lokasi',
      onBack: widget.onBack,
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pilihan proyek dari Supabase
            fieldLabel('Proyek'),

            FutureBuilder<List<Map<String, dynamic>>>(
              future: _projects,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Column(
                    children: [
                      const Text('Gagal memuat proyek.'),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _projects = ContributionService.projects();
                          });
                        },
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  );
                }

                final projects = snapshot.data ?? [];

                if (projects.isEmpty) {
                  return const Text('Belum ada proyek tersedia.');
                }

                final selectedId = d.project?['id'];

                final Object? current =
                    projects.any((p) => p['id'] == selectedId)
                    ? selectedId
                    : null;

                return DropdownButtonFormField<Object>(
                  initialValue: current,
                  isExpanded: true,
                  decoration: contributionInput('Pilih proyek'),
                  items: projects.map((p) {
                    return DropdownMenuItem<Object>(
                      value: p['id'] as Object,
                      child: Text(
                        '${p['project_code']} · '
                        '${p['project_name']}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Pilih proyek.';
                    }

                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      d.project = projects.firstWhere((p) => p['id'] == value);

                      d.location =
                          (d.project!['project_location'] ??
                                  d.project!['district'] ??
                                  '')
                              .toString();

                      _location.text = d.location;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            // Lokasi dokumentasi
            fieldLabel('Lokasi dokumentasi'),

            TextFormField(
              controller: _location,
              decoration: contributionInput('Masukkan lokasi'),
              onChanged: (value) {
                d.location = value;
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Lokasi wajib diisi.';
                }

                return null;
              },
            ),

            const SizedBox(height: 20),

            // Tanggal dokumentasi
            fieldLabel('Tanggal dokumentasi'),

            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: d.date ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );

                if (mounted && date != null) {
                  setState(() {
                    d.date = date;
                  });
                }
              },
              child: InputDecorator(
                decoration: contributionInput(
                  'Pilih tanggal',
                  suffix: const Icon(Icons.calendar_today_outlined, size: 18),
                ),
                child: Text(
                  d.date == null
                      ? 'Pilih tanggal'
                      : MaterialLocalizations.of(context)
                            .formatMediumDate(d.date!),
                  style: TextStyle(color: d.date == null ? grey : navy),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Kategori kontribusi
            fieldLabel('Kategori'),

            DropdownButtonFormField<String>(
              initialValue: d.category,
              isExpanded: true,
              decoration: contributionInput('Pilih kategori'),
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    d.category = value;
                  });
                }
              },
            ),

            // Tombol navigasi
            formActions([
              ContributionButton(
                label: 'Batal',
                onPressed: widget.onBack,
                secondary: true,
                arrow: false,
              ),

              ContributionButton(
                label: 'Lanjut',
                onPressed: () {
                  if (!_form.currentState!.validate()) {
                    return;
                  }

                  if (d.project == null || d.date == null) {
                    contributionMessage(
                      context,
                      'Pilih proyek dan tanggal dokumentasi.',
                    );

                    return;
                  }

                  widget.onNext();
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

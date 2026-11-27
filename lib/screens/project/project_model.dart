import 'package:flutter/material.dart';

// DAFTAR STATUS YANG DITAMPILKAN DI UI
class ProjectStatus {
  static const String procurement = 'Dalam proses pengadaan';
  static const String ongoing = 'Dalam pengerjaan';
  static const String done = 'Selesai';
  static const String unknown = 'Belum tersedia';

  static const List<String> all = [ongoing, procurement, done];

  // Menyamakan nilai status dari database ke label UI.
  static String normalize(String? raw) {
    final s = (raw ?? '').toLowerCase();
    if (s.contains('selesai') || s.contains('complete') || s.contains('done')) {
      return done;
    }
    if (s.contains('pengadaan') || s.contains('procure') || s.contains('tender')) {
      return procurement;
    }
    if (s.contains('kerja') || s.contains('progress') || s.contains('ongoing')) {
      return ongoing;
    }
    return unknown;
  }

  static Color color(String status) {
    switch (status) {
      case ongoing:
        return const Color(0xFF18A394);
      case procurement:
        return const Color(0xFF2861A0);
      case done:
        return const Color(0xFF218A5D);
      default:
        return const Color(0xFF8190A5);
    }
  }
}

// FILTER PROYEK (dikirim antara ProjectScreen <-> ProjectFilterScreen)
class ProjectFilter {
  final int year;
  final String? district;
  final int? categoryId;
  final String? categoryName;
  final String? status;
  final double? maxBudget;

  const ProjectFilter({
    this.year = 2026,
    this.district,
    this.categoryId,
    this.categoryName,
    this.status,
    this.maxBudget,
  });

  // Jumlah filter aktif (tahun tidak dihitung karena selalu ada).
  int get activeCount => [district, categoryId, status, maxBudget]
      .where((e) => e != null)
      .length;

  // Menghapus satu filter (dipakai tombol x pada chip).
  ProjectFilter clear({
    bool district = false,
    bool category = false,
    bool status = false,
    bool budget = false,
  }) {
    return ProjectFilter(
      year: year,
      district: district ? null : this.district,
      categoryId: category ? null : categoryId,
      categoryName: category ? null : categoryName,
      status: status ? null : this.status,
      maxBudget: budget ? null : maxBudget,
    );
  }

  ProjectFilter reset() => ProjectFilter(year: year);
}

class Project {
  final int id;
  final String code;
  final String name;
  final String? district;
  final String? location;
  final double? latitude;
  final double? longitude;
  final int fiscalYear;
  final int? categoryId;
  final String? categoryName;
  final String status;
  final double? budget;
  final double? progress;
  final DateTime? updatedAt;
  final String? imageUrl;

  const Project({
    required this.id,
    required this.code,
    required this.name,
    required this.fiscalYear,
    required this.status,
    this.district,
    this.location,
    this.latitude,
    this.longitude,
    this.categoryId,
    this.categoryName,
    this.budget,
    this.progress,
    this.updatedAt,
    this.imageUrl,
  });

  bool get hasLocation => latitude != null && longitude != null;

  static double? _num(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  factory Project.fromMap(
    Map<String, dynamic> m,
    Map<int, String> categories,
  ) {
    final categoryId = m['category_id'] as int?;
    final status = ProjectStatus.normalize(m['project_status']?.toString());
    final progress = _num(m['physical_progress']);

    return Project(
      id: m['id'] as int,
      code: m['project_code']?.toString() ?? '',
      name: m['project_name']?.toString() ?? '-',
      fiscalYear: m['fiscal_year'] as int,
      district: m['district']?.toString(),
      location: m['project_location']?.toString(),
      latitude: _num(m['latitude']),
      longitude: _num(m['longitude']),
      categoryId: categoryId,
      categoryName: categoryId == null ? null : categories[categoryId],
      status: status,
      budget: _num(m['budget_ceiling']),
      // Proyek yang masih pengadaan belum punya progres fisik (sesuai UI).
      progress: (status == ProjectStatus.procurement && (progress ?? 0) == 0)
          ? null
          : progress,
      updatedAt: DateTime.tryParse(m['last_updated']?.toString() ?? '')
          ?.toLocal(),
      imageUrl: m['image_url']?.toString(),
    );
  }
}

// FORMAT NOMINAL: Rp2 miliar, Rp1,5 miliar, Rp850 juta
String formatRupiah(double n) {
  String trim(double v) {
    var s = v.toStringAsFixed(2);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return s.replaceAll('.', ',');
  }

  if (n.abs() >= 1e12) return 'Rp${trim(n / 1e12)} triliun';
  if (n.abs() >= 1e9) return 'Rp${trim(n / 1e9)} miliar';
  if (n.abs() >= 1e6) return 'Rp${trim(n / 1e6)} juta';
  return 'Rp${n.toStringAsFixed(0)}';
}

// FORMAT TANGGAL: 31 Oktober 2026
String formatDate(DateTime d) {
  const months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}
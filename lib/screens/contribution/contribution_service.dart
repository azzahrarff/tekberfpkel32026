import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/supabase_service.dart';

class ContributionDraft {
  Map<String, dynamic>? project;
  String location = '';
  DateTime? date;
  String category = 'Progres proyek';
  String description = '';
  PlatformFile? file;
  bool consent = false;
  Map<String, dynamic>? savedReport;
  String? uploadedPath;
  bool mediaSaved = false;
}

class ContributionService {
  static const bucket = 'contribution-evidence';
  static final _random = Random.secure();
  static SupabaseClient get _db => SupabaseService.client;

  static Future<List<Map<String, dynamic>>> projects() async => await _db
      .from('projects')
      .select('id,project_code,project_name,project_location,district')
      .order('project_name');

  static Future<int> profileId() async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) throw StateError('Silakan login terlebih dahulu.');
    final row = await _db
        .from('profiles')
        .select('id')
        .eq('auth_user_id', uid)
        .maybeSingle();
    if (row == null)
      throw StateError('Profil belum tersedia. Hubungi pengelola aplikasi.');
    return (row['id'] as num).toInt();
  }

  static Future<List<Map<String, dynamic>>> reports() async {
    final id = await profileId();
    return await _db
        .from('contributions')
        .select(
          'id,reference_code,title,description,contribution_status,documented_at,projects(project_name)',
        )
        .eq('profile_id', id)
        .order('submitted_at', ascending: false);
  }

  static String sqlDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static Future<Map<String, dynamic>> submit(ContributionDraft d) async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) throw StateError('Silakan login terlebih dahulu.');
    if (d.project == null ||
        d.location.trim().isEmpty ||
        d.date == null ||
        d.description.trim().isEmpty ||
        !d.consent) {
      throw StateError(
        'Lengkapi formulir dan berikan persetujuan terlebih dahulu.',
      );
    }
    final id = await profileId();
    // Simpan lampiran terlebih dahulu agar laporan tidak dibuat jika upload gagal.
    final file = d.file;
    if (file != null && d.uploadedPath == null) {
      final ext = file.extension?.toLowerCase();
      final mime = switch (ext) {
        'jpg' || 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        'mp4' => 'video/mp4',
        _ => throw StateError('Format berkas tidak didukung.'),
      };
      final bytes = file.bytes;
      if (bytes == null ||
          bytes.isEmpty ||
          bytes.length > (ext == 'mp4' ? 50 : 10) * 1024 * 1024)
        throw StateError('Ukuran atau isi berkas tidak valid.');
      final path =
          '$uid/${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(1 << 30)}.$ext';
      await _db.storage
          .from(bucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: mime),
          );
      d.uploadedPath = path;
    }
    if (d.savedReport == null) {
      try {
        d.savedReport = await _db
            .from('contributions')
            .insert({
              'profile_id': id,
              'project_id': d.project!['id'],
              'contribution_type': d.category,
              'title': d.category,
              'description': d.description.trim(),
              'documented_location': d.location.trim(),
              'documented_at': sqlDate(d.date!),
              'personal_observation_consent': d.consent,
            })
            .select('id,reference_code,contribution_status')
            .single();
      } catch (_) {
        // Bersihkan upload yang belum terhubung dengan laporan bila memungkinkan.
        if (d.uploadedPath != null) {
          try {
            await _db.storage.from(bucket).remove([d.uploadedPath!]);
            d.uploadedPath = null;
          } catch (_) {
            /* retry memakai path yang sama */
          }
        }
        rethrow;
      }
    }
    if (file != null && !d.mediaSaved) {
      final reportId = d.savedReport!['id'];
      final existing = await _db
          .from('contribution_media')
          .select('id')
          .eq('contribution_id', reportId)
          .eq('file_url', d.uploadedPath!)
          .maybeSingle();
      if (existing == null) {
        await _db.from('contribution_media').insert({
          'contribution_id': reportId,
          'file_name': file.name.length > 255
              ? file.name.substring(0, 255)
              : file.name,
          'file_url': d.uploadedPath,
          'file_type': file.extension?.toLowerCase() == 'mp4'
              ? 'video'
              : 'foto',
        });
      }
      d.mediaSaved = true;
    }
    return d.savedReport!;
  }
}

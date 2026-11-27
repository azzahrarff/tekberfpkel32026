import '../../core/services/supabase_service.dart';

class ProjectReviewData {
  final Map<String, dynamic> project;
  final List<Map<String, dynamic>> timeline;
  final List<Map<String, dynamic>> procurement;
  const ProjectReviewData(this.project, this.timeline, this.procurement);
}

class ProjectReviewService {
  static final db = SupabaseService.client;

  static Future<List<Map<String, dynamic>>> projects() async {
    return await db.from('projects').select('id,project_code,project_name,project_location,project_status,physical_progress').order('project_name');
  }

  static Future<ProjectReviewData> load(int id) async {
    final p = await db.from('projects').select('*,regions(region_name),budget_categories(category_name)').eq('id', id).single();
    final t = await db.from('project_timelines').select().eq('project_id', id).order('start_date').order('id');
    final procurement = await db.from('procurements').select().eq('project_id', id).order('id');
    return ProjectReviewData(p, t, procurement);
  }

  static Future<int?> profileId() async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) return null;
    final profile = await db.from('profiles').select('id').eq('auth_user_id', uid).maybeSingle();
    return profile == null ? null : (profile['id'] as num).toInt();
  }

  static Future<bool> isSaved(int id) async {
    final profile = await profileId();
    if (profile == null) return false;
    final saved = await db.from('saved_projects').select('id').eq('profile_id', profile).eq('project_id', id).maybeSingle();
    return saved != null;
  }

  static Future<bool> toggleSaved(int id) async {
    final profile = await profileId();
    if (profile == null) throw StateError('Login dan profil diperlukan.');
    final saved = await db.from('saved_projects').select('id').eq('profile_id', profile).eq('project_id', id).maybeSingle();
    if (saved == null) {
      await db.from('saved_projects').insert({'profile_id': profile, 'project_id': id});
      return true;
    }
    await db.from('saved_projects').delete().eq('profile_id', profile).eq('project_id', id);
    return false;
  }

  static Future<List<Map<String, dynamic>>> glossary() async =>
      await db.from('glossary_terms').select('term_name,definition').order('term_name');
}

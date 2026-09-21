import '../models/issue.dart';
import '../supabase_config.dart';

class IssueService {
  // Get all issues
  Future<List<Issue>> getAllIssues() async {
    final data = await supabase
        .from('issues')
        .select()
        .order('created_at', ascending: false);

    return (data as List).map((json) => Issue.fromJson(json)).toList();
  }

  // Get single issue
  Future<Issue> getIssueById(String id) async {
    final data = await supabase
        .from('issues')
        .select()
        .eq('id', id)
        .single();

    return Issue.fromJson(data);
  }

  // Get issues by category
  Future<List<Issue>> getIssuesByCategory(String category) async {
    final data = await supabase
        .from('issues')
        .select()
        .eq('category', category)
        .order('created_at', ascending: false);

    return (data as List).map((json) => Issue.fromJson(json)).toList();
  }

  // Get issues by status
  Future<List<Issue>> getIssuesByStatus(String status) async {
    final data = await supabase
        .from('issues')
        .select()
        .eq('status', status)
        .order('created_at', ascending: false);

    return (data as List).map((json) => Issue.fromJson(json)).toList();
  }

  // Get issues by user
  Future<List<Issue>> getIssuesByUser(String userId) async {
    final data = await supabase
        .from('issues')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List).map((json) => Issue.fromJson(json)).toList();
  }

  // Create issue
  Future<Issue> createIssue({
    required String category,
    required String title,
    String? description,
    String? photoUrl,
    required double lat,
    required double lng,
    String? suburb,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not logged in');

    final data = await supabase.from('issues').insert({
      'user_id': userId,
      'category': category,
      'title': title,
      'description': description,
      'photo_url': photoUrl,
      'lat': lat,
      'lng': lng,
      'suburb': suburb,
      'status': 'open',
    }).select().single();

    return Issue.fromJson(data);
  }

  // Update issue status
  Future<void> updateStatus(String issueId, String status) async {
    await supabase
        .from('issues')
        .update({'status': status})
        .eq('id', issueId);
  }

  // Real-time stream of all issues
  Stream<List<Issue>> streamIssues() {
    return supabase
        .from('issues')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => Issue.fromJson(json)).toList());
  }
}

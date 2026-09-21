import '../models/comment.dart';
import '../supabase_config.dart';

class CommentService {
  // Get comments for an issue
  Future<List<Comment>> getComments(String issueId) async {
    final data = await supabase
        .from('comments')
        .select('*, profiles(full_name)')
        .eq('issue_id', issueId)
        .order('created_at', ascending: true);

    return (data as List).map((json) => Comment.fromJson(json)).toList();
  }

  // Add a comment
  Future<Comment> addComment({
    required String issueId,
    required String body,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not logged in');

    final data = await supabase.from('comments').insert({
      'issue_id': issueId,
      'user_id': userId,
      'body': body,
    }).select('*, profiles(full_name)').single();

    return Comment.fromJson(data);
  }

  // Delete a comment
  Future<void> deleteComment(String commentId) async {
    await supabase
        .from('comments')
        .delete()
        .eq('id', commentId);
  }

  // Stream comments for real-time updates
  Stream<List<Comment>> streamComments(String issueId) {
    return supabase
        .from('comments')
        .stream(primaryKey: ['id'])
        .eq('issue_id', issueId)
        .order('created_at', ascending: true)
        .map((data) => data.map((json) => Comment.fromJson(json)).toList());
  }
}

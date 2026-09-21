import '../supabase_config.dart';

class VoteService {
  final String? _userId = supabase.auth.currentUser?.id;

  // Check if current user has voted on an issue
  Future<bool> hasVoted(String issueId) async {
    if (_userId == null) return false;

    final data = await supabase
        .from('votes')
        .select()
        .eq('issue_id', issueId)
        .eq('user_id', _userId!)
        .maybeSingle();

    return data != null;
  }

  // Upvote an issue
  Future<void> upvote(String issueId) async {
    if (_userId == null) throw Exception('Not logged in');

    await supabase.from('votes').insert({
      'issue_id': issueId,
      'user_id': _userId,
    });
  }

  // Remove vote
  Future<void> removeVote(String issueId) async {
    if (_userId == null) throw Exception('Not logged in');

    await supabase
        .from('votes')
        .delete()
        .eq('issue_id', issueId)
        .eq('user_id', _userId!);
  }

  // Toggle vote — upvote if not voted, remove if already voted
  Future<bool> toggleVote(String issueId) async {
    final voted = await hasVoted(issueId);
    if (voted) {
      await removeVote(issueId);
      return false;
    } else {
      await upvote(issueId);
      return true;
    }
  }

  // Get all issue IDs the current user has voted on
  Future<List<String>> getUserVotedIssueIds() async {
    if (_userId == null) return [];

    final data = await supabase
        .from('votes')
        .select('issue_id')
        .eq('user_id', _userId!);

    return (data as List)
        .map((row) => row['issue_id'] as String)
        .toList();
  }
}

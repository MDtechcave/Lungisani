import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/issue.dart';
import '../services/issue_service.dart';
import '../services/vote_service.dart';

final issueServiceProvider = Provider<IssueService>((ref) => IssueService());
final voteServiceProvider = Provider<VoteService>((ref) => VoteService());

// Stream all issues in real-time
final issuesStreamProvider = StreamProvider<List<Issue>>((ref) {
  final issueService = ref.watch(issueServiceProvider);
  return issueService.streamIssues();
});

// Selected category filter
final categoryFilterProvider = StateProvider<String?>((ref) => null);

// Selected status filter
final statusFilterProvider = StateProvider<String?>((ref) => null);

// Filtered issues based on category and status
final filteredIssuesProvider = Provider<AsyncValue<List<Issue>>>((ref) {
  final issuesAsync = ref.watch(issuesStreamProvider);
  final categoryFilter = ref.watch(categoryFilterProvider);
  final statusFilter = ref.watch(statusFilterProvider);

  return issuesAsync.when(
    data: (issues) {
      var filtered = issues;

      if (categoryFilter != null) {
        filtered = filtered
            .where((i) => i.category == categoryFilter)
            .toList();
      }

      if (statusFilter != null) {
        filtered = filtered
            .where((i) => i.status == statusFilter)
            .toList();
      }

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

// Single issue by ID
final issueByIdProvider =
    FutureProvider.family<Issue, String>((ref, id) async {
  final issueService = ref.watch(issueServiceProvider);
  return issueService.getIssueById(id);
});

// Issues by current user
final userIssuesProvider =
    FutureProvider.family<List<Issue>, String>((ref, userId) async {
  final issueService = ref.watch(issueServiceProvider);
  return issueService.getIssuesByUser(userId);
});

// Voted issue IDs for current user
final userVotedIssueIdsProvider = FutureProvider<List<String>>((ref) async {
  final voteService = ref.watch(voteServiceProvider);
  return voteService.getUserVotedIssueIds();
});

// Issue creation notifier
class IssueNotifier extends StateNotifier<AsyncValue<void>> {
  final IssueService _issueService;

  IssueNotifier(this._issueService) : super(const AsyncValue.data(null));

  Future<Issue?> createIssue({
    required String category,
    required String title,
    String? description,
    String? photoUrl,
    required double lat,
    required double lng,
    String? suburb,
  }) async {
    state = const AsyncValue.loading();
    Issue? created;
    state = await AsyncValue.guard(() async {
      created = await _issueService.createIssue(
        category: category,
        title: title,
        description: description,
        photoUrl: photoUrl,
        lat: lat,
        lng: lng,
        suburb: suburb,
      );
    });
    return created;
  }
}

final issueNotifierProvider =
    StateNotifierProvider<IssueNotifier, AsyncValue<void>>((ref) {
  final issueService = ref.watch(issueServiceProvider);
  return IssueNotifier(issueService);
});

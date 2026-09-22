import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/issue.dart';
import '../services/issue_service.dart';
import '../services/vote_service.dart';

final issueServiceProvider = Provider<IssueService>((ref) => IssueService());
final voteServiceProvider = Provider<VoteService>((ref) => VoteService());

final issuesStreamProvider = StreamProvider<List<Issue>>((ref) {
  final issueService = ref.watch(issueServiceProvider);
  return issueService.streamIssues();
});

// Category filter
class CategoryFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? value) => state = value;
  void clear() => state = null;
}

final categoryFilterProvider =
    NotifierProvider<CategoryFilterNotifier, String?>(
        CategoryFilterNotifier.new);

// Status filter
class StatusFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? value) => state = value;
  void clear() => state = null;
}

final statusFilterProvider =
    NotifierProvider<StatusFilterNotifier, String?>(StatusFilterNotifier.new);

// Filtered issues
final filteredIssuesProvider = Provider<AsyncValue<List<Issue>>>((ref) {
  final issuesAsync = ref.watch(issuesStreamProvider);
  final categoryFilter = ref.watch(categoryFilterProvider);
  final statusFilter = ref.watch(statusFilterProvider);

  return issuesAsync.when(
    data: (issues) {
      var filtered = issues;
      if (categoryFilter != null) {
        filtered =
            filtered.where((i) => i.category == categoryFilter).toList();
      }
      if (statusFilter != null) {
        filtered = filtered.where((i) => i.status == statusFilter).toList();
      }
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

final issueByIdProvider =
    FutureProvider.family<Issue, String>((ref, id) async {
  final issueService = ref.watch(issueServiceProvider);
  return issueService.getIssueById(id);
});

final userIssuesProvider =
    FutureProvider.family<List<Issue>, String>((ref, userId) async {
  final issueService = ref.watch(issueServiceProvider);
  return issueService.getIssuesByUser(userId);
});

final userVotedIssueIdsProvider = FutureProvider<List<String>>((ref) async {
  final voteService = ref.watch(voteServiceProvider);
  return voteService.getUserVotedIssueIds();
});

// Issue creation notifier
class IssueNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

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
      created = await ref.read(issueServiceProvider).createIssue(
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
    NotifierProvider<IssueNotifier, AsyncValue<void>>(IssueNotifier.new);

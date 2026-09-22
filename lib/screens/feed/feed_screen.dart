import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/issue.dart';
import '../../providers/issues_provider.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'escalated':
        return const Color(0xFFF97316);
      case 'in_progress':
        return const Color(0xFF8B5CF6);
      case 'resolved':
        return const Color(0xFF06D6A0);
      default:
        return const Color(0xFF118AB2);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredIssuesProvider);
    final categoryFilter = ref.watch(categoryFilterProvider);
    final statusFilter = ref.watch(statusFilterProvider);

    final categories = [
      {'value': null, 'label': 'All'},
      {'value': 'road_hazard', 'label': '🕳️ Road'},
      {'value': 'sewage_emergency', 'label': '💧 Sewage'},
      {'value': 'traffic_light_out', 'label': '🚦 Robots'},
      {'value': 'water_crisis', 'label': '🚰 Water'},
      {'value': 'light_outage', 'label': '💡 Lights'},
      {'value': 'waste_buildup', 'label': '🗑️ Waste'},
    ];

    final statuses = [
      {'value': null, 'label': 'All'},
      {'value': 'open', 'label': 'Open'},
      {'value': 'escalated', 'label': 'Escalated'},
      {'value': 'in_progress', 'label': 'In Progress'},
      {'value': 'resolved', 'label': 'Resolved'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Community Reports'),
        actions: [
          if (categoryFilter != null || statusFilter != null)
            TextButton(
              onPressed: () {
                ref.read(categoryFilterProvider.notifier).clear();
                ref.read(statusFilterProvider.notifier).clear();
              },
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Category filters
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = categoryFilter == cat['value'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => ref
                        .read(categoryFilterProvider.notifier)
                        .set(cat['value'] as String?),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1B4332)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1B4332)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        cat['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF374151),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Status filters
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: statuses.length,
              itemBuilder: (context, index) {
                final stat = statuses[index];
                final isSelected = statusFilter == stat['value'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => ref
                        .read(statusFilterProvider.notifier)
                        .set(stat['value'] as String?),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFD62828)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFD62828)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        stat['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF374151),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Issues list
          Expanded(
            child: filteredAsync.when(
              data: (issues) {
                if (issues.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('📭', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 16),
                        Text(
                          'No reports found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.refresh(issuesStreamProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: issues.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final issue = issues[index];
                      return GestureDetector(
                        onTap: () => context.push('/issue/${issue.id}'),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Color(Issue.categoryColor(
                                                issue.category))
                                            .withOpacity(0.12),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${Issue.categoryEmoji(issue.category)} ${Issue.categoryLabel(issue.category)}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(Issue.categoryColor(
                                              issue.category)),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _statusColor(issue.status)
                                            .withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        issue.status,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color:
                                              _statusColor(issue.status),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  issue.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                                if (issue.suburb != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    issue.suburb!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.thumb_up_outlined,
                                      size: 14,
                                      color: Color(0xFF6B7280),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${issue.voteCount}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      timeago.format(issue.createdAt),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF1B4332),
                ),
              ),
              error: (e, _) => Center(
                child: Text('Error: $e'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/issue.dart';
import '../../models/comment.dart';
import '../../providers/issues_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/vote_service.dart';
import '../../services/comment_service.dart';

class IssueDetailScreen extends ConsumerStatefulWidget {
  final String issueId;
  const IssueDetailScreen({super.key, required this.issueId});

  @override
  ConsumerState<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends ConsumerState<IssueDetailScreen> {
  final _commentController = TextEditingController();
  final _voteService = VoteService();
  final _commentService = CommentService();
  bool _hasVoted = false;
  bool _isVoting = false;
  bool _isCommenting = false;
  List<Comment> _comments = [];
  bool _loadingComments = true;

  @override
  void initState() {
    super.initState();
    _checkVote();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _checkVote() async {
    final voted = await _voteService.hasVoted(widget.issueId);
    if (mounted) setState(() => _hasVoted = voted);
  }

  Future<void> _loadComments() async {
    try {
      final comments = await _commentService.getComments(widget.issueId);
      if (mounted) setState(() {
        _comments = comments;
        _loadingComments = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loadingComments = false);
    }
  }

  Future<void> _toggleVote() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to vote')),
      );
      return;
    }
    setState(() => _isVoting = true);
    try {
      final voted = await _voteService.toggleVote(widget.issueId);
      if (mounted) setState(() => _hasVoted = voted);
      ref.refresh(issueByIdProvider(widget.issueId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isVoting = false);
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;
    setState(() => _isCommenting = true);
    try {
      final comment = await _commentService.addComment(
        issueId: widget.issueId,
        body: _commentController.text.trim(),
      );
      if (mounted) {
        setState(() => _comments.add(comment));
        _commentController.clear();
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCommenting = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'escalated': return const Color(0xFFF97316);
      case 'in_progress': return const Color(0xFF8B5CF6);
      case 'resolved': return const Color(0xFF06D6A0);
      default: return const Color(0xFF118AB2);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'in_progress': return 'In Progress';
      case 'escalated': return 'Escalated';
      case 'resolved': return 'Resolved';
      default: return 'Open';
    }
  }

  Widget _buildStatusTimeline(String status) {
    final steps = ['open', 'escalated', 'in_progress', 'resolved'];
    final labels = ['Open', 'Escalated', 'In Progress', 'Resolved'];
    final currentIndex = steps.indexOf(status);

    return Row(
      children: List.generate(steps.length, (i) {
        final isActive = i <= currentIndex;
        final isLast = i == steps.length - 1;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF1B4332)
                            : const Color(0xFFE5E7EB),
                        shape: BoxShape.circle,
                      ),
                      child: isActive
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: isActive
                            ? const Color(0xFF1B4332)
                            : const Color(0xFF9CA3AF),
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 20),
                    color: i < currentIndex
                        ? const Color(0xFF1B4332)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final issueAsync = ref.watch(issueByIdProvider(widget.issueId));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Report Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: issueAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF1B4332)),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (issue) => Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (issue.photoUrl != null)
                      Image.network(
                        issue.photoUrl!,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 220,
                          color: const Color(0xFFE5E7EB),
                          child: const Icon(Icons.image_not_supported,
                              size: 48, color: Color(0xFF9CA3AF)),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Color(Issue.categoryColor(
                                          issue.category))
                                      .withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${Issue.categoryEmoji(issue.category)} ${Issue.categoryLabel(issue.category)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(Issue.categoryColor(
                                        issue.category)),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor(issue.status)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _statusLabel(issue.status),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _statusColor(issue.status),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            issue.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              if (issue.suburb != null) ...[
                                const Icon(Icons.location_on_outlined,
                                    size: 14, color: Color(0xFF6B7280)),
                                const SizedBox(width: 3),
                                Text(
                                  issue.suburb!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                timeago.format(issue.createdAt),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildStatusTimeline(issue.status),
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 16),
                          if (issue.description != null) ...[
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              issue.description!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 16),
                          ],
                          Text(
                            'Comments (${_comments.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_loadingComments)
                            const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF1B4332),
                              ),
                            )
                          else if (_comments.isEmpty)
                            const Text(
                              'No comments yet. Be the first to comment.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9CA3AF),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _comments.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final comment = _comments[index];
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: const Color(0xFFE5E7EB)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 14,
                                            backgroundColor:
                                                const Color(0xFF1B4332),
                                            child: Text(
                                              comment.userFullName != null
                                                  ? comment.userFullName![0]
                                                      .toUpperCase()
                                                  : '?',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            comment.userFullName ??
                                                'Anonymous',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF374151),
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            timeago.format(comment.createdAt),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF9CA3AF),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        comment.body,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF374151),
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _isVoting ? null : _toggleVote,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: _hasVoted
                            ? const Color(0xFF1B4332)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF1B4332)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _hasVoted
                                ? Icons.thumb_up
                                : Icons.thumb_up_outlined,
                            size: 18,
                            color: _hasVoted
                                ? Colors.white
                                : const Color(0xFF1B4332),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${issue.voteCount}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _hasVoted
                                  ? Colors.white
                                  : const Color(0xFF1B4332),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9CA3AF),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                      ),
                      onSubmitted: (_) => _addComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isCommenting ? null : _addComment,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B4332),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _isCommenting
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send,
                              size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

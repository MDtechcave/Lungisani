class Comment {
  final String id;
  final String issueId;
  final String userId;
  final String body;
  final DateTime createdAt;
  final String? userFullName;

  Comment({
    required this.id,
    required this.issueId,
    required this.userId,
    required this.body,
    required this.createdAt,
    this.userFullName,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      issueId: json['issue_id'],
      userId: json['user_id'],
      body: json['body'],
      createdAt: DateTime.parse(json['created_at']),
      userFullName: json['profiles'] != null
          ? json['profiles']['full_name']
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'issue_id': issueId,
      'user_id': userId,
      'body': body,
    };
  }
}

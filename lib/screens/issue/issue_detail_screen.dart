import 'package:flutter/material.dart';

class IssueDetailScreen extends StatelessWidget {
  final String issueId;
  const IssueDetailScreen({super.key, required this.issueId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Issue $issueId')),
    );
  }
}
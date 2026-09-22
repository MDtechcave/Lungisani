import 'package:flutter/material.dart';
import '../../models/issue.dart';

class IssuePinWidget extends StatelessWidget {
  final String category;

  const IssuePinWidget({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final color = Color(Issue.categoryColor(category));
    final emoji = Issue.categoryEmoji(category);

    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

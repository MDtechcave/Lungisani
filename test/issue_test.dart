import 'package:flutter_test/flutter_test.dart';
import 'package:lungisani/models/issue.dart';

void main() {
  group('Issue model', () {
    final testJson = <String, dynamic>{
      'id': 'abc-123',
      'user_id': 'user-456',
      'category': 'road_hazard',
      'title': 'Big pothole on Main Road',
      'description': 'Dangerous pothole near the traffic light',
      'photo_url': null,
      'lat': -33.9249,
      'lng': 18.4241,
      'suburb': 'Cape Town',
      'status': 'open',
      'vote_count': 5,
      'created_at': '2024-01-15T08:00:00.000Z',
      'escalated_at': null,
      'resolved_at': null,
    };

    test('fromJson creates Issue correctly', () {
      final issue = Issue.fromJson(testJson);
      expect(issue.id, 'abc-123');
      expect(issue.category, 'road_hazard');
      expect(issue.status, 'open');
      expect(issue.voteCount, 5);
    });

    test('categoryLabel returns correct label', () {
      expect(Issue.categoryLabel('road_hazard'), 'Road Hazard');
      expect(Issue.categoryLabel('water_crisis'), 'Water Crisis');
      expect(Issue.categoryLabel('waste_buildup'), 'Waste Buildup');
    });

    test('categoryColor returns correct color', () {
      expect(Issue.categoryColor('road_hazard'), 0xFFE63946);
      expect(Issue.categoryColor('unknown'), 0xFF888888);
    });
  });
}

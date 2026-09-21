import 'package:flutter_test/flutter_test.dart';
import 'package:lungisani/models/comment.dart';
import 'package:lungisani/models/profile.dart';

void main() {
  group('Comment model', () {
    final testJson = <String, dynamic>{
      'id': 'comment-123',
      'issue_id': 'issue-456',
      'user_id': 'user-789',
      'body': 'This pothole has been here for months!',
      'created_at': '2024-01-15T08:00:00.000Z',
      'profiles': {'full_name': 'Mihle Dudumashe'},
    };

    test('fromJson creates Comment correctly', () {
      final comment = Comment.fromJson(testJson);
      expect(comment.id, 'comment-123');
      expect(comment.issueId, 'issue-456');
      expect(comment.body, 'This pothole has been here for months!');
      expect(comment.userFullName, 'Mihle Dudumashe');
    });

    test('handles missing profile gracefully', () {
      final json = Map<String, dynamic>.from(testJson);
      json['profiles'] = null;
      final comment = Comment.fromJson(json);
      expect(comment.userFullName, isNull);
    });

    test('toJson returns correct map', () {
      final comment = Comment.fromJson(testJson);
      final json = comment.toJson();
      expect(json['body'], 'This pothole has been here for months!');
      expect(json['issue_id'], 'issue-456');
    });
  });

  group('Profile model', () {
    final testJson = <String, dynamic>{
      'id': 'user-123',
      'full_name': 'Mihle Dudumashe',
      'ward': 'Ward 34',
      'suburb': 'Khayelitsha',
      'avatar_url': null,
      'created_at': '2024-01-15T08:00:00.000Z',
    };

    test('fromJson creates Profile correctly', () {
      final profile = Profile.fromJson(testJson);
      expect(profile.id, 'user-123');
      expect(profile.fullName, 'Mihle Dudumashe');
      expect(profile.suburb, 'Khayelitsha');
      expect(profile.avatarUrl, isNull);
    });

    test('initials returns correct letters', () {
      final profile = Profile.fromJson(testJson);
      expect(profile.initials, 'MD');
    });

    test('initials handles single name', () {
      final json = Map<String, dynamic>.from(testJson);
      json['full_name'] = 'Mihle';
      final profile = Profile.fromJson(json);
      expect(profile.initials, 'M');
    });

    test('initials handles null name', () {
      final json = Map<String, dynamic>.from(testJson);
      json['full_name'] = null;
      final profile = Profile.fromJson(json);
      expect(profile.initials, '?');
    });
  });
}

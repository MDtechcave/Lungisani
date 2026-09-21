import 'dart:io';
import 'package:uuid/uuid.dart';
import '../supabase_config.dart';

class StorageService {
  final _uuid = const Uuid();

  // Upload issue photo
  Future<String> uploadIssuePhoto(File file) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not logged in');

    final fileExt = file.path.split('.').last;
    final fileName = '${_uuid.v4()}.$fileExt';
    final filePath = '$userId/$fileName';

    await supabase.storage
        .from('issue-photos')
        .upload(filePath, file);

    final url = supabase.storage
        .from('issue-photos')
        .getPublicUrl(filePath);

    return url;
  }

  // Delete issue photo
  Future<void> deleteIssuePhoto(String photoUrl) async {
    final uri = Uri.parse(photoUrl);
    final pathSegments = uri.pathSegments;
    final filePath = pathSegments
        .skipWhile((s) => s != 'issue-photos')
        .skip(1)
        .join('/');

    await supabase.storage
        .from('issue-photos')
        .remove([filePath]);
  }
}

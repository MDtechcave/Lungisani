class Profile {
  final String id;
  final String? fullName;
  final String? ward;
  final String? suburb;
  final String? avatarUrl;
  final DateTime? createdAt;

  Profile({
    required this.id,
    this.fullName,
    this.ward,
    this.suburb,
    this.avatarUrl,
    this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      fullName: json['full_name'],
      ward: json['ward'],
      suburb: json['suburb'],
      avatarUrl: json['avatar_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'ward': ward,
      'suburb': suburb,
      'avatar_url': avatarUrl,
    };
  }

  String get initials {
    if (fullName == null || fullName!.isEmpty) return '?';
    final parts = fullName!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}

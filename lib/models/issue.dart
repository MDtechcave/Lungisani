class Issue {
  final String id;
  final String userId;
  final String category;
  final String title;
  final String? description;
  final String? photoUrl;
  final double lat;
  final double lng;
  final String? suburb;
  final String status;
  final int voteCount;
  final DateTime createdAt;
  final DateTime? escalatedAt;
  final DateTime? resolvedAt;

  Issue({
    required this.id,
    required this.userId,
    required this.category,
    required this.title,
    this.description,
    this.photoUrl,
    required this.lat,
    required this.lng,
    this.suburb,
    required this.status,
    required this.voteCount,
    required this.createdAt,
    this.escalatedAt,
    this.resolvedAt,
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      id: json['id'],
      userId: json['user_id'] ?? '',
      category: json['category'],
      title: json['title'],
      description: json['description'],
      photoUrl: json['photo_url'],
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      suburb: json['suburb'],
      status: json['status'],
      voteCount: json['vote_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      escalatedAt: json['escalated_at'] != null
          ? DateTime.parse(json['escalated_at'])
          : null,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'category': category,
      'title': title,
      'description': description,
      'photo_url': photoUrl,
      'lat': lat,
      'lng': lng,
      'suburb': suburb,
      'status': status,
    };
  }

  static String categoryLabel(String category) {
    const labels = {
      'road_hazard': 'Road Hazard',
      'sewage_emergency': 'Sewage Emergency',
      'traffic_light_out': 'Traffic Light Out',
      'water_crisis': 'Water Crisis',
      'light_outage': 'Light Outage',
      'waste_buildup': 'Waste Buildup',
    };
    return labels[category] ?? category;
  }

  static String categoryEmoji(String category) {
    const emojis = {
      'road_hazard': '🕳️',
      'sewage_emergency': '💧',
      'traffic_light_out': '🚦',
      'water_crisis': '🚰',
      'light_outage': '💡',
      'waste_buildup': '🗑️',
    };
    return emojis[category] ?? '⚠️';
  }

  static int categoryColor(String category) {
    const colors = {
      'road_hazard': 0xFFE63946,
      'sewage_emergency': 0xFF6B4226,
      'traffic_light_out': 0xFFF4A261,
      'water_crisis': 0xFF118AB2,
      'light_outage': 0xFFFFD166,
      'waste_buildup': 0xFF06D6A0,
    };
    return colors[category] ?? 0xFF888888;
  }
}

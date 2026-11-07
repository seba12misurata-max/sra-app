class MemoryItem {
  final int id;
  final String type; // fact / preference / goal / event
  final String content;
  final double importanceScore;
  final DateTime createdAt;

  MemoryItem({
    required this.id,
    required this.type,
    required this.content,
    required this.importanceScore,
    required this.createdAt,
  });

  factory MemoryItem.fromJson(Map<String, dynamic> json) {
    return MemoryItem(
      id: json['id'] as int,
      type: json['type'] as String,
      content: json['content'] as String,
      importanceScore: (json['importance_score'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static const Map<String, String> typeLabels = {
    'fact': 'حقيقة',
    'preference': 'تفضيل',
    'goal': 'هدف',
    'event': 'حدث',
  };

  String get typeLabel => typeLabels[type] ?? type;
}

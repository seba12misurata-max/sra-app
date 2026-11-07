class Conversation {
  final int id;
  final String title;
  final DateTime updatedAt;

  Conversation({required this.id, required this.title, required this.updatedAt});

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as int,
      title: (json['title'] as String?) ?? 'محادثة جديدة',
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

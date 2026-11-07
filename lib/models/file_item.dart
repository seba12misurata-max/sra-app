class FileItem {
  final int id;
  final String filename;
  final String fileType;
  final String category;
  final String? summary;
  final DateTime createdAt;

  FileItem({
    required this.id,
    required this.filename,
    required this.fileType,
    required this.category,
    required this.summary,
    required this.createdAt,
  });

  factory FileItem.fromJson(Map<String, dynamic> json) {
    return FileItem(
      id: json['id'] as int,
      filename: json['filename'] as String,
      fileType: (json['file_type'] as String?) ?? '',
      category: (json['category'] as String?) ?? 'note',
      summary: json['summary'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

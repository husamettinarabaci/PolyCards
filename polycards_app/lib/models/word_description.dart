class WordDescription {
  final String id;
  final String description;
  final String category;

  WordDescription({
    required this.id,
    required this.description,
    required this.category,
  });

  factory WordDescription.fromJson(Map<String, dynamic> json) {
    return WordDescription(
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'category': category,
    };
  }
}

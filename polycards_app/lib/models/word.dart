class Word {
  final String id;
  final String translation;
  final String example;
  final String? phonetic;

  Word({
    required this.id,
    required this.translation,
    required this.example,
    this.phonetic,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] ?? '',
      translation: json['translation'] ?? '',
      example: json['example'] ?? '',
      phonetic: json['phonetic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'translation': translation,
      'example': example,
      if (phonetic != null) 'phonetic': phonetic,
    };
  }
}

class Word {
  final String id;
  final String word;
  final String translation;
  final String example;
  final String category;
  final String? phonetic;

  Word({
    required this.id,
    required this.word,
    required this.translation,
    required this.example,
    required this.category,
    this.phonetic,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] ?? '',
      word: json['word'] ?? '',
      translation: json['translation'] ?? '',
      example: json['example'] ?? '',
      category: json['category'] ?? '',
      phonetic: json['phonetic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'translation': translation,
      'example': example,
      'category': category,
      if (phonetic != null) 'phonetic': phonetic,
    };
  }
}

import 'word.dart';

class LanguageData {
  final String languageName;
  final String languageCode;
  final List<Word> words;

  LanguageData({
    required this.languageName,
    required this.languageCode,
    required this.words,
  });

  factory LanguageData.fromJson(Map<String, dynamic> json) {
    return LanguageData(
      languageName: json['language_name'] ?? '',
      languageCode: json['language_code'] ?? '',
      words: (json['words'] as List<dynamic>?)
              ?.map((wordJson) => Word.fromJson(wordJson))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language_name': languageName,
      'language_code': languageCode,
      'words': words.map((word) => word.toJson()).toList(),
    };
  }
}

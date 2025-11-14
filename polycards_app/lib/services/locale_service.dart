import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/language_data.dart';

class LocaleService {
  static Map<String, String>? _descriptions;

  static Future<LanguageData> loadLanguage(String languageCode) async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/locales/$languageCode.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return LanguageData.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load language data for $languageCode: $e');
    }
  }

  static Future<Map<String, String>> loadWordDescriptions() async {
    // Return cached descriptions if already loaded
    if (_descriptions != null) {
      return _descriptions!;
    }

    try {
      final String jsonString =
          await rootBundle.loadString('assets/locales/word_descriptions.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      
      // Convert list to map for easy lookup by word ID
      final Map<String, String> descriptionsMap = {};
      for (final item in jsonData) {
        descriptionsMap[item['id']] = item['description'];
      }
      
      _descriptions = descriptionsMap;
      return descriptionsMap;
    } catch (e) {
      throw Exception('Failed to load word descriptions: $e');
    }
  }

  static String? getDescription(String wordId) {
    return _descriptions?[wordId];
  }

  static List<Map<String, String>> getAvailableLanguages() {
    return [
      {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
      {'code': 'tr', 'name': 'Türkçe', 'flag': '🇹🇷'},
      {'code': 'zh', 'name': '简体中文', 'flag': '🇨🇳'},
      {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
      {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
      {'code': 'ku', 'name': 'Kurdî', 'flag': '☀️'},
    ];
  }
}

import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/language_data.dart';

class LocaleService {
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

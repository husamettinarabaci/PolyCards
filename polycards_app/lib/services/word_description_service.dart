import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/word_description.dart';

class WordDescriptionService {
  static Map<String, WordDescription>? _descriptionsMap;

  /// Load word descriptions from the JSON file
  static Future<void> loadWordDescriptions() async {
    if (_descriptionsMap != null) {
      return; // Already loaded
    }

    try {
      final String jsonString =
          await rootBundle.loadString('assets/locales/word_descriptions.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      
      // Convert list to map for easy lookup by word ID
      final Map<String, WordDescription> tempMap = {};
      for (final item in jsonData) {
        final wordDesc = WordDescription.fromJson(item);
        tempMap[wordDesc.id] = wordDesc;
      }
      
      _descriptionsMap = tempMap;
    } catch (e) {
      throw Exception('Failed to load word descriptions: $e');
    }
  }

  /// Get description for a specific word ID
  static String? getDescription(String wordId) {
    return _descriptionsMap?[wordId]?.description;
  }

  /// Get category for a specific word ID
  static String? getCategory(String wordId) {
    return _descriptionsMap?[wordId]?.category;
  }

  /// Get full WordDescription object for a specific word ID
  static WordDescription? getWordDescription(String wordId) {
    return _descriptionsMap?[wordId];
  }

  /// Check if word descriptions are loaded
  static bool get isLoaded => _descriptionsMap != null;

  /// Get all word descriptions
  static Map<String, WordDescription>? get allDescriptions => _descriptionsMap;
}

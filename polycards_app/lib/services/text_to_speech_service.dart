import 'package:audioplayers/audioplayers.dart';

/// Service for text-to-speech functionality using Google Translate TTS API
class TextToSpeechService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  /// Get current playing state
  bool get isPlaying => _isPlaying;
  
  /// Check if a language is supported by Google TTS
  /// 
  /// Note: Google Translate TTS does NOT support Kurdish (Kurmanji/Sorani)
  bool isLanguageSupported(String languageCode) {
    switch (languageCode) {
      case 'ku':
        return false; // Kurdish is not supported by Google TTS
      default:
        return true;
    }
  }

  /// Convert language code to Google TTS format
  String _convertLanguageCode(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'en';
      case 'tr':
        return 'tr';
      case 'zh':
        return 'zh-CN';
      case 'ru':
        return 'ru';
      case 'ar':
        return 'ar';
      case 'ku':
        return 'ku'; // Will not work, but kept for consistency
      default:
        return 'en';
    }
  }

  /// Play text using Google Translate TTS
  /// 
  /// [text] - The text to speak
  /// [languageCode] - The language code (en, tr, zh, ru, ar, ku)
  /// Returns true if playback started successfully, false otherwise
  Future<bool> speak(String text, String languageCode) async {
    if (text.isEmpty) return false;
    
    // Check if language is supported
    if (!isLanguageSupported(languageCode)) {
      print('TTS: Language $languageCode is not supported by Google TTS');
      return false;
    }

    try {
      // Stop any currently playing audio
      await stop();

      // Convert language code
      final ttsLanguageCode = _convertLanguageCode(languageCode);

      // Build Google Translate TTS URL
      final encodedText = Uri.encodeComponent(text);
      final url =
          'https://translate.google.com/translate_tts?ie=UTF-8&tl=$ttsLanguageCode&client=tw-ob&q=$encodedText';

      print('TTS: Playing $languageCode ($ttsLanguageCode): "$text"');

      // Play audio
      _isPlaying = true;
      await _audioPlayer.play(UrlSource(url));

      // Listen for completion
      _audioPlayer.onPlayerComplete.listen((_) {
        _isPlaying = false;
        print('TTS: Playback completed');
      });
      
      return true;
    } catch (e) {
      _isPlaying = false;
      print('TTS Error for $languageCode: $e');
      return false;
    }
  }

  /// Stop currently playing audio
  Future<void> stop() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      _isPlaying = false;
    }
  }

  /// Dispose of resources
  void dispose() {
    _audioPlayer.dispose();
  }
}

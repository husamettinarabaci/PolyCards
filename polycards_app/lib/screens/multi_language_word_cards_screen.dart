import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/language_data.dart';
import '../models/word.dart';
import '../providers/settings_provider.dart';
import '../services/locale_service.dart';

class MultiLanguageWordCardsScreen extends StatefulWidget {
  const MultiLanguageWordCardsScreen({super.key});

  @override
  State<MultiLanguageWordCardsScreen> createState() =>
      _MultiLanguageWordCardsScreenState();
}

class _MultiLanguageWordCardsScreenState
    extends State<MultiLanguageWordCardsScreen> {
  Map<String, LanguageData> _languagesData = {};
  bool _isLoading = true;
  String? _errorMessage;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAllLanguagesData();
  }

  Future<void> _loadAllLanguagesData() async {
    try {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final activeLanguages = settingsProvider.settings.activeLanguages;

      final Map<String, LanguageData> loadedData = {};

      for (final langCode in activeLanguages) {
        try {
          final data = await LocaleService.loadLanguage(langCode);
          loadedData[langCode] = data;
        } catch (e) {
          print('Error loading language $langCode: $e');
        }
      }

      setState(() {
        _languagesData = loadedData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _nextCard() {
    final englishData = _languagesData['en'];
    if (englishData != null && _currentIndex < englishData.words.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Cards'),
        actions: [
          Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) {
              return IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () async {
                  // Navigate to settings and reload when coming back
                  final result = await Navigator.pushNamed(context, '/settings');
                  if (result == true) {
                    _loadAllLanguagesData();
                  }
                },
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading language data',
                          style: textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : _languagesData.isEmpty
                  ? Center(
                      child: Text(
                        'No languages loaded',
                        style: textTheme.titleLarge,
                      ),
                    )
                  : _buildMultiLanguageCard(textTheme, colorScheme),
    );
  }

  Widget _buildMultiLanguageCard(TextTheme textTheme, ColorScheme colorScheme) {
    final englishData = _languagesData['en'];
    if (englishData == null || _currentIndex >= englishData.words.length) {
      return Center(
        child: Text('No words available', style: textTheme.titleLarge),
      );
    }

    final englishWord = englishData.words[_currentIndex];
    final totalWords = englishData.words.length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Progress indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Word ${_currentIndex + 1} of $totalWords',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  englishWord.category.toUpperCase(),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentIndex + 1) / totalWords,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
          const SizedBox(height: 16),

          // Main card with scrollable content
          Expanded(
            child: Card(
              elevation: 4,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image
                    _buildWordImage(englishWord.id),
                    const SizedBox(height: 16),

                    // English word (main)
                    Center(
                      child: Text(
                        englishWord.word,
                        style: textTheme.displaySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    // English phonetic (if available)
                    if (englishWord.phonetic != null && englishWord.phonetic!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          englishWord.phonetic!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.secondary,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),

                    // English example
                    Center(
                      child: Text(
                        englishWord.example,
                        style: textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Divider(),
                    const SizedBox(height: 16),

                    // Other active languages
                    ..._buildLanguageSections(englishWord.id, textTheme, colorScheme),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _currentIndex > 0 ? _previousCard : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _currentIndex < totalWords - 1 ? _nextCard : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWordImage(String wordId) {
    final imagePath = 'assets/images/words/$wordId.png';
    
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 40,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Image not available',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildLanguageSections(
    String wordId,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    final sections = <Widget>[];
    final languages = LocaleService.getAvailableLanguages();

    for (final lang in languages) {
      final langCode = lang['code']!;
      
      // Skip English as it's already shown at the top
      if (langCode == 'en') continue;
      
      // Only show if language is active
      if (!_languagesData.containsKey(langCode)) continue;

      final languageData = _languagesData[langCode]!;
      if (_currentIndex >= languageData.words.length) continue;

      final word = languageData.words[_currentIndex];

      sections.add(_buildLanguageSection(
        lang['name']!,
        lang['flag']!,
        word,
        textTheme,
        colorScheme,
      ));
      sections.add(const SizedBox(height: 16));
    }

    return sections;
  }

  Widget _buildLanguageSection(
    String languageName,
    String flag,
    Word word,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                flag,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Text(
                languageName,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            word.word,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // Phonetic (if available)
          if (word.phonetic != null && word.phonetic!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              word.phonetic!,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.secondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            word.example,
            style: textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

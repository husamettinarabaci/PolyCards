import 'package:flutter/material.dart';
import '../models/language_data.dart';
import '../models/word.dart';
import '../services/locale_service.dart';
import '../services/word_description_service.dart';

class WordCardsScreen extends StatefulWidget {
  final String languageCode;
  final String languageName;

  const WordCardsScreen({
    super.key,
    required this.languageCode,
    required this.languageName,
  });

  @override
  State<WordCardsScreen> createState() => _WordCardsScreenState();
}

class _WordCardsScreenState extends State<WordCardsScreen> {
  LanguageData? _languageData;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentIndex = 0;
  bool _showTranslation = false;

  @override
  void initState() {
    super.initState();
    _loadLanguageData();
  }

  Future<void> _loadLanguageData() async {
    try {
      // Load word descriptions first
      await WordDescriptionService.loadWordDescriptions();
      
      final data = await LocaleService.loadLanguage(widget.languageCode);
      setState(() {
        _languageData = data;
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
    if (_languageData != null && _currentIndex < _languageData!.words.length - 1) {
      setState(() {
        _currentIndex++;
        _showTranslation = false;
      });
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _showTranslation = false;
      });
    }
  }

  void _toggleTranslation() {
    setState(() {
      _showTranslation = !_showTranslation;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.languageName} Words'),
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
              : _languageData == null || _languageData!.words.isEmpty
                  ? Center(
                      child: Text(
                        'No words available',
                        style: textTheme.titleLarge,
                      ),
                    )
                  : _buildWordCard(
                      _languageData!.words[_currentIndex],
                      textTheme,
                      colorScheme,
                    ),
    );
  }

  Widget _buildWordCard(Word word, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Progress indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Word ${_currentIndex + 1} of ${_languageData!.words.length}',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                'Category: ${WordDescriptionService.getCategory(word.id) ?? 'N/A'}',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _languageData!.words.length,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
          const SizedBox(height: 32),

          // Main card
          Expanded(
            child: GestureDetector(
              onTap: _toggleTranslation,
              child: Card(
                elevation: 4,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        word.id,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        word.translation,
                        style: textTheme.displayMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (_showTranslation) ...[
                        const Divider(),
                        const SizedBox(height: 16),
                        Text(
                          'Translation:',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          word.translation,
                          style: textTheme.headlineMedium?.copyWith(
                            color: colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Example:',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          word.example,
                          style: textTheme.bodyLarge?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ] else
                        Text(
                          'Tap to reveal translation',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilledButton.icon(
                onPressed: _currentIndex > 0 ? _previousCard : null,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
              ),
              OutlinedButton.icon(
                onPressed: _toggleTranslation,
                icon: Icon(_showTranslation ? Icons.visibility_off : Icons.visibility),
                label: Text(_showTranslation ? 'Hide' : 'Show'),
              ),
              FilledButton.icon(
                onPressed: _currentIndex < _languageData!.words.length - 1
                    ? _nextCard
                    : null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/locale_service.dart';
import 'word_cards_screen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final languages = LocaleService.getAvailableLanguages();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose a language to learn',
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select which language you want to practice',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final language = languages[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Text(
                        language['flag']!,
                        style: const TextStyle(fontSize: 40),
                      ),
                      title: Text(
                        language['name']!,
                        style: textTheme.titleLarge,
                      ),
                      subtitle: Text(
                        'Language code: ${language['code']}',
                        style: textTheme.bodySmall,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: colorScheme.primary,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WordCardsScreen(
                              languageCode: language['code']!,
                              languageName: language['name']!,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:polycards_app/config/theme.dart';
import 'package:polycards_app/providers/settings_provider.dart';
import 'package:polycards_app/screens/multi_language_word_cards_screen.dart';
import 'package:polycards_app/screens/settings_screen.dart';

void main() {
  runApp(const PolyCardsApp());
}

class PolyCardsApp extends StatelessWidget {
  const PolyCardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'PolyCards',
            debugShowCheckedModeBanner: false,
            
            // Use custom Material Design 3 theme with dynamic theme mode
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.settings.themeMode.toThemeMode(),
            
            home: const HomePage(),
            routes: {
              '/settings': (context) => const SettingsScreen(),
              '/cards': (context) => const MultiLanguageWordCardsScreen(),
            },
          );
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PolyCards',
          style: textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.language,
                size: 120,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to PolyCards',
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Learn 1000 words in multiple languages',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Consumer<SettingsProvider>(
                builder: (context, settingsProvider, child) {
                  final activeCount = settingsProvider.settings.activeLanguages.length;
                  return Text(
                    '$activeCount language${activeCount > 1 ? 's' : ''} active',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/cards');
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Get Started'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
                icon: const Icon(Icons.tune),
                label: const Text('Settings'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

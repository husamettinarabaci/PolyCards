import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';
import '../providers/settings_provider.dart';
import '../services/locale_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          if (settingsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Theme Section
              Text(
                'Appearance',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme Mode',
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      _buildThemeOption(
                        context,
                        settingsProvider,
                        AppThemeMode.light,
                        'Light',
                        Icons.light_mode,
                      ),
                      const SizedBox(height: 8),
                      _buildThemeOption(
                        context,
                        settingsProvider,
                        AppThemeMode.dark,
                        'Dark',
                        Icons.dark_mode,
                      ),
                      const SizedBox(height: 8),
                      _buildThemeOption(
                        context,
                        settingsProvider,
                        AppThemeMode.system,
                        'System',
                        Icons.brightness_auto,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Languages Section
              Text(
                'Active Languages',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select which languages to display on word cards',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: LocaleService.getAvailableLanguages()
                        .map((lang) => _buildLanguageToggle(
                              context,
                              settingsProvider,
                              lang,
                            ))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Note: English cannot be disabled and at least one language must be active.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    SettingsProvider settingsProvider,
    AppThemeMode themeMode,
    String label,
    IconData icon,
  ) {
    final isSelected = settingsProvider.settings.themeMode == themeMode;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => settingsProvider.setThemeMode(themeMode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 2,
          ),
          color: isSelected
              ? colorScheme.primaryContainer.withOpacity(0.3)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color:
                      isSelected ? colorScheme.primary : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageToggle(
    BuildContext context,
    SettingsProvider settingsProvider,
    Map<String, String> language,
  ) {
    final languageCode = language['code']!;
    final isActive = settingsProvider.isLanguageActive(languageCode);
    final isEnglish = languageCode == 'en';

    return SwitchListTile(
      secondary: Text(
        language['flag']!,
        style: const TextStyle(fontSize: 32),
      ),
      title: Text(language['name']!),
      subtitle: Text('Code: $languageCode'),
      value: isActive,
      onChanged: isEnglish
          ? null // English cannot be toggled
          : (value) => settingsProvider.toggleLanguage(languageCode),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';
import '../models/notification_settings.dart';
import '../providers/settings_provider.dart';
import '../services/locale_service.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
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
                      Text('Theme Mode', style: textTheme.titleMedium),
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

              // Notifications Section
              Text(
                'Daily Word Reminders',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Get notifications to learn new words throughout the day',
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              _buildNotificationSettings(context, settingsProvider),
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
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: LocaleService.getAvailableLanguages()
                        .map((lang) => _buildLanguageToggle(context, settingsProvider, lang))
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
          color: isSelected ? colorScheme.primaryContainer.withOpacity(0.3) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? colorScheme.primary : colorScheme.onSurface),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: colorScheme.primary),
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
      secondary: Text(language['flag']!, style: const TextStyle(fontSize: 32)),
      title: Text(language['name']!),
      subtitle: Text('Code: $languageCode'),
      value: isActive,
      onChanged: isEnglish
          ? null // English cannot be toggled
          : (value) => settingsProvider.toggleLanguage(languageCode),
    );
  }

  Widget _buildNotificationSettings(BuildContext context, SettingsProvider settingsProvider) {
    final notificationSettings = settingsProvider.settings.notificationSettings;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(
                Icons.notifications_active,
                color: notificationSettings.enabled
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              title: Text('Enable Reminders', style: textTheme.titleMedium),
              subtitle: const Text('Receive daily word learning notifications'),
              value: notificationSettings.enabled,
              onChanged: (value) async {
                if (value) {
                  // Request permission when enabling
                  final hasPermission = await settingsProvider.requestNotificationPermissions();
                  if (!hasPermission) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Notification permission denied. Please enable it in system settings.',
                          ),
                        ),
                      );
                    }
                    return;
                  }
                }

                settingsProvider.updateNotificationSettings(
                  notificationSettings.copyWith(enabled: value),
                );
              },
            ),
            if (notificationSettings.enabled) ...[
              const Divider(height: 32),
              Text('Words Per Day', style: textTheme.titleSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: notificationSettings.wordsPerDay.toDouble(),
                      min: 1,
                      max: 20,
                      divisions: 19,
                      label: '${notificationSettings.wordsPerDay} words',
                      onChanged: (value) {
                        settingsProvider.updateNotificationSettings(
                          notificationSettings.copyWith(wordsPerDay: value.toInt()),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${notificationSettings.wordsPerDay}',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Active Hours', style: textTheme.titleSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTimePicker(context, 'Start Time', notificationSettings.startTime, (
                      time,
                    ) {
                      settingsProvider.updateNotificationSettings(
                        notificationSettings.copyWith(startTime: time),
                      );
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimePicker(context, 'End Time', notificationSettings.endTime, (
                      time,
                    ) {
                      settingsProvider.updateNotificationSettings(
                        notificationSettings.copyWith(endTime: time),
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You will receive ${notificationSettings.wordsPerDay} notifications evenly distributed between ${notificationSettings.startTime.format(context)} and ${notificationSettings.endTime.format(context)}',
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await NotificationService().sendTestNotification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Test notification sent! Check your notification tray.'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Send Test Notification Now'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(
    BuildContext context,
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onChanged,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () async {
        final newTime = await showTimePicker(context: context, initialTime: time);
        if (newTime != null) {
          onChanged(newTime);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time.format(context),
                  style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
                ),
                Icon(Icons.access_time, size: 20, color: colorScheme.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

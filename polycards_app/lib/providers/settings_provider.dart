import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../models/notification_settings.dart';
import '../services/settings_service.dart';
import '../services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  final NotificationService _notificationService = NotificationService();
  AppSettings _settings = AppSettings();
  bool _isLoading = true;

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;

  SettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    _settings = await _settingsService.loadSettings();
    
    // Initialize notification service and reschedule if enabled
    await _notificationService.initialize();
    if (_settings.notificationSettings.enabled) {
      await _notificationService.scheduleDailyNotifications(_settings.notificationSettings);
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode themeMode) async {
    _settings = _settings.copyWith(themeMode: themeMode);
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> toggleLanguage(String languageCode) async {
    final newActiveLanguages = Set<String>.from(_settings.activeLanguages);
    
    if (newActiveLanguages.contains(languageCode)) {
      // Don't allow removing English
      if (languageCode == 'en') return;
      // Don't allow removing if it's the last language
      if (newActiveLanguages.length <= 1) return;
      
      newActiveLanguages.remove(languageCode);
    } else {
      newActiveLanguages.add(languageCode);
    }
    
    _settings = _settings.copyWith(activeLanguages: newActiveLanguages);
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }

  bool isLanguageActive(String languageCode) {
    return _settings.activeLanguages.contains(languageCode);
  }
  
  /// Update notification settings
  Future<void> updateNotificationSettings(NotificationSettings notificationSettings) async {
    _settings = _settings.copyWith(notificationSettings: notificationSettings);
    await _settingsService.saveSettings(_settings);
    
    // Reschedule notifications
    await _notificationService.scheduleDailyNotifications(notificationSettings);
    
    notifyListeners();
  }
  
  /// Request notification permissions
  Future<bool> requestNotificationPermissions() async {
    return await _notificationService.requestPermissions();
  }
  
  /// Check if notifications are enabled in system
  Future<bool> areNotificationsEnabled() async {
    return await _notificationService.areNotificationsEnabled();
  }
}

import 'package:flutter/material.dart';
import 'notification_settings.dart';

enum AppThemeMode {
  light,
  dark,
  system;

  ThemeMode toThemeMode() {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  static AppThemeMode fromString(String value) {
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
        return AppThemeMode.system;
      default:
        return AppThemeMode.system;
    }
  }
}

class AppSettings {
  final AppThemeMode themeMode;
  final Set<String> activeLanguages;
  final NotificationSettings notificationSettings;

  AppSettings({
    this.themeMode = AppThemeMode.system,
    Set<String>? activeLanguages,
    NotificationSettings? notificationSettings,
  })  : activeLanguages = activeLanguages ?? {'en', 'tr'},
        notificationSettings = notificationSettings ?? NotificationSettings();

  AppSettings copyWith({
    AppThemeMode? themeMode,
    Set<String>? activeLanguages,
    NotificationSettings? notificationSettings,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      activeLanguages: activeLanguages ?? this.activeLanguages,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'activeLanguages': activeLanguages.toList(),
      'notificationSettings': notificationSettings.toJson(),
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: AppThemeMode.fromString(json['themeMode'] ?? 'system'),
      activeLanguages: (json['activeLanguages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          {'en', 'tr'},
      notificationSettings: json['notificationSettings'] != null
          ? NotificationSettings.fromJson(json['notificationSettings'])
          : NotificationSettings(),
    );
  }
}

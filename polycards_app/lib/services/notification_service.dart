import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../models/notification_settings.dart';
import '../models/word.dart';
import 'locale_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  static const platform = MethodChannel('com.polycards.polycards_app/alarm');

  bool _initialized = false;
  final Random _random = Random();
  final Set<int> _usedWordIndices = {};
  
  /// Callback for handling notification taps
  static Function(int)? onNotificationTap;
  
  /// Store initial notification details
  NotificationAppLaunchDetails? _launchDetails;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    
    // Set local timezone
    final String timeZoneName = 'Europe/Istanbul'; // You can make this configurable
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    
    // Get notification launch details before initialization
    _launchDetails = await _notifications.getNotificationAppLaunchDetails();

    // Android initialization with notification channel
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Create Android notification channel
    const androidChannel = AndroidNotificationChannel(
      'daily_word_reminders',
      'Daily Word Reminders',
      description: 'Daily notifications for learning new words',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );
    
    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(androidChannel);
    }

    _initialized = true;
    debugPrint('NotificationService initialized successfully');
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to word cards screen with specific word index
    debugPrint('Notification tapped: ${response.payload}');
    
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        final wordIndex = int.parse(response.payload!);
        debugPrint('Navigating to word index: $wordIndex');
        
        // Call the callback if it's set
        if (onNotificationTap != null) {
          onNotificationTap!(wordIndex);
        }
      } catch (e) {
        debugPrint('Error parsing word index from payload: $e');
      }
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    // First request notification permission
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      if (!status.isGranted) {
        return false;
      }
    }
    
    // Then request exact alarm permission for Android 12+
    try {
      final canSchedule = await platform.invokeMethod<bool>('canScheduleExactAlarms');
      if (canSchedule != null && !canSchedule) {
        debugPrint('Requesting exact alarm permission...');
        await platform.invokeMethod('requestExactAlarmPermission');
      }
    } catch (e) {
      debugPrint('Error checking exact alarm permission: $e');
    }
    
    return await Permission.notification.isGranted;
  }

  /// Schedule daily word notifications
  Future<void> scheduleDailyNotifications(NotificationSettings settings) async {
    if (!_initialized) await initialize();

    // Cancel all existing notifications
    await cancelAllNotifications();

    if (!settings.enabled || settings.wordsPerDay <= 0) {
      return;
    }

    // Request permissions first
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      debugPrint('Notification permission denied');
      return;
    }

    // Get notification times
    final notificationTimes = settings.getNotificationTimes();

    // Schedule notifications for each time slot
    for (int i = 0; i < notificationTimes.length; i++) {
      await _scheduleDailyNotification(
        id: i,
        time: notificationTimes[i],
      );
    }

    debugPrint('Scheduled ${notificationTimes.length} daily notifications');
  }

  /// Schedule a single daily notification
  Future<void> _scheduleDailyNotification({
    required int id,
    required TimeOfDay time,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the scheduled time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Get a random word for this notification
    final wordData = await _getRandomWordWithIndex();
    final word = wordData?['word'] as Word?;
    final wordIndex = wordData?['index'] as int? ?? 0;

    await _notifications.zonedSchedule(
      id,
      'Learn a New Word! 📚',
      word != null ? '"${word.translation}" - Tap to learn more' : 'Tap to learn new words',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_word_reminders',
          'Daily Word Reminders',
          channelDescription: 'Daily notifications for learning new words',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableLights: true,
          enableVibration: true,
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: wordIndex.toString(), // Add word index as payload
    );
  }

  /// Get a random word from the locale data with its index
  Future<Map<String, dynamic>?> _getRandomWordWithIndex() async {
    try {
      final languageData = await LocaleService.loadLanguage('en');
      final words = languageData.words;
      
      if (words.isEmpty) return null;

      // Get a random word that hasn't been used recently
      int attempts = 0;
      while (attempts < 10) {
        final index = _random.nextInt(words.length);
        if (!_usedWordIndices.contains(index)) {
          _usedWordIndices.add(index);
          
          // Keep only last 50 used words to allow cycling
          if (_usedWordIndices.length > 50) {
            _usedWordIndices.remove(_usedWordIndices.first);
          }
          
          return {'word': words[index], 'index': index};
        }
        attempts++;
      }

      // If all attempts failed, just return a random word
      final index = _random.nextInt(words.length);
      return {'word': words[index], 'index': index};
    } catch (e) {
      debugPrint('Error getting random word: $e');
      return null;
    }
  }
  
  /// Get a random word from the locale data
  Future<Word?> _getRandomWord() async {
    final wordData = await _getRandomWordWithIndex();
    return wordData?['word'] as Word?;
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('All notifications cancelled');
  }

  /// Check if notifications are enabled in system settings
  Future<bool> areNotificationsEnabled() async {
    return await Permission.notification.isGranted;
  }

  /// Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
  
  /// Check if app was launched from notification and return word index
  Future<int?> getInitialNotificationWordIndex() async {
    if (!_initialized) await initialize();
    
    if (_launchDetails?.didNotificationLaunchApp ?? false) {
      final payload = _launchDetails?.notificationResponse?.payload;
      if (payload != null && payload.isNotEmpty) {
        try {
          return int.parse(payload);
        } catch (e) {
          debugPrint('Error parsing initial notification payload: $e');
        }
      }
    }
    return null;
  }
  
  /// Send an immediate test notification
  Future<void> sendTestNotification() async {
    if (!_initialized) await initialize();
    
    final wordData = await _getRandomWordWithIndex();
    final word = wordData?['word'] as Word?;
    final wordIndex = wordData?['index'] as int? ?? 0;
    
    await _notifications.show(
      999, // Test notification ID
      'Test Notification - Learn a New Word! 📚',
      word != null ? '"${word.translation}" - ${word.translation}' : 'Tap to learn new words',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_word_reminders',
          'Daily Word Reminders',
          channelDescription: 'Daily notifications for learning new words',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          enableLights: true,
          enableVibration: true,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: wordIndex.toString(), // Add word index as payload
    );
    
    debugPrint('Test notification sent with word index: $wordIndex');
  }
}

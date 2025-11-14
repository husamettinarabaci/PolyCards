import 'package:flutter/material.dart';

class NotificationSettings {
  final bool enabled;
  final int wordsPerDay;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  
  NotificationSettings({
    this.enabled = false,
    this.wordsPerDay = 5,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  })  : startTime = startTime ?? const TimeOfDay(hour: 9, minute: 0),
        endTime = endTime ?? const TimeOfDay(hour: 21, minute: 0);

  NotificationSettings copyWith({
    bool? enabled,
    int? wordsPerDay,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      wordsPerDay: wordsPerDay ?? this.wordsPerDay,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'wordsPerDay': wordsPerDay,
      'startTimeHour': startTime.hour,
      'startTimeMinute': startTime.minute,
      'endTimeHour': endTime.hour,
      'endTimeMinute': endTime.minute,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'] ?? false,
      wordsPerDay: json['wordsPerDay'] ?? 5,
      startTime: TimeOfDay(
        hour: json['startTimeHour'] ?? 9,
        minute: json['startTimeMinute'] ?? 0,
      ),
      endTime: TimeOfDay(
        hour: json['endTimeHour'] ?? 21,
        minute: json['endTimeMinute'] ?? 0,
      ),
    );
  }
  
  /// Calculate the interval between notifications in minutes
  int get intervalMinutes {
    if (wordsPerDay <= 0) return 0;
    
    final totalMinutes = _getMinutesBetweenTimes(startTime, endTime);
    return totalMinutes ~/ wordsPerDay;
  }
  
  /// Helper method to calculate minutes between two times
  int _getMinutesBetweenTimes(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    
    if (endMinutes > startMinutes) {
      return endMinutes - startMinutes;
    } else {
      // If end time is before start time, assume next day
      return (24 * 60 - startMinutes) + endMinutes;
    }
  }
  
  /// Get list of notification times for the day
  List<TimeOfDay> getNotificationTimes() {
    if (wordsPerDay <= 0) return [];
    
    final times = <TimeOfDay>[];
    final interval = intervalMinutes;
    
    for (int i = 0; i < wordsPerDay; i++) {
      final minutesFromStart = interval * i;
      final totalMinutes = startTime.hour * 60 + startTime.minute + minutesFromStart;
      
      final hour = (totalMinutes ~/ 60) % 24;
      final minute = totalMinutes % 60;
      
      times.add(TimeOfDay(hour: hour, minute: minute));
    }
    
    return times;
  }
}

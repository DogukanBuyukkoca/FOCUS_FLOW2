import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models.dart';
import 'hive_adapters.dart';

// Storage Service
class StorageService {
  static late Box _preferencesBox;
  static late Box _sessionsBox;
  static late Box<Goal> _goalsBox;
  
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters if not registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(GoalAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SubTaskAdapter());
    }
    
    _preferencesBox = await Hive.openBox('preferences');
    _sessionsBox = await Hive.openBox('sessions');
    _goalsBox = await Hive.openBox<Goal>('goals');
  }
  
  // Goals Operations
  static Future<List<Goal>> getAllGoals() async {
    return _goalsBox.values.toList();
  }
  
  static Future<void> saveGoal(Goal goal) async {
    await _goalsBox.put(goal.id, goal);
  }
  
  static Future<void> updateGoal(Goal goal) async {
    await _goalsBox.put(goal.id, goal);
  }
  
  static Future<void> deleteGoal(String id) async {
    await _goalsBox.delete(id);
  }
  
  static Goal? getGoal(String id) {
    return _goalsBox.get(id);
  }
  
  static Future<void> clearAllGoals() async {
    await _goalsBox.clear();
  }
  
  static Future<bool> isOnboardingComplete() async {
    return _preferencesBox.get('onboarding_complete', defaultValue: false);
  }
  
  static Future<void> setOnboardingComplete(bool value) async {
    await _preferencesBox.put('onboarding_complete', value);
  }
  
  static Future<void> setUserGoal(String goal) async {
    await _preferencesBox.put('user_goal', goal);
  }
  
  static Future<UserPreferences> getUserPreferences() async {
    return UserPreferences(
      defaultFocusMinutes: _preferencesBox.get('focus_minutes', defaultValue: 25),
      autoStartNext: _preferencesBox.get('auto_start_next', defaultValue: false),
      autoStartBreaks: _preferencesBox.get('auto_start_breaks', defaultValue: false),
    );
  }
  
  static UserPreferences getCachedPreferences() {
    return UserPreferences(
      defaultFocusMinutes: _preferencesBox.get('focus_minutes', defaultValue: 25),
      autoStartNext: _preferencesBox.get('auto_start_next', defaultValue: false),
      autoStartBreaks: _preferencesBox.get('auto_start_breaks', defaultValue: false),
    );
  }
  
  static Future<int> getTodaySessionCount() async {
    final today = DateTime.now();
    final sessions = _sessionsBox.values.where((session) {
      final sessionDate = DateTime.parse(session['date']);
      return sessionDate.year == today.year &&
          sessionDate.month == today.month &&
          sessionDate.day == today.day;
    }).toList();
    return sessions.length;
  }
  
  static Future<int> getCurrentStreak() async {
    // Calculate streak logic
    return 5; // Mock value
  }
  
  static Future<void> saveSession({
    required DateTime startTime,
    required DateTime endTime,
    required SessionType sessionType,
    required bool wasCompleted,
  }) async {
    await _sessionsBox.add({
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'date': startTime.toIso8601String().split('T')[0],
      'session_type': sessionType.toString(),
      'completed': wasCompleted,
    });
  }
  
  static Future<void> saveCheckpoint({
    required DateTime sessionStart,
    required Duration elapsed,
    required SessionType sessionType,
  }) async {
    await _preferencesBox.put('checkpoint', {
      'session_start': sessionStart.toIso8601String(),
      'elapsed_seconds': elapsed.inSeconds,
      'session_type': sessionType.toString(),
      'saved_at': DateTime.now().toIso8601String(),
    });
  }
  
  static Future<Map<String, dynamic>?> getLastCheckpoint() async {
    return _preferencesBox.get('checkpoint');
  }
  
  static Future<void> clearCheckpoint() async {
    await _preferencesBox.delete('checkpoint');
  }
  
  // Settings storage methods
  static Future<void> saveFocusDuration(int minutes) async {
    await _preferencesBox.put('focus_minutes', minutes);
  }
  
  static Future<void> saveShortBreakDuration(int minutes) async {
    await _preferencesBox.put('short_break_minutes', minutes);
  }
  
  static Future<void> saveLongBreakDuration(int minutes) async {
    await _preferencesBox.put('long_break_minutes', minutes);
  }
  
  static Future<void> saveAutoStartBreaks(bool value) async {
    await _preferencesBox.put('auto_start_breaks', value);
  }
  
  static Future<void> saveAutoStartFocus(bool value) async {
    await _preferencesBox.put('auto_start_focus', value);
  }
  
  static Future<void> saveSoundEnabled(bool value) async {
    await _preferencesBox.put('sound_enabled', value);
  }
  
  static Future<void> saveHapticEnabled(bool value) async {
    await _preferencesBox.put('haptic_enabled', value);
  }
  
  static Future<void> saveNotificationsEnabled(bool value) async {
    await _preferencesBox.put('notifications_enabled', value);
  }
  
  static Future<void> saveDailyReminderTime(String? time) async {
    if (time != null) {
      await _preferencesBox.put('daily_reminder_time', time);
    } else {
      await _preferencesBox.delete('daily_reminder_time');
    }
  }
  
  static Future<void> saveThemeMode(String mode) async {
    await _preferencesBox.put('theme_mode', mode);
  }
  
  static Future<void> saveLocale(String languageCode) async {
    await _preferencesBox.put('locale', languageCode);
  }
  
  static Future<Settings> getSettings() async {
    return Settings(
      focusDuration: _preferencesBox.get('focus_minutes', defaultValue: 25),
      shortBreakDuration: _preferencesBox.get('short_break_minutes', defaultValue: 5),
      longBreakDuration: _preferencesBox.get('long_break_minutes', defaultValue: 15),
      sessionsUntilLongBreak: _preferencesBox.get('sessions_until_long_break', defaultValue: 4),
      autoStartBreaks: _preferencesBox.get('auto_start_breaks', defaultValue: false),
      autoStartFocus: _preferencesBox.get('auto_start_focus', defaultValue: false),
      soundEnabled: _preferencesBox.get('sound_enabled', defaultValue: true),
      hapticEnabled: _preferencesBox.get('haptic_enabled', defaultValue: true),
      notificationsEnabled: _preferencesBox.get('notifications_enabled', defaultValue: true),
      dailyReminderTime: _preferencesBox.get('daily_reminder_time'),
      isPremium: _preferencesBox.get('is_premium', defaultValue: false),
    );
  }
  
  static String getThemeMode() {
    return _preferencesBox.get('theme_mode', defaultValue: 'system');
  }
  
  static String getLocale() {
    return _preferencesBox.get('locale', defaultValue: 'en');
  }
  
  static Future<void> clearAllData() async {
    await _preferencesBox.clear();
    await _sessionsBox.clear();
  }
}

// Notification Service
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(initSettings);
  }
  
  static Future<void> scheduleSessionComplete(Duration duration) async {
    // final scheduledTime = DateTime.now().add(duration);
    
    const androidDetails = AndroidNotificationDetails(
      'focus_flow_timer',
      'Timer Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails();
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    // Using zonedSchedule instead of deprecated schedule method
    await _notifications.show(
      1,
      'Focus Session Complete!',
      'Great job! Time for a break.',
      details,
    );
    
    // Note: For actual scheduled notifications, you would need to use
    // zonedSchedule with timezone package, but for simplicity we're using show
    // which displays immediately. In production, implement proper scheduling.
  }
  
  static Future<void> showSessionComplete(SessionType type) async {
    String title;
    String body;
    
    switch (type) {
      case SessionType.focus:
        title = 'Focus Session Complete!';
        body = 'Great job! Time for a break.';
        break;
      case SessionType.shortBreak:
        title = 'Break Complete!';
        body = 'Ready to focus again?';
        break;
      case SessionType.longBreak:
        title = 'Long Break Complete!';
        body = 'Feeling refreshed? Let\'s continue!';
        break;
    }
    
    await _notifications.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'focus_flow_timer',
          'Timer Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
  
  static Future<void> cancelScheduledNotifications() async {
    await _notifications.cancelAll();
  }
}

// Audio Service
class AudioService {
  static void playStartSound() {
    // Implement sound playback
  }
  
  static void playPauseSound() {
    // Implement sound playback
  }
  
  static void playResumeSound() {
    // Implement sound playback
  }
  
  static void playCompletionSound() {
    // Implement sound playback
  }
}

// App Constants
class AppConstants {
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('tr'),
  ];
}
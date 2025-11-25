import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models.dart';
import 'hive_adapters.dart';

// ============================================================================
// STORAGE SERVICE - UPDATED: Removed sessionsUntilLongBreak, autoStartBreaks, autoStartFocus
// ============================================================================
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
    await Hive.openBox('space_progress');
  }
  
  // ============================================================================
  // GOALS OPERATIONS
  // ============================================================================
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
  
  // ============================================================================
  // ONBOARDING & USER PREFERENCES
  // ============================================================================
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
  
  // ============================================================================
  // SESSIONS OPERATIONS
  // ============================================================================
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
  
  // Updated saveSession method - simplified signature
  static Future<void> saveSession(DateTime date, int durationMinutes) async {
    await _sessionsBox.add({
      'date': date.toIso8601String().split('T')[0],
      'duration_minutes': durationMinutes,
      'timestamp': date.toIso8601String(),
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
  
  // ============================================================================
  // SETTINGS OPERATIONS - UPDATED: Removed sessionsUntilLongBreak, autoStartBreaks, autoStartFocus
  // ============================================================================
  static Future<Settings> getSettings() async {
    return Settings(
      focusDuration: _preferencesBox.get('focus_duration', defaultValue: 25),
      shortBreakDuration: _preferencesBox.get('short_break_duration', defaultValue: 5),
      longBreakDuration: _preferencesBox.get('long_break_duration', defaultValue: 15),
      soundEnabled: _preferencesBox.get('sound_enabled', defaultValue: true),
      hapticEnabled: _preferencesBox.get('haptic_enabled', defaultValue: true),
      notificationsEnabled: _preferencesBox.get('notifications_enabled', defaultValue: true),
      dailyReminderTime: _preferencesBox.get('daily_reminder_time'),
      darkMode: _preferencesBox.get('dark_mode', defaultValue: false),
      isPremium: _preferencesBox.get('is_premium', defaultValue: false),
    );
  }
  
  static Future<void> saveFocusDuration(int minutes) async {
    await _preferencesBox.put('focus_duration', minutes);
  }
  
  static Future<void> saveShortBreakDuration(int minutes) async {
    await _preferencesBox.put('short_break_duration', minutes);
  }
  
  static Future<void> saveLongBreakDuration(int minutes) async {
    await _preferencesBox.put('long_break_duration', minutes);
  }
  
  // REMOVED: saveSessionsUntilLongBreak
  // REMOVED: saveAutoStartBreaks
  // REMOVED: saveAutoStartFocus
  
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
  
  static Future<void> saveDarkMode(bool value) async {
    await _preferencesBox.put('dark_mode', value);
  }
  
  static Future<void> saveIsPremium(bool value) async {
    await _preferencesBox.put('is_premium', value);
  }
}

// ============================================================================
// NOTIFICATION SERVICE
// ============================================================================
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );
    
    // Request permissions
    await _requestPermissions();
  }
  
  static Future<void> _requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    await androidPlugin?.requestNotificationsPermission();
    
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  
  static Future<void> scheduleReminder(String time) async {
    const details = NotificationDetails(
      android: const AndroidNotificationDetails(
        'focus_flow_reminders',
        'Daily Reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    
    await _notifications.show(
      1,
      'Time to Focus!',
      'Great job! Time for a break.',
      details,
    );
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

// ============================================================================
// AUDIO SERVICE
// ============================================================================
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

// ============================================================================
// APP CONSTANTS
// ============================================================================
class AppConstants {
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('tr'),
  ];
}
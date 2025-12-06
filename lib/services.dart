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
    final sessions = _sessionsBox.values.toList();
    if (sessions.isEmpty) {
      print('🔴 No sessions found for streak calculation');
      return 0;
    }

    print('📊 Total sessions in box: ${sessions.length}');

    int streak = 0;
    DateTime currentDate = DateTime.now();

    // Bugünden başlayarak geriye doğru kontrol et
    // Maksimum 365 gün kontrol et (sonsuz döngüyü önlemek için)
    for (int i = 0; i < 365; i++) {
      final dateStr = currentDate.toIso8601String().split('T')[0];
      final dailySessions = sessions.where((session) {
        return session['date'] == dateStr;
      }).toList();

      // Günlük toplam odaklanma süresini hesapla
      int dailyMinutes = 0;
      for (var session in dailySessions) {
        dailyMinutes += (session['duration_minutes'] as int? ?? 0);
      }

      print('📅 Date: $dateStr, Minutes: $dailyMinutes');

      // En az 5 dakika odaklanma olmalı
      if (dailyMinutes >= 5) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        // Bugün odaklanma yoksa, dünden devam et
        // Ancak eğer bugün değilse (i > 0), streak'i kır
        if (i > 0) {
          break;
        }
        // Bugünse (i == 0), dünü kontrol et
        currentDate = currentDate.subtract(const Duration(days: 1));
      }
    }

    print('🔥 Current Streak: $streak days');
    return streak;
  }

  static Future<int> getBestStreak() async {
    final currentStreak = await getCurrentStreak();
    final savedBestStreak = _preferencesBox.get('best_streak', defaultValue: 0);

    if (currentStreak > savedBestStreak) {
      await _preferencesBox.put('best_streak', currentStreak);
      return currentStreak;
    }

    return savedBestStreak;
  }

  // Period bazlı total focus time hesaplama
  static Future<Duration> getTotalFocusTime(TimePeriod period) async {
    final sessions = _sessionsBox.values.toList();
    print('⏰ getTotalFocusTime - Total sessions: ${sessions.length}');

    if (sessions.isEmpty) {
      print('⏰ No sessions, returning zero');
      return Duration.zero;
    }

    final now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case TimePeriod.day:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case TimePeriod.week:
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case TimePeriod.month:
        startDate = DateTime(now.year, now.month, 1);
        break;
      case TimePeriod.year:
        startDate = DateTime(now.year, 1, 1);
        break;
    }

    print('⏰ Start date: $startDate, Now: $now');

    int totalMinutes = 0;
    for (var session in sessions) {
      final sessionDate = DateTime.parse(session['timestamp']);
      final minutes = session['duration_minutes'] as int? ?? 0;
      print('⏰ Session: ${session['timestamp']}, Minutes: $minutes');

      if (sessionDate.isAfter(startDate) || sessionDate.isAtSameMomentAs(startDate)) {
        totalMinutes += minutes;
        print('✅ Added to total');
      } else {
        print('❌ Before start date, skipped');
      }
    }

    print('⏰ Total minutes for $period: $totalMinutes');
    return Duration(minutes: totalMinutes);
  }

  // Period bazlı günlük data ve labels
  static Future<Map<String, dynamic>> getDailyDataForPeriod(TimePeriod period) async {
    final sessions = _sessionsBox.values.toList();
    final now = DateTime.now();

    List<int> dailyData = [];
    List<String> dailyLabels = [];

    switch (period) {
      case TimePeriod.day:
        // Bugünün saatlik dağılımı (6 saat aralıkları)
        dailyLabels = ['00-06', '06-12', '12-18', '18-24'];
        dailyData = [0, 0, 0, 0];

        for (var session in sessions) {
          final sessionDate = DateTime.parse(session['timestamp']);
          if (sessionDate.year == now.year &&
              sessionDate.month == now.month &&
              sessionDate.day == now.day) {
            final hour = sessionDate.hour;
            final index = hour ~/ 6;
            dailyData[index] += (session['duration_minutes'] as int? ?? 0);
          }
        }
        break;

      case TimePeriod.week:
        // Son 7 gün
        dailyLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        dailyData = [0, 0, 0, 0, 0, 0, 0];

        final weekStart = now.subtract(Duration(days: now.weekday - 1));

        for (var session in sessions) {
          final sessionDate = DateTime.parse(session['timestamp']);
          final daysDiff = sessionDate.difference(weekStart).inDays;

          if (daysDiff >= 0 && daysDiff < 7) {
            dailyData[daysDiff] += (session['duration_minutes'] as int? ?? 0);
          }
        }
        break;

      case TimePeriod.month:
        // Son 4 hafta
        dailyLabels = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
        dailyData = [0, 0, 0, 0];

        final monthStart = DateTime(now.year, now.month, 1);

        for (var session in sessions) {
          final sessionDate = DateTime.parse(session['timestamp']);
          if (sessionDate.year == now.year && sessionDate.month == now.month) {
            final weekIndex = ((sessionDate.day - 1) ~/ 7).clamp(0, 3);
            dailyData[weekIndex] += (session['duration_minutes'] as int? ?? 0);
          }
        }
        break;

      case TimePeriod.year:
        // 12 ay
        dailyLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        dailyData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

        for (var session in sessions) {
          final sessionDate = DateTime.parse(session['timestamp']);
          if (sessionDate.year == now.year) {
            dailyData[sessionDate.month - 1] += (session['duration_minutes'] as int? ?? 0);
          }
        }
        break;
    }

    final maxMinutes = dailyData.isEmpty ? 0 : dailyData.reduce((a, b) => a > b ? a : b);

    return {
      'dailyData': dailyData,
      'dailyLabels': dailyLabels,
      'maxDailyMinutes': maxMinutes,
    };
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
      android: AndroidNotificationDetails(
        'focus_flow_reminders',
        'Daily Reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
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
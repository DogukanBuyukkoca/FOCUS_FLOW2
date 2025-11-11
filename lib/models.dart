import 'package:flutter/material.dart';

// Timer Models
enum SessionType { focus, shortBreak, longBreak }

class TimerState {
  final Duration targetDuration;
  final Duration remaining;
  final bool isRunning;
  final bool isPaused;
  final bool isCompleted;
  final double progress;
  final SessionType sessionType;
  final int todaysSessions;
  final int currentStreak;
  final bool isSpecialSession;

  TimerState({
    required this.targetDuration,
    required this.remaining,
    required this.isRunning,
    required this.isPaused,
    required this.isCompleted,
    required this.progress,
    required this.sessionType,
    required this.todaysSessions,
    required this.currentStreak,
    this.isSpecialSession = false,
  });

  factory TimerState.initial() {
    return TimerState(
      targetDuration: const Duration(minutes: 25),
      remaining: const Duration(minutes: 25),
      isRunning: false,
      isPaused: false,
      isCompleted: false,
      progress: 0.0,
      sessionType: SessionType.focus,
      todaysSessions: 0,
      currentStreak: 0,
      isSpecialSession: false,
    );
  }

  TimerState copyWith({
    Duration? targetDuration,
    Duration? remaining,
    bool? isRunning,
    bool? isPaused,
    bool? isCompleted,
    double? progress,
    SessionType? sessionType,
    int? todaysSessions,
    int? currentStreak,
    bool? isSpecialSession,
  }) {
    return TimerState(
      targetDuration: targetDuration ?? this.targetDuration,
      remaining: remaining ?? this.remaining,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
      sessionType: sessionType ?? this.sessionType,
      todaysSessions: todaysSessions ?? this.todaysSessions,
      currentStreak: currentStreak ?? this.currentStreak,
      isSpecialSession: isSpecialSession ?? this.isSpecialSession,
    );
  }
}

// Enhanced Goals Models
enum GoalFilter { all, today, active, completed, thisWeek, overdue }
enum GoalPriority { low, medium, high, urgent }
enum GoalCategory { work, personal, health, education, finance, hobby, other }
enum RepeatType { none, daily, weekly, monthly }

class Goal {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? dueDate;
  final int? linkedSessions;
  final GoalCategory category;
  final GoalPriority priority;
  final List<SubTask> subTasks;
  final RepeatType repeatType;
  final List<String> tags;
  final String? notes;
  final int streak;
  final double progress;
  final DateTime? reminderTime;
  final List<DateTime> completionHistory;
  final int estimatedMinutes;
  final int actualMinutes;

  Goal({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.dueDate,
    this.linkedSessions,
    this.category = GoalCategory.personal,
    this.priority = GoalPriority.medium,
    this.subTasks = const [],
    this.repeatType = RepeatType.none,
    this.tags = const [],
    this.notes,
    this.streak = 0,
    this.progress = 0.0,
    this.reminderTime,
    this.completionHistory = const [],
    this.estimatedMinutes = 0,
    this.actualMinutes = 0,
  });

  bool get isToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  bool get isThisWeek {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return dueDate!.isAfter(weekStart) && dueDate!.isBefore(weekEnd);
  }

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  double get completionRate {
    if (subTasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    final completed = subTasks.where((t) => t.isCompleted).length;
    return completed / subTasks.length;
  }

  Color get priorityColor {
    switch (priority) {
      case GoalPriority.urgent:
        return Colors.red;
      case GoalPriority.high:
        return Colors.orange;
      case GoalPriority.medium:
        return Colors.blue;
      case GoalPriority.low:
        return Colors.grey;
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case GoalCategory.work:
        return Icons.work_rounded;
      case GoalCategory.personal:
        return Icons.person_rounded;
      case GoalCategory.health:
        return Icons.favorite_rounded;
      case GoalCategory.education:
        return Icons.school_rounded;
      case GoalCategory.finance:
        return Icons.attach_money_rounded;
      case GoalCategory.hobby:
        return Icons.palette_rounded;
      case GoalCategory.other:
        return Icons.category_rounded;
    }
  }

  Goal copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? dueDate,
    int? linkedSessions,
    GoalCategory? category,
    GoalPriority? priority,
    List<SubTask>? subTasks,
    RepeatType? repeatType,
    List<String>? tags,
    String? notes,
    int? streak,
    double? progress,
    DateTime? reminderTime,
    List<DateTime>? completionHistory,
    int? estimatedMinutes,
    int? actualMinutes,
  }) {
    return Goal(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      dueDate: dueDate ?? this.dueDate,
      linkedSessions: linkedSessions ?? this.linkedSessions,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      subTasks: subTasks ?? this.subTasks,
      repeatType: repeatType ?? this.repeatType,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      streak: streak ?? this.streak,
      progress: progress ?? this.progress,
      reminderTime: reminderTime ?? this.reminderTime,
      completionHistory: completionHistory ?? this.completionHistory,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      actualMinutes: actualMinutes ?? this.actualMinutes,
    );
  }
}

class SubTask {
  final String id;
  final String title;
  final bool isCompleted;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  SubTask copyWith({
    String? title,
    bool? isCompleted,
  }) {
    return SubTask(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

// Statistics Models
enum TimePeriod { day, week, month, year }

class StatisticsData {
  final Duration totalFocusTime;
  final int totalSessions;
  final int averageSessionMinutes;
  final int bestStreak;
  final double completionRate;
  final double focusTimeTrend;
  final double sessionsChange;
  final double avgDurationChange;
  final double completionChange;
  final List<int> dailyData;
  final List<String> dailyLabels;
  final int maxDailyMinutes;

  StatisticsData({
    required this.totalFocusTime,
    required this.totalSessions,
    required this.averageSessionMinutes,
    required this.bestStreak,
    required this.completionRate,
    this.focusTimeTrend = 0,
    this.sessionsChange = 0,
    this.avgDurationChange = 0,
    this.completionChange = 0,
    required this.dailyData,
    required this.dailyLabels,
    required this.maxDailyMinutes,
  });
}

// Settings Models
class Settings {
  final int focusDuration;
  final int shortBreakDuration;
  final int longBreakDuration;
  final int sessionsUntilLongBreak;
  final bool autoStartBreaks;
  final bool autoStartFocus;
  final bool soundEnabled;
  final bool hapticEnabled;
  final bool notificationsEnabled;
  final String? dailyReminderTime;
  final bool isPremium;

  Settings({
    this.focusDuration = 25,
    this.shortBreakDuration = 5,
    this.longBreakDuration = 15,
    this.sessionsUntilLongBreak = 4,
    this.autoStartBreaks = false,
    this.autoStartFocus = false,
    this.soundEnabled = true,
    this.hapticEnabled = true,
    this.notificationsEnabled = true,
    this.dailyReminderTime,
    this.isPremium = false,
  });

  Settings copyWith({
    int? focusDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    int? sessionsUntilLongBreak,
    bool? autoStartBreaks,
    bool? autoStartFocus,
    bool? soundEnabled,
    bool? hapticEnabled,
    bool? notificationsEnabled,
    String? dailyReminderTime,
    bool? isPremium,
  }) {
    return Settings(
      focusDuration: focusDuration ?? this.focusDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      sessionsUntilLongBreak: sessionsUntilLongBreak ?? this.sessionsUntilLongBreak,
      autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
      autoStartFocus: autoStartFocus ?? this.autoStartFocus,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}

// Premium Models
class PremiumFeature {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  PremiumFeature({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

// User Preferences
class UserPreferences {
  final int defaultFocusMinutes;
  final bool autoStartNext;
  final bool autoStartBreaks;

  UserPreferences({
    this.defaultFocusMinutes = 25,
    this.autoStartNext = false,
    this.autoStartBreaks = false,
  });
}
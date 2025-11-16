import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models.dart';
import 'services.dart';
import 'storage_service.dart';

// Selected Goal Provider for Special Timer
final selectedGoalProvider = StateProvider<Goal?>((ref) => null);

// Timer Provider with Enhanced Special Session Support
final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier(ref);
});

class TimerNotifier extends StateNotifier<TimerState> {
  Timer? _timer;
  final Ref ref;
  
  TimerNotifier(this.ref) : super(TimerState.initial());
  
  void start() {
    state = state.copyWith(isRunning: true, isPaused: false);
    _startTimer();
  }
  
  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false, isPaused: true);
  }
  
  void resume() {
    state = state.copyWith(isRunning: true, isPaused: false);
    _startTimer();
  }
  
  void reset() {
    _timer?.cancel();
    // Keep the current session type but reset the timer
    Duration duration;
    if (state.isSpecialSession) {
      final selectedGoal = ref.read(selectedGoalProvider);
      duration = Duration(minutes: selectedGoal?.estimatedMinutes ?? 25);
    } else {
      switch (state.sessionType) {
        case SessionType.focus:
          duration = const Duration(minutes: 25);
          break;
        case SessionType.shortBreak:
          duration = const Duration(minutes: 5);
          break;
        case SessionType.longBreak:
          duration = const Duration(minutes: 15);
          break;
      }
    }
    
    state = state.copyWith(
      targetDuration: duration,
      remaining: duration,
      isRunning: false,
      isPaused: false,
      isCompleted: false,
      progress: 0.0,
    );
  }
  
  void skip() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false, isCompleted: true);
  }
  
  void changeSessionType(SessionType type) {
    Duration duration;
    switch (type) {
      case SessionType.focus:
        duration = const Duration(minutes: 25);
        break;
      case SessionType.shortBreak:
        duration = const Duration(minutes: 5);
        break;
      case SessionType.longBreak:
        duration = const Duration(minutes: 15);
        break;
    }
    
    state = state.copyWith(
      sessionType: type,
      targetDuration: duration,
      remaining: duration,
      progress: 0.0,
      isSpecialSession: false,  // Clear special session when changing type
    );
  }
  
  void setSpecialSession() {
    final selectedGoal = ref.read(selectedGoalProvider);
    if (selectedGoal != null && selectedGoal.estimatedMinutes > 0) {
      final duration = Duration(minutes: selectedGoal.estimatedMinutes);
      state = state.copyWith(
        targetDuration: duration,
        remaining: duration,
        progress: 0.0,
        isSpecialSession: true,
        sessionType: SessionType.focus,  // Special sessions are focus sessions
      );
    } else {
      // If no goal is selected or has no estimated time, use default focus duration
      final duration = const Duration(minutes: 25);
      state = state.copyWith(
        targetDuration: duration,
        remaining: duration,
        progress: 0.0,
        isSpecialSession: true,
        sessionType: SessionType.focus,
      );
    }
  }
  
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remaining.inSeconds > 0) {
        final newRemaining = Duration(seconds: state.remaining.inSeconds - 1);
        final progress = 1 - (newRemaining.inSeconds / state.targetDuration.inSeconds);
        
        state = state.copyWith(
          remaining: newRemaining,
          progress: progress,
        );
      } else {
        timer.cancel();
        state = state.copyWith(
          isRunning: false,
          isCompleted: true,
          progress: 1.0,
          todaysSessions: state.todaysSessions + 1,
        );
      }
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Enhanced Goals Provider with Hive Support
final goalsProvider = StateNotifierProvider<GoalsNotifier, List<Goal>>((ref) {
  return GoalsNotifier();
});

class GoalsNotifier extends StateNotifier<List<Goal>> {
  GoalsNotifier() : super([]) {
    _loadGoals();
  }
  
  Future<void> _loadGoals() async {
    try {
      final goals = await StorageService.getAllGoals();
      state = goals;
    } catch (e) {
      // If error loading from storage, initialize with empty list
      state = [];
    }
  }
  
  Future<void> addGoal(Goal goal) async {
    state = [...state, goal];
    await StorageService.saveGoal(goal);
  }
  
  Future<void> updateGoal(Goal updatedGoal) async {
    state = state.map((goal) {
      return goal.id == updatedGoal.id ? updatedGoal : goal;
    }).toList();
    await StorageService.updateGoal(updatedGoal);
  }
  
  Future<void> toggleComplete(String id) async {
    final goalIndex = state.indexWhere((goal) => goal.id == id);
    if (goalIndex != -1) {
      final goal = state[goalIndex];
      final now = DateTime.now();
      final updatedGoal = goal.copyWith(
        isCompleted: !goal.isCompleted,
        completedAt: !goal.isCompleted ? now : null,
        actualMinutes: !goal.isCompleted ? goal.estimatedMinutes : 0,
        completionHistory: !goal.isCompleted 
            ? [...goal.completionHistory, now]
            : goal.completionHistory,
        streak: !goal.isCompleted ? goal.streak + 1 : goal.streak,
        progress: !goal.isCompleted ? 1.0 : 0.0,
      );
      
      state = [
        ...state.sublist(0, goalIndex),
        updatedGoal,
        ...state.sublist(goalIndex + 1),
      ];
      
      await StorageService.updateGoal(updatedGoal);
    }
  }
  
  Future<void> toggleSubTask(String goalId, String subTaskId) async {
    final goalIndex = state.indexWhere((goal) => goal.id == goalId);
    if (goalIndex != -1) {
      final goal = state[goalIndex];
      final updatedSubTasks = goal.subTasks.map((subTask) {
        if (subTask.id == subTaskId) {
          return subTask.copyWith(isCompleted: !subTask.isCompleted);
        }
        return subTask;
      }).toList();
      
      // Calculate progress based on subtasks
      final completedCount = updatedSubTasks.where((t) => t.isCompleted).length;
      final progress = updatedSubTasks.isEmpty 
          ? 0.0 
          : completedCount / updatedSubTasks.length;
      
      // Check if all subtasks are completed
      final allCompleted = updatedSubTasks.isNotEmpty && 
                          updatedSubTasks.every((t) => t.isCompleted);
      
      final updatedGoal = goal.copyWith(
        subTasks: updatedSubTasks,
        progress: progress,
        isCompleted: allCompleted,
        completedAt: allCompleted ? DateTime.now() : null,
      );
      
      state = [
        ...state.sublist(0, goalIndex),
        updatedGoal,
        ...state.sublist(goalIndex + 1),
      ];
      
      await StorageService.updateGoal(updatedGoal);
    }
  }
  
  Future<void> deleteGoal(String id) async {
    state = state.where((goal) => goal.id != id).toList();
    await StorageService.deleteGoal(id);
  }
  
  List<Goal> searchGoals(String query) {
    if (query.isEmpty) return state;
    
    final lowercaseQuery = query.toLowerCase();
    return state.where((goal) {
      return goal.title.toLowerCase().contains(lowercaseQuery) ||
             (goal.description?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             goal.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }
  
  // UPDATED: Active filtresi kaldırıldı
  List<Goal> filterGoals(GoalFilter filter) {
    switch (filter) {
      case GoalFilter.all:
        return state;
      case GoalFilter.today:
        return state.where((goal) => goal.isToday).toList();
      case GoalFilter.completed:
        return state.where((goal) => goal.isCompleted).toList();
      case GoalFilter.thisWeek:
        return state.where((goal) => goal.isThisWeek).toList();
      case GoalFilter.overdue:
        return state.where((goal) => goal.isOverdue).toList();
    }
  }
  
  List<Goal> filterByCategory(GoalCategory category) {
    return state.where((goal) => goal.category == category).toList();
  }
  
  List<Goal> filterByPriority(GoalPriority priority) {
    return state.where((goal) => goal.priority == priority).toList();
  }
  
  Map<GoalCategory, int> getCategoryStats() {
    final stats = <GoalCategory, int>{};
    for (var category in GoalCategory.values) {
      stats[category] = state.where((g) => g.category == category).length;
    }
    return stats;
  }
  
  double getOverallProgress() {
    if (state.isEmpty) return 0.0;
    final totalProgress = state.fold(0.0, (sum, goal) => sum + goal.progress);
    return totalProgress / state.length;
  }
  
  int getTodayCompletedCount() {
    final today = DateTime.now();
    return state.where((goal) {
      if (goal.completedAt == null) return false;
      return goal.completedAt!.year == today.year &&
             goal.completedAt!.month == today.month &&
             goal.completedAt!.day == today.day;
    }).length;
  }
  
  int getActiveGoalsCount() {
    return state.where((goal) => !goal.isCompleted).length;
  }
  
  int getTotalStreak() {
    return state.fold(0, (sum, goal) => sum + goal.streak);
  }
}

// Statistics Provider
final statisticsProvider = Provider.family<AsyncValue<StatisticsData>, TimePeriod>((ref, period) {
  // Mock data for now
  return AsyncValue.data(
    StatisticsData(
      totalFocusTime: const Duration(hours: 12, minutes: 30),
      totalSessions: 25,
      averageSessionMinutes: 23,
      bestStreak: 7,
      completionRate: 85.5,
      focusTimeTrend: 12.5,
      sessionsChange: 8.0,
      avgDurationChange: -2.3,
      completionChange: 5.0,
      dailyData: [20, 35, 45, 30, 50, 40, 55],
      dailyLabels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      maxDailyMinutes: 60,
    ),
  );
});

// Settings Provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<Settings> {
  SettingsNotifier() : super(Settings());
  
  void updateFocusDuration(int minutes) {
    state = state.copyWith(focusDuration: minutes);
  }
  
  void updateShortBreakDuration(int minutes) {
    state = state.copyWith(shortBreakDuration: minutes);
  }
  
  void updateLongBreakDuration(int minutes) {
    state = state.copyWith(longBreakDuration: minutes);
  }
  
  void updateSessionsUntilLongBreak(int sessions) {
    state = state.copyWith(sessionsUntilLongBreak: sessions);
  }
  
  void updateAutoStartBreaks(bool value) {
    state = state.copyWith(autoStartBreaks: value);
  }
  
  void updateAutoStartFocus(bool value) {
    state = state.copyWith(autoStartFocus: value);
  }
  
  void updateSoundEnabled(bool value) {
    state = state.copyWith(soundEnabled: value);
  }
  
  void updateHapticEnabled(bool value) {
    state = state.copyWith(hapticEnabled: value);
  }
  
  void updateNotificationsEnabled(bool value) {
    state = state.copyWith(notificationsEnabled: value);
  }
  
  void updateDailyReminderTime(String time) {
    state = state.copyWith(dailyReminderTime: time);
  }
  
  void setPremium(bool value) {
    state = state.copyWith(isPremium: value);
  }
}

// Theme Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);
  
  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}

// Locale Provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en'));
  
  void setLocale(Locale locale) {
    state = locale;
  }
}

// Premium Offerings Provider (Mock data instead of RevenueCat)
final premiumOfferingsProvider = FutureProvider<List<PremiumPackage>>((ref) async {
  // Mock premium packages - later you can integrate with RevenueCat
  await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
  
  return [
    PremiumPackage(
      identifier: 'pro_month',
      priceString: '\$4.99',
      title: 'Monthly',
      description: 'Billed monthly',
    ),
    PremiumPackage(
      identifier: 'pro_year', 
      priceString: '\$39.99',
      title: 'Yearly',
      description: 'Save 35%',
    ),
  ];
});

// Mock Premium Package class
class PremiumPackage {
  final String identifier;
  final String priceString;
  final String title;
  final String description;
  
  PremiumPackage({
    required this.identifier,
    required this.priceString,
    required this.title,
    required this.description,
  });
}
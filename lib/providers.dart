import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models.dart';
import 'services.dart' hide SessionType; // SessionType models.dart'tan gelecek

final selectedGoalProvider = StateProvider<Goal?>((ref) => null);
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
      
      final completedCount = updatedSubTasks.where((t) => t.isCompleted).length;
      final progress = updatedSubTasks.isEmpty 
          ? 0.0 
          : completedCount / updatedSubTasks.length;
      
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


// ============================================================================
// STATISTICS PROVIDER
// ============================================================================

final statisticsProvider = Provider.family<AsyncValue<StatisticsData>, TimePeriod>((ref, period) {
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


// ============================================================================
// SETTINGS PROVIDER - Kalıcı ayarlar için Hive entegrasyonu
// UPDATED: Removed updateSessionsUntilLongBreak, updateAutoStartBreaks, updateAutoStartFocus
// ============================================================================

final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  return SettingsNotifier(ref);
});

class SettingsNotifier extends StateNotifier<Settings> {
  final Ref ref;
  
  SettingsNotifier(this.ref) : super(Settings()) {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    try {
      final settings = await StorageService.getSettings();
      state = settings;
    } catch (e) {
      state = Settings();
    }
  }
  
  Future<void> updateFocusDuration(int minutes) async {
    state = state.copyWith(focusDuration: minutes);
    await StorageService.saveFocusDuration(minutes);
  }
  
  Future<void> updateShortBreakDuration(int minutes) async {
    state = state.copyWith(shortBreakDuration: minutes);
    await StorageService.saveShortBreakDuration(minutes);
  }
  
  Future<void> updateLongBreakDuration(int minutes) async {
    state = state.copyWith(longBreakDuration: minutes);
    await StorageService.saveLongBreakDuration(minutes);
  }
  
  // REMOVED: updateSessionsUntilLongBreak
  // REMOVED: updateAutoStartBreaks
  // REMOVED: updateAutoStartFocus
  
  Future<void> updateSoundEnabled(bool value) async {
    state = state.copyWith(soundEnabled: value);
    await StorageService.saveSoundEnabled(value);
  }
  
  Future<void> updateHapticEnabled(bool value) async {
    state = state.copyWith(hapticEnabled: value);
    await StorageService.saveHapticEnabled(value);
  }
  
  Future<void> updateNotificationsEnabled(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
    await StorageService.saveNotificationsEnabled(value);
  }
  
  Future<void> updateDailyReminderTime(String? time) async {
    state = state.copyWith(dailyReminderTime: time);
    await StorageService.saveDailyReminderTime(time);
  }
  
  Future<void> updateDarkMode(bool value) async {
    state = state.copyWith(darkMode: value);
    await StorageService.saveDarkMode(value);
  }
  
  Future<void> updateIsPremium(bool value) async {
    state = state.copyWith(isPremium: value);
    await StorageService.saveIsPremium(value);
  }
}

// Theme Mode Provider
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.darkMode ? ThemeMode.dark : ThemeMode.light;
});

// Locale Provider
final localeProvider = StateProvider<Locale>((ref) {
  return const Locale('en');
});
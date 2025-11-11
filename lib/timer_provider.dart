import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models.dart';

// Selected Goal Provider for Special Timer
final selectedGoalProvider = StateProvider<Goal?>((ref) => null);

// Timer Provider
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

// Extended TimerState with Special Session flag
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
  final bool isSpecialSession;  // New field for special session

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
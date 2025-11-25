import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'space_progress_provider.dart';
import 'services.dart';
import 'models.dart';
import 'providers.dart';

// Timer Provider
final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier(ref);
});

class TimerNotifier extends StateNotifier<TimerState> {
  Timer? _timer;
  final Ref ref;
  DateTime? _sessionStartTime;
  int _accumulatedFocusSeconds = 0;

  TimerNotifier(this.ref) : super(TimerState.initial()) {
    _loadSessionCounts();
  }

  Future<void> _loadSessionCounts() async {
    final todayCount = await StorageService.getTodaySessionCount();
    state = state.copyWith(todaysSessions: todayCount);
  }

  void changeSessionType(SessionType type) {
    if (state.isRunning || state.isPaused) return;

    final settings = ref.read(settingsProvider);
    Duration duration;

    switch (type) {
      case SessionType.focus:
        duration = Duration(minutes: settings.focusDuration);
        break;
      case SessionType.shortBreak:
        duration = Duration(minutes: settings.shortBreakDuration);
        break;
      case SessionType.longBreak:
        duration = Duration(minutes: settings.longBreakDuration);
        break;
    }

    state = state.copyWith(
      targetDuration: duration,
      remaining: duration,
      progress: 0.0,
      sessionType: type,
      isSpecialSession: false,
    );
  }

  void setSpecialSession(String? goalId) {
    if (state.isRunning || state.isPaused) return;

    final selectedGoal = ref.read(selectedGoalProvider);
    if (selectedGoal != null && selectedGoal.estimatedMinutes > 0) {
      final duration = Duration(minutes: selectedGoal.estimatedMinutes);
      state = state.copyWith(
        targetDuration: duration,
        remaining: duration,
        progress: 0.0,
        isSpecialSession: true,
        sessionType: SessionType.focus,
        selectedGoalId: goalId,
      );
    } else {
      final settings = ref.read(settingsProvider);
      final duration = Duration(minutes: settings.focusDuration);
      state = state.copyWith(
        targetDuration: duration,
        remaining: duration,
        progress: 0.0,
        isSpecialSession: true,
        sessionType: SessionType.focus,
        selectedGoalId: goalId,
      );
    }
  }

  void updateFromSettings() {
    if (!state.isRunning && !state.isPaused && !state.isSpecialSession) {
      final settings = ref.read(settingsProvider);
      Duration duration;

      switch (state.sessionType) {
        case SessionType.focus:
          duration = Duration(minutes: settings.focusDuration);
          break;
        case SessionType.shortBreak:
          duration = Duration(minutes: settings.shortBreakDuration);
          break;
        case SessionType.longBreak:
          duration = Duration(minutes: settings.longBreakDuration);
          break;
      }

      state = state.copyWith(
        targetDuration: duration,
        remaining: duration,
        progress: 0.0,
      );
    }
  }

  void start() {
    _sessionStartTime = DateTime.now();
    _accumulatedFocusSeconds = 0;
    state = state.copyWith(isRunning: true, isPaused: false, isCompleted: false);
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
    _sessionStartTime = null;
    _accumulatedFocusSeconds = 0;

    state = state.copyWith(
      remaining: state.targetDuration,
      progress: 0.0,
      isRunning: false,
      isPaused: false,
      isCompleted: false,
    );
  }

  void skip() {
    _timer?.cancel();
    _completeSession();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (state.remaining.inSeconds > 0) {
        final newRemaining = Duration(seconds: state.remaining.inSeconds - 1);
        final progress = 1 - (newRemaining.inSeconds / state.targetDuration.inSeconds);

        state = state.copyWith(
          remaining: newRemaining,
          progress: progress,
        );

        // SADECE FOCUS OTURUMLARINDA available fuel'i artır
        // Total focus time ve star map % ateşlemede artacak
        if (state.sessionType == SessionType.focus) {
          _accumulatedFocusSeconds++;
          // Sadece available fuel (unspent) artacak, total focus time artmayacak
          await ref.read(spaceProgressProvider.notifier).addUnspentFuelOnly(1);
        }
      } else {
        timer.cancel();
        await _completeSession();
      }
    });
  }

  Future<void> _completeSession() async {
    _timer?.cancel();

    // Oturum tamamlandığında
    if (state.sessionType == SessionType.focus) {
      await StorageService.saveSession(
        DateTime.now(),
        state.targetDuration.inMinutes,
      );

      final newTodayCount = await StorageService.getTodaySessionCount();
      final newTotalCount = state.totalSessions + 1;

      state = state.copyWith(
        todaysSessions: newTodayCount,
        totalSessions: newTotalCount,
      );

      // Goal progress güncelle
      if (state.selectedGoalId != null) {
        final goal = StorageService.getGoal(state.selectedGoalId!);
        if (goal != null) {
          final updatedGoal = goal.copyWith(
            actualMinutes: goal.actualMinutes + state.targetDuration.inMinutes,
          );
          await StorageService.updateGoal(updatedGoal);
        }
      }
    }

    state = state.copyWith(
      isRunning: false,
      isCompleted: true,
      progress: 1.0,
    );

    _sessionStartTime = null;
    _accumulatedFocusSeconds = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
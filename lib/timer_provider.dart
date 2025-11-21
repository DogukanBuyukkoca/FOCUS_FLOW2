import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'space_progress_provider.dart';

// Timer provider that integrates with space progress
final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier(ref);
});

class TimerNotifier extends StateNotifier<TimerState> {
  Timer? _timer;
  final Ref ref;
  DateTime? _sessionStartTime;
  
  TimerNotifier(this.ref) : super(TimerState.initial());

  void start() {
    _sessionStartTime = DateTime.now();
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
    _sessionStartTime = null;
    
    final duration = Duration(minutes: 25); // Default focus duration
    state = state.copyWith(
      targetDuration: duration,
      remaining: duration,
      progress: 0.0,
      isRunning: false,
      isPaused: false,
      isCompleted: false,
    );
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
      } else {
        timer.cancel();
        
        // Calculate total focused seconds
        if (_sessionStartTime != null) {
          final focusedSeconds = DateTime.now().difference(_sessionStartTime!).inSeconds;
          
          // Add focus time to space progress
          await ref.read(spaceProgressProvider.notifier).addFocusTime(focusedSeconds);
        }
        
        state = state.copyWith(
          isRunning: false,
          isCompleted: true,
          progress: 1.0,
        );
        
        _sessionStartTime = null;
      }
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class TimerState {
  final Duration targetDuration;
  final Duration remaining;
  final bool isRunning;
  final bool isPaused;
  final bool isCompleted;
  final double progress;

  TimerState({
    required this.targetDuration,
    required this.remaining,
    required this.isRunning,
    required this.isPaused,
    required this.isCompleted,
    required this.progress,
  });

  factory TimerState.initial() {
    return TimerState(
      targetDuration: const Duration(minutes: 25),
      remaining: const Duration(minutes: 25),
      isRunning: false,
      isPaused: false,
      isCompleted: false,
      progress: 0.0,
    );
  }

  TimerState copyWith({
    Duration? targetDuration,
    Duration? remaining,
    bool? isRunning,
    bool? isPaused,
    bool? isCompleted,
    double? progress,
  }) {
    return TimerState(
      targetDuration: targetDuration ?? this.targetDuration,
      remaining: remaining ?? this.remaining,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
    );
  }
}
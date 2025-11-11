import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'models.dart';
import 'services.dart';

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier(ref);
});

class TimerNotifier extends StateNotifier<TimerState> {
  final Ref _ref;
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();
  DateTime? _sessionStartTime;
  
  TimerNotifier(this._ref) : super(TimerState.initial()) {
    _loadUserPreferences();
  }
  
  void _loadUserPreferences() async {
    final prefs = await StorageService.getUserPreferences();
    state = state.copyWith(
      targetDuration: Duration(minutes: prefs.defaultFocusMinutes),
      sessionType: SessionType.focus,
      todaysSessions: await StorageService.getTodaySessionCount(),
      currentStreak: await StorageService.getCurrentStreak(),
    );
  }
  
  void start() {
    if (state.isRunning) return;
    
    _sessionStartTime = DateTime.now();
    _stopwatch.start();
    
    // Schedule completion notification
    NotificationService.scheduleSessionComplete(state.targetDuration);
    
    // Play start sound
    AudioService.playStartSound();
    
    // Haptic feedback
    HapticFeedback.mediumImpact();
    
    state = state.copyWith(
      isRunning: true,
      isPaused: false,
      isCompleted: false,
    );
    
    _startTimer();
  }
  
  void pause() {
    if (!state.isRunning) return;
    
    _stopwatch.stop();
    _timer?.cancel();
    
    // Cancel scheduled notification
    NotificationService.cancelScheduledNotifications();
    
    // Play pause sound
    AudioService.playPauseSound();
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    state = state.copyWith(
      isRunning: false,
      isPaused: true,
    );
  }
  
  void resume() {
    if (!state.isPaused) return;
    
    _stopwatch.start();
    
    // Reschedule notification for remaining time
    NotificationService.scheduleSessionComplete(state.remaining);
    
    // Play resume sound
    AudioService.playResumeSound();
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    state = state.copyWith(
      isRunning: true,
      isPaused: false,
    );
    
    _startTimer();
  }
  
  void reset() {
    _timer?.cancel();
    _stopwatch.reset();
    _sessionStartTime = null;
    
    // Cancel any scheduled notifications
    NotificationService.cancelScheduledNotifications();
    
    // Haptic feedback
    HapticFeedback.mediumImpact();
    
    state = state.copyWith(
      isRunning: false,
      isPaused: false,
      isCompleted: false,
      remaining: state.targetDuration,
      progress: 0.0,
    );
  }
  
  void skip() {
    if (!state.isRunning) return;
    
    // Haptic feedback
    HapticFeedback.heavyImpact();
    
    _completeSession(wasSkipped: true);
  }
  
  void changeSessionType(SessionType type) {
    if (state.isRunning || state.isPaused) return;
    
    Duration targetDuration;
    switch (type) {
      case SessionType.focus:
        targetDuration = const Duration(minutes: 25);
        break;
      case SessionType.shortBreak:
        targetDuration = const Duration(minutes: 5);
        break;
      case SessionType.longBreak:
        targetDuration = const Duration(minutes: 15);
        break;
    }
    
    state = state.copyWith(
      sessionType: type,
      targetDuration: targetDuration,
      remaining: targetDuration,
      progress: 0.0,
    );
  }
  
  void _startTimer() {
    _timer?.cancel();
    
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _updateTimerState();
    });
  }
  
  void _updateTimerState() {
    if (!state.isRunning) {
      _timer?.cancel();
      return;
    }
    
    final elapsed = _stopwatch.elapsed;
    final remaining = state.targetDuration - elapsed;
    
    if (remaining <= Duration.zero) {
      _completeSession();
      return;
    }
    
    final progress = elapsed.inMilliseconds / state.targetDuration.inMilliseconds;
    
    state = state.copyWith(
      remaining: remaining,
      progress: progress.clamp(0.0, 1.0),
    );
    
    // Save checkpoint every 5 seconds
    if (elapsed.inSeconds % 5 == 0) {
      _saveCheckpoint();
    }
  }
  
  void _completeSession({bool wasSkipped = false}) {
    _timer?.cancel();
    _stopwatch.stop();
    
    if (!wasSkipped) {
      // Play completion sound
      AudioService.playCompletionSound();
      
      // Show completion notification
      NotificationService.showSessionComplete(state.sessionType);
      
      // Heavy haptic for completion
      HapticFeedback.heavyImpact();
    }
    
    // Save session to storage
    if (_sessionStartTime != null && state.sessionType == SessionType.focus) {
      StorageService.saveSession(
        startTime: _sessionStartTime!,
        endTime: DateTime.now(),
        sessionType: state.sessionType,
        wasCompleted: !wasSkipped,
      );
      
      // Update stats
      _updateStats();
    }
    
    // Reset timer
    _stopwatch.reset();
    _sessionStartTime = null;
    
    state = state.copyWith(
      isRunning: false,
      isPaused: false,
      isCompleted: true,
      remaining: Duration.zero,
      progress: 1.0,
    );
    
    // Auto-transition to next session type after a delay
    if (!wasSkipped) {
      Future.delayed(const Duration(seconds: 2), () {
        _autoTransitionToNext();
      });
    }
  }
  
  void _autoTransitionToNext() {
    final userPrefs = StorageService.getCachedPreferences();
    if (!userPrefs.autoStartNext) return;
    
    SessionType nextType;
    final completedSessions = state.todaysSessions;
    
    if (state.sessionType == SessionType.focus) {
      // After focus, take a break
      if (completedSessions % 4 == 0) {
        nextType = SessionType.longBreak;
      } else {
        nextType = SessionType.shortBreak;
      }
    } else {
      // After break, back to focus
      nextType = SessionType.focus;
    }
    
    changeSessionType(nextType);
    
    // Auto-start if enabled
    if (userPrefs.autoStartBreaks && state.sessionType != SessionType.focus) {
      Future.delayed(const Duration(seconds: 3), () {
        start();
      });
    }
  }
  
  void _updateStats() async {
    final todaysSessions = await StorageService.getTodaySessionCount();
    final currentStreak = await StorageService.getCurrentStreak();
    
    state = state.copyWith(
      todaysSessions: todaysSessions,
      currentStreak: currentStreak,
    );
  }
  
  void _saveCheckpoint() {
    if (_sessionStartTime == null) return;
    
    StorageService.saveCheckpoint(
      sessionStart: _sessionStartTime!,
      elapsed: _stopwatch.elapsed,
      sessionType: state.sessionType,
    );
  }
  
  Future<void> restoreFromCheckpoint() async {
  final Map<String, dynamic>? checkpoint = await StorageService.getLastCheckpoint();
  if (checkpoint == null) return;

  // savedAt: ISO string veya epoch ms olabilir
  final dynamic rawSavedAt = checkpoint['savedAt'];
  DateTime? savedAt;
  if (rawSavedAt is int) {
    savedAt = DateTime.fromMillisecondsSinceEpoch(rawSavedAt);
  } else if (rawSavedAt is String) {
    savedAt = DateTime.tryParse(rawSavedAt);
  }

  if (savedAt == null) {
    // Bozuk kayıt: temizle ve çık
    await StorageService.clearCheckpoint();
    return;
  }

  // elapsed: ms cinsinden int varsayıyoruz (kendi kaydetme formatına göre değiştir)
  final int? elapsedMs = (checkpoint['elapsedMs'] ?? checkpoint['elapsed']) as int?;
  if (elapsedMs == null) {
    await StorageService.clearCheckpoint();
    return;
  }

  final now = DateTime.now();
  final timeSinceCheckpoint = now.difference(savedAt);

  // Sadece 1 saatten küçükse geri yükle
  if (timeSinceCheckpoint.inHours >= 1) {
    await StorageService.clearCheckpoint();
    return;
  }

  final totalElapsed = Duration(milliseconds: elapsedMs) + timeSinceCheckpoint;
  final remaining = state.targetDuration - totalElapsed;

  if (remaining > Duration.zero) {
    final progress = (totalElapsed.inMilliseconds / state.targetDuration.inMilliseconds)
        .clamp(0.0, 1.0);

    state = state.copyWith(
      remaining: remaining,
      progress: progress,
      isPaused: true,
    );

    _stopwatch.reset();
    // Stopwatch’a doğrudan elapsed set edemeyiz; paused bırakıyoruz
    // veya kendi elapsed’ımızı state içinde takip ediyoruz.
  } else {
    // Süre bitmişse checkpoint’i temizlemek mantıklı
    await StorageService.clearCheckpoint();
  }
}

  
  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:glass_kit/glass_kit.dart';
import 'app_theme.dart';
import 'timer_provider.dart';
import 'widgets.dart';
import 'providers.dart';
import 'models.dart';

class TimerPage extends ConsumerStatefulWidget {
  const TimerPage({super.key});

  @override
  ConsumerState<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends ConsumerState<TimerPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleController = AnimationController(
      duration: AppTheme.animBase,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleStartStop() {
    HapticFeedback.lightImpact();
    final timerState = ref.read(timerProvider);
    final timerNotifier = ref.read(timerProvider.notifier);
    
    if (timerState.isRunning) {
      timerNotifier.pause();
      _scaleController.reverse();
    } else if (timerState.isPaused) {
      timerNotifier.resume();
      _scaleController.forward();
    } else {
      timerNotifier.start();
      _scaleController.forward();
    }
  }

  void _handleReset() {
    HapticFeedback.mediumImpact();
    ref.read(timerProvider.notifier).reset();
    _scaleController.reverse();
  }

  String _formatTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    
    // Responsive sizing
    final timerSize = size.width * 0.7;
    const maxTimerSize = 280.0;
    final actualTimerSize = timerSize > maxTimerSize ? maxTimerSize : timerSize;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppTheme.darkBackground,
                    AppTheme.darkSurface,
                  ]
                : [
                    AppTheme.lightBackground,
                    Colors.white,
                  ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  'Focus Flow',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    foreground: Paint()
                      ..shader = AppTheme.primaryGradient.createShader(
                        const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                      ),
                  ),
                ).animate().fadeIn(duration: AppTheme.animSlow),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.history_rounded),
                    onPressed: () {
                      // Navigate to history
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_rounded),
                    onPressed: () {
                      // Navigate to settings
                    },
                  ),
                ],
              ),
              
              // Main Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  child: Column(
                    children: [
                      // Enhanced Session Type Selector with Special button
                      EnhancedSessionTypeSelector(
                        selectedType: timerState.sessionType,
                        isSpecialSelected: timerState.isSpecialSession,
                        onTypeChanged: (type) {
                          if (!timerState.isRunning) {
                            ref.read(timerProvider.notifier).changeSessionType(type);
                          }
                        },
                        onSpecialPressed: () {
                          if (!timerState.isRunning) {
                            // Get the selected goal's ID
                            final selectedGoal = ref.read(selectedGoalProvider);
                            ref.read(timerProvider.notifier).setSpecialSession(selectedGoal?.id);
                          }
                        },
                      ).animate().fadeIn(delay: 100.ms),
                      
                      const SizedBox(height: AppTheme.spacing32),
                      
                      // Timer Circle
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow effect when running
                          if (timerState.isRunning)
                            Container(
                              width: actualTimerSize + 40,
                              height: actualTimerSize + 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryColor.withOpacity(0.3),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                            ).animate(
                              onPlay: (controller) => controller.repeat(),
                            ).scale(
                              begin: const Offset(0.95, 0.95),
                              end: const Offset(1.05, 1.05),
                              duration: 2.seconds,
                              curve: Curves.easeInOut,
                            ),
                          
                          // Glass background
                          GlassContainer(
                            width: actualTimerSize,
                            height: actualTimerSize,
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderGradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.2),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                            blur: 10,
                            borderRadius: BorderRadius.circular(actualTimerSize / 2),
                            elevation: 0,
                            shadowColor: Colors.black.withOpacity(0.1),
                          ),
                          
                          // Progress Indicator
                          CircularPercentIndicator(
                            radius: actualTimerSize / 2,
                            lineWidth: 8,
                            percent: timerState.progress,
                            backgroundColor: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.1),
                            linearGradient: AppTheme.primaryGradient,
                            circularStrokeCap: CircularStrokeCap.round,
                            animation: true,
                            animationDuration: 300,
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _formatTime(timerState.remaining),
                                  style: theme.textTheme.displayMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spacing8),
                                Text(
                                  timerState.isSpecialSession 
                                      ? 'Special Focus' 
                                      : timerState.sessionType == SessionType.focus
                                          ? 'Focus Time'
                                          : timerState.sessionType == SessionType.shortBreak
                                              ? 'Short Break'
                                              : 'Long Break',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ).animate().scale(delay: 200.ms),
                      
                      const SizedBox(height: AppTheme.spacing32),
                      
                      // Control Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Reset Button
                          if (timerState.isPaused || timerState.isCompleted)
                            _buildControlButton(
                              onPressed: _handleReset,
                              icon: Icons.refresh_rounded,
                              backgroundColor: theme.colorScheme.surface,
                              iconColor: theme.colorScheme.error,
                              size: 56,
                            ).animate().fadeIn().scale(),
                          
                          if (timerState.isPaused || timerState.isCompleted)
                            const SizedBox(width: AppTheme.spacing24),
                          
                          // Main Action Button
                          _buildMainActionButton(
                            onPressed: _handleStartStop,
                            isRunning: timerState.isRunning,
                            size: 80,
                          ).animate().fadeIn().scale(delay: 100.ms),
                          
                          if (timerState.isRunning)
                            const SizedBox(width: AppTheme.spacing24),
                          
                          // Skip Button
                          if (timerState.isRunning) _buildControlButton(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                ref.read(timerProvider.notifier).skip();
                              },
                              icon: Icons.skip_next_rounded,
                              backgroundColor: theme.colorScheme.surface,
                              iconColor: theme.colorScheme.secondary,
                              size: 56,
                            ).animate().fadeIn().scale(),
                        ],
                      ).animate().fadeIn(delay: 300.ms),
                      
                      const SizedBox(height: AppTheme.spacing32),
                      
                      // Quick Stats
                      Row(
                        children: [
                          Expanded(
                            child: QuickStatsCard(
                              title: 'Today',
                              value: '${timerState.todaysSessions}',
                              subtitle: 'sessions',
                              icon: Icons.today_rounded,
                              color: AppTheme.primaryColor,
                            ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),
                          ),
                          const SizedBox(width: AppTheme.spacing12),
                          Expanded(
                            child: QuickStatsCard(
                              title: 'Streak',
                              value: '${timerState.currentStreak}',
                              subtitle: 'days',
                              icon: Icons.local_fire_department_rounded,
                              color: AppTheme.secondaryColor,
                            ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.2),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppTheme.spacing16),
                      
                      // Motivational Quote
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // Responsive width calculation
                          final containerWidth = constraints.maxWidth - (AppTheme.spacing16 * 2);
                          
                          return Container(
                            width: containerWidth,
                            margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacing8),
                            child: GlassContainer(
                              width: containerWidth,
                              height: 120,
                              padding: const EdgeInsets.all(AppTheme.spacing12),
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryColor.withOpacity(0.1),
                                  AppTheme.secondaryColor.withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderGradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryColor.withOpacity(0.2),
                                  AppTheme.secondaryColor.withOpacity(0.2),
                                ],
                              ),
                              blur: 10,
                              borderRadius: BorderRadius.circular(AppTheme.radius16),
                              elevation: 0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.format_quote_rounded,
                                    color: AppTheme.primaryColor,
                                    size: 20,
                                  ),
                                  const SizedBox(height: AppTheme.spacing4),
                                  Flexible(
                                    child: Text(
                                      '"The secret to getting ahead is getting started."',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 13,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacing4),
                                  Text(
                                    '- Mark Twain',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 11,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainActionButton({
    required VoidCallback onPressed,
    required bool isRunning,
    required double size,
  }) {
    
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: AppTheme.animBase,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppTheme.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(
          isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required double size,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: size * 0.45,
        ),
      ),
    );
  }
}
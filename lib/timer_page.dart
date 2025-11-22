import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:permission_handler/permission_handler.dart';
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
  bool _isDeepFocusEnabled = false;

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

  Future<void> _showDNDPermissionDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radius24),
          ),
          backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: const Icon(
                    Icons.do_not_disturb_on_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacing16),
                
                // Title
                Text(
                  'Deep Focus Mode',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppTheme.spacing12),
                
                // Message
                Text(
                  'Do you want to enable Do Not Disturb for better focus?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppTheme.spacing24),
                
                // Buttons
                Row(
                  children: [
                    // Deny Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.spacing12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radius16),
                          ),
                          side: BorderSide(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        child: const Text('Don\'t Allow'),
                      ),
                    ),
                    
                    const SizedBox(width: AppTheme.spacing12),
                    
                    // Allow Button
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(AppTheme.radius16),
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spacing12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radius16),
                            ),
                          ),
                          child: const Text(
                            'Allow',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == true) {
      await _requestDNDPermission();
    } else {
      setState(() {
        _isDeepFocusEnabled = false;
      });
    }
  }

  Future<void> _requestDNDPermission() async {
    try {
      final status = await Permission.accessNotificationPolicy.request();
      
      if (status.isGranted) {
        setState(() {
          _isDeepFocusEnabled = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Deep Focus Mode enabled! 2X fuel boost active 🚀'),
              backgroundColor: AppTheme.primaryColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radius16),
              ),
            ),
          );
        }
      } else {
        setState(() {
          _isDeepFocusEnabled = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Permission denied. Deep Focus Mode disabled.'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radius16),
              ),
              action: SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: () {
                  openAppSettings();
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isDeepFocusEnabled = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radius16),
            ),
          ),
        );
      }
    }
  }

  void _showDeepFocusInfo() {
    HapticFeedback.lightImpact();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radius24),
          ),
          backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacing16),
                
                // Title
                Text(
                  'Deep Focus Boost',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppTheme.spacing12),
                
                // Info Text
                Text(
                  'When Deep Focus mode is active, every second of focused time adds 2X fuel to your space rocket!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppTheme.spacing24),
                
                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radius16),
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacing12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radius16),
                        ),
                      ),
                      child: const Text(
                        'Got it!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                title: Row(
                  children: [
                    // Deep Focus Switch
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing8,
                        vertical: AppTheme.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: _isDeepFocusEnabled
                            ? AppTheme.primaryColor.withOpacity(0.1)
                            : theme.colorScheme.surface.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(AppTheme.radius16),
                        border: Border.all(
                          color: _isDeepFocusEnabled
                              ? AppTheme.primaryColor.withOpacity(0.3)
                              : theme.colorScheme.outline.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: _isDeepFocusEnabled,
                              onChanged: (value) {
                                HapticFeedback.lightImpact();
                                if (value) {
                                  _showDNDPermissionDialog();
                                } else {
                                  setState(() {
                                    _isDeepFocusEnabled = false;
                                  });
                                }
                              },
                              activeColor: AppTheme.primaryColor,
                              activeTrackColor: AppTheme.primaryColor.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacing4),
                          GestureDetector(
                            onTap: _showDeepFocusInfo,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              child: Icon(
                                Icons.help_outline_rounded,
                                size: 18,
                                color: theme.colorScheme.onSurface.withOpacity(0.4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: AppTheme.spacing12),
                    
                    // Focus Flow Title
                    Expanded(
                      child: Text(
                        'Focus Flow',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          foreground: Paint()
                            ..shader = AppTheme.primaryGradient.createShader(
                              const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                            ),
                        ),
                      ).animate().fadeIn(duration: AppTheme.animSlow),
                    ),
                  ],
                ),
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
                          HapticFeedback.selectionClick();
                          ref.read(timerProvider.notifier).changeSessionType(type);
                        },
                        onSpecialPressed: () {
                          HapticFeedback.mediumImpact();
                          final selectedGoal = ref.read(selectedGoalProvider);
                          ref.read(timerProvider.notifier).setSpecialSession(selectedGoal?.id);
                        },
                      ).animate().fadeIn().slideY(begin: -0.1),
                      
                      const SizedBox(height: AppTheme.spacing32),
                      
                      // Timer Circle
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow
                          if (timerState.isRunning)
                            Container(
                              width: actualTimerSize + 40,
                              height: actualTimerSize + 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryColor.withOpacity(0.3),
                                    blurRadius: 60,
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
                          ),
                        ],
                      ).animate().fadeIn(delay: 300.ms),
                      
                      const SizedBox(height: AppTheme.spacing32),
                      
                      // Motivational Quote Card
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Container(
                            constraints: BoxConstraints(
                              maxWidth: constraints.maxWidth > 600 
                                  ? 500 
                                  : constraints.maxWidth - 32,
                            ),
                            padding: const EdgeInsets.all(AppTheme.spacing20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [
                                        AppTheme.darkSurface.withOpacity(0.6),
                                        AppTheme.darkSurface.withOpacity(0.3),
                                      ]
                                    : [
                                        Colors.white.withOpacity(0.8),
                                        Colors.white.withOpacity(0.4),
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(AppTheme.radius24),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.05),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.format_quote_rounded,
                                  color: AppTheme.primaryColor,
                                  size: 32,
                                ),
                                const SizedBox(height: AppTheme.spacing12),
                                Text(
                                  '"The secret of getting ahead is getting started."',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
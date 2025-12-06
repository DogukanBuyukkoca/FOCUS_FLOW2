import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;
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
  late AnimationController _twinkleController;
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

    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    _twinkleController.dispose();
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

  Future<void> _handleReset() async {
    HapticFeedback.mediumImpact();
    await ref.read(timerProvider.notifier).reset();
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

  Widget _buildSpaceBackground(Size size) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0a0e27),
            Color(0xFF1a1a2e),
            Color(0xFF16213e),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedStars(Size size) {
    return AnimatedBuilder(
      animation: _twinkleController,
      builder: (context, child) {
        return CustomPaint(
          size: size,
          painter: _BackgroundStarsPainter(
            animation: _twinkleController.value,
          ),
        );
      },
    );
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
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: const Icon(
                    Icons.nightlight_rounded,
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
                  decoration: const BoxDecoration(
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
      body: Stack(
        children: [
          // Space background
          _buildSpaceBackground(size),

          // Animated stars background
          _buildAnimatedStars(size),

          // Content
          SafeArea(
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
                    // Deep Focus Switch - Modern Design
                    AnimatedContainer(
                      duration: AppTheme.animBase,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing12,
                        vertical: AppTheme.spacing8,
                      ),
                      decoration: BoxDecoration(
                        gradient: _isDeepFocusEnabled
                            ? LinearGradient(
                                colors: [
                                  const Color(0xFF6B4BA6).withOpacity(0.2),
                                  const Color(0xFF4A3B7A).withOpacity(0.15),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: _isDeepFocusEnabled 
                            ? null 
                            : theme.colorScheme.surface.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(AppTheme.radius24),
                        boxShadow: _isDeepFocusEnabled
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF6B4BA6).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Custom Switch with Crescent Moon
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              if (!_isDeepFocusEnabled) {
                                _showDNDPermissionDialog();
                              } else {
                                setState(() {
                                  _isDeepFocusEnabled = false;
                                });
                              }
                            },
                            child: AnimatedContainer(
                              duration: AppTheme.animBase,
                              width: 52,
                              height: 28,
                              decoration: BoxDecoration(
                                gradient: _isDeepFocusEnabled
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF6B4BA6),
                                          Color(0xFF8B5FBF),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      )
                                    : LinearGradient(
                                        colors: [
                                          theme.colorScheme.outline.withOpacity(0.3),
                                          theme.colorScheme.outline.withOpacity(0.2),
                                        ],
                                      ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: _isDeepFocusEnabled
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF6B4BA6).withOpacity(0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Stack(
                                children: [
                                  // Stars background when enabled
                                  if (_isDeepFocusEnabled)
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: CustomPaint(
                                          painter: _StarsPainter(),
                                        ),
                                      ),
                                    ),
                                  // Toggle circle with crescent moon
                                  AnimatedAlign(
                                    duration: AppTheme.animBase,
                                    curve: Curves.easeInOut,
                                    alignment: _isDeepFocusEnabled
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      margin: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: AnimatedSwitcher(
                                          duration: AppTheme.animBase,
                                          transitionBuilder: (child, animation) {
                                            return RotationTransition(
                                              turns: animation,
                                              child: FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: Icon(
                                            _isDeepFocusEnabled
                                                ? Icons.nightlight_rounded
                                                : Icons.nightlight_rounded,
                                            key: ValueKey(_isDeepFocusEnabled),
                                            size: 14,
                                            color: _isDeepFocusEnabled
                                                ? const Color(0xFF6B4BA6)
                                                : Colors.grey[400],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: AppTheme.spacing8),
                          
                          // Info Icon
                          GestureDetector(
                            onTap: _showDeepFocusInfo,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: _isDeepFocusEnabled
                                    ? Colors.white.withOpacity(0.15)
                                    : theme.colorScheme.surface.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.info_outline_rounded,
                                size: 16,
                                color: _isDeepFocusEnabled
                                    ? Colors.white.withOpacity(0.9)
                                    : theme.colorScheme.onSurface.withOpacity(0.5),
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
                            ..shader = const LinearGradient(
                              colors: [
                                Color(0xFF00D4FF),
                                Color(0xFF7B2FFF),
                              ],
                            ).createShader(
                              const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                            ),
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: const Color(0xFF00D4FF).withOpacity(0.3),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: AppTheme.animSlow),
                    ),
                  ],
                ),
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
                                    color: const Color(0xFF00D4FF).withOpacity(0.4),
                                    blurRadius: 60,
                                    spreadRadius: 10,
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFF7B2FFF).withOpacity(0.3),
                                    blurRadius: 80,
                                    spreadRadius: 5,
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
                          
                          // Glass background with darker overlay for better contrast
                          Container(
                            width: actualTimerSize,
                            height: actualTimerSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF1a1a2e).withOpacity(0.8),
                                  const Color(0xFF16213e).withOpacity(0.9),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                          ),

                          // Progress Indicator
                          CircularPercentIndicator(
                            radius: actualTimerSize / 2,
                            lineWidth: 10,
                            percent: timerState.progress,
                            backgroundColor: Colors.white.withOpacity(0.15),
                            linearGradient: const LinearGradient(
                              colors: [
                                Color(0xFF00D4FF),
                                Color(0xFF7B2FFF),
                                Color(0xFFFF2E63),
                              ],
                            ),
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
                                    color: Colors.white,
                                    fontSize: 48,
                                    shadows: [
                                      Shadow(
                                        color: const Color(0xFF00D4FF).withOpacity(0.5),
                                        blurRadius: 10,
                                      ),
                                    ],
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
                                    color: const Color(0xFF00D4FF).withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
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
                                colors: [
                                  const Color(0xFF1a1a2e).withOpacity(0.7),
                                  const Color(0xFF16213e).withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(AppTheme.radius24),
                              border: Border.all(
                                color: const Color(0xFF00D4FF).withOpacity(0.2),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7B2FFF).withOpacity(0.1),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.format_quote_rounded,
                                  color: Color(0xFF00D4FF),
                                  size: 32,
                                ),
                                const SizedBox(height: AppTheme.spacing12),
                                Text(
                                  '"The secret of getting ahead is getting started."',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.9),
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
                                    color: const Color(0xFF7B2FFF).withOpacity(0.8),
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
        ],
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
          gradient: const LinearGradient(
            colors: [
              Color(0xFF00D4FF),
              Color(0xFF7B2FFF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D4FF).withOpacity(0.5),
              blurRadius: 25,
              offset: const Offset(0, 10),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: const Color(0xFF7B2FFF).withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 5),
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
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1a1a2e).withOpacity(0.8),
              const Color(0xFF16213e).withOpacity(0.9),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFFF2E63).withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF2E63).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: const Color(0xFFFF2E63),
          size: size * 0.45,
        ),
      ),
    );
  }
}

// Custom Painter for Stars Background in Toggle Switch
class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Draw small stars
    final stars = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.2),
      Offset(size.width * 0.5, size.height * 0.6),
      Offset(size.width * 0.8, size.height * 0.7),
      Offset(size.width * 0.3, size.height * 0.8),
    ];

    for (var star in stars) {
      canvas.drawCircle(star, 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Background stars painter for animated starfield
class _BackgroundStarsPainter extends CustomPainter {
  final double animation;

  _BackgroundStarsPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42);

    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final baseSize = random.nextDouble() * 2 + 0.5;

      // Twinkle effect
      final twinkle = (math.sin(animation * math.pi * 2 + i) + 1) / 2;
      final starSize = baseSize * (0.6 + twinkle * 0.4);

      paint.color = Colors.white.withOpacity(0.3 + twinkle * 0.4);
      canvas.drawCircle(Offset(x, y), starSize, paint);
    }
  }

  @override
  bool shouldRepaint(_BackgroundStarsPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
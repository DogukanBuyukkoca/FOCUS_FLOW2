import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import 'space_progress_provider.dart';
import 'timer_provider.dart';

class SpaceRocketPage extends ConsumerStatefulWidget {
  const SpaceRocketPage({super.key});

  @override
  ConsumerState<SpaceRocketPage> createState() => _SpaceRocketPageState();
}

class _SpaceRocketPageState extends ConsumerState<SpaceRocketPage>
    with TickerProviderStateMixin {
  late AnimationController _launchController;
  late AnimationController _idleAnimationController;
  late AnimationController _thrusterController;
  
  bool _isLaunching = false;
  int _animatedFuelValue = 0;

  @override
  void initState() {
    super.initState();
    
    // Launch animation controller (5 seconds)
    _launchController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    
    // Idle floating animation
    _idleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    // Thruster flicker animation
    _thrusterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _launchController.dispose();
    _idleAnimationController.dispose();
    _thrusterController.dispose();
    super.dispose();
  }

  Future<void> _handleLaunch() async {
  final spaceData = ref.read(spaceProgressProvider);
  
  if (spaceData.unspentFocusSeconds <= 0) {
    if (!mounted) return;  // ✅ MOUNTED KONTROLÜ EKLENDİ
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No fuel available! Focus to earn fuel.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  HapticFeedback.heavyImpact();
  
  if (!mounted) return;  // ✅ MOUNTED KONTROLÜ EKLENDİ
  setState(() {
    _isLaunching = true;
    _animatedFuelValue = spaceData.unspentFocusSeconds;
  });

  // Start launch animation
  _launchController.forward(from: 0);
  
  // Animate fuel countdown
  await ref.read(spaceProgressProvider.notifier).consumeFuelAnimated((remainingFuel) {
    if (mounted) {
      setState(() {
        _animatedFuelValue = remainingFuel;
      });
    }
  });
  
  // ✅ KRİTİK: MOUNTED KONTROLÜ EKLENDİ (HATA BURADAYDı!)
  if (!mounted) return;
  
  setState(() {
    _isLaunching = false;
  });
  
  _launchController.reset();
  
  HapticFeedback.mediumImpact();
  
  // Show completion message
  if (mounted) {
    final focusSeconds = spaceData.unspentFocusSeconds;
    final hours = focusSeconds ~/ 3600;
    final minutes = (focusSeconds % 3600) ~/ 60;
    
    String message = 'Journey complete! Used ';
    if (hours > 0) {
      message += '${hours}h ';
    }
    if (minutes > 0 || hours == 0) {
      message += '${minutes}m ';
    }
    message += 'of focus time!';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final spaceData = ref.watch(spaceProgressProvider);
    final isFocusing = ref.watch(timerProvider).isRunning;
    
    // Use animated values during launch, otherwise use actual values
    final displayFuel = _isLaunching ? _animatedFuelValue : spaceData.unspentFocusSeconds;
    
    // Responsive sizing
    final isSmallScreen = size.width < 360;
    final rocketSize = size.width * (isSmallScreen ? 0.25 : 0.3);
    final buttonSize = isSmallScreen ? 60.0 : 72.0;

    return Scaffold(
      body: Stack(
        children: [
          // Background - Space
          _buildSpaceBackground(size),
          
          // Parallax layers
          _buildParallaxLayers(size, _isLaunching),
          
          // Rocket
          Center(
            child: _buildRocket(rocketSize, isFocusing || _isLaunching),
          ),
          
          // Top info bar - Responsive (SADECE 2 KUTU)
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInfoCard(
                    'Total Focus Time',
                    _formatDuration(spaceData.totalFocusSeconds),
                    Icons.timer_rounded,
                    theme,
                    isSmallScreen,
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  _buildInfoCard(
                    'Current Rank',
                    spaceData.currentRank,
                    Icons.military_tech_rounded,
                    theme,
                    isSmallScreen,
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom fuel display and launch button
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Fuel display with animation
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: size.width - (isSmallScreen ? 32 : 48),
                      ),
                      child: AnimatedBuilder(
                        animation: _launchController,
                        builder: (context, child) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 16 : 24,
                              vertical: isSmallScreen ? 12 : 16,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_fire_department_rounded,
                                  color: theme.colorScheme.primary,
                                  size: isSmallScreen ? 34 : 50,
                                ),
                                SizedBox(width: isSmallScreen ? 12 : 16),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          'Available Fuel',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                                            fontSize: isSmallScreen ? 12 : 14,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          _formatDuration(displayFuel),
                                          style: theme.textTheme.headlineSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                            fontSize: isSmallScreen ? 20 : 24,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    
                    SizedBox(height: isSmallScreen ? 16 : 24),
                    
                    // Launch button
                    SizedBox(
                      width: buttonSize,
                      height: buttonSize,
                      child: FloatingActionButton(
                        onPressed: _isLaunching ? null : _handleLaunch,
                        backgroundColor: _isLaunching
                            ? theme.colorScheme.surface
                            : theme.colorScheme.primary,
                        elevation: _isLaunching ? 0 : 8,
                        child: _isLaunching
                            ? SizedBox(
                                width: buttonSize * 0.5,
                                height: buttonSize * 0.5,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.primary,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.rocket_launch_rounded,
                                size: buttonSize * 0.5,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpaceBackground(Size size) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Color(0xFF1a1a2e),
            Color(0xFF0f0f1e),
            Color(0xFF050510),
          ],
        ),
      ),
    );
  }

  Widget _buildParallaxLayers(Size size, bool isLaunching) {
    return Stack(
      children: [
        // Layer 1 - Far stars
        AnimatedBuilder(
          animation: _launchController,
          builder: (context, child) {
            final offset = isLaunching ? _launchController.value * size.height * 0.3 : 0.0;
            return Transform.translate(
              offset: Offset(0, offset),
              child: _buildStarLayer(size, 50, 1.0, 0.3),
            );
          },
        ),
        
        // Layer 2 - Mid stars
        AnimatedBuilder(
          animation: _launchController,
          builder: (context, child) {
            final offset = isLaunching ? _launchController.value * size.height * 0.6 : 0.0;
            return Transform.translate(
              offset: Offset(0, offset),
              child: _buildStarLayer(size, 30, 2.0, 0.6),
            );
          },
        ),
        
        // Layer 3 - Near stars
        AnimatedBuilder(
          animation: _launchController,
          builder: (context, child) {
            final offset = isLaunching ? _launchController.value * size.height * 1.0 : 0.0;
            return Transform.translate(
              offset: Offset(0, offset),
              child: _buildStarLayer(size, 20, 3.0, 0.9),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStarLayer(Size size, int count, double maxSize, double opacity) {
    return CustomPaint(
      size: size,
      painter: _StarPainter(
        count: count,
        maxSize: maxSize,
        opacity: opacity,
        seed: count * 100,
      ),
    );
  }

  Widget _buildRocket(double size, bool isActive) {
    return AnimatedBuilder(
      animation: _idleAnimationController,
      builder: (context, child) {
        final float = math.sin(_idleAnimationController.value * math.pi) * 8;
        
        return Transform.translate(
          offset: Offset(0, float),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gradient rocket icon - cyan to purple
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF00E5FF), // Parlak Cyan - Burun
                      Color(0xFF00B0FF), // Parlak Mavi - Gövde
                      Color(0xFF7C4DFF), // Parlak Mor - Kuyruk
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ).createShader(bounds);
                },
                child: Icon(
                  Icons.rocket_rounded,
                  size: size * 1.8, // 3x of the original 0.6 (0.6 * 3 = 1.8)
                  color: Colors.white, // Base color for shader mask
                ),
              ),
              
              // Thrusters (active when focusing or launching)
              if (isActive)
                AnimatedBuilder(
                  animation: _thrusterController,
                  builder: (context, child) {
                    final flicker = 0.7 + (_thrusterController.value * 0.3);
                    return Opacity(
                      opacity: flicker,
                      child: Container(
                        width: size * 0.6,
                        height: size * 0.8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.orange.withOpacity(0.9),
                              Colors.deepOrange.withOpacity(0.7),
                              Colors.red.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    ThemeData theme,
    bool isSmall,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width - (isSmall ? 24 : 32),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 12 : 16,
          vertical: isSmall ? 8 : 12,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isSmall ? 18 : 22,
              color: theme.colorScheme.primary,
            ),
            SizedBox(width: isSmall ? 8 : 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: isSmall ? 10 : 12,
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmall ? 14 : 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }
}

// Star painter for parallax effect
class _StarPainter extends CustomPainter {
  final int count;
  final double maxSize;
  final double opacity;
  final int seed;

  _StarPainter({
    required this.count,
    required this.maxSize,
    required this.opacity,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final random = math.Random(seed);
    
    for (int i = 0; i < count; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = random.nextDouble() * maxSize + 0.5;
      
      canvas.drawCircle(Offset(x, y), starSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
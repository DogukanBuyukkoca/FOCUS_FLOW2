import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import 'space_progress_provider.dart';
import 'timer_provider.dart';
import 'models.dart'; // SessionType için

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
  late AnimationController _fuelCountdownController;
  
  bool _isLaunching = false;
  int _animatedFuelValue = 0;
  double _animatedDistanceValue = 0.0;

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
    
    // Fuel countdown animation controller
    _fuelCountdownController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void dispose() {
    _launchController.dispose();
    _idleAnimationController.dispose();
    _thrusterController.dispose();
    _fuelCountdownController.dispose();
    super.dispose();
  }

  Future<void> _handleLaunch() async {
    final spaceData = ref.read(spaceProgressProvider);
    
    if (spaceData.unspentFocusSeconds <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No fuel available! Focus to earn fuel.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.heavyImpact();
    
    setState(() {
      _isLaunching = true;
      _animatedFuelValue = spaceData.unspentFocusSeconds;
      _animatedDistanceValue = spaceData.totalDistanceLightYears;
    });

    // Calculate target distance
    final hoursToConsume = spaceData.unspentFocusSeconds / 3600.0;
    final distanceToAdd = hoursToConsume * 0.1;
    final targetDistance = spaceData.totalDistanceLightYears + distanceToAdd;

    // Start launch animation
    _launchController.forward(from: 0);
    
    // Animate fuel countdown and distance increase
    await ref.read(spaceProgressProvider.notifier).consumeFuelAnimated((remainingFuel) {
      if (mounted) {
        setState(() {
          _animatedFuelValue = remainingFuel;
          // Distance artışını da animasyonla göster
          double progress = 1 - (remainingFuel / spaceData.unspentFocusSeconds);
          _animatedDistanceValue = spaceData.totalDistanceLightYears + (distanceToAdd * progress);
        });
      }
    });
    
    setState(() {
      _isLaunching = false;
    });
    
    _launchController.reset();
    
    HapticFeedback.mediumImpact();
    
    // Show completion message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Journey complete! Traveled ${distanceToAdd.toStringAsFixed(2)} light years!'),
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
    final displayDistance = _isLaunching ? _animatedDistanceValue : spaceData.totalDistanceLightYears;
    
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
          
          // Top info bar - Responsive
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
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  AnimatedBuilder(
                    animation: _launchController,
                    builder: (context, child) {
                      return _buildInfoCard(
                        'Distance Traveled',
                        '${displayDistance.toStringAsFixed(2)} ly',
                        Icons.flight_rounded,
                        theme,
                        isSmallScreen,
                      );
                    },
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
                              color: theme.colorScheme.surface.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Column(
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
                                SizedBox(height: isSmallScreen ? 4 : 8),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    _formatDuration(displayFuel),
                                    style: theme.textTheme.headlineLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: _isLaunching 
                                          ? theme.colorScheme.secondary
                                          : theme.colorScheme.primary,
                                      fontSize: isSmallScreen ? 28 : 36,
                                    ),
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
            final offset = isLaunching ? _launchController.value * size.height * 0.9 : 0.0;
            return Transform.translate(
              offset: Offset(0, offset),
              child: _buildStarLayer(size, 20, 3.0, 1.0),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStarLayer(Size size, int count, double maxSize, double opacity) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: CustomPaint(
        painter: _StarPainter(
          count: count,
          maxSize: maxSize,
          opacity: opacity,
          seed: count,
        ),
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
              // Just the white rocket icon, 3x larger than before
              Icon(
                Icons.rocket_rounded,
                size: size * 1.8, // 3x of the original 0.6 (0.6 * 3 = 1.8)
                color: Colors.white,
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
    return Container(
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: isSmall ? 10 : 12,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isSmall ? 14 : 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
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
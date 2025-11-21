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
    });

    // Start launch animation
    await _launchController.forward(from: 0);
    
    // Consume fuel and update distance
    await ref.read(spaceProgressProvider.notifier).consumeFuel();
    
    setState(() {
      _isLaunching = false;
    });
    
    _launchController.reset();
    
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final spaceData = ref.watch(spaceProgressProvider);
    final isFocusing = ref.watch(timerProvider).isRunning;
    
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
          _buildParallaxLayers(size),
          
          // Rocket
          Center(
            child: _buildRocket(rocketSize, isFocusing),
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
                  _buildInfoCard(
                    'Distance Traveled',
                    '${spaceData.totalDistanceLightYears.toStringAsFixed(2)} ly',
                    Icons.flight_rounded,
                    theme,
                    isSmallScreen,
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom fuel display and launch button - Responsive with safe overflow
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Fuel display with constrained width
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: size.width - (isSmallScreen ? 32 : 48),
                      ),
                      child: Container(
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
                                _formatDuration(spaceData.unspentFocusSeconds),
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                  fontSize: isSmallScreen ? 28 : 36,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 24),
                    
                    // Launch button
                    AnimatedBuilder(
                      animation: _launchController,
                      builder: (context, child) {
                        final scale = 1.0 + (_launchController.value * 0.2);
                        return Transform.scale(
                          scale: scale,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isLaunching ? null : _handleLaunch,
                              borderRadius: BorderRadius.circular(buttonSize / 2),
                              child: Container(
                                width: buttonSize,
                                height: buttonSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: spaceData.unspentFocusSeconds > 0
                                        ? [
                                            theme.colorScheme.primary,
                                            theme.colorScheme.secondary,
                                          ]
                                        : [
                                            Colors.grey.shade400,
                                            Colors.grey.shade600,
                                          ],
                                  ),
                                  boxShadow: [
                                    if (spaceData.unspentFocusSeconds > 0)
                                      BoxShadow(
                                        color: theme.colorScheme.primary.withOpacity(0.5),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                  ],
                                ),
                                child: Icon(
                                  _isLaunching
                                      ? Icons.rocket_launch_rounded
                                      : Icons.flight_takeoff_rounded,
                                  size: buttonSize * 0.45,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: isSmallScreen ? 4 : 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'LAUNCH',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontSize: isSmallScreen ? 12 : 14,
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
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0E27),
            Color(0xFF1A1F3A),
            Color(0xFF2D1B4E),
          ],
        ),
      ),
    );
  }

  Widget _buildParallaxLayers(Size size) {
    return AnimatedBuilder(
      animation: Listenable.merge([_launchController, _idleAnimationController]),
      builder: (context, child) {
        final launchOffset = _launchController.value * size.height * 2;
        final idleOffset = math.sin(_idleAnimationController.value * math.pi) * 10;
        
        return Stack(
          children: [
            // Layer 1 - Far stars
            _buildStarLayer(
              size,
              count: 50,
              speed: 0.3,
              launchOffset: launchOffset,
              idleOffset: idleOffset,
              minSize: 1,
              maxSize: 2,
            ),
            
            // Layer 2 - Mid stars
            _buildStarLayer(
              size,
              count: 30,
              speed: 0.6,
              launchOffset: launchOffset,
              idleOffset: idleOffset,
              minSize: 2,
              maxSize: 3,
            ),
            
            // Layer 3 - Near stars
            _buildStarLayer(
              size,
              count: 20,
              speed: 1.0,
              launchOffset: launchOffset,
              idleOffset: idleOffset,
              minSize: 3,
              maxSize: 4,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStarLayer(
    Size size, {
    required int count,
    required double speed,
    required double launchOffset,
    required double idleOffset,
    required double minSize,
    required double maxSize,
  }) {
    final random = math.Random(count);
    return Stack(
      children: List.generate(count, (index) {
        final x = random.nextDouble() * size.width;
        final baseY = random.nextDouble() * size.height;
        final y = baseY + (launchOffset * speed) + idleOffset;
        final starSize = minSize + random.nextDouble() * (maxSize - minSize);
        final opacity = 0.3 + random.nextDouble() * 0.7;
        
        // Wrap stars around when they go off screen
        final wrappedY = y % (size.height + 100) - 50;
        
        return Positioned(
          left: x,
          top: wrappedY,
          child: Container(
            width: starSize,
            height: starSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(opacity),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(opacity * 0.5),
                  blurRadius: starSize * 2,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRocket(double size, bool isFocusing) {
    return AnimatedBuilder(
      animation: _idleAnimationController,
      builder: (context, child) {
        final wobble = math.sin(_idleAnimationController.value * math.pi * 2) * 5;
        return Transform.translate(
          offset: Offset(wobble, math.sin(_idleAnimationController.value * math.pi) * 10),
          child: Transform.rotate(
            angle: wobble * 0.01,
            child: SizedBox(
              width: size,
              height: size * 1.5,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Thrusters (bottom)
                  if (isFocusing || _isLaunching)
                    Positioned(
                      bottom: -size * 0.2,
                      child: _buildThrusters(size * 0.6),
                    ),
                  
                  // Rocket body
                  CustomPaint(
                    size: Size(size, size * 1.5),
                    painter: RocketPainter(
                      isActive: isFocusing,
                    ),
                  ),
                  
                  // Debris particles when not focusing
                  if (!isFocusing && !_isLaunching)
                    ..._buildDebrisParticles(size),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThrusters(double width) {
    return AnimatedBuilder(
      animation: _thrusterController,
      builder: (context, child) {
        final intensity = 0.8 + (_thrusterController.value * 0.2);
        final scale = 1.0 + (_launchController.value * 2);
        
        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: width,
            height: width * 1.5,
            child: CustomPaint(
              painter: ThrusterPainter(intensity: intensity),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildDebrisParticles(double rocketSize) {
    final random = math.Random(42);
    return List.generate(5, (index) {
      final angle = (index / 5) * 2 * math.pi;
      final distance = rocketSize * 0.8 + (random.nextDouble() * rocketSize * 0.4);
      final x = math.cos(angle) * distance;
      final y = math.sin(angle) * distance;
      final particleSize = 4.0 + random.nextDouble() * 6;
      
      return Positioned(
        left: rocketSize / 2 + x,
        top: rocketSize * 0.75 + y,
        child: AnimatedBuilder(
          animation: _idleAnimationController,
          builder: (context, child) {
            final float = math.sin(
              (_idleAnimationController.value + index * 0.2) * math.pi * 2
            ) * 15;
            
            return Transform.translate(
              offset: Offset(0, float),
              child: Container(
                width: particleSize,
                height: particleSize,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
    bool isSmallScreen,
  ) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: isSmallScreen ? 180 : 220,
      ),
      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: isSmallScreen ? 18 : 20,
          ),
          SizedBox(width: isSmallScreen ? 6 : 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: isSmallScreen ? 10 : 11,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
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

// Custom Painter for Rocket
class RocketPainter extends CustomPainter {
  final bool isActive;

  RocketPainter({required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Main body - gradient
    final bodyRect = Rect.fromLTWH(
      size.width * 0.3,
      size.height * 0.2,
      size.width * 0.4,
      size.height * 0.6,
    );
    
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isActive
          ? [Colors.blue.shade300, Colors.blue.shade700]
          : [Colors.grey.shade400, Colors.grey.shade700],
    ).createShader(bodyRect);
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(10)),
      paint,
    );

    // Nose cone
    paint.shader = null;
    paint.color = isActive ? Colors.red.shade400 : Colors.grey.shade600;
    
    final nosePath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.2)
      ..lineTo(size.width * 0.5, size.height * 0.05)
      ..lineTo(size.width * 0.7, size.height * 0.2)
      ..close();
    
    canvas.drawPath(nosePath, paint);

    // Windows
    paint.color = isActive ? Colors.cyan.shade300 : Colors.grey.shade500;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.35),
      size.width * 0.08,
      paint,
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.08,
      paint,
    );

    // Fins
    paint.color = isActive ? Colors.red.shade600 : Colors.grey.shade700;
    
    final leftFin = Path()
      ..moveTo(size.width * 0.3, size.height * 0.7)
      ..lineTo(size.width * 0.1, size.height * 0.85)
      ..lineTo(size.width * 0.3, size.height * 0.8)
      ..close();
    
    canvas.drawPath(leftFin, paint);
    
    final rightFin = Path()
      ..moveTo(size.width * 0.7, size.height * 0.7)
      ..lineTo(size.width * 0.9, size.height * 0.85)
      ..lineTo(size.width * 0.7, size.height * 0.8)
      ..close();
    
    canvas.drawPath(rightFin, paint);
  }

  @override
  bool shouldRepaint(covariant RocketPainter oldDelegate) {
    return oldDelegate.isActive != isActive;
  }
}

// Custom Painter for Thrusters
class ThrusterPainter extends CustomPainter {
  final double intensity;

  ThrusterPainter({required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Main flame
    final flameGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white,
        Colors.yellow.shade400,
        Colors.orange.shade600,
        Colors.red.shade700,
      ],
    );

    paint.shader = flameGradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );

    final flamePath = Path()
      ..moveTo(size.width * 0.35, 0)
      ..quadraticBezierTo(
        size.width * 0.2,
        size.height * 0.3 * intensity,
        size.width * 0.3,
        size.height * 0.6 * intensity,
      )
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.8 * intensity,
        size.width * 0.5,
        size.height * intensity,
      )
      ..quadraticBezierTo(
        size.width * 0.6,
        size.height * 0.8 * intensity,
        size.width * 0.7,
        size.height * 0.6 * intensity,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.3 * intensity,
        size.width * 0.65,
        0,
      )
      ..close();

    canvas.drawPath(flamePath, paint);
  }

  @override
  bool shouldRepaint(covariant ThrusterPainter oldDelegate) {
    return oldDelegate.intensity != intensity;
  }
}
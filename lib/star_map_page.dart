import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import 'space_progress_provider.dart';

class StarMapPage extends ConsumerStatefulWidget {
  const StarMapPage({super.key});

  @override
  ConsumerState<StarMapPage> createState() => _StarMapPageState();
}

class _StarMapPageState extends ConsumerState<StarMapPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _twinkleController;
  
  @override
  void initState() {
    super.initState();
    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _twinkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final spaceData = ref.watch(spaceProgressProvider);
    
    final isSmallScreen = size.width < 360;

    return Scaffold(
      body: Stack(
        children: [
          // Space background
          _buildSpaceBackground(size),
          
          // Animated stars background
          _buildAnimatedStars(size),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
                  child: Column(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Star Map',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: isSmallScreen ? 24 : 28,
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 12),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Your Journey Through the Cosmos',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: isSmallScreen ? 13 : 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Progress card
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16.0 : 20.0,
                  ),
                  child: _buildProgressCard(theme, spaceData, isSmallScreen),
                ),
                
                SizedBox(height: isSmallScreen ? 16 : 20),
                
                // Star systems list
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16.0 : 20.0,
                      vertical: isSmallScreen ? 8.0 : 12.0,
                    ),
                    itemCount: starSystems.length,
                    itemBuilder: (context, index) {
                      return _buildStarSystemItem(
                        starSystems[index],
                        index,
                        theme,
                        spaceData,
                        isSmallScreen,
                      );
                    },
                  ),
                ),
              ],
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

  Widget _buildProgressCard(ThemeData theme, SpaceProgressData spaceData, bool isSmallScreen) {
    final progress = ref.read(spaceProgressProvider.notifier).getProgressToNextStar();
    final currentStar = starSystems[spaceData.currentStarIndex];
    final nextStar = spaceData.currentStarIndex < starSystems.length - 1
        ? starSystems[spaceData.currentStarIndex + 1]
        : null;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Current Location',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: isSmallScreen ? 10 : 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        currentStar.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 16 : 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: theme.colorScheme.primary,
                size: isSmallScreen ? 20 : 24,
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Next Destination',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: isSmallScreen ? 10 : 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        nextStar?.name ?? 'Journey\'s End',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 13 : 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 10 : 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: isSmallScreen ? 6 : 8,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${(progress * 100).toStringAsFixed(1)}% to next star',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontSize: isSmallScreen ? 10 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarSystemItem(
    StarSystem star,
    int index,
    ThemeData theme,
    SpaceProgressData spaceData,
    bool isSmallScreen,
  ) {
    final isUnlocked = spaceData.unlockedStars.contains(star.name);
    final isCurrent = spaceData.currentStarIndex == index;
    final isNext = spaceData.currentStarIndex + 1 == index;
    
    // Bir önceki yıldızdan bu yıldıza kadar gerekli süre
    final timeFromPrevious = index > 0
        ? star.focusSecondsRequired - starSystems[index - 1].focusSecondsRequired
        : star.focusSecondsRequired;

    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 12.0 : 16.0),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _showStarDetails(star, isUnlocked, timeFromPrevious, theme);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
          decoration: BoxDecoration(
            color: isCurrent
                ? theme.colorScheme.primary.withOpacity(0.15)
                : theme.colorScheme.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrent
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.3),
              width: isCurrent ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Star icon with animation
              Container(
                width: isSmallScreen ? 44 : 48,
                height: isSmallScreen ? 44 : 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnlocked
                      ? theme.colorScheme.primary.withOpacity(0.2)
                      : theme.colorScheme.surfaceContainerHighest,
                ),
                child: Center(
                  child: Icon(
                    isUnlocked ? Icons.star_rounded : Icons.star_border_rounded,
                    color: isUnlocked
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.4),
                    size: isSmallScreen ? 24 : 28,
                  ),
                ),
              ),
              SizedBox(width: isSmallScreen ? 12 : 16),
              
              // Star info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              star.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                          ),
                        ),
                        if (isCurrent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Current',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 9 : 10,
                              ),
                            ),
                          ),
                        ],
                        if (isNext && !isCurrent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Next',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 9 : 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        star.spectralType,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: isSmallScreen ? 11 : 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Focus time required
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _formatDuration(timeFromPrevious),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isUnlocked
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      index > 0 ? 'from previous' : 'start',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontSize: isSmallScreen ? 9 : 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStarDetails(StarSystem star, bool isUnlocked, int timeFromPrevious, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final size = MediaQuery.of(context).size;
        final isSmallScreen = size.width < 360;
        
        return Container(
          margin: EdgeInsets.all(isSmallScreen ? 12 : 16),
          padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    isUnlocked ? Icons.star_rounded : Icons.star_border_rounded,
                    color: theme.colorScheme.primary,
                    size: isSmallScreen ? 32 : 40,
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 16),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        star.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 20 : 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              
              _buildDetailRow(
                'Spectral Type',
                star.spectralType,
                Icons.wb_sunny_rounded,
                theme,
                isSmallScreen,
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              
              _buildDetailRow(
                'Focus Time Required',
                _formatDuration(timeFromPrevious),
                Icons.timer_rounded,
                theme,
                isSmallScreen,
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              
              _buildDetailRow(
                'Total Time to Reach',
                _formatDuration(star.focusSecondsRequired),
                Icons.flight_rounded,
                theme,
                isSmallScreen,
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  star.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: isSmallScreen ? 13 : 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: isSmallScreen ? 16 : 20),
              
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, ThemeData theme, bool isSmall) {
    return Row(
      children: [
        Icon(
          icon,
          size: isSmall ? 18 : 20,
          color: theme.colorScheme.primary,
        ),
        SizedBox(width: isSmall ? 8 : 12),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: isSmall ? 12 : 14,
              ),
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isSmall ? 13 : 15,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }
}

// Background stars painter
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import 'space_progress_provider.dart';

class StarMapPage extends ConsumerStatefulWidget {
  const StarMapPage({super.key});

  @override
  ConsumerState<StarMapPage> createState() => _StarMapPageState();
}

class _StarMapPageState extends ConsumerState<StarMapPage> {
  final ScrollController _scrollController = ScrollController();
  StarSystem? _selectedStar;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final spaceData = ref.watch(spaceProgressProvider);
    final isSmallScreen = size.width < 360;

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Star Map',
            style: TextStyle(fontSize: isSmallScreen ? 18 : 20),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: isSmallScreen ? 8 : 16),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 12,
                  vertical: isSmallScreen ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${spaceData.totalDistanceLightYears.toStringAsFixed(2)} ly',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 11 : 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              _buildProgressIndicator(theme, spaceData, isSmallScreen),
              
              // Star map
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
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
      ),
    );
  }

  Widget _buildProgressIndicator(
    ThemeData theme,
    SpaceProgressData spaceData,
    bool isSmallScreen,
  ) {
    final currentStar = ref.read(spaceProgressProvider.notifier).getCurrentStar();
    final nextStar = ref.read(spaceProgressProvider.notifier).getNextStar();
    final progress = ref.read(spaceProgressProvider.notifier).getProgressToNextStar();

    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 12 : 16),
      padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 13 : 16,
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
    
    final distanceFromPrevious = index > 0
        ? star.distanceFromEarth - starSystems[index - 1].distanceFromEarth
        : 0.0;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStar = _selectedStar == star ? null : star;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: isSmallScreen ? 20 : 32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side - connection line and icon
            SizedBox(
              width: isSmallScreen ? 50 : 60,
              child: Column(
                children: [
                  // Connection line from previous
                  if (index > 0)
                    Container(
                      width: 2,
                      height: isSmallScreen ? 30 : 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            isUnlocked
                                ? theme.colorScheme.primary
                                : Colors.grey.shade700,
                            isUnlocked || isNext
                                ? theme.colorScheme.primary.withOpacity(0.5)
                                : Colors.grey.shade800,
                          ],
                        ),
                      ),
                    ),
                  
                  // Star icon
                  Container(
                    width: isSmallScreen ? 44 : 56,
                    height: isSmallScreen ? 44 : 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isUnlocked
                            ? [
                                theme.colorScheme.primary,
                                theme.colorScheme.secondary,
                              ]
                            : [
                                Colors.grey.shade700,
                                Colors.grey.shade900,
                              ],
                      ),
                      boxShadow: [
                        if (isCurrent)
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.6),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                      ],
                      border: Border.all(
                        color: isCurrent
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      isUnlocked
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.white,
                      size: isSmallScreen ? 22 : 28,
                    ),
                  ),
                  
                  // Connection line to next
                  if (index < starSystems.length - 1)
                    Container(
                      width: 2,
                      height: isSmallScreen ? 30 : 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            isUnlocked
                                ? theme.colorScheme.primary.withOpacity(0.5)
                                : Colors.grey.shade800,
                            isNext
                                ? theme.colorScheme.primary.withOpacity(0.3)
                                : Colors.grey.shade900,
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Right side - star info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? theme.colorScheme.primary.withOpacity(0.15)
                          : theme.colorScheme.surface.withOpacity(
                              isUnlocked ? 0.8 : 0.4,
                            ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrent
                            ? theme.colorScheme.primary
                            : (isUnlocked
                                ? theme.colorScheme.primary.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.2)),
                        width: isCurrent ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Star name and badges
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                star.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isUnlocked
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurface.withOpacity(0.5),
                                  fontSize: isSmallScreen ? 15 : 18,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isCurrent)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 6 : 8,
                                  vertical: isSmallScreen ? 2 : 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'CURRENT',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isSmallScreen ? 9 : 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            if (isNext && !isCurrent)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 6 : 8,
                                  vertical: isSmallScreen ? 2 : 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'NEXT',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isSmallScreen ? 9 : 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? 6 : 8),
                        
                        // Spectral type
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Spectral Type: ${star.spectralType}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                isUnlocked ? 0.7 : 0.4,
                              ),
                              fontSize: isSmallScreen ? 11 : 12,
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 4 : 6),
                        
                        // Distance info with proper wrapping
                        Wrap(
                          spacing: isSmallScreen ? 8 : 12,
                          runSpacing: 4,
                          children: [
                            _buildInfoChip(
                              '${star.distanceFromEarth.toStringAsFixed(2)} ly',
                              Icons.straighten_rounded,
                              theme,
                              isUnlocked,
                              isSmallScreen,
                            ),
                            if (index > 0)
                              _buildInfoChip(
                                '+${distanceFromPrevious.toStringAsFixed(2)} ly',
                                Icons.add_rounded,
                                theme,
                                isUnlocked,
                                isSmallScreen,
                              ),
                            _buildInfoChip(
                              '${star.focusHoursRequired}h',
                              Icons.timer_rounded,
                              theme,
                              isUnlocked,
                              isSmallScreen,
                            ),
                          ],
                        ),
                        
                        // Description - expanded view
                        if (_selectedStar == star) ...[
                          SizedBox(height: isSmallScreen ? 10 : 12),
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              star.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.8),
                                fontSize: isSmallScreen ? 12 : 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ],
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

  Widget _buildInfoChip(
    String label,
    IconData icon,
    ThemeData theme,
    bool isUnlocked,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6 : 8,
        vertical: isSmallScreen ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(isUnlocked ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isSmallScreen ? 12 : 14,
            color: isUnlocked
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          SizedBox(width: isSmallScreen ? 3 : 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isUnlocked
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withOpacity(0.4),
              fontSize: isSmallScreen ? 10 : 11,
            ),
          ),
        ],
      ),
    );
  }
}
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'app_theme.dart';
import 'edit_goaL_sheet.dart';
import 'providers.dart';
import 'models.dart';
import 'widgets.dart';

class GoalsPage extends ConsumerStatefulWidget {
  const GoalsPage({super.key});

  @override
  ConsumerState<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends ConsumerState<GoalsPage> with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  GoalFilter _selectedFilter = GoalFilter.all;
  late AnimationController _starAnimationController;
  late AnimationController _glowAnimationController;
  
  @override
  void initState() {
    super.initState();
    _starAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    
    _glowAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _starAnimationController.dispose();
    _glowAnimationController.dispose();
    super.dispose();
  }
  
  void _showAddGoalSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddGoalSheet(),
    );
  }

  List<Goal> _getFilteredGoals(List<Goal> allGoals) {
    switch (_selectedFilter) {
      case GoalFilter.all:
        return allGoals;
      case GoalFilter.today:
        return allGoals.where((g) => g.isToday).toList();
      case GoalFilter.completed:
        return allGoals.where((g) => g.isCompleted).toList();
      case GoalFilter.thisWeek:
        return allGoals.where((g) => g.isThisWeek).toList();
      case GoalFilter.overdue:
        return allGoals.where((g) => g.isOverdue).toList();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final allGoals = ref.watch(goalsProvider);
    
    // Filtreleme mantığını burada uyguluyoruz
    final goals = _getFilteredGoals(allGoals);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1a1a2e),
                    const Color(0xFF16213e),
                  ]
                : [
                    Colors.grey[50]!,
                    Colors.grey[100]!,
                  ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 85,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Goals',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                ),
                
              ),
              
              // Premium Button Section - NEW!
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing16,
                    vertical: AppTheme.spacing12,
                  ),
                  child: _buildPremiumButton(isDark),
                ),
              ),
              
              // Filter Chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing16,
                    vertical: AppTheme.spacing12,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: 'All',
                          isSelected: _selectedFilter == GoalFilter.all,
                          onTap: () {
                            setState(() => _selectedFilter = GoalFilter.all);
                            HapticFeedback.lightImpact();
                          },
                        ),
                        const SizedBox(width: AppTheme.spacing8),
                        _buildFilterChip(
                          label: 'Today',
                          isSelected: _selectedFilter == GoalFilter.today,
                          onTap: () {
                            setState(() => _selectedFilter = GoalFilter.today);
                            HapticFeedback.lightImpact();
                          },
                        ),
                        const SizedBox(width: AppTheme.spacing8),
                        _buildFilterChip(
                          label: 'Completed',
                          isSelected: _selectedFilter == GoalFilter.completed,
                          onTap: () {
                            setState(() => _selectedFilter = GoalFilter.completed);
                            HapticFeedback.lightImpact();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Progress Stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing16,
                    vertical: AppTheme.spacing12,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GlassContainer(
                        width: constraints.maxWidth,
                        height: 100,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.surface.withOpacity(0.7),
                            theme.colorScheme.surface.withOpacity(0.5),
                          ],
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
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildProgressStat(
                                title: 'Today\'s Progress',
                                value: '${_getTodayProgress(allGoals)}%',
                                icon: Icons.today_rounded,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: theme.colorScheme.onSurface.withOpacity(0.1),
                            ),
                            Expanded(
                              child: _buildProgressStat(
                                title: 'Week Completion',
                                value: '${_getWeekCompletion(allGoals)}%',
                                icon: Icons.calendar_view_week_rounded,
                                color: AppTheme.secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Goals List
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
                sliver: goals.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment_outlined,
                                size: 80,
                                color: theme.colorScheme.onSurface.withOpacity(0.3),
                              ),
                              const SizedBox(height: AppTheme.spacing16),
                              Text(
                                'No goals yet',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacing8),
                              Text(
                                'Add your first goal to get started',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final goal = goals[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
                              child: GoalCard(
                                goal: goal,
                                onTap: () => _showGoalDetails(goal),
                                onComplete: () async {
                                  HapticFeedback.lightImpact();
                                  await ref.read(goalsProvider.notifier).toggleComplete(goal.id);
                                },
                                onDelete: () async {
                                  HapticFeedback.mediumImpact();
                                  await ref.read(goalsProvider.notifier).deleteGoal(goal.id);
                                },
                              ),
                            );
                          },
                          childCount: goals.length,
                        ),
                      ),
              ),
              
              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGoalSheet,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Goal'),
      ),
    );
  }

  // Premium Button Widget - NEW!
  Widget _buildPremiumButton(bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        // Premium functionality will be added later
      },
      child: AnimatedBuilder(
        animation: _glowAnimationController,
        builder: (context, child) {
          return Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6B46C1), // Deep purple
                  const Color(0xFF9333EA), // Purple
                  const Color(0xFF4C1D95), // Dark purple
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9333EA).withOpacity(0.3 + _glowAnimationController.value * 0.2),
                  blurRadius: 20 + _glowAnimationController.value * 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Animated stars background
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CustomPaint(
                      painter: _PremiumStarsPainter(
                        animation: _starAnimationController,
                        isDark: isDark,
                      ),
                    ),
                  ),
                ),
                
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                          Colors.black.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      // Crown icon with glow
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Go Premium',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFBBF24),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'NEW',
                                    style: TextStyle(
                                      color: Color(0xFF78350F),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Unlock exclusive features',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Arrow icon
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate(onPlay: (controller) => controller.repeat())
              .shimmer(
                duration: const Duration(seconds: 3),
                color: Colors.white.withOpacity(0.3),
                angle: 0,
              );
        },
      ),
    );
  }
  
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: AppTheme.spacing12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : theme.colorScheme.surface.withOpacity(0.7),
          borderRadius: BorderRadius.circular(AppTheme.radius12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : theme.colorScheme.onSurface.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? Colors.white
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
  
  Widget _buildProgressStat({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: AppTheme.spacing4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: AppTheme.spacing4),
        Flexible(
          child: Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  
  void _showGoalDetails(Goal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditGoalSheet(goal: goal),
    );
  }
  
  void _showSortOptions() {
    // Show sort options
  }
  
  int _getTodayProgress(List<Goal> goals) {
    final todayGoals = goals.where((g) => g.isToday).toList();
    if (todayGoals.isEmpty) return 0;
    final completed = todayGoals.where((g) => g.isCompleted).length;
    return ((completed / todayGoals.length) * 100).round();
  }
  
  int _getWeekCompletion(List<Goal> goals) {
    final weekGoals = goals.where((g) => g.isThisWeek).toList();
    if (weekGoals.isEmpty) return 0;
    final completed = weekGoals.where((g) => g.isCompleted).length;
    return ((completed / weekGoals.length) * 100).round();
  }
}

// Custom Painter for Premium Stars Background
class _PremiumStarsPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDark;
  
  _PremiumStarsPainter({
    required this.animation,
    required this.isDark,
  }) : super(repaint: animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    // Generate stars
    final random = math.Random(42); // Fixed seed for consistent star positions
    final starCount = 20;
    
    for (int i = 0; i < starCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = random.nextDouble() * 2 + 1;
      
      // Animated opacity
      final phase = (animation.value + random.nextDouble()) % 1.0;
      final opacity = (math.sin(phase * math.pi * 2) + 1) / 2;
      
      paint.color = Colors.white.withOpacity(opacity * 0.6);
      
      // Draw star
      _drawStar(canvas, paint, Offset(x, y), starSize);
    }
  }
  
  void _drawStar(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * math.pi / 5) - math.pi / 2;
      final x = center.dx + size * math.cos(angle);
      final y = center.dy + size * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      
      // Inner point
      final innerAngle = angle + (2 * math.pi / 5);
      final innerX = center.dx + (size * 0.4) * math.cos(innerAngle);
      final innerY = center.dy + (size * 0.4) * math.sin(innerAngle);
      path.lineTo(innerX, innerY);
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(_PremiumStarsPainter oldDelegate) => true;
}
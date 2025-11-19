import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glass_kit/glass_kit.dart';
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

class _GoalsPageState extends ConsumerState<GoalsPage> {
  final _searchController = TextEditingController();
  GoalFilter _selectedFilter = GoalFilter.all;
  
  @override
  void dispose() {
    _searchController.dispose();
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
                expandedHeight: 120,
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
                  titlePadding: const EdgeInsets.only(
                    left: AppTheme.spacing16,
                    bottom: AppTheme.spacing16,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search_rounded),
                    onPressed: () {
                      // Search functionality can be implemented here
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.sort_rounded),
                    onPressed: _showSortOptions,
                  ),
                ],
              ),
              
              // Filter Chips - Responsive ve overflow önlendi
              SliverToBoxAdapter(
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: 'All',
                          filter: GoalFilter.all,
                          count: allGoals.length,
                        ),
                        const SizedBox(width: AppTheme.spacing8),
                        _buildFilterChip(
                          label: 'Today',
                          filter: GoalFilter.today,
                          count: allGoals.where((g) => g.isToday).length,
                        ),
                        const SizedBox(width: AppTheme.spacing8),
                        // Active butonu kaldırıldı
                        _buildFilterChip(
                          label: 'Completed',
                          filter: GoalFilter.completed,
                          count: allGoals.where((g) => g.isCompleted).length,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Progress Summary Card - Responsive boyut
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GlassContainer.clearGlass(
                        width: constraints.maxWidth,
                        height: 120,
                        padding: const EdgeInsets.all(AppTheme.spacing16),
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
                                Icons.flag_outlined,
                                size: 64,
                                color: theme.colorScheme.onSurface.withOpacity(0.3),
                              ),
                              const SizedBox(height: AppTheme.spacing16),
                              Text(
                                'No goals yet',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacing8),
                              Text(
                                'Tap the + button to add your first goal',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverAnimatedList(
                        initialItemCount: goals.length,
                        itemBuilder: (context, index, animation) {
                          final goal = goals[index];
                          return SlideTransition(
                            position: animation.drive(
                              Tween(
                                begin: const Offset(0.3, 0),
                                end: Offset.zero,
                              ).chain(CurveTween(curve: Curves.easeOut)),
                            ),
                            child: FadeTransition(
                              opacity: animation,
                              child: GoalCard(
                                goal: goal,
                                onTap: () => _showGoalDetails(goal),
                                onComplete: () {
                                  HapticFeedback.mediumImpact();
                                  ref.read(goalsProvider.notifier).toggleComplete(goal.id);
                                },
                                onDelete: () {
                                  HapticFeedback.heavyImpact();
                                  ref.read(goalsProvider.notifier).deleteGoal(goal.id);
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
              
              // Bottom Padding for FAB
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGoalSheet,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Goal',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  
  // Filtreleme mantığı - doğru çalışacak şekilde düzenlendi
  List<Goal> _getFilteredGoals(List<Goal> allGoals) {
    switch (_selectedFilter) {
      case GoalFilter.all:
        return allGoals;
      case GoalFilter.today:
        return allGoals.where((goal) => goal.isToday).toList();
      case GoalFilter.completed:
        return allGoals.where((goal) => goal.isCompleted).toList();
      case GoalFilter.thisWeek:
        return allGoals.where((goal) => goal.isThisWeek).toList();
      case GoalFilter.overdue:
        return allGoals.where((goal) => goal.isOverdue).toList();
    }
  }
  
  Widget _buildFilterChip({
    required String label,
    required GoalFilter filter,
    required int count,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedFilter == filter;
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: AppTheme.spacing4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing4,
                vertical: AppTheme.spacing4,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radius8),
              ),
              child: Text(
                '$count',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected ? Colors.white : AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = filter;
          });
        }
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius12),
        side: BorderSide(
          color: isSelected
              ? AppTheme.primaryColor
              : theme.colorScheme.onSurface.withOpacity(0.1),
          width: 1,
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
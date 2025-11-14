import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    final goals = ref.watch(goalsProvider);
    final mediaQuery = MediaQuery.of(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppTheme.darkBackground, AppTheme.darkSurface]
                : [AppTheme.lightBackground, Colors.white],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar with Search - FIX: Overflow Ã¶nlendi
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                expandedHeight: 85,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded( // FIX: Title iÃ§in Expanded ekledik
                              child: Text(
                                'Goals',
                                style: theme.textTheme.headlineLarge,
                                overflow: TextOverflow.ellipsis,
                              ).animate().fadeIn(),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min, // FIX: Minimum boyut kullan
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.sort_rounded),
                                  onPressed: () {
                                    _showSortOptions();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.calendar_today_rounded),
                                  onPressed: () {
                                    // Show calendar view
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),

                        //const SizedBox(height: AppTheme.spacing4),

                        // Search Bar - FIX: Responsive geniÅŸlik
                        // Expanded(
                        //   child: Container(
                        //     width: double.infinity, // FIX: Tam geniÅŸlik
                        //     height: 100,
                        //     decoration: BoxDecoration(
                        //       color: theme.colorScheme.surface,
                        //       borderRadius: BorderRadius.circular(AppTheme.radius12),
                        //       border: Border.all(
                        //         color: theme.colorScheme.onSurface.withOpacity(0.1),
                        //         width: 1,
                        //       ),
                        //     ),
                        //     child: TextField(
                        //       controller: _searchController,
                        //       style: theme.textTheme.bodyMedium,
                        //       decoration: InputDecoration(
                        //         hintText: 'Search goals...',
                        //         hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        //           color: theme.colorScheme.onSurface.withOpacity(0.5),
                        //         ),
                        //         prefixIcon: Icon(
                        //           Icons.search_rounded,
                        //           color: theme.colorScheme.onSurface.withOpacity(0.5),
                        //         ),
                        //         border: InputBorder.none,
                        //         contentPadding: const EdgeInsets.symmetric(
                        //           horizontal: AppTheme.spacing16,
                        //           vertical: AppTheme.spacing12,
                        //         ),
                        //       ),
                        //       onChanged: (value) {
                        //         ref.read(goalsProvider.notifier).searchGoals(value);
                        //       },
                        //     ),
                        //   ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.2),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Filter Chips - FIX: Scroll overflow Ã¶nlendi
              SliverToBoxAdapter(
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
                  child: SingleChildScrollView( // FIX: ScrollView eklendi
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row( // FIX: ListView yerine Row kullandÄ±k
                      children: [
                        _buildFilterChip(
                          label: 'All',
                          filter: GoalFilter.all,
                          count: goals.length,
                        ),
                        const SizedBox(width: AppTheme.spacing8),
                        _buildFilterChip(
                          label: 'Today',
                          filter: GoalFilter.today,
                          count: goals.where((g) => g.isToday).length,
                        ),
                        const SizedBox(width: AppTheme.spacing8),
                        _buildFilterChip(
                          label: 'Active',
                          filter: GoalFilter.active,
                          count: goals.where((g) => !g.isCompleted).length,
                        ),
                        const SizedBox(width: AppTheme.spacing8),
                        _buildFilterChip(
                          label: 'Completed',
                          filter: GoalFilter.completed,
                          count: goals.where((g) => g.isCompleted).length,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms),
              ),
              
              // Progress Summary Card - FIX: Responsive boyut
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  child: LayoutBuilder( // FIX: LayoutBuilder eklendi
                    builder: (context, constraints) {
                      return GlassContainer.clearGlass(
                        width: constraints.maxWidth, // FIX: Responsive geniÅŸlik
                        height: 120, // FIX: Daha kompakt yÃ¼kseklik
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
                                value: '${_getTodayProgress(goals)}%',
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
                                value: '${_getWeekCompletion(goals)}%',
                                icon: Icons.calendar_view_week_rounded,
                                color: AppTheme.secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
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
                                Icons.task_alt_rounded,
                                size: 80,
                                color: theme.colorScheme.onSurface.withOpacity(0.3),
                              ),
                              const SizedBox(height: AppTheme.spacing16),
                              Text(
                                'No goals yet',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacing8),
                              Text(
                                'Add your first goal to get started',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                                ),
                              ),
                              // const SizedBox(height: AppTheme.spacing24),
                              // ElevatedButton.icon(
                              //   onPressed: _showAddGoalSheet,
                              //   icon: const Icon(Icons.add_rounded),
                              //   label: const Text('Add Goal'),
                              // ),
                            ],
                          ).animate().fadeIn(),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final goal = goals[index];
                            return GoalCard(
                              goal: goal,
                              onTap: () => _showGoalDetails(goal),
                              onComplete: () {
                                ref.read(goalsProvider.notifier).toggleComplete(goal.id);
                              },
                              onDelete: () {
                                ref.read(goalsProvider.notifier).deleteGoal(goal.id);
                              },
                            ).animate().fadeIn(delay: (400 + index * 50).ms).slideX(
                              begin: index.isEven ? -0.2 : 0.2,
                            );
                          },
                          childCount: goals.length,
                        ),
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
      ).animate().scale(delay: 500.ms),
    );
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
        mainAxisSize: MainAxisSize.min, // FIX: Minimum boyut
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: AppTheme.spacing4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing4, // FIX: Padding kÃ¼Ã§Ã¼ltÃ¼ldÃ¼
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
                  fontSize: 10, // FIX: Font boyutu kÃ¼Ã§Ã¼ltÃ¼ldÃ¼
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
          ref.read(goalsProvider.notifier).filterGoals(filter);
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
      mainAxisSize: MainAxisSize.min, // FIX: Minimum boyut
      children: [
        Icon(icon, color: color, size: 20), // FIX: Icon boyutu kÃ¼Ã§Ã¼ltÃ¼ldÃ¼
        const SizedBox(height: AppTheme.spacing4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith( // FIX: headlineSmall â†’ titleLarge
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: AppTheme.spacing4),
        Flexible( // FIX: Flexible eklendi
          child: Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 11, // FIX: Font boyutu kÃ¼Ã§Ã¼ltÃ¼ldÃ¼
            ),
            textAlign: TextAlign.center,
            maxLines: 2, // FIX: Maksimum 2 satÄ±r
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
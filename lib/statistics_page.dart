import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glass_kit/glass_kit.dart';
import 'app_theme.dart';
import 'models.dart';
import 'providers.dart';
import 'widgets.dart';

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  TimePeriod _selectedPeriod = TimePeriod.week;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final stats = ref.watch(statisticsProvider(_selectedPeriod));
    
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
              // App Bar
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  'Statistics',
                  style: theme.textTheme.headlineLarge,
                ).animate().fadeIn(),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share_rounded),
                    onPressed: () {
                      // Share statistics
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.download_rounded),
                    onPressed: () {
                      // Export data
                    },
                  ),
                ],
              ),
              
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time Period Selector
                      TimePeriodSelector(
                        selected: _selectedPeriod,
                        onChanged: (period) {
                          setState(() {
                            _selectedPeriod = period;
                          });
                        },
                      ).animate().fadeIn().slideY(begin: -0.1),
                      
                      const SizedBox(height: AppTheme.spacing24),
                      
                      // Summary Cards
                      stats.when(
                        data: (data) => Column(
                          children: [
                            // Total Focus Time
                            _buildSummaryCard(
                              title: 'Total Focus Time',
                              value: _formatDuration(data.totalFocusTime),
                              icon: Icons.timer_rounded,
                              color: AppTheme.primaryColor,
                              trend: data.focusTimeTrend,
                            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
                            
                            const SizedBox(height: AppTheme.spacing16),
                            
                            // Statistics Grid
                            Row(
                              children: [
                                Expanded(
                                  child: StatCard(
                                    title: 'Sessions',
                                    value: '${data.totalSessions}',
                                    icon: Icons.play_circle_outline_rounded,
                                    color: AppTheme.secondaryColor,
                                    change: data.sessionsChange,
                                  ).animate().fadeIn(delay: 200.ms).scale(),
                                ),
                                const SizedBox(width: AppTheme.spacing12),
                                Expanded(
                                  child: StatCard(
                                    title: 'Avg Duration',
                                    value: '${data.averageSessionMinutes} min',
                                    icon: Icons.av_timer_rounded,
                                    color: Colors.orange,
                                    change: data.avgDurationChange,
                                  ).animate().fadeIn(delay: 250.ms).scale(),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: AppTheme.spacing12),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: StatCard(
                                    title: 'Best Streak',
                                    value: '${data.bestStreak} days',
                                    icon: Icons.local_fire_department_rounded,
                                    color: Colors.red,
                                  ).animate().fadeIn(delay: 300.ms).scale(),
                                ),
                                const SizedBox(width: AppTheme.spacing12),
                                Expanded(
                                  child: StatCard(
                                    title: 'Completion',
                                    value: '${data.completionRate}%',
                                    icon: Icons.check_circle_outline_rounded,
                                    color: Colors.green,
                                    change: data.completionChange,
                                  ).animate().fadeIn(delay: 350.ms).scale(),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: AppTheme.spacing24),
                            
                            // Daily Chart
                            GlassContainer(
                              width: 150,
                              height: 250,
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
                              borderRadius: BorderRadius.circular(AppTheme.radius16),
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(AppTheme.spacing16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Daily Progress',
                                      style: theme.textTheme.headlineSmall,
                                    ),
                                    const SizedBox(height: AppTheme.spacing16),
                                    Expanded(
                                      child: BarChart(
                                        BarChartData(
                                          alignment: BarChartAlignment.spaceAround,
                                          maxY: data.maxDailyMinutes.toDouble() * 1.2,
                                          barTouchData: BarTouchData(
                                            enabled: true,
                                            touchTooltipData: BarTouchTooltipData(
                                              //tooltipColor: theme.colorScheme.surface,
                                              tooltipRoundedRadius: AppTheme.radius8,
                                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                                return BarTooltipItem(
                                                  '${rod.toY.toInt()} min',
                                                  TextStyle(
                                                    color: theme.colorScheme.onSurface,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          titlesData: FlTitlesData(
                                            show: true,
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget: (value, meta) {
                                                  final labels = data.dailyLabels;
                                                  if (value.toInt() < labels.length) {
                                                    return Text(
                                                      labels[value.toInt()],
                                                      style: theme.textTheme.bodySmall,
                                                    );
                                                  }
                                                  return const Text('');
                                                },
                                                reservedSize: 30,
                                              ),
                                            ),
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 40,
                                                getTitlesWidget: (value, meta) {
                                                  return Text(
                                                    '${value.toInt()}',
                                                    style: theme.textTheme.bodySmall,
                                                  );
                                                },
                                              ),
                                            ),
                                            topTitles: const AxisTitles(
                                              sideTitles: SideTitles(showTitles: false),
                                            ),
                                            rightTitles: const AxisTitles(
                                              sideTitles: SideTitles(showTitles: false),
                                            ),
                                          ),
                                          borderData: FlBorderData(show: false),
                                          barGroups: data.dailyData.asMap().entries.map((entry) {
                                            return BarChartGroupData(
                                              x: entry.key,
                                              barRods: [
                                                BarChartRodData(
                                                  toY: entry.value.toDouble(),
                                                  gradient: AppTheme.primaryGradient,
                                                  width: 20,
                                                  borderRadius: const BorderRadius.vertical(
                                                    top: Radius.circular(AppTheme.radius8),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                          gridData: FlGridData(
                                            show: true,
                                            drawVerticalLine: false,
                                            horizontalInterval: 30,
                                            getDrawingHorizontalLine: (value) {
                                              return FlLine(
                                                color: theme.colorScheme.onSurface.withOpacity(0.1),
                                                strokeWidth: 1,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                            
                            const SizedBox(height: AppTheme.spacing24),
                            
                            // Productivity Heatmap
                            _buildProductivityHeatmap(data)
                                .animate()
                                .fadeIn(delay: 500.ms)
                                .slideY(begin: 0.1),
                            
                            const SizedBox(height: AppTheme.spacing24),
                            
                            // Best Focus Hours
                            _buildBestHoursCard(data)
                                .animate()
                                .fadeIn(delay: 600.ms)
                                .slideY(begin: 0.1),
                          ],
                        ),
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (error, stack) => Center(
                          child: Text('Error loading statistics: $error'),
                        ),
                      ),
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
  
  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    double? trend,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radius16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppTheme.radius12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (trend != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing8,
                vertical: AppTheme.spacing4,
              ),
              decoration: BoxDecoration(
                color: trend >= 0 ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppTheme.radius8),
              ),
              child: Row(
                children: [
                  Icon(
                    trend >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: trend >= 0 ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: AppTheme.spacing4),
                  Text(
                    '${trend.abs().toStringAsFixed(1)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: trend >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildProductivityHeatmap(StatisticsData data) {
    // Heatmap implementation
    return Container(); // Placeholder
  }
  
  Widget _buildBestHoursCard(StatisticsData data) {
    // Best hours card implementation
    return Container(); // Placeholder
  }
  
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours> 0) {
      return '${hours}h ${minutes}m';
    }
    return '$minutes min';
  } }
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
  void initState() {
    super.initState();
    // Sayfa açıldığında provider'ı yenile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(statisticsProvider);
    });
  }

  Future<void> _refreshStats() async {
    ref.invalidate(statisticsProvider);
    await Future.delayed(const Duration(milliseconds: 500));
  }

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
          child: RefreshIndicator(
            onRefresh: _refreshStats,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
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
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: () {
                      ref.invalidate(statisticsProvider);
                    },
                    tooltip: 'Refresh Statistics (No Erase)',
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
                            // Total Focus Time - Period tabanlı
                            _buildSummaryCard(
                              title: _getPeriodLabel(_selectedPeriod),
                              value: _formatDuration(data.totalFocusTime),
                              icon: Icons.timer_rounded,
                              color: AppTheme.primaryColor,
                              trend: data.focusTimeTrend,
                            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),

                            const SizedBox(height: AppTheme.spacing16),

                            // Streak Cards - Güncel ve En İyi Streak
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStreakCard(
                                    title: 'Current Streak',
                                    streakDays: data.currentStreak,
                                    isCurrent: true,
                                  ).animate().fadeIn(delay: 200.ms).scale(),
                                ),
                                const SizedBox(width: AppTheme.spacing12),
                                Expanded(
                                  child: StatCard(
                                    title: 'Best Streak',
                                    value: '${data.bestStreak} days',
                                    icon: Icons.emoji_events_rounded,
                                    color: Colors.amber,
                                  ).animate().fadeIn(delay: 250.ms).scale(),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppTheme.spacing24),

                            // Pie Chart - Dairesel pasta grafiği
                            _buildPieChart(data)
                                .animate()
                                .fadeIn(delay: 400.ms)
                                .slideY(begin: 0.1),

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
        ),
      );
  }

  String _getPeriodLabel(TimePeriod period) {
    switch (period) {
      case TimePeriod.day:
        return 'Daily Focus Time';
      case TimePeriod.week:
        return 'Weekly Focus Time';
      case TimePeriod.month:
        return 'Monthly Focus Time';
      case TimePeriod.year:
        return 'Yearly Focus Time';
    }
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

  // Renk kodlu animasyonlu streak kartı
  Widget _buildStreakCard({
    required String title,
    required int streakDays,
    required bool isCurrent,
  }) {
    final theme = Theme.of(context);

    // Streak gün sayısına göre renk belirleme
    Color streakColor;
    if (streakDays == 0) {
      streakColor = Colors.red;
    } else if (streakDays < 3) {
      streakColor = Colors.red;
    } else if (streakDays < 7) {
      streakColor = Colors.yellow;
    } else if (streakDays < 10) {
      streakColor = Colors.orange;
    } else if (streakDays < 14) {
      streakColor = Colors.green;
    } else if (streakDays < 20) {
      streakColor = Colors.purple;
    } else {
      streakColor = const Color(0xFF9B59B6); // Eflatun
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            streakColor.withOpacity(0.3),
            streakColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radius16),
        border: Border.all(
          color: streakColor.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: streakColor.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                color: streakColor,
                size: 24,
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(
                    duration: 2000.ms,
                    color: Colors.white.withOpacity(0.5),
                  )
                  .shake(duration: 1000.ms, delay: 500.ms, hz: 2),
              const SizedBox(width: AppTheme.spacing8),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            '$streakDays days',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: streakColor,
            ),
          ),
        ],
      ),
    );
  }

  // Pie Chart Widget
  Widget _buildPieChart(StatisticsData data) {
    final theme = Theme.of(context);

    // Günlük verileri kullanarak pasta grafiği için bölümler oluştur
    final sections = <PieChartSectionData>[];
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.pink,
      Colors.cyan,
    ];

    for (int i = 0; i < data.dailyData.length; i++) {
      if (data.dailyData[i] > 0) {
        sections.add(
          PieChartSectionData(
            value: data.dailyData[i].toDouble(),
            title: '${data.dailyLabels[i]}\n${data.dailyData[i]}m',
            color: colors[i % colors.length],
            radius: 100,
            titleStyle: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
    }

    return GlassContainer(
      width: double.infinity,
      height: 350,
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
              'Focus Time Distribution',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.spacing16),
            Expanded(
              child: sections.isEmpty
                  ? Center(
                      child: Text(
                        'No data available',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    )
                  : PieChart(
                      PieChartData(
                        sections: sections,
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        startDegreeOffset: -90,
                        borderData: FlBorderData(show: false),
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            // Handle touch events
                          },
                        ),
                      ),
                    ),
            ),
          ],
        ),
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
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '$minutes min';
  }
}

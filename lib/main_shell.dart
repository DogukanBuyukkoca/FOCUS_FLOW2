import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'app_theme.dart';
import 'goals_page.dart';
import 'settings_page.dart';
import 'statistics_page.dart';
import 'timer_page.dart';

final selectedIndexProvider = StateProvider<int>((ref) => 0);

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  late PageController _pageController;
  
  final List<Widget> _pages = const [
    TimerPage(),
    StatisticsPage(),
    GoalsPage(),
    SettingsPage(),
  ];
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _onItemTapped(int index) {
    HapticFeedback.lightImpact();
    ref.read(selectedIndexProvider.notifier).state = index;
    _pageController.animateToPage(
      index,
      duration: AppTheme.animBase,
      curve: Curves.easeOutCubic,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          // Dinamik yükseklik - küçük ekranlarda daha az yer kaplar
          height: mediaQuery.size.width < 360 ? 60 : 65,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: _onItemTapped,
            backgroundColor: theme.colorScheme.surface,
            indicatorColor: AppTheme.primaryColor.withOpacity(0.2),
            // Overflow'u tamamen önlemek için sadece icon'lar göster
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            destinations: [
              NavigationDestination(
                icon: _buildAnimatedIcon(
                  Icons.timer_outlined,
                  selectedIndex == 0,
                  theme,
                ),
                selectedIcon: _buildSelectedIcon(Icons.timer_rounded),
                label: '', // Boş label
              ),
              NavigationDestination(
                icon: _buildAnimatedIcon(
                  Icons.bar_chart_outlined,
                  selectedIndex == 1,
                  theme,
                ),
                selectedIcon: _buildSelectedIcon(Icons.bar_chart_rounded),
                label: '',
              ),
              NavigationDestination(
                icon: _buildAnimatedIcon(
                  Icons.task_alt_outlined,
                  selectedIndex == 2,
                  theme,
                ),
                selectedIcon: _buildSelectedIcon(Icons.task_alt_rounded),
                label: '',
              ),
              NavigationDestination(
                icon: _buildAnimatedIcon(
                  Icons.settings_outlined,
                  selectedIndex == 3,
                  theme,
                ),
                selectedIcon: _buildSelectedIcon(Icons.settings_rounded),
                label: '',
              ),
            ],
          ),
        ),
      ).animate().slideY(
        begin: 1,
        end: 0,
        duration: AppTheme.animSlow,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  // Icon'ları ayrı metodlara çıkardık - kod tekrarını azaltır
  Widget _buildAnimatedIcon(IconData iconData, bool isSelected, ThemeData theme) {
    return Icon(
      iconData,
      // Küçük ekranlarda icon boyutunu küçült
      size: MediaQuery.of(context).size.width < 360 ? 20 : 24,
      color: isSelected 
          ? AppTheme.primaryColor 
          : theme.colorScheme.onSurface.withOpacity(0.5),
    ).animate(target: isSelected ? 1 : 0)
      .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1));
  }

  Widget _buildSelectedIcon(IconData iconData) {
    return Icon(
      iconData,
      size: MediaQuery.of(context).size.width < 360 ? 20 : 24,
      color: AppTheme.primaryColor,
    ).animate()
      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'goals_page.dart';
import 'settings_page.dart';
import 'space_rocket_page.dart';
import 'star_map_page.dart';
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
    TimerPage(), // Your existing timer page
    SpaceRocketPage(), // New space rocket page
    StarMapPage(), // New star map page
    GoalsPage(), // Your existing goals page
    StatisticsPage(), // Your existing statistics page
    SettingsPage(), // Your existing settings page
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
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    
    // Responsive sizing
    final isSmallScreen = size.width < 360;
    final isTinyScreen = size.width < 340;
    
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: isTinyScreen ? 60 : (isSmallScreen ? 65 : 72),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate if we need to use compact mode
              final availableWidth = constraints.maxWidth;
              final itemCount = 6;
              final minItemWidth = 50.0;
              final needsCompactMode = availableWidth / itemCount < minItemWidth;
              
              if (needsCompactMode || isTinyScreen) {
                // Ultra compact mode - icons only, smaller
                return _buildCompactNavBar(theme, selectedIndex, isTinyScreen);
              } else {
                // Standard mode with labels
                return _buildStandardNavBar(theme, selectedIndex, isSmallScreen);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStandardNavBar(ThemeData theme, int selectedIndex, bool isSmallScreen) {
    final iconSize = isSmallScreen ? 22.0 : 24.0;
    final fontSize = isSmallScreen ? 10.0 : 11.0;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavItem(
          icon: Icons.timer_rounded,
          label: 'Timer',
          index: 0,
          selectedIndex: selectedIndex,
          theme: theme,
          iconSize: iconSize,
          fontSize: fontSize,
        ),
        _buildNavItem(
          icon: Icons.rocket_launch_rounded,
          label: 'Rocket',
          index: 1,
          selectedIndex: selectedIndex,
          theme: theme,
          iconSize: iconSize,
          fontSize: fontSize,
        ),
        _buildNavItem(
          icon: Icons.map_rounded,
          label: 'Map',
          index: 2,
          selectedIndex: selectedIndex,
          theme: theme,
          iconSize: iconSize,
          fontSize: fontSize,
        ),
        _buildNavItem(
          icon: Icons.flag_rounded,
          label: 'Goals',
          index: 3,
          selectedIndex: selectedIndex,
          theme: theme,
          iconSize: iconSize,
          fontSize: fontSize,
        ),
        _buildNavItem(
          icon: Icons.insights_rounded,
          label: 'Stats',
          index: 4,
          selectedIndex: selectedIndex,
          theme: theme,
          iconSize: iconSize,
          fontSize: fontSize,
        ),
        _buildNavItem(
          icon: Icons.settings_rounded,
          label: 'Settings',
          index: 5,
          selectedIndex: selectedIndex,
          theme: theme,
          iconSize: iconSize,
          fontSize: fontSize,
        ),
      ],
    );
  }

  Widget _buildCompactNavBar(ThemeData theme, int selectedIndex, bool isTinyScreen) {
    final iconSize = isTinyScreen ? 20.0 : 22.0;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCompactNavItem(
          icon: Icons.timer_rounded,
          index: 0,
          selectedIndex: selectedIndex,
          theme: theme,
          iconSize: iconSize,
        ),
        _buildCompactNavItem(
          icon: Icons.rocket_launch_rounded,
          index: 1,
          selectedIndex: selectedIndex,
          theme: theme,
          iconSize: iconSize,
        ),
        _buildCompactNavItem(
          icon: Icons.map_rounded,
          index: 2,
          selectedIndex: selectedIndex,
          theme: theme,
          iconSize: iconSize,
        ),
        _buildCompactNavItem(
          icon: Icons.flag_rounded,
          index: 3,
          selectedIndex: selectedIndex,
          theme: theme,
          iconSize: iconSize,
        ),
        _buildCompactNavItem(
          icon: Icons.insights_rounded,
          index: 4,
          selectedIndex: selectedIndex,
          theme: theme,
          iconSize: iconSize,
        ),
        _buildCompactNavItem(
          icon: Icons.settings_rounded,
          index: 5,
          selectedIndex: selectedIndex,
          theme: theme,
          iconSize: iconSize,
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required int selectedIndex,
    required ThemeData theme,
    required double iconSize,
    required double fontSize,
  }) {
    final isSelected = selectedIndex == index;
    
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: iconSize,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactNavItem({
    required IconData icon,
    required int index,
    required int selectedIndex,
    required ThemeData theme,
    required double iconSize,
  }) {
    final isSelected = selectedIndex == index;
    
    return InkWell(
      onTap: () => _onItemTapped(index),
      customBorder: const CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }
}
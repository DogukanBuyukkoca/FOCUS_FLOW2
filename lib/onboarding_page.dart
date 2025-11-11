import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'app_router.dart';
import 'app_theme.dart';
import 'services.dart';
import 'widgets.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? _selectedGoal;
  
  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'Welcome to Focus Flow',
      subtitle: 'Build deep work habits and boost your productivity',
      image: Icons.rocket_launch_rounded,
      primaryColor: AppTheme.primaryColor,
      secondaryColor: AppTheme.secondaryColor,
    ),
    OnboardingPageData(
      title: 'Pomodoro Technique',
      subtitle: 'Work for 25 minutes, take a 5-minute break. Stay focused and refreshed.',
      image: Icons.timer_rounded,
      primaryColor: AppTheme.secondaryColor,
      secondaryColor: Colors.orange,
    ),
    OnboardingPageData(
      title: 'Track Your Progress',
      subtitle: 'Monitor your focus sessions, build streaks, and achieve your goals',
      image: Icons.insights_rounded,
      primaryColor: Colors.purple,
      secondaryColor: Colors.pink,
    ),
    OnboardingPageData(
      title: 'What\'s Your Goal?',
      subtitle: 'Choose your primary focus to personalize your experience',
      image: Icons.flag_rounded,
      primaryColor: Colors.blue,
      secondaryColor: Colors.cyan,
      isGoalSelection: true,
    ),
  ];
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppTheme.animBase,
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }
  
  void _previousPage() {
    HapticFeedback.lightImpact();
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AppTheme.animBase,
        curve: Curves.easeOutCubic,
      );
    }
  }
  
  void _skipOnboarding() {
    HapticFeedback.mediumImpact();
    _completeOnboarding();
  }
  
  void _completeOnboarding() async {
    if (_currentPage == _pages.length - 1 && _selectedGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your goal to continue'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    await StorageService.setOnboardingComplete(true);
    if (_selectedGoal != null) {
      await StorageService.setUserGoal(_selectedGoal!);
    }
    
    if (mounted) {
      ref.read(appRouterProvider).go('/');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    //final size = MediaQuery.of(context).size;
    
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
          child: Column(
            children: [
              // Skip Button
              if (_currentPage < _pages.length - 1)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    child: TextButton(
                      onPressed: _skipOnboarding,
                      child: Text(
                        'Skip',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ).animate().fadeIn(),
                  ),
                )
              else
                const SizedBox(height: 56),
              
              // Page Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    
                    if (page.isGoalSelection) {
                      return _buildGoalSelectionPage(page);
                    }
                    
                    return OnboardingPageContent(
                      data: page,
                    );
                  },
                ),
              ),
              
              // Page Indicators
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: AppTheme.animBase,
                      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppTheme.primaryColor
                            : theme.colorScheme.onSurface.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ).animate().scale(delay: (index * 50).ms),
                  ),
                ),
              ),
              
              // Navigation Buttons
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacing20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    if (_currentPage > 0)
                      IconButton(
                        onPressed: _previousPage,
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: theme.colorScheme.onSurface,
                        ),
                      ).animate().fadeIn().slideX(begin: -0.2)
                    else
                      const SizedBox(width: 48),
                    
                    // Next/Complete Button
                    ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: _currentPage == _pages.length - 1
                              ? AppTheme.spacing32
                              : AppTheme.spacing24,
                          vertical: AppTheme.spacing12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radius12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage == _pages.length - 1
                                ? 'Get Started'
                                : 'Next',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_currentPage < _pages.length - 1) ...[
                            const SizedBox(width: AppTheme.spacing8),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ],
                      ),
                    ).animate().fadeIn().slideX(begin: 0.2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildGoalSelectionPage(OnboardingPageData page) {
    final theme = Theme.of(context);
    final goals = [
      GoalOption(
        id: 'study',
        title: 'Study & Learn',
        subtitle: 'Prepare for exams, learn new skills',
        icon: Icons.school_rounded,
        color: Colors.blue,
      ),
      GoalOption(
        id: 'work',
        title: 'Work & Projects',
        subtitle: 'Complete tasks, meet deadlines',
        icon: Icons.work_rounded,
        color: Colors.green,
      ),
      GoalOption(
        id: 'creative',
        title: 'Creative Work',
        subtitle: 'Writing, design, art projects',
        icon: Icons.palette_rounded,
        color: Colors.purple,
      ),
      GoalOption(
        id: 'personal',
        title: 'Personal Growth',
        subtitle: 'Build habits, self-improvement',
        icon: Icons.self_improvement_rounded,
        color: Colors.orange,
      ),
    ];
    
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      child: Column(
        children: [
          const SizedBox(height: AppTheme.spacing32),
          
          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [page.primaryColor, page.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.image,
              size: 50,
              color: Colors.white,
            ),
          ).animate().scale(duration: AppTheme.animSlow),
          
          const SizedBox(height: AppTheme.spacing32),
          
          // Title
          Text(
            page.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 100.ms),
          
          const SizedBox(height: AppTheme.spacing12),
          
          // Subtitle
          Text(
            page.subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),
          
          const SizedBox(height: AppTheme.spacing32),
          
          // Goal Options
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                final isSelected = _selectedGoal == goal.id;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedGoal = goal.id;
                      });
                    },
                    child: AnimatedContainer(
                      duration: AppTheme.animBase,
                      padding: const EdgeInsets.all(AppTheme.spacing16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? goal.color.withOpacity(0.1)
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radius16),
                        border: Border.all(
                          color: isSelected
                              ? goal.color
                              : theme.colorScheme.onSurface.withOpacity(0.1),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: goal.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppTheme.radius12),
                            ),
                            child: Icon(
                              goal.icon,
                              color: goal.color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacing16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.title,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spacing4),
                                Text(
                                  goal.subtitle,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: goal.color,
                              size: 24,
                            ).animate().scale(),
                        ],
                      ),
                    ),
                  ).animate()
                    .fadeIn(delay: (300 + index * 100).ms)
                    .slideX(begin: 0.2),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

//class OnboardingPageData {
  //final String title;
  //final String subtitle;
  //final IconData image;
  //final Color primaryColor;
  //final Color secondaryColor;
  //final bool isGoalSelection;
  
  //OnboardingPageData({
    //required this.title,
    //required this.subtitle,
    //required this.image,
    //required this.primaryColor,
    //required this.secondaryColor,
    //this.isGoalSelection = false,
  //});
//}

class GoalOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  
  GoalOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
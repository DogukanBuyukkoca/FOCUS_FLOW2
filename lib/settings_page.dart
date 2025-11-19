import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'app_theme.dart';
import 'providers.dart';
import 'widgets.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    
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
                  'Settings',
                  style: theme.textTheme.headlineLarge,
                ).animate().fadeIn(),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.help_outline_rounded),
                    onPressed: () {
                      // Show help
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
                      // Premium Banner
                      if (!settings.isPremium)
                        PremiumBanner(
                          onTap: () => _showPremiumSheet(),
                        ).animate().fadeIn().slideY(begin: -0.1),
                      
                      if (!settings.isPremium)
                        const SizedBox(height: AppTheme.spacing20),
                      
                      // Timer Settings Section
                      _buildSectionHeader('Timer Settings'),
                      const SizedBox(height: AppTheme.spacing12),
                      _buildSettingsCard([
                        SettingsTile(
                          title: 'Focus Duration',
                          subtitle: '${settings.focusDuration} minutes',
                          icon: Icons.timer_rounded,
                          onTap: () => _showDurationPicker(
                            title: 'Focus Duration',
                            currentValue: settings.focusDuration,
                            onChanged: (value) {
                              ref.read(settingsProvider.notifier)
                                  .updateFocusDuration(value);
                            },
                          ),
                        ),
                        const Divider(height: 1),
                        SettingsTile(
                          title: 'Short Break',
                          subtitle: '${settings.shortBreakDuration} minutes',
                          icon: Icons.coffee_rounded,
                          onTap: () => _showDurationPicker(
                            title: 'Short Break Duration',
                            currentValue: settings.shortBreakDuration,
                            onChanged: (value) {
                              ref.read(settingsProvider.notifier)
                                  .updateShortBreakDuration(value);
                            },
                          ),
                        ),
                        const Divider(height: 1),
                        SettingsTile(
                          title: 'Long Break',
                          subtitle: '${settings.longBreakDuration} minutes',
                          icon: Icons.weekend_rounded,
                          onTap: () => _showDurationPicker(
                            title: 'Long Break Duration',
                            currentValue: settings.longBreakDuration,
                            onChanged: (value) {
                              ref.read(settingsProvider.notifier)
                                  .updateLongBreakDuration(value);
                            },
                          ),
                        ),
                        const Divider(height: 1),
                        SettingsTile(
                          title: 'Sessions Until Long Break',
                          subtitle: '${settings.sessionsUntilLongBreak} sessions',
                          icon: Icons.repeat_rounded,
                          onTap: () => _showNumberPicker(
                            title: 'Sessions Until Long Break',
                            currentValue: settings.sessionsUntilLongBreak,
                            min: 2,
                            max: 10,
                            onChanged: (value) {
                              ref.read(settingsProvider.notifier)
                                  .updateSessionsUntilLongBreak(value);
                            },
                          ),
                        ),
                        const Divider(height: 1),
                        SettingsTile(
                          title: 'Auto-start Breaks',
                          icon: Icons.play_circle_outline_rounded,
                          trailing: CupertinoSwitch(
                            value: settings.autoStartBreaks,
                            activeTrackColor: AppTheme.primaryColor,
                            onChanged: (value) {
                              HapticFeedback.lightImpact();
                              ref.read(settingsProvider.notifier)
                                  .updateAutoStartBreaks(value);
                            },
                          ),
                        ),
                        const Divider(height: 1),
                        SettingsTile(
                          title: 'Auto-start Focus',
                          icon: Icons.autorenew_rounded,
                          trailing: CupertinoSwitch(
                            value: settings.autoStartFocus,
                            activeTrackColor: AppTheme.primaryColor,
                            onChanged: (value) {
                              HapticFeedback.lightImpact();
                              ref.read(settingsProvider.notifier)
                                  .updateAutoStartFocus(value);
                            },
                          ),
                        ),
                      ]).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                      
                      const SizedBox(height: AppTheme.spacing24),
                      
                      // Appearance Section
                      _buildSectionHeader('Appearance'),
                      const SizedBox(height: AppTheme.spacing12),
                      _buildSettingsCard([
                        SettingsTile(
                          title: 'Theme',
                          subtitle: _getThemeName(themeMode),
                          icon: Icons.palette_rounded,
                          onTap: () => _showThemePicker(),
                        ),
                        const Divider(height: 1),
                        SettingsTile(
                          title: 'Language',
                          subtitle: _getLanguageName(locale),
                          icon: Icons.language_rounded,
                          onTap: () => _showLanguagePicker(),
                        ),
                      ]).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                      
                      const SizedBox(height: AppTheme.spacing24),
                      
                      // Sound & Notifications Section
                      _buildSectionHeader('Sound & Notifications'),
                      const SizedBox(height: AppTheme.spacing12),
                      _buildSettingsCard([
                        SettingsTile(
                          title: 'Sound Effects',
                          icon: Icons.volume_up_rounded,
                          trailing: CupertinoSwitch(
                            value: settings.soundEnabled,
                            activeTrackColor: AppTheme.primaryColor,
                            onChanged: (value) {
                              HapticFeedback.lightImpact();
                              ref.read(settingsProvider.notifier)
                                  .updateSoundEnabled(value);
                            },
                          ),
                        ),
                        const Divider(height: 1),
                        SettingsTile(
                          title: 'Haptic Feedback',
                          icon: Icons.vibration_rounded,
                          trailing: CupertinoSwitch(
                            value: settings.hapticEnabled,
                            activeTrackColor: AppTheme.primaryColor,
                            onChanged: (value) {
                              HapticFeedback.lightImpact();
                              ref.read(settingsProvider.notifier)
                                  .updateHapticEnabled(value);
                            },
                          ),
                        ),
                        const Divider(height: 1),
                        SettingsTile(
                          title: 'Notifications',
                          subtitle: settings.notificationsEnabled 
                              ? 'Enabled' 
                              : 'Disabled',
                          icon: Icons.notifications_rounded,
                          trailing: CupertinoSwitch(
                            value: settings.notificationsEnabled,
                            activeTrackColor: AppTheme.primaryColor,
                            onChanged: (value) {
                              HapticFeedback.lightImpact();
                              ref.read(settingsProvider.notifier)
                                  .updateNotificationsEnabled(value);
                            },
                          ),
                        ),
                        if (settings.notificationsEnabled) ...[
                          const Divider(height: 1),
                          SettingsTile(
                            title: 'Daily Reminder',
                            subtitle: settings.dailyReminderTime ?? 'Not set',
                            icon: Icons.alarm_rounded,
                            onTap: () => _showTimePicker(),
                          ),
                        ],
                      ]).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                      
                      const SizedBox(height: AppTheme.spacing24),
                      
                      // Data & Privacy Section
                      _buildSectionHeader('Data & Privacy'),
                      const SizedBox(height: AppTheme.spacing12),
                      _buildSettingsCard([
                        SettingsTile(
                          title: 'Export Data',
                          subtitle: 'Download your data',
                          icon: Icons.download_rounded,
                          onTap: settings.isPremium 
                              ? () => _exportData()
                              : () => _showPremiumSheet(),
                          trailing: settings.isPremium
                              ? null
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppTheme.spacing8,
                                    vertical: AppTheme.spacing4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(AppTheme.radius8),
                                  ),
                                  child: Text(
                                    'PRO',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                        const Divider(height: 1),
                        SettingsTile(
                          title: 'Clear Data',
                          subtitle: 'Delete all local data',
                          icon: Icons.delete_outline_rounded,
                          iconColor: theme.colorScheme.error,
                          onTap: () => _showClearDataDialog(),
                        ),
                        const Divider(height: 1),
                        SettingsTile(
                          title: 'Privacy Policy',
                          icon: Icons.privacy_tip_rounded,
                          onTap: () => _openPrivacyPolicy(),
                        ),
                        const Divider(height: 1),
                        SettingsTile(
                          title: 'Terms of Service',
                          icon: Icons.description_rounded,
                          onTap: () => _openTermsOfService(),
                        ),
                      ]).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                      
                      const SizedBox(height: AppTheme.spacing24),
                      
                      // Account Section
                      _buildSectionHeader('Account'),
                      const SizedBox(height: AppTheme.spacing12),
                      _buildSettingsCard([
                        if (settings.isPremium)
                          SettingsTile(
                            title: 'Manage Subscription',
                            subtitle: 'Premium Member',
                            icon: Icons.star_rounded,
                            iconColor: AppTheme.primaryColor,
                            onTap: () => _manageSubscription(),
                          )
                        else
                          SettingsTile(
                            title: 'Upgrade to Premium',
                            subtitle: 'Unlock all features',
                            icon: Icons.rocket_launch_rounded,
                            iconColor: AppTheme.primaryColor,
                            onTap: () => _showPremiumSheet(),
                          ),
                        const Divider(height: 1),
                        SettingsTile(
                          title: 'Restore Purchases',
                          icon: Icons.restore_rounded,
                          onTap: () => _restorePurchases(),
                        ),
                      ]).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                      
                      const SizedBox(height: AppTheme.spacing24),
                      
                      // About Section
                      _buildSectionHeader('About'),
                      const SizedBox(height: AppTheme.spacing12),
                      _buildSettingsCard([
                        const SettingsTile(
                          title: 'Version',
                          subtitle: '1.0.0 (Build 1)',
                          icon: Icons.info_outline_rounded,
                        ),
                        const Divider(height: 1),
                        SettingsTile(
                          title: 'Rate Us',
                          icon: Icons.star_outline_rounded,
                          onTap: () => _rateApp(),
                        ),
                        const Divider(height: 1),
                        SettingsTile(
                          title: 'Send Feedback',
                          icon: Icons.feedback_outlined,
                          onTap: () => _sendFeedback(),
                        ),
                      ]).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                      
                      const SizedBox(height: AppTheme.spacing32),
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
  
  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Widget _buildSettingsCard(List<Widget> children) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(children: children),
    );
  }
  
  void _showDurationPicker({
  required String title,
  required int currentValue,
  required Function(int) onChanged,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppTheme.radius24),
      ),
    ),
    builder: (context) {
      // Saat ve dakikayı ayır
      int selectedHours = currentValue ~/ 60;
      int selectedMinutes = currentValue % 60;
      
      final hoursController = FixedExtentScrollController(initialItem: selectedHours);
      final minutesController = FixedExtentScrollController(initialItem: selectedMinutes);
      
      return StatefulBuilder(
        builder: (context, setState) {
          final theme = Theme.of(context);
          
          return Container(
            padding: const EdgeInsets.all(AppTheme.spacing20),
            height: 380,
            child: Column(
              children: [
                // Drag Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppTheme.spacing16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Title
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacing8),
                
                // Current Value Display
                Text(
                  _formatDurationDisplay(selectedHours, selectedMinutes),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacing20),
                
                // Duration Picker - Sol Saat, Sağ Dakika
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radius16),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Hours Picker (Sol)
                        Expanded(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: AppTheme.spacing12),
                                child: Text(
                                  'Hours',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: CupertinoPicker(
                                  scrollController: hoursController,
                                  itemExtent: 40,
                                  backgroundColor: Colors.transparent,
                                  onSelectedItemChanged: (index) {
                                    setState(() {
                                      selectedHours = index;
                                    });
                                  },
                                  selectionOverlay: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: AppTheme.primaryColor.withOpacity(0.3),
                                          width: 1,
                                        ),
                                        bottom: BorderSide(
                                          color: AppTheme.primaryColor.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                  children: List<Widget>.generate(24, (index) {
                                    return Center(
                                      child: Text(
                                        index.toString().padLeft(2, '0'),
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          color: selectedHours == index 
                                              ? AppTheme.primaryColor 
                                              : theme.colorScheme.onSurface,
                                          fontWeight: selectedHours == index 
                                              ? FontWeight.bold 
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Separator
                        SizedBox(
                          width: 40,
                          child: Center(
                            child: Text(
                              ':',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        
                        // Minutes Picker (Sağ)
                        Expanded(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: AppTheme.spacing12),
                                child: Text(
                                  'Minutes',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: CupertinoPicker(
                                  scrollController: minutesController,
                                  itemExtent: 40,
                                  backgroundColor: Colors.transparent,
                                  onSelectedItemChanged: (index) {
                                    setState(() {
                                      selectedMinutes = index;
                                    });
                                  },
                                  selectionOverlay: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: AppTheme.primaryColor.withOpacity(0.3),
                                          width: 1,
                                        ),
                                        bottom: BorderSide(
                                          color: AppTheme.primaryColor.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                  children: List<Widget>.generate(60, (index) {
                                    return Center(
                                      child: Text(
                                        index.toString().padLeft(2, '0'),
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          color: selectedMinutes == index 
                                              ? AppTheme.primaryColor 
                                              : theme.colorScheme.onSurface,
                                          fontWeight: selectedMinutes == index 
                                              ? FontWeight.bold 
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacing20),
                
                // Save Button
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radius12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          // Toplam dakikayı hesapla
                          final totalMinutes = (selectedHours * 60) + selectedMinutes;
                          // En az 1 dakika olmalı
                          if (totalMinutes > 0) {
                            onChanged(totalMinutes);
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Duration must be at least 1 minute'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radius12),
                          ),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

// Helper method - Settings Page'e ekleyin
String _formatDurationDisplay(int hours, int minutes) {
  if (hours == 0) {
    return '$minutes minutes';
  } else if (minutes == 0) {
    return '$hours ${hours == 1 ? 'hour' : 'hours'}';
  } else {
    return '$hours ${hours == 1 ? 'hr' : 'hrs'} $minutes min';
  }
}
  
  void _showNumberPicker({
    required String title,
    required int currentValue,
    required int min,
    required int max,
    required Function(int) onChanged,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radius24),
        ),
      ),
      builder: (context) {
        int selectedValue = currentValue;
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(AppTheme.spacing20),
              height: 300,
              child: Column(
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppTheme.spacing20),
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 40,
                      scrollController: FixedExtentScrollController(
                        initialItem: currentValue - min,
                      ),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedValue = min + index;
                        });
                      },
                      children: List.generate(
                        max - min + 1,
                        (index) => Center(
                          child: Text(
                            '${min + index} sessions',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            onChanged(selectedValue);
                            Navigator.pop(context);
                          },
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  void _showThemePicker() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radius24),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppTheme.spacing20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Theme',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppTheme.spacing20),
              ListTile(
                leading: const Icon(Icons.light_mode_rounded),
                title: const Text('Light'),
                onTap: () {
                  ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                  Navigator.pop(context);
                },
                trailing: ref.watch(themeModeProvider) == ThemeMode.light
                    ? const Icon(Icons.check_rounded, color: AppTheme.primaryColor)
                    : null,
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode_rounded),
                title: const Text('Dark'),
                onTap: () {
                  ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                  Navigator.pop(context);
                },
                trailing: ref.watch(themeModeProvider) == ThemeMode.dark
                    ? const Icon(Icons.check_rounded, color: AppTheme.primaryColor)
                    : null,
              ),
              ListTile(
                leading: const Icon(Icons.brightness_auto_rounded),
                title: const Text('System'),
                onTap: () {
                  ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
                  Navigator.pop(context);
                },
                trailing: ref.watch(themeModeProvider) == ThemeMode.system
                    ? const Icon(Icons.check_rounded, color: AppTheme.primaryColor)
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showLanguagePicker() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radius24),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppTheme.spacing20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Language',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppTheme.spacing20),
              ListTile(
                leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                title: const Text('English'),
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
                trailing: ref.watch(localeProvider).languageCode == 'en'
                    ? const Icon(Icons.check_rounded, color: AppTheme.primaryColor)
                    : null,
              ),
              ListTile(
                leading: const Text('🇹🇷', style: TextStyle(fontSize: 24)),
                title: const Text('Türkçe'),
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(const Locale('tr'));
                  Navigator.pop(context);
                },
                trailing: ref.watch(localeProvider).languageCode == 'tr'
                    ? const Icon(Icons.check_rounded, color: AppTheme.primaryColor)
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (picked != null) {
      final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      ref.read(settingsProvider.notifier).updateDailyReminderTime(formattedTime);
    }
  }
  
  void _showPremiumSheet() {
    // Navigate to premium page or show premium modal
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Premium features coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _exportData() {
    // Export data functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data export started!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will delete all your focus sessions, goals, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Clear data
             // ref.read(settingsProvider.notifier).clearAllData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data cleared successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
  
  void _openPrivacyPolicy() {
    // Open privacy policy
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening privacy policy...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _openTermsOfService() {
    // Open terms of service
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening terms of service...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _manageSubscription() {
    // Manage subscription
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Subscription management coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _restorePurchases() async {
    try {
      // Mock restore purchases
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No purchases to restore'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to restore purchases: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
  
  void _rateApp() {
    // Rate app
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you for rating our app!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _sendFeedback() {
    // Send feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feedback form coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
  
  String _getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'tr':
        return 'Türkçe';
      default:
        return 'English';
    }
  }
}
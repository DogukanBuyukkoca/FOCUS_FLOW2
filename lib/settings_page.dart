import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';
import 'providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: theme.colorScheme.onSurface,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Settings',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
            ),
          ),

          // Settings Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: AppTheme.spacing16),

                // Timer Settings Section
                _buildSection(
                  title: 'Timer Settings',
                  children: [
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
                  ],
                ),

                const SizedBox(height: AppTheme.spacing24),

                // Notifications Section
                _buildSection(
                  title: 'Notifications',
                  children: [
                    SettingsTile(
                      title: 'Sound',
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
                      title: 'Push Notifications',
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
                  ],
                ),

                const SizedBox(height: AppTheme.spacing24),

                // Appearance Section
                _buildSection(
                  title: 'Appearance',
                  children: [
                    SettingsTile(
                      title: 'Dark Mode',
                      icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      trailing: CupertinoSwitch(
                        value: settings.darkMode,
                        activeTrackColor: AppTheme.primaryColor,
                        onChanged: (value) {
                          HapticFeedback.lightImpact();
                          ref.read(settingsProvider.notifier)
                              .updateDarkMode(value);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacing24),

                // About Section
                _buildSection(
                  title: 'About',
                  children: [
                    const SettingsTile(
                      title: 'Version',
                      subtitle: '1.0.0',
                      icon: Icons.info_rounded,
                      trailing: SizedBox.shrink(),
                    ),
                    const Divider(height: 1),
                    SettingsTile(
                      title: 'Terms of Service',
                      icon: Icons.description_rounded,
                      onTap: () {
                        // Navigate to Terms of Service
                      },
                    ),
                    const Divider(height: 1),
                    SettingsTile(
                      title: 'Privacy Policy',
                      icon: Icons.privacy_tip_rounded,
                      onTap: () {
                        // Navigate to Privacy Policy
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacing32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing20,
            vertical: AppTheme.spacing8,
          ),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(AppTheme.radius24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showDurationPicker({
    required String title,
    required int currentValue,
    required Function(int) onChanged,
  }) {
    final theme = Theme.of(context);
    int selectedValue = currentValue;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radius24),
          ),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      onChanged(selectedValue);
                      Navigator.pop(context);
                      HapticFeedback.mediumImpact();
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Picker
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: currentValue - 1,
                ),
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  selectedValue = index + 1;
                  HapticFeedback.selectionClick();
                },
                children: List.generate(
                  120,
                  (index) => Center(
                    child: Text(
                      '${index + 1} minutes',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNumberPicker({
    required String title,
    required int currentValue,
    required int min,
    required int max,
    required Function(int) onChanged,
  }) {
    final theme = Theme.of(context);
    int selectedValue = currentValue;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radius24),
          ),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.6,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      onChanged(selectedValue);
                      Navigator.pop(context);
                      HapticFeedback.mediumImpact();
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Picker
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: currentValue - min,
                ),
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  selectedValue = min + index;
                  HapticFeedback.selectionClick();
                },
                children: List.generate(
                  max - min + 1,
                  (index) => Center(
                    child: Text(
                      '${min + index}',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing12,
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radius16),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Trailing
              if (trailing != null)
                trailing!
              else if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
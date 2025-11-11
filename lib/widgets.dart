import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';
import 'models.dart';
import 'providers.dart';

// Enhanced Session Type Selector Widget with Special Button
class EnhancedSessionTypeSelector extends ConsumerWidget {
  final SessionType selectedType;
  final bool isSpecialSelected;
  final Function(SessionType) onTypeChanged;
  final VoidCallback onSpecialPressed;
  
  const EnhancedSessionTypeSelector({
    super.key,
    required this.selectedType,
    required this.isSpecialSelected,
    required this.onTypeChanged,
    required this.onSpecialPressed,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedGoal = ref.watch(selectedGoalProvider);
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius12),
      ),
      child: Row(
        children: [
          _buildOption(
            context: context,
            type: SessionType.longBreak,
            label: 'Long',
            icon: Icons.weekend_rounded,
            isSelected: !isSpecialSelected && selectedType == SessionType.longBreak,
            onTap: () => onTypeChanged(SessionType.longBreak),
          ),
          _buildOption(
            context: context,
            type: SessionType.shortBreak,
            label: 'Short',
            icon: Icons.coffee_rounded,
            isSelected: !isSpecialSelected && selectedType == SessionType.shortBreak,
            onTap: () => onTypeChanged(SessionType.shortBreak),
          ),
          _buildOption(
            context: context,
            type: SessionType.focus,
            label: 'Focus',
            icon: Icons.work_rounded,
            isSelected: !isSpecialSelected && selectedType == SessionType.focus,
            onTap: () => onTypeChanged(SessionType.focus),
          ),
          _buildSpecialOption(
            context: context,
            label: 'Special',
            icon: Icons.star_rounded,
            isSelected: isSpecialSelected,
            onTap: onSpecialPressed,
            hasGoal: selectedGoal != null && selectedGoal.estimatedMinutes > 0,
          ),
        ],
      ),
    );
  }
  
  Widget _buildOption({
    required BuildContext context,
    required SessionType type,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppTheme.animBase,
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radius8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              ),
              const SizedBox(width: AppTheme.spacing4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSpecialOption({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool hasGoal,
  }) {
    final theme = Theme.of(context);
    final color = hasGoal 
        ? (isSelected ? AppTheme.secondaryColor : theme.colorScheme.onSurface)
        : theme.colorScheme.onSurface.withOpacity(0.3);
    
    return Expanded(
      child: GestureDetector(
        onTap: hasGoal ? onTap : null,
        child: AnimatedContainer(
          duration: AppTheme.animBase,
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.secondaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radius8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: AppTheme.spacing4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected ? Colors.white : color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Original Session Type Selector Widget
class SessionTypeSelector extends StatelessWidget {
  final SessionType selectedType;
  final Function(SessionType) onTypeChanged;
  
  const SessionTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius12),
      ),
      child: Row(
        children: [
          _buildOption(
            context: context,
            type: SessionType.focus,
            label: 'Focus',
            icon: Icons.work_rounded,
          ),
          _buildOption(
            context: context,
            type: SessionType.shortBreak,
            label: 'Short',
            icon: Icons.coffee_rounded,
          ),
          _buildOption(
            context: context,
            type: SessionType.longBreak,
            label: 'Long',
            icon: Icons.weekend_rounded,
          ),
        ],
      ),
    );
  }
  
  Widget _buildOption({
    required BuildContext context,
    required SessionType type,
    required String label,
    required IconData icon,
  }) {
    final isSelected = selectedType == type;
    final theme = Theme.of(context);
    
    return Expanded(
      child: GestureDetector(
        onTap: () => onTypeChanged(type),
        child: AnimatedContainer(
          duration: AppTheme.animBase,
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radius8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              ),
              const SizedBox(width: AppTheme.spacing4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Time Duration Picker Widget with Hour and Minute Wheels
class TimeDurationPicker extends StatefulWidget {
  final Duration initialDuration;
  final Function(Duration) onDurationChanged;
  
  const TimeDurationPicker({
    super.key,
    required this.initialDuration,
    required this.onDurationChanged,
  });
  
  @override
  State<TimeDurationPicker> createState() => _TimeDurationPickerState();
}

class _TimeDurationPickerState extends State<TimeDurationPicker> {
  late int selectedHours;
  late int selectedMinutes;
  late FixedExtentScrollController hoursController;
  late FixedExtentScrollController minutesController;
  
  @override
  void initState() {
    super.initState();
    selectedHours = widget.initialDuration.inHours;
    selectedMinutes = widget.initialDuration.inMinutes.remainder(60);
    hoursController = FixedExtentScrollController(initialItem: selectedHours);
    minutesController = FixedExtentScrollController(initialItem: selectedMinutes);
  }
  
  @override
  void dispose() {
    hoursController.dispose();
    minutesController.dispose();
    super.dispose();
  }
  
  void _updateDuration() {
    final duration = Duration(hours: selectedHours, minutes: selectedMinutes);
    widget.onDurationChanged(duration);
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      height: 200,
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
          // Hours Picker
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
                      _updateDuration();
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
          Container(
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
          
          // Minutes Picker
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
                      _updateDuration();
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
    );
  }
}

// Continue with the rest of the widgets...
// Quick Stats Card Widget
class QuickStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  
  const QuickStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppTheme.spacing8),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// Original Goal Card Widget (unchanged)
class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  
  const GoalCard({
    super.key,
    required this.goal,
    required this.onTap,
    required this.onComplete,
    required this.onDelete,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dismissible(
      key: Key(goal.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(AppTheme.radius16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppTheme.spacing20),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
          padding: const EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radius16),
            border: Border.all(
              color: goal.priorityColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(goal.categoryIcon, color: goal.priorityColor, size: 20),
                  const SizedBox(width: AppTheme.spacing8),
                  Expanded(
                    child: Text(
                      goal.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (goal.isOverdue)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing8,
                        vertical: AppTheme.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radius8),
                      ),
                      child: Text(
                        'Overdue',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              if (goal.description != null) ...[
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  goal.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (goal.subTasks.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacing12),
                LinearProgressIndicator(
                  value: goal.completionRate,
                  backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(goal.priorityColor),
                ),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  '${goal.subTasks.where((t) => t.isCompleted).length}/${goal.subTasks.length} subtasks completed',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
              if (goal.tags.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacing12),
                Wrap(
                  spacing: AppTheme.spacing4,
                  children: goal.tags.take(3).map((tag) {
                    return Chip(
                      label: Text(tag),
                      labelStyle: theme.textTheme.labelSmall,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// The rest of the widgets file continues below...
// Enhanced Add Goal Sheet with Time Duration Picker
class AddGoalSheet extends ConsumerStatefulWidget {
  const AddGoalSheet({super.key});

  @override
  ConsumerState<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends ConsumerState<AddGoalSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _tagController = TextEditingController();
  
  Duration _estimatedDuration = const Duration(minutes: 25); // Default 25 minutes
  GoalPriority _priority = GoalPriority.medium;
  GoalCategory _category = GoalCategory.personal;
  DateTime? _selectedDate;
  TimeOfDay? _reminderTime;
  RepeatType _repeatType = RepeatType.none;
  
  final List<TextEditingController> _subTaskControllers = [];
  final List<String> _tags = [];

  void _addSubTask() {
    setState(() {
      _subTaskControllers.add(TextEditingController());
    });
  }

  void _removeSubTask(int index) {
    setState(() {
      _subTaskControllers[index].dispose();
      _subTaskControllers.removeAt(index);
    });
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _showTimePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 300,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radius24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: AppTheme.spacing12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                child: Text(
                  'Set Estimated Time',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
                  child: TimeDurationPicker(
                    initialDuration: _estimatedDuration,
                    onDurationChanged: (duration) {
                      setState(() {
                        _estimatedDuration = duration;
                      });
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radius12),
                    ),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveGoal() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a goal title')),
      );
      return;
    }

    final newGoal = Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: _descriptionController.text.trim(),
      createdAt: DateTime.now(),
      dueDate: _selectedDate,
      category: _category,
      priority: _priority,
      estimatedMinutes: _estimatedDuration.inMinutes,
      repeatType: _repeatType,
      reminderTime: _reminderTime != null && _selectedDate != null
          ? DateTime(
              _selectedDate!.year,
              _selectedDate!.month,
              _selectedDate!.day,
              _reminderTime!.hour,
              _reminderTime!.minute,
            )
          : null,
      subTasks: _subTaskControllers.asMap().entries.map((entry) {
        return SubTask(
          id: 'sub_${entry.key}',
          title: entry.value.text.trim(),
        );
      }).where((task) => task.title.isNotEmpty).toList(),
      tags: _tags,
      notes: _notesController.text.trim(),
    );

    ref.read(goalsProvider.notifier).addGoal(newGoal);
    
    // Set as selected goal for Special timer if it has estimated time
    if (newGoal.estimatedMinutes > 0) {
      ref.read(selectedGoalProvider.notifier).state = newGoal;
    }
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Goal added successfully')),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _tagController.dispose();
    for (var controller in _subTaskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radius24),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add New Goal',
                  style: theme.textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: keyboardHeight),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    TextField(
                      controller: _titleController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Goal Title',
                        hintText: 'Enter your goal',
                        prefixIcon: const Icon(Icons.flag_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    TextField(
                      controller: _descriptionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Add more details',
                        prefixIcon: const Icon(Icons.description_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Priority and Category
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<GoalPriority>(
                            value: _priority,
                            decoration: InputDecoration(
                              labelText: 'Priority',
                              prefixIcon: const Icon(Icons.priority_high_rounded),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: GoalPriority.values.map((priority) {
                              return DropdownMenuItem(
                                value: priority,
                                child: Text(priority.name.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _priority = value;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<GoalCategory>(
                            value: _category,
                            decoration: InputDecoration(
                              labelText: 'Category',
                              prefixIcon: const Icon(Icons.category_rounded),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: GoalCategory.values.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category.name.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _category = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Due Date and Time
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                setState(() {
                                  _selectedDate = date;
                                });
                              }
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: theme.colorScheme.outline),
                            ),
                            leading: const Icon(Icons.calendar_today_rounded),
                            title: Text(
                              _selectedDate == null
                                  ? 'Set Due Date'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ListTile(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                setState(() {
                                  _reminderTime = time;
                                });
                              }
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: theme.colorScheme.outline),
                            ),
                            leading: const Icon(Icons.alarm_rounded),
                            title: Text(
                              _reminderTime == null
                                  ? 'Set Reminder'
                                  : _reminderTime!.format(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Repeat Type
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Repeat',
                          style: theme.textTheme.labelMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: RepeatType.values.map((type) {
                            final isSelected = _repeatType == type;
                            return ChoiceChip(
                              label: Text(type.name.toUpperCase()),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _repeatType = type;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Estimated Time with Time Picker
                    GestureDetector(
                      onTap: () => _showTimePicker(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.colorScheme.outline),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timer_rounded,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Estimated Time',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _estimatedDuration.inMinutes == 0
                                        ? 'Tap to set duration'
                                        : '${_estimatedDuration.inHours}h ${_estimatedDuration.inMinutes.remainder(60)}m',
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.edit_rounded,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Sub Tasks
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Sub Tasks',
                              style: theme.textTheme.labelMedium,
                            ),
                            TextButton.icon(
                              onPressed: _addSubTask,
                              icon: const Icon(Icons.add, size: 20),
                              label: const Text('Add'),
                            ),
                          ],
                        ),
                        ..._subTaskControllers.asMap().entries.map((entry) {
                          final index = entry.key;
                          final controller = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: controller,
                                    decoration: InputDecoration(
                                      hintText: 'Sub task ${index + 1}',
                                      prefixIcon: const Icon(Icons.check_circle_outline, size: 20),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => _removeSubTask(index),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Tags
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tags',
                          style: theme.textTheme.labelMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _tagController,
                                decoration: InputDecoration(
                                  hintText: 'Add a tag',
                                  prefixIcon: const Icon(Icons.label_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                onSubmitted: (_) => _addTag(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _addTag,
                              icon: const Icon(Icons.add_circle),
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                        if (_tags.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: _tags.map((tag) {
                              return Chip(
                                label: Text(tag),
                                onDeleted: () {
                                  setState(() {
                                    _tags.remove(tag);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Notes
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Additional notes or thoughts',
                        prefixIcon: const Icon(Icons.note_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _saveGoal,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Create Goal',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// DiÄŸer widget'lar (deÄŸiÅŸmemiÅŸ)
class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? theme.colorScheme.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radius8),
        ),
        child: Icon(
          icon,
          color: iconColor ?? theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                )
              : null),
    );
  }
}

// Premium Banner Widget
class PremiumBanner extends StatelessWidget {
  final VoidCallback onTap;

  const PremiumBanner({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(AppTheme.radius16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.workspace_premium_rounded,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upgrade to Premium',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Unlock all features',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

// Time Period Selector Widget
class TimePeriodSelector extends StatelessWidget {
  final TimePeriod selected;
  final Function(TimePeriod) onChanged;

  const TimePeriodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius12),
      ),
      child: Row(
        children: [
          _buildOption(context, TimePeriod.day, 'Day'),
          _buildOption(context, TimePeriod.week, 'Week'),
          _buildOption(context, TimePeriod.month, 'Month'),
          _buildOption(context, TimePeriod.year, 'Year'),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, TimePeriod period, String label) {
    final isSelected = selected == period;
    final theme = Theme.of(context);
    
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(period),
        child: AnimatedContainer(
          duration: AppTheme.animBase,
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radius8),
          ),
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// Stat Card Widget
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double? change;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.change,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              if (change != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing8,
                    vertical: AppTheme.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: change! >= 0
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radius8),
                  ),
                  child: Text(
                    '${change! >= 0 ? '+' : ''}${change!.toStringAsFixed(1)}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: change! >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// Onboarding Page Content Widget
class OnboardingPageContent extends StatelessWidget {
  final OnboardingPageData data;

  const OnboardingPageContent({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [data.primaryColor, data.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.image,
              size: 60,
              color: Colors.white,
            ),
          ).animate().scale(duration: AppTheme.animSlow),
          const SizedBox(height: AppTheme.spacing32),
          Text(
            data.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            data.subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }
}

// Onboarding Page Data
class OnboardingPageData {
  final String title;
  final String subtitle;
  final IconData image;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isGoalSelection;

  OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.primaryColor,
    required this.secondaryColor,
    this.isGoalSelection = false,
  });
}
// Edit Goal Sheet Widget
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';
import 'models.dart';
import 'providers.dart';

class EditGoalSheet extends ConsumerStatefulWidget {
  final Goal goal;
  
  const EditGoalSheet({
    super.key,
    required this.goal,
  });

  @override
  ConsumerState<EditGoalSheet> createState() => _EditGoalSheetState();
}

class _EditGoalSheetState extends ConsumerState<EditGoalSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;
  final _tagController = TextEditingController();
  
  late Duration _estimatedDuration;
  late GoalPriority _priority;
  late GoalCategory _category;
  late DateTime? _selectedDate;
  late TimeOfDay? _reminderTime;
  late RepeatType _repeatType;
  late List<TextEditingController> _subTaskControllers;
  late List<String> _tags;
  late List<SubTask> _existingSubTasks;

  @override
  void initState() {
    super.initState();
    // Initialize with existing goal data
    _titleController = TextEditingController(text: widget.goal.title);
    _descriptionController = TextEditingController(text: widget.goal.description ?? '');
    _notesController = TextEditingController(text: widget.goal.notes ?? '');
    
    _estimatedDuration = Duration(minutes: widget.goal.estimatedMinutes);
    _priority = widget.goal.priority;
    _category = widget.goal.category;
    _selectedDate = widget.goal.dueDate;
    _reminderTime = widget.goal.reminderTime != null 
        ? TimeOfDay.fromDateTime(widget.goal.reminderTime!)
        : null;
    _repeatType = widget.goal.repeatType;
    _tags = List.from(widget.goal.tags);
    
    // Initialize subtasks
    _existingSubTasks = List.from(widget.goal.subTasks);
    _subTaskControllers = [];
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

  void _removeExistingSubTask(int index) {
    setState(() {
      _existingSubTasks.removeAt(index);
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

  void _updateGoal() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a goal title')),
      );
      return;
    }

    // Combine existing subtasks with new ones
    final allSubTasks = [
      ..._existingSubTasks,
      ..._subTaskControllers.asMap().entries.map((entry) {
        return SubTask(
          id: 'sub_new_${entry.key}',
          title: entry.value.text.trim(),
        );
      }).where((task) => task.title.isNotEmpty),
    ];

    final updatedGoal = widget.goal.copyWith(
      title: title,
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
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
      subTasks: allSubTasks,
      tags: _tags,
      notes: _notesController.text.trim().isEmpty 
          ? null 
          : _notesController.text.trim(),
    );

    ref.read(goalsProvider.notifier).updateGoal(updatedGoal);
    
    // Update selected goal if this was the selected one
    final selectedGoal = ref.read(selectedGoalProvider);
    if (selectedGoal?.id == updatedGoal.id) {
      ref.read(selectedGoalProvider.notifier).state = updatedGoal;
    }
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Goal updated successfully')),
    );
  }

  void _deleteGoal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Are you sure you want to delete "${widget.goal.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(goalsProvider.notifier).deleteGoal(widget.goal.id);
              
              // Clear selected goal if this was the selected one
              final selectedGoal = ref.read(selectedGoalProvider);
              if (selectedGoal?.id == widget.goal.id) {
                ref.read(selectedGoalProvider.notifier).state = null;
              }
              
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close sheet
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Goal deleted successfully')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
            padding: const EdgeInsets.all(20),
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
                  'Edit Goal',
                  style: theme.textTheme.titleLarge,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: _deleteGoal,
                      color: Colors.red,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
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
                    
                    // Priority and Category - Responsive with LayoutBuilder
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmallScreen = constraints.maxWidth < 360;
                        return Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<GoalPriority>(
                                value: _priority,
                                decoration: InputDecoration(
                                  labelText: 'Priority',
                                  prefixIcon: Icon(
                                    Icons.priority_high_rounded,
                                    size: isSmallScreen ? 18 : 24,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 8 : 12,
                                    vertical: isSmallScreen ? 8 : 16,
                                  ),
                                ),
                                items: GoalPriority.values.map((priority) {
                                  return DropdownMenuItem(
                                    value: priority,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(priority.name.toUpperCase()),
                                    ),
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
                                  prefixIcon: Icon(
                                    Icons.category_rounded,
                                    size: isSmallScreen ? 18 : 24,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 8 : 12,
                                    vertical: isSmallScreen ? 8 : 16,
                                  ),
                                ),
                                items: GoalCategory.values.map((category) {
                                  return DropdownMenuItem(
                                    value: category,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(category.name.toUpperCase()),
                                    ),
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
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Due Date and Time - FIX: Proper date validation
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmallScreen = constraints.maxWidth < 360;
                        return Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                onTap: () async {
                                  // Get current date without time
                                  final now = DateTime.now();
                                  final today = DateTime(now.year, now.month, now.day);
                                  
                                  // Determine initial date for picker
                                  DateTime initialDate;
                                  if (_selectedDate != null) {
                                    // If selected date is before today, use today
                                    if (_selectedDate!.isBefore(today)) {
                                      initialDate = today;
                                    } else {
                                      initialDate = _selectedDate!;
                                    }
                                  } else {
                                    initialDate = today;
                                  }
                                  
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: initialDate,
                                    firstDate: today, // Can't select past dates
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      _selectedDate = date;
                                    });
                                  }
                                },
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 8 : 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: theme.colorScheme.outline),
                                ),
                                leading: Icon(
                                  Icons.calendar_today_rounded,
                                  size: isSmallScreen ? 18 : 24,
                                ),
                                title: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _selectedDate == null
                                        ? 'Set Due Date'
                                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 12 : 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ListTile(
                                onTap: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: _reminderTime ?? TimeOfDay.now(),
                                  );
                                  if (time != null) {
                                    setState(() {
                                      _reminderTime = time;
                                    });
                                  }
                                },
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 8 : 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: theme.colorScheme.outline),
                                ),
                                leading: Icon(
                                  Icons.alarm_rounded,
                                  size: isSmallScreen ? 18 : 24,
                                ),
                                title: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _reminderTime == null
                                        ? 'Set Reminder'
                                        : _reminderTime!.format(context),
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 12 : 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Repeat Type - Responsive Wrap
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
                          runSpacing: 8,
                          children: RepeatType.values.map((type) {
                            final isSelected = _repeatType == type;
                            return ChoiceChip(
                              label: Text(
                                type.name.toUpperCase(),
                                style: const TextStyle(fontSize: 12),
                              ),
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                    
                    // Existing Sub Tasks
                    if (_existingSubTasks.isNotEmpty) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Existing Sub Tasks',
                            style: theme.textTheme.labelMedium,
                          ),
                          const SizedBox(height: 8),
                          ..._existingSubTasks.asMap().entries.map((entry) {
                            final index = entry.key;
                            final subTask = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: subTask.isCompleted,
                                    onChanged: (value) {
                                      setState(() {
                                        _existingSubTasks[index] = subTask.copyWith(
                                          isCompleted: value ?? false,
                                        );
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      subTask.title,
                                      style: TextStyle(
                                        decoration: subTask.isCompleted 
                                            ? TextDecoration.lineThrough 
                                            : null,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () => _removeExistingSubTask(index),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // New Sub Tasks
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Add New Sub Tasks',
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
                                      hintText: 'New sub task ${index + 1}',
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
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Tags - Responsive
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
                            runSpacing: 8,
                            children: _tags.map((tag) {
                              return Chip(
                                label: Text(
                                  tag,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
          
          // Action Buttons - Responsive
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 360;
                return Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 12 : 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: const Text('Cancel'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _updateGoal,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 12 : 16,
                          ),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: const Text(
                            'Update Goal',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Import the TimeDurationPicker widget
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
    
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          // Hours Picker
          Expanded(
            child: CupertinoPicker(
              scrollController: hoursController,
              itemExtent: 40,
              onSelectedItemChanged: (index) {
                setState(() {
                  selectedHours = index;
                });
                _updateDuration();
              },
              children: List<Widget>.generate(24, (index) {
                return Center(
                  child: Text(
                    '$index h',
                    style: theme.textTheme.titleLarge,
                  ),
                );
              }),
            ),
          ),
          
          Text(':', style: theme.textTheme.headlineMedium),
          
          // Minutes Picker
          Expanded(
            child: CupertinoPicker(
              scrollController: minutesController,
              itemExtent: 40,
              onSelectedItemChanged: (index) {
                setState(() {
                  selectedMinutes = index;
                });
                _updateDuration();
              },
              children: List<Widget>.generate(60, (index) {
                return Center(
                  child: Text(
                    '$index m',
                    style: theme.textTheme.titleLarge,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
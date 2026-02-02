import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/attendance_provider.dart';
import '../utils/theme.dart';
import '../widgets/common_widgets.dart';

/// Screen for adding or editing a subject
class AddEditSubjectScreen extends StatefulWidget {
  final String? subjectId;

  const AddEditSubjectScreen({super.key, this.subjectId});

  @override
  State<AddEditSubjectScreen> createState() => _AddEditSubjectScreenState();
}

class _AddEditSubjectScreenState extends State<AddEditSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _classesPerWeekController = TextEditingController();
  final _weeklyGoalController = TextEditingController();
  final _overallGoalController = TextEditingController();

  int _selectedIconIndex = 0;
  bool _isLoading = false;
  Subject? _existingSubject;

  /// Selected days for class schedule (1 = Monday, ..., 5 = Friday)
  final Set<int> _selectedDays = {};

  static const List<String> _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  bool get isEditing => widget.subjectId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadExistingSubject();
    } else {
      _classesPerWeekController.text = '5';
      _weeklyGoalController.text = '4';
      _overallGoalController.text = '75';
    }
  }

  void _loadExistingSubject() {
    final provider = Provider.of<AttendanceProvider>(context, listen: false);
    _existingSubject = provider.getSubjectById(widget.subjectId!);

    if (_existingSubject != null) {
      _nameController.text = _existingSubject!.name;
      _selectedIconIndex = int.tryParse(_existingSubject!.icon) ?? 0;
      _classesPerWeekController.text = _existingSubject!.classesPerWeek
          .toString();
      _weeklyGoalController.text = _existingSubject!.weeklyGoal.toString();
      _overallGoalController.text = _existingSubject!.overallGoalPercentage
          .toStringAsFixed(0);
      _selectedDays.addAll(_existingSubject!.scheduledDays);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _classesPerWeekController.dispose();
    _weeklyGoalController.dispose();
    _overallGoalController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select at least one day for the class schedule',
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = Provider.of<AttendanceProvider>(context, listen: false);

    bool success;
    if (isEditing && _existingSubject != null) {
      final updatedSubject = _existingSubject!.copyWith(
        name: _nameController.text.trim(),
        icon: _selectedIconIndex.toString(),
        classesPerWeek: int.parse(_classesPerWeekController.text),
        weeklyGoal: int.parse(_weeklyGoalController.text),
        overallGoalPercentage: double.parse(_overallGoalController.text),
        scheduledDays: _selectedDays.toList()..sort(),
      );
      success = await provider.updateSubject(updatedSubject);
    } else {
      success = await provider.addSubject(
        name: _nameController.text.trim(),
        icon: _selectedIconIndex.toString(),
        classesPerWeek: int.parse(_classesPerWeekController.text),
        weeklyGoal: int.parse(_weeklyGoalController.text),
        overallGoalPercentage: double.parse(_overallGoalController.text),
        scheduledDays: _selectedDays.toList()..sort(),
      );
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Subject updated successfully'
                : 'Subject added successfully',
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text(
          'Are you sure you want to delete "${_existingSubject?.name}"? This will also delete all attendance records for this subject.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = Provider.of<AttendanceProvider>(context, listen: false);
      await provider.deleteSubject(widget.subjectId!);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subject deleted successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Subject' : 'Add Subject'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _handleDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Icon',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 8,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                        itemCount: SubjectIcons.icons.length,
                        itemBuilder: (context, index) {
                          final isSelected = index == _selectedIconIndex;
                          return InkWell(
                            onTap: () {
                              setState(() => _selectedIconIndex = index);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: isSelected
                                    ? null
                                    : Border.all(color: Colors.grey.shade300),
                              ),
                              child: Icon(
                                SubjectIcons.icons[index],
                                size: 24,
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Subject Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Subject Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _nameController,
                        label: 'Subject Name',
                        hint: 'e.g., Mathematics',
                        prefixIcon: const Icon(Icons.book),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a subject name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _classesPerWeekController,
                        label: 'Classes Per Week',
                        hint: 'e.g., 5',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.calendar_today),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter classes per week';
                          }
                          final num = int.tryParse(value);
                          if (num == null || num < 1) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Class Schedule Days
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Class Schedule',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Select the days when this class is scheduled',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(5, (index) {
                          final day = index + 1; // 1 = Monday, ..., 5 = Friday
                          final isSelected = _selectedDays.contains(day);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedDays.remove(day);
                                } else {
                                  _selectedDays.add(day);
                                }
                              });
                            },
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? null
                                    : Border.all(color: Colors.grey.shade300),
                              ),
                              child: Center(
                                child: Text(
                                  _dayNames[index],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Goals
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Attendance Goals',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _weeklyGoalController,
                        label: 'Weekly Goal (classes)',
                        hint: 'e.g., 4',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.flag),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a weekly goal';
                          }
                          final num = int.tryParse(value);
                          if (num == null || num < 1) {
                            return 'Please enter a valid number';
                          }
                          if (num > _selectedDays.length) {
                            return 'Cannot exceed scheduled days (${_selectedDays.length})';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _overallGoalController,
                        label: 'Overall Goal (%)',
                        hint: 'e.g., 75',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.percent),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an overall goal';
                          }
                          final num = double.tryParse(value);
                          if (num == null || num < 0 || num > 100) {
                            return 'Please enter a valid percentage (0-100)';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              LoadingButton(
                text: isEditing ? 'Save Changes' : 'Add Subject',
                isLoading: _isLoading,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

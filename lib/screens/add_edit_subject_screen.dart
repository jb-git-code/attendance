import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Please select at least one day for the class schedule',
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    final provider = Provider.of<AttendanceProvider>(context, listen: false);

    bool success;
    if (isEditing && _existingSubject != null) {
      setState(() => _isLoading = true);
      final updatedSubject = _existingSubject!.copyWith(
        name: _nameController.text.trim(),
        icon: _selectedIconIndex.toString(),
        classesPerWeek: int.parse(_classesPerWeekController.text),
        weeklyGoal: int.parse(_weeklyGoalController.text),
        overallGoalPercentage: double.parse(_overallGoalController.text),
        scheduledDays: _selectedDays.toList()..sort(),
      );
      success = await provider.updateSubject(updatedSubject);
      setState(() => _isLoading = false);
    } else {
      // For new subjects, check if backdated attendance is needed
      final scheduledDays = _selectedDays.toList()..sort();
      final gapClasses = provider.calculateGapClasses(scheduledDays);

      double? backdatedPercentage;
      if (gapClasses > 0 && provider.needsBackdatedAttendance()) {
        // Show backdated attendance popup
        backdatedPercentage = await _showBackdatedAttendanceDialog(
          gapClasses,
          provider.getDaysSinceSemesterStart(),
        );
        // If user cancelled the dialog, don't proceed
        if (backdatedPercentage == null && mounted) {
          return;
        }
      }

      setState(() => _isLoading = true);
      success = await provider.addSubject(
        name: _nameController.text.trim(),
        icon: _selectedIconIndex.toString(),
        classesPerWeek: int.parse(_classesPerWeekController.text),
        weeklyGoal: int.parse(_weeklyGoalController.text),
        overallGoalPercentage: double.parse(_overallGoalController.text),
        scheduledDays: scheduledDays,
        backdatedAttendancePercentage: backdatedPercentage,
      );
      setState(() => _isLoading = false);
    }

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isEditing
                    ? 'Subject updated successfully'
                    : 'Subject added successfully',
              ),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
        ),
      );
    }
  }

  /// Show dialog to get approximate attendance percentage for backdated period
  Future<double?> _showBackdatedAttendanceDialog(
    int gapClasses,
    int daysSinceSemesterStart,
  ) async {
    double selectedPercentage = 75.0;
    final percentageController = TextEditingController(text: '75');

    return showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Past Attendance',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'The semester started $daysSinceSemesterStart days ago. '
                            'About $gapClasses classes have occurred for this subject.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'What percentage of classes did you attend approximately?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Slider for percentage
                  Row(
                    children: [
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppTheme.primaryColor,
                            inactiveTrackColor: AppTheme.primaryColor
                                .withOpacity(0.2),
                            thumbColor: AppTheme.primaryColor,
                            overlayColor: AppTheme.primaryColor.withOpacity(
                              0.1,
                            ),
                            trackHeight: 6,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 10,
                            ),
                          ),
                          child: Slider(
                            value: selectedPercentage,
                            min: 0,
                            max: 100,
                            divisions: 20,
                            onChanged: (value) {
                              setDialogState(() {
                                selectedPercentage = value;
                                percentageController.text = value
                                    .toInt()
                                    .toString();
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: percentageController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            suffixText: '%',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSm,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSm,
                              ),
                              borderSide: const BorderSide(
                                color: AppTheme.primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            final parsed = double.tryParse(value);
                            if (parsed != null &&
                                parsed >= 0 &&
                                parsed <= 100) {
                              setDialogState(() {
                                selectedPercentage = parsed;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Preview calculation
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calculate_outlined,
                          color: AppTheme.successColor,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'This will initialize: ${(gapClasses * selectedPercentage / 100).round()} attended out of $gapClasses classes',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.successColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context, null);
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context, selectedPercentage);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleDelete() async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                color: AppTheme.errorColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete Subject',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${_existingSubject?.name}"? This will also delete all attendance records for this subject.',
          style: const TextStyle(color: AppTheme.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context, true);
            },
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
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Subject deleted successfully'),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            boxShadow: AppTheme.cardShadow,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: AppTheme.textPrimary,
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
        ),
        title: Text(
          isEditing ? 'Edit Subject' : 'Add Subject',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (isEditing)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                boxShadow: AppTheme.cardShadow,
              ),
              child: IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                color: AppTheme.errorColor,
                onPressed: _handleDelete,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.of(context).padding.bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon Selection
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSm,
                              ),
                            ),
                            child: const Icon(
                              Icons.emoji_emotions_rounded,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Select Icon',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
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
                              HapticFeedback.selectionClick();
                              setState(() => _selectedIconIndex = index);
                            },
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSm,
                            ),
                            child: AnimatedContainer(
                              duration: AppTheme.animFast,
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? AppTheme.primaryGradient
                                    : null,
                                color: isSelected
                                    ? null
                                    : AppTheme.backgroundColor,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusSm,
                                ),
                                border: isSelected
                                    ? null
                                    : Border.all(color: AppTheme.dividerColor),
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSm,
                              ),
                            ),
                            child: const Icon(
                              Icons.book_rounded,
                              color: AppTheme.secondaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Subject Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _nameController,
                        label: 'Subject Name',
                        hint: 'e.g., Mathematics',
                        prefixIcon: const Icon(Icons.book_rounded),
                        textInputAction: TextInputAction.next,
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
                        prefixIcon: const Icon(Icons.calendar_today_rounded),
                        textInputAction: TextInputAction.next,
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.warningColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSm,
                              ),
                            ),
                            child: const Icon(
                              Icons.schedule_rounded,
                              color: AppTheme.warningColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Class Schedule',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                'Select the days when this class is scheduled',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(5, (index) {
                          final day = index + 1; // 1 = Monday, ..., 5 = Friday
                          final isSelected = _selectedDays.contains(day);
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                if (isSelected) {
                                  _selectedDays.remove(day);
                                } else {
                                  _selectedDays.add(day);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: AppTheme.animFast,
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? AppTheme.primaryGradient
                                    : null,
                                color: isSelected
                                    ? null
                                    : AppTheme.backgroundColor,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMd,
                                ),
                                border: isSelected
                                    ? null
                                    : Border.all(color: AppTheme.dividerColor),
                                boxShadow: isSelected
                                    ? AppTheme.primaryShadow(0.2)
                                    : null,
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSm,
                              ),
                            ),
                            child: const Icon(
                              Icons.flag_rounded,
                              color: AppTheme.successColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Attendance Goals',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _weeklyGoalController,
                        label: 'Weekly Goal (classes)',
                        hint: 'e.g., 4',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.flag_rounded),
                        textInputAction: TextInputAction.next,
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
                        prefixIcon: const Icon(Icons.percent_rounded),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleSave(),
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
                icon: isEditing ? Icons.save_rounded : Icons.add_rounded,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

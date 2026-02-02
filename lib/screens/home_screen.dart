import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/theme.dart';
import '../widgets/common_widgets.dart';
import 'add_edit_subject_screen.dart';
import 'subject_detail_screen.dart';
import 'profile_screen.dart';

/// Home screen showing the list of subjects
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showStatusUpdateDialog(
    BuildContext context,
    Subject subject,
    AttendanceProvider provider,
  ) {
    HapticFeedback.mediumImpact();

    // Don't allow marking if semester has ended
    if (provider.isSemesterEnded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.lock_outline, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('Semester completed. Attendance is locked.'),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final todayRecord = provider.getTodayAttendance(subject.id);
    final currentStatus = todayRecord?.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              todayRecord == null
                  ? 'Mark Today\'s Class'
                  : 'Update Class Status',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    SubjectIcons.getIcon(subject.icon),
                    size: 18,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    subject.name,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildStatusOption(
              context,
              icon: Icons.check_circle_rounded,
              label: 'Attended',
              subtitle: 'I was present in class',
              color: AppTheme.successColor,
              isSelected: currentStatus == ClassStatus.attended,
              onTap: () => _updateStatus(
                context,
                subject.id,
                ClassStatus.attended,
                todayRecord,
                provider,
              ),
            ),
            const SizedBox(height: 10),
            _buildStatusOption(
              context,
              icon: Icons.cancel_rounded,
              label: 'Missed',
              subtitle: 'I was absent from class',
              color: AppTheme.errorColor,
              isSelected: currentStatus == ClassStatus.missed,
              onTap: () => _updateStatus(
                context,
                subject.id,
                ClassStatus.missed,
                todayRecord,
                provider,
              ),
            ),
            const SizedBox(height: 10),
            _buildStatusOption(
              context,
              icon: Icons.event_busy_rounded,
              label: 'Cancelled',
              subtitle: 'Class was cancelled today',
              color: AppTheme.warningColor,
              isSelected: currentStatus == ClassStatus.cancelled,
              onTap: () => _updateStatus(
                context,
                subject.id,
                ClassStatus.cancelled,
                todayRecord,
                provider,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.infoColor,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You can update the status until 8 AM tomorrow',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.infoColor,
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
    );
  }

  Widget _buildStatusOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: AppTheme.animFast,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withOpacity(0.1)
                : AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : AppTheme.dividerColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? color : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    String subjectId,
    ClassStatus status,
    AttendanceRecord? existingRecord,
    AttendanceProvider provider,
  ) async {
    Navigator.pop(context);
    HapticFeedback.mediumImpact();

    bool success;
    if (existingRecord != null) {
      success = await provider.updateAttendanceStatus(
        recordId: existingRecord.id,
        newStatus: status,
      );
    } else {
      success = await provider.markAttendanceWithStatus(
        subjectId: subjectId,
        status: status,
      );
    }

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(_getStatusIcon(status), color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text('Class marked as ${status.name}'),
            ],
          ),
          backgroundColor: _getStatusColor(status),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Smart Attendance',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 22,
                  color: AppTheme.primaryColor,
                ),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 3),
            );
          }

          if (provider.subjects.isEmpty) {
            return EmptyState(
              icon: Icons.school_rounded,
              title: 'No Subjects Yet',
              subtitle:
                  'Add your first subject to start\ntracking your attendance',
              action: ElevatedButton.icon(
                onPressed: () => _navigateToAddSubject(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Subject'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadData(),
            color: AppTheme.primaryColor,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // Overall Stats Card
                SliverToBoxAdapter(
                  child: _buildOverallStatsCard(context, provider),
                ),
                // Section Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your Subjects',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          '${provider.subjects.length} subjects',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Subject List
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final subject = provider.subjects[index];
                      return _buildSubjectCard(context, subject, provider);
                    }, childCount: provider.subjects.length),
                  ),
                ),
                // Bottom padding for FAB
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.primaryShadow(0.3),
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _navigateToAddSubject(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Add Subject',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildOverallStatsCard(
    BuildContext context,
    AttendanceProvider provider,
  ) {
    final stats = provider.getOverallStats();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final percentFontSize = isSmallScreen
        ? 36.0
        : (screenWidth < 400 ? 42.0 : 48.0);
    final titleFontSize = isSmallScreen ? 13.0 : 15.0;
    final subjectIconSize = isSmallScreen ? 24.0 : 28.0;
    final subjectCountFontSize = isSmallScreen ? 18.0 : 22.0;
    final cardPadding = isSmallScreen ? 16.0 : 22.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppTheme.primaryShadow(0.35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.insights_rounded,
                  size: 18,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Overall Attendance',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      tween: Tween<double>(
                        begin: 0,
                        end: stats['percentage'] as double,
                      ),
                      builder: (context, value, child) {
                        return Text(
                          '${value.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: percentFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -1,
                            height: 1,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${stats['totalAttended']} of ${stats['totalClasses']} classes',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12.0 : 13.0,
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.school_rounded,
                      size: subjectIconSize,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${stats['subjectCount']}',
                      style: TextStyle(
                        fontSize: subjectCountFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Subjects',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10.0 : 11.0,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(
    BuildContext context,
    Subject subject,
    AttendanceProvider provider,
  ) {
    final weeklyAttended = provider.getWeeklyAttendedCount(subject.id);
    final weeklyProgress = subject.weeklyGoal > 0
        ? (weeklyAttended / subject.weeklyGoal * 100).clamp(0, 100).toDouble()
        : 0.0;

    final needsUpdate = provider.needsStatusUpdate(subject.id);
    final hasClassToday = subject.hasClassToday;
    final todayRecord = provider.getTodayAttendance(subject.id);
    final canEdit = provider.canEditTodayAttendance(subject.id);

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final iconContainerSize = isSmallScreen ? 46.0 : 52.0;
    final iconSize = isSmallScreen ? 24.0 : 26.0;
    final circularProgressSize = isSmallScreen ? 48.0 : 54.0;
    final circularStrokeWidth = isSmallScreen ? 5.0 : 5.5;
    final cardPadding = isSmallScreen ? 12.0 : 14.0;
    final nameFontSize = isSmallScreen ? 15.0 : 16.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SubjectDetailScreen(subjectId: subject.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Row(
              children: [
                // Subject Icon with notification dot
                Stack(
                  children: [
                    Container(
                      width: iconContainerSize,
                      height: iconContainerSize,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withOpacity(0.15),
                            AppTheme.primaryColor.withOpacity(0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        SubjectIcons.getIcon(subject.icon),
                        size: iconSize,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    // Notification dot for pending status update
                    if (needsUpdate)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.errorColor,
                                AppTheme.errorColor.withOpacity(0.8),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.errorColor.withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: isSmallScreen ? 12.0 : 14.0),
                // Subject Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              subject.name,
                              style: TextStyle(
                                fontSize: nameFontSize,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Show update button if class today and can edit
                          if (hasClassToday && canEdit)
                            GestureDetector(
                              onTap: () => _showStatusUpdateDialog(
                                context,
                                subject,
                                provider,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: needsUpdate
                                      ? AppTheme.primaryColor
                                      : _getStatusColor(todayRecord?.status),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          (needsUpdate
                                                  ? AppTheme.primaryColor
                                                  : _getStatusColor(
                                                      todayRecord?.status,
                                                    ))
                                              .withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      needsUpdate
                                          ? Icons.add_circle_outline_rounded
                                          : _getStatusIcon(todayRecord?.status),
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      needsUpdate
                                          ? 'Mark'
                                          : _getStatusLabel(
                                              todayRecord?.status,
                                            ),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${subject.attendedClasses}/${subject.totalClasses} classes attended',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Weekly Progress Bar
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeOutCubic,
                                tween: Tween<double>(
                                  begin: 0,
                                  end: weeklyProgress / 100,
                                ),
                                builder: (context, value, child) {
                                  return LinearProgressIndicator(
                                    value: value,
                                    minHeight: 5,
                                    backgroundColor: AppTheme.dividerColor
                                        .withOpacity(0.5),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _getProgressColor(weeklyProgress),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$weeklyAttended/${subject.weeklyGoal}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getProgressColor(weeklyProgress),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8.0 : 10.0),
                // Attendance Percentage
                CircularProgressWithPercentage(
                  percentage: subject.attendancePercentage,
                  size: circularProgressSize,
                  strokeWidth: circularStrokeWidth,
                  showAnimation: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 75) return AppTheme.successColor;
    if (percentage >= 50) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  Color _getStatusColor(ClassStatus? status) {
    switch (status) {
      case ClassStatus.attended:
        return AppTheme.successColor;
      case ClassStatus.missed:
        return AppTheme.errorColor;
      case ClassStatus.cancelled:
        return AppTheme.warningColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getStatusIcon(ClassStatus? status) {
    switch (status) {
      case ClassStatus.attended:
        return Icons.check_circle_rounded;
      case ClassStatus.missed:
        return Icons.cancel_rounded;
      case ClassStatus.cancelled:
        return Icons.event_busy_rounded;
      default:
        return Icons.add_circle_outline_rounded;
    }
  }

  String _getStatusLabel(ClassStatus? status) {
    switch (status) {
      case ClassStatus.attended:
        return 'Present';
      case ClassStatus.missed:
        return 'Absent';
      case ClassStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Mark';
    }
  }

  void _navigateToAddSubject(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditSubjectScreen()),
    );
  }
}

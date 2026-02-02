import 'package:flutter/material.dart';
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
    // Don't allow marking if semester has ended
    if (provider.isSemesterEnded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semester completed. Attendance is locked.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final todayRecord = provider.getTodayAttendance(subject.id);
    final currentStatus = todayRecord?.status;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              todayRecord == null
                  ? 'Mark Today\'s Class'
                  : 'Update Class Status',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subject.name,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _buildStatusOption(
              context,
              icon: Icons.check_circle,
              label: 'Attended',
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
            const SizedBox(height: 12),
            _buildStatusOption(
              context,
              icon: Icons.cancel,
              label: 'Missed',
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
            const SizedBox(height: 12),
            _buildStatusOption(
              context,
              icon: Icons.event_busy,
              label: 'Cancelled',
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
            const SizedBox(height: 16),
            const Text(
              'Note: You can update the status until midnight only.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
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
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            if (isSelected) Icon(Icons.check, color: color),
          ],
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
          content: Text('Class marked as ${status.name}'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Smart Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.subjects.isEmpty) {
            return EmptyState(
              icon: Icons.menu_book,
              title: 'No Subjects Yet',
              subtitle: 'Add your first subject to start tracking attendance',
              action: ElevatedButton.icon(
                onPressed: () => _navigateToAddSubject(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Subject'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadData(),
            child: CustomScrollView(
              slivers: [
                // Overall Stats Card
                SliverToBoxAdapter(
                  child: _buildOverallStatsCard(context, provider),
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
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddSubject(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
      ),
    );
  }

  Widget _buildOverallStatsCard(
    BuildContext context,
    AttendanceProvider provider,
  ) {
    final stats = provider.getOverallStats();
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF8B80FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overall Attendance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${stats['percentage'].toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${stats['totalAttended']} of ${stats['totalClasses']} classes',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.school, size: 32, color: Colors.white),
                    const SizedBox(height: 4),
                    Text(
                      '${stats['subjectCount']}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Subjects',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SubjectDetailScreen(subjectId: subject.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Subject Icon with notification dot
              Stack(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      SubjectIcons.getIcon(subject.icon),
                      size: 28,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  // Notification dot for pending status update
                  if (needsUpdate)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
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
              const SizedBox(width: 16),
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
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
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: needsUpdate
                                    ? AppTheme.primaryColor
                                    : _getStatusColor(todayRecord?.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    needsUpdate
                                        ? Icons.add_circle_outline
                                        : _getStatusIcon(todayRecord?.status),
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    needsUpdate
                                        ? 'Mark'
                                        : _getStatusLabel(todayRecord?.status),
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
                    const SizedBox(height: 4),
                    Text(
                      '${subject.attendedClasses}/${subject.totalClasses} classes attended',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Weekly Progress Bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: weeklyProgress / 100,
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getProgressColor(weeklyProgress),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$weeklyAttended/${subject.weeklyGoal}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Attendance Percentage
              CircularProgressWithPercentage(
                percentage: subject.attendancePercentage,
                size: 56,
                strokeWidth: 6,
              ),
            ],
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
        return Icons.check_circle;
      case ClassStatus.missed:
        return Icons.cancel;
      case ClassStatus.cancelled:
        return Icons.event_busy;
      default:
        return Icons.add_circle_outline;
    }
  }

  String _getStatusLabel(ClassStatus? status) {
    switch (status) {
      case ClassStatus.attended:
        return 'Attended';
      case ClassStatus.missed:
        return 'Missed';
      case ClassStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Mark';
    }
  }

  void _navigateToAddSubject(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditSubjectScreen()),
    );
  }
}

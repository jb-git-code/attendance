import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/attendance_provider.dart';
import '../utils/theme.dart';
import '../widgets/common_widgets.dart';
import 'add_edit_subject_screen.dart';

/// Screen showing detailed attendance for a subject
class SubjectDetailScreen extends StatelessWidget {
  final String subjectId;

  const SubjectDetailScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, _) {
        final subject = provider.getSubjectById(subjectId);

        if (subject == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Subject Details')),
            body: const Center(child: Text('Subject not found')),
          );
        }

        final attendanceRecords = provider.getAttendanceBySubject(subjectId);
        final weeklyAttended = provider.getWeeklyAttendedCount(subjectId);

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            title: Text(subject.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AddEditSubjectScreen(subjectId: subjectId),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _showDeleteDialog(context, provider, subject),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Semester Status Banner (if semester ended)
                if (provider.isSemesterEnded) ...[
                  _buildSemesterEndedBanner(),
                  const SizedBox(height: 16),
                ],

                // Semester Info Card (if semester dates are set)
                if (provider.hasSemesterDates && !provider.isSemesterEnded) ...[
                  _buildSemesterInfoCard(subject, provider),
                  const SizedBox(height: 16),
                ],

                // Overall Stats Card
                _buildStatsCard(subject, weeklyAttended),
                const SizedBox(height: 16),

                // Attendance Prediction Card
                _buildPredictionCard(subject, provider),
                const SizedBox(height: 16),

                // Bunk Calculator Card
                _buildBunkCalculatorCard(subject, provider, context),
                const SizedBox(height: 16),

                // Attendance Chart
                _buildAttendanceChart(subject),
                const SizedBox(height: 16),

                // Weekly Progress
                _buildWeeklyProgressCard(subject, weeklyAttended),
                const SizedBox(height: 16),

                // Recent Records
                _buildRecentRecordsCard(attendanceRecords),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsCard(Subject subject, int weeklyAttended) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Subject Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                SubjectIcons.getIcon(subject.icon),
                size: 40,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 20),
            // Stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatItem(
                        'Attended',
                        subject.attendedClasses.toString(),
                        AppTheme.successColor,
                      ),
                      const SizedBox(width: 16),
                      _buildStatItem(
                        'Total',
                        subject.totalClasses.toString(),
                        AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 16),
                      _buildStatItem(
                        'Weekly',
                        '$weeklyAttended/${subject.weeklyGoal}',
                        AppTheme.warningColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Percentage
            CircularProgressWithPercentage(
              percentage: subject.attendancePercentage,
              size: 80,
              strokeWidth: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildAttendanceChart(Subject subject) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendance Overview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: subject.attendedClasses.toDouble(),
                      title: 'Attended\n${subject.attendedClasses}',
                      color: AppTheme.successColor,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: (subject.totalClasses - subject.attendedClasses)
                          .toDouble(),
                      title:
                          'Missed\n${subject.totalClasses - subject.attendedClasses}',
                      color: AppTheme.errorColor,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  centerSpaceRadius: 0,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Attended', AppTheme.successColor),
                const SizedBox(width: 24),
                _buildLegendItem('Missed', AppTheme.errorColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildWeeklyProgressCard(Subject subject, int weeklyAttended) {
    final weeklyProgress = subject.weeklyGoal > 0
        ? (weeklyAttended / subject.weeklyGoal * 100).clamp(0, 100).toDouble()
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Weekly Progress',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: weeklyProgress >= 100
                        ? AppTheme.successColor.withOpacity(0.1)
                        : AppTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    weeklyProgress >= 100 ? 'Goal Met!' : 'In Progress',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: weeklyProgress >= 100
                          ? AppTheme.successColor
                          : AppTheme.warningColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LabeledProgressBar(
              label: 'Classes this week',
              percentage: weeklyProgress,
            ),
            const SizedBox(height: 8),
            Text(
              '$weeklyAttended of ${subject.weeklyGoal} classes attended',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRecordsCard(List<AttendanceRecord> records) {
    final recentRecords = records.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Records',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (recentRecords.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No attendance records yet',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentRecords.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final record = recentRecords[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getStatusColor(record.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getStatusIcon(record.status),
                        color: _getStatusColor(record.status),
                      ),
                    ),
                    title: Text(
                      DateFormat('EEEE, MMM dd').format(record.date),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      DateFormat('hh:mm a').format(record.date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    trailing: Text(
                      _getStatusLabel(record.status),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(record.status),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    AttendanceProvider provider,
    Subject subject,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text(
          'Are you sure you want to delete "${subject.name}"?\n\nThis will also delete all attendance records for this subject. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              final success = await provider.deleteSubject(subjectId);
              if (success && context.mounted) {
                Navigator.pop(context); // Go back to home
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Subject deleted successfully'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ClassStatus status) {
    switch (status) {
      case ClassStatus.attended:
        return AppTheme.successColor;
      case ClassStatus.missed:
        return AppTheme.errorColor;
      case ClassStatus.cancelled:
        return AppTheme.warningColor;
    }
  }

  IconData _getStatusIcon(ClassStatus status) {
    switch (status) {
      case ClassStatus.attended:
        return Icons.check_circle;
      case ClassStatus.missed:
        return Icons.cancel;
      case ClassStatus.cancelled:
        return Icons.event_busy;
    }
  }

  String _getStatusLabel(ClassStatus status) {
    switch (status) {
      case ClassStatus.attended:
        return 'Attended';
      case ClassStatus.missed:
        return 'Missed';
      case ClassStatus.cancelled:
        return 'Cancelled';
    }
  }

  Widget _buildPredictionCard(Subject subject, AttendanceProvider provider) {
    final predictIfAttend = provider.getPredictedAttendanceIfAttend(subjectId);
    final predictIfMiss = provider.getPredictedAttendanceIfMiss(subjectId);
    final warning = provider.getAttendanceWarning(subjectId);
    final willDrop = provider.willDropBelowThreshold(subjectId);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Attendance Prediction',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (subject.totalClasses == 0)
              const Text(
                'Start attending classes to see predictions',
                style: TextStyle(color: AppTheme.textSecondary),
              )
            else ...[
              // If attend next class
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.successColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up, color: AppTheme.successColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'If you attend: ${predictIfAttend.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.successColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // If miss next class
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      (willDrop ? AppTheme.errorColor : AppTheme.warningColor)
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        (willDrop ? AppTheme.errorColor : AppTheme.warningColor)
                            .withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_down,
                      color: willDrop
                          ? AppTheme.errorColor
                          : AppTheme.warningColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'If you miss: ${predictIfMiss.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: willDrop
                              ? AppTheme.errorColor
                              : AppTheme.warningColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Warning message
              if (warning != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          warning,
                          style: const TextStyle(
                            color: AppTheme.errorColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBunkCalculatorCard(
    Subject subject,
    AttendanceProvider provider,
    BuildContext context,
  ) {
    final safeBunks = provider.calculateSafeBunks(subjectId);
    final bunkMessage = provider.getBunkMessage(subjectId);
    final isSafe = safeBunks > 0;
    final isBelow =
        subject.totalClasses > 0 &&
        subject.attendancePercentage < subject.overallGoalPercentage;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calculate_outlined,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Bunk Calculator',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                // Refresh button
                IconButton(
                  icon: const Icon(Icons.refresh),
                  color: AppTheme.primaryColor,
                  tooltip: 'Refresh calculations',
                  onPressed: () {
                    provider.refresh();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bunk calculator refreshed'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isBelow
                    ? AppTheme.errorColor.withOpacity(0.1)
                    : isSafe
                    ? AppTheme.successColor.withOpacity(0.1)
                    : AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    isBelow
                        ? '⚠️'
                        : isSafe
                        ? '✅'
                        : '⚡',
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 8),
                  if (subject.totalClasses > 0 && !isBelow)
                    Text(
                      '$safeBunks',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: isSafe
                            ? AppTheme.successColor
                            : AppTheme.warningColor,
                      ),
                    ),
                  Text(
                    bunkMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isBelow
                          ? AppTheme.errorColor
                          : isSafe
                          ? AppTheme.successColor
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
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

  Widget _buildSemesterEndedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
      ),
      child: Row(
        children: const [
          Icon(Icons.lock_outline, color: AppTheme.errorColor, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Semester Completed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.errorColor,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Attendance is locked. No further changes allowed.',
                  style: TextStyle(color: AppTheme.errorColor, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterInfoCard(Subject subject, AttendanceProvider provider) {
    final remainingClasses = provider.getRemainingClasses(subjectId);
    final remainingDays = provider.getRemainingDays();
    final remainingWeeks = provider.getRemainingWeeks();
    final semesterWarning = provider.getSemesterAwareWarning(subjectId);

    return Card(
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Semester Progress',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        provider.getSemesterStatusMessage(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSemesterStatItem(
                    value: '$remainingClasses',
                    label: 'Classes Left',
                    icon: Icons.class_outlined,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Expanded(
                  child: _buildSemesterStatItem(
                    value: '$remainingDays',
                    label: 'Days Left',
                    icon: Icons.today,
                    color: AppTheme.warningColor,
                  ),
                ),
                Expanded(
                  child: _buildSemesterStatItem(
                    value: '$remainingWeeks',
                    label: 'Weeks Left',
                    icon: Icons.date_range,
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
            if (semesterWarning != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  semesterWarning,
                  style: const TextStyle(
                    color: AppTheme.warningColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSemesterStatItem({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

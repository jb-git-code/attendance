import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              subject.name,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 20),
                  color: AppTheme.primaryColor,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddEditSubjectScreen(subjectId: subjectId),
                      ),
                    );
                  },
                ),
              ),
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
                  onPressed: () =>
                      _showDeleteDialog(context, provider, subject),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 340;
        final isMediumScreen = constraints.maxWidth < 380;
        final iconSize = isSmallScreen ? 56.0 : (isMediumScreen ? 64.0 : 80.0);
        final iconIconSize = isSmallScreen
            ? 28.0
            : (isMediumScreen ? 32.0 : 40.0);
        final progressSize = isSmallScreen
            ? 56.0
            : (isMediumScreen ? 64.0 : 80.0);
        final progressStroke = isSmallScreen
            ? 5.0
            : (isMediumScreen ? 6.0 : 8.0);
        final titleFontSize = isSmallScreen
            ? 16.0
            : (isMediumScreen ? 18.0 : 20.0);
        final padding = isSmallScreen ? 14.0 : (isMediumScreen ? 16.0 : 20.0);
        final spacing = isSmallScreen ? 10.0 : (isMediumScreen ? 14.0 : 20.0);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Row(
              children: [
                // Subject Icon
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    boxShadow: AppTheme.primaryShadow(0.2),
                  ),
                  child: Icon(
                    SubjectIcons.getIcon(subject.icon),
                    size: iconIconSize,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: spacing),
                // Stats
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: isSmallScreen ? 8 : 12,
                        runSpacing: 8,
                        children: [
                          _buildStatItem(
                            'Attended',
                            subject.attendedClasses.toString(),
                            AppTheme.successColor,
                            isSmall: isSmallScreen,
                          ),
                          _buildStatItem(
                            'Total',
                            subject.totalClasses.toString(),
                            AppTheme.primaryColor,
                            isSmall: isSmallScreen,
                          ),
                          _buildStatItem(
                            'Weekly',
                            '$weeklyAttended/${subject.weeklyGoal}',
                            AppTheme.warningColor,
                            isSmall: isSmallScreen,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                // Percentage
                CircularProgressWithPercentage(
                  percentage: subject.attendancePercentage,
                  size: progressSize,
                  strokeWidth: progressStroke,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color, {
    bool isSmall = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: isSmall ? 14 : 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmall ? 10 : 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceChart(Subject subject) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Icon(
                    Icons.pie_chart_rounded,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Attendance Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: const Icon(
                        Icons.trending_up_rounded,
                        color: AppTheme.warningColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Weekly Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
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
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: AppTheme.secondaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Recent Records',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
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
    HapticFeedback.mediumImpact();
    showDialog(
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
          'Are you sure you want to delete "${subject.name}"?\n\nThis will also delete all attendance records for this subject. This action cannot be undone.',
          style: const TextStyle(color: AppTheme.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              Navigator.pop(context); // Close dialog
              final success = await provider.deleteSubject(subjectId);
              if (success && context.mounted) {
                Navigator.pop(context); // Go back to home
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
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
        return Icons.check_circle_rounded;
      case ClassStatus.missed:
        return Icons.cancel_rounded;
      case ClassStatus.cancelled:
        return Icons.event_busy_rounded;
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
    final currentPercentage = subject.attendancePercentage;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 340;
        final cardPadding = isSmallScreen ? 12.0 : 16.0;
        final predictionFontSize = isSmallScreen ? 20.0 : 24.0;
        final labelFontSize = isSmallScreen ? 11.0 : 12.0;
        final iconSize = isSmallScreen ? 20.0 : 24.0;
        final iconPadding = isSmallScreen ? 8.0 : 10.0;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(cardPadding),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusLg),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: const Icon(
                        Icons.analytics_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Attendance Prediction',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Column(
                  children: [
                    if (subject.totalClasses == 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 16 : 24,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.hourglass_empty_rounded,
                              size: isSmallScreen ? 36 : 48,
                              color: AppTheme.textTertiary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Start attending classes to see predictions',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else ...[
                      // Current percentage
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12 : 16,
                          vertical: isSmallScreen ? 10 : 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Current: ',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                            Text(
                              '${currentPercentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Prediction cards row
                      Row(
                        children: [
                          // If attend card
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.successColor.withOpacity(0.15),
                                    AppTheme.successColor.withOpacity(0.05),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMd,
                                ),
                                border: Border.all(
                                  color: AppTheme.successColor.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(iconPadding),
                                    decoration: BoxDecoration(
                                      color: AppTheme.successColor.withOpacity(
                                        0.2,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      color: AppTheme.successColor,
                                      size: iconSize,
                                    ),
                                  ),
                                  SizedBox(height: isSmallScreen ? 8 : 12),
                                  Text(
                                    'If Attend',
                                    style: TextStyle(
                                      fontSize: labelFontSize,
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '${predictIfAttend.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: predictionFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.successColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_upward_rounded,
                                        size: isSmallScreen ? 12 : 14,
                                        color: AppTheme.successColor,
                                      ),
                                      Text(
                                        '+${(predictIfAttend - currentPercentage).toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 10 : 12,
                                          color: AppTheme.successColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 8 : 12),
                          // If miss card
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    (willDrop
                                            ? AppTheme.errorColor
                                            : AppTheme.warningColor)
                                        .withOpacity(0.15),
                                    (willDrop
                                            ? AppTheme.errorColor
                                            : AppTheme.warningColor)
                                        .withOpacity(0.05),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMd,
                                ),
                                border: Border.all(
                                  color:
                                      (willDrop
                                              ? AppTheme.errorColor
                                              : AppTheme.warningColor)
                                          .withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(iconPadding),
                                    decoration: BoxDecoration(
                                      color:
                                          (willDrop
                                                  ? AppTheme.errorColor
                                                  : AppTheme.warningColor)
                                              .withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      willDrop
                                          ? Icons.cancel_rounded
                                          : Icons.remove_circle_rounded,
                                      color: willDrop
                                          ? AppTheme.errorColor
                                          : AppTheme.warningColor,
                                      size: iconSize,
                                    ),
                                  ),
                                  SizedBox(height: isSmallScreen ? 8 : 12),
                                  Text(
                                    'If Miss',
                                    style: TextStyle(
                                      fontSize: labelFontSize,
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '${predictIfMiss.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: predictionFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: willDrop
                                            ? AppTheme.errorColor
                                            : AppTheme.warningColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_downward_rounded,
                                        size: isSmallScreen ? 12 : 14,
                                        color: willDrop
                                            ? AppTheme.errorColor
                                            : AppTheme.warningColor,
                                      ),
                                      Text(
                                        '${(predictIfMiss - currentPercentage).toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 10 : 12,
                                          color: willDrop
                                              ? AppTheme.errorColor
                                              : AppTheme.warningColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Warning message
                      if (warning != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMd,
                            ),
                            border: Border.all(
                              color: AppTheme.errorColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: AppTheme.errorColor,
                                size: isSmallScreen ? 18 : 20,
                              ),
                              SizedBox(width: isSmallScreen ? 8 : 10),
                              Expanded(
                                child: Text(
                                  warning,
                                  style: TextStyle(
                                    color: AppTheme.errorColor,
                                    fontSize: isSmallScreen ? 11 : 13,
                                    fontWeight: FontWeight.w500,
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildBunkCalculatorCard(
    Subject subject,
    AttendanceProvider provider,
    BuildContext context,
  ) {
    final safeBunks = provider.calculateSafeBunks(subjectId);
    final remainingClasses = provider.getRemainingClasses(subjectId);
    final isSafe = safeBunks > 0;
    final isBelow =
        subject.totalClasses > 0 &&
        subject.attendancePercentage < subject.overallGoalPercentage;
    final targetPercentage = subject.overallGoalPercentage.toInt();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 340;
        final cardPadding = isSmallScreen ? 14.0 : 20.0;
        final bunkFontSize = isSmallScreen ? 44.0 : 56.0;
        final labelFontSize = isSmallScreen ? 12.0 : 14.0;
        final subLabelFontSize = isSmallScreen ? 11.0 : 13.0;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            children: [
              // Header with gradient
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isBelow
                        ? [
                            AppTheme.errorColor,
                            AppTheme.errorColor.withOpacity(0.8),
                          ]
                        : isSafe
                        ? [
                            AppTheme.successColor,
                            AppTheme.successColor.withOpacity(0.8),
                          ]
                        : [
                            AppTheme.warningColor,
                            AppTheme.warningColor.withOpacity(0.8),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusLg),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: const Icon(
                        Icons.calculate_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bunk Calculator',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Column(
                  children: [
                    // Main bunk display
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 18 : 24,
                      ),
                      decoration: BoxDecoration(
                        color: isBelow
                            ? AppTheme.errorColor.withOpacity(0.08)
                            : isSafe
                            ? AppTheme.successColor.withOpacity(0.08)
                            : AppTheme.warningColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: Column(
                        children: [
                          if (subject.totalClasses == 0) ...[
                            Icon(
                              Icons.hourglass_empty_rounded,
                              size: isSmallScreen ? 36 : 48,
                              color: AppTheme.textTertiary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No classes yet',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: labelFontSize,
                              ),
                            ),
                            Text(
                              'Start tracking to see your bunk allowance',
                              style: TextStyle(
                                color: AppTheme.textTertiary,
                                fontSize: isSmallScreen ? 11 : 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ] else if (isBelow) ...[
                            Container(
                              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                              decoration: BoxDecoration(
                                color: AppTheme.errorColor.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.warning_rounded,
                                size: isSmallScreen ? 32 : 40,
                                color: AppTheme.errorColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Below Target',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.errorColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'You need to recover attendance first',
                              style: TextStyle(
                                fontSize: subLabelFontSize,
                                color: AppTheme.errorColor.withOpacity(0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ] else ...[
                            Text(
                              isSafe
                                  ? 'You can safely skip'
                                  : 'No bunks available',
                              style: TextStyle(
                                fontSize: labelFontSize,
                                color: isSafe
                                    ? AppTheme.successColor
                                    : AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '$safeBunks',
                                    style: TextStyle(
                                      fontSize: bunkFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: isSafe
                                          ? AppTheme.successColor
                                          : AppTheme.warningColor,
                                      height: 1,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 4,
                                    bottom: isSmallScreen ? 6 : 8,
                                  ),
                                  child: Text(
                                    safeBunks == 1 ? 'class' : 'classes',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 14 : 16,
                                      color: isSafe
                                          ? AppTheme.successColor.withOpacity(
                                              0.8,
                                            )
                                          : AppTheme.warningColor.withOpacity(
                                              0.8,
                                            ),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'and stay above $targetPercentage%',
                              style: TextStyle(
                                fontSize: subLabelFontSize,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Stats row - show only when below target
                    if (subject.totalClasses > 0 && isBelow) ...[
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildBunkStat(
                                'Remaining',
                                '$remainingClasses',
                                Icons.event_available_rounded,
                                isSmall: isSmallScreen,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: isSmallScreen ? 32 : 40,
                              color: AppTheme.dividerColor,
                            ),
                            Expanded(
                              child: _buildBunkStat(
                                'Must Attend',
                                '${provider.getClassesNeededToRecover(subjectId)}',
                                Icons.check_circle_outline_rounded,
                                isSmall: isSmallScreen,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: isSmallScreen ? 32 : 40,
                              color: AppTheme.dividerColor,
                            ),
                            Expanded(
                              child: _buildBunkStat(
                                'Target',
                                '$targetPercentage%',
                                Icons.flag_rounded,
                                isSmall: isSmallScreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBunkStat(
    String label,
    String value,
    IconData icon, {
    bool isSmall = false,
  }) {
    return Column(
      children: [
        Icon(icon, size: isSmall ? 16 : 18, color: AppTheme.textTertiary),
        SizedBox(height: isSmall ? 4 : 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: isSmall ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        SizedBox(height: isSmall ? 1 : 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary),
        ),
      ],
    );
  }

  Widget _buildSemesterEndedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: AppTheme.errorColor,
            size: 28,
          ),
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

    return Container(
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
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.white,
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
                    icon: Icons.class_rounded,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Expanded(
                  child: _buildSemesterStatItem(
                    value: '$remainingDays',
                    label: 'Days Left',
                    icon: Icons.today_rounded,
                    color: AppTheme.warningColor,
                  ),
                ),
                Expanded(
                  child: _buildSemesterStatItem(
                    value: '$remainingWeeks',
                    label: 'Weeks Left',
                    icon: Icons.date_range_rounded,
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
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
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

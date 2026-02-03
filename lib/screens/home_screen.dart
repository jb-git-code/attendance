import 'dart:math' as math;
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
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late Animation<double> _cardSlideAnimation;
  late Animation<double> _cardFadeAnimation;
  late Animation<double> _cardScaleAnimation;
  bool _hasShownSemesterPrompt = false;

  @override
  void initState() {
    super.initState();
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _cardSlideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _cardFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _cardScaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _cardAnimationController.forward();

    // Check and show semester dates prompt after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowSemesterPrompt();
    });
  }

  void _checkAndShowSemesterPrompt() {
    if (_hasShownSemesterPrompt) return;

    final provider = Provider.of<AttendanceProvider>(context, listen: false);
    if (!provider.hasSemesterDates) {
      _hasShownSemesterPrompt = true;
      _showSetSemesterDatesDialog();
    }
  }

  void _showSetSemesterDatesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Welcome to Classy!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set your semester dates first to get the most out of the app.',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'This helps calculate predictions and bunk allowances accurately.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Set Dates'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    super.dispose();
  }

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
      extendBody: true,
      extendBodyBehindAppBar: false,
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Classy',
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
                // Bottom padding for FAB and navigation bar
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 80 + MediaQuery.of(context).padding.bottom,
                  ),
                ),
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
    final titleFontSize = isSmallScreen ? 13.0 : 15.0;
    final cardPadding = isSmallScreen ? 16.0 : 22.0;
    final percentage = stats['percentage'] as double;
    final ringSize = isSmallScreen ? 90.0 : 110.0;

    return AnimatedBuilder(
      animation: _cardAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _cardSlideAnimation.value),
          child: Transform.scale(
            scale: _cardScaleAnimation.value,
            child: Opacity(opacity: _cardFadeAnimation.value, child: child),
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _showOverallStatsDetails(context, provider),
        child: Container(
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
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, value, child) {
                      return Transform.rotate(
                        angle: (1 - value) * math.pi * 0.5,
                        child: Opacity(
                          opacity: value,
                          child: Container(
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
                        ),
                      );
                    },
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
                  const Spacer(),
                  // Tap hint icon
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Animated circular progress
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    tween: Tween<double>(begin: 0, end: percentage / 100),
                    builder: (context, value, child) {
                      return SizedBox(
                        width: ringSize,
                        height: ringSize,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Background ring
                            SizedBox(
                              width: ringSize,
                              height: ringSize,
                              child: CircularProgressIndicator(
                                value: 1,
                                strokeWidth: 8,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withOpacity(0.15),
                                ),
                              ),
                            ),
                            // Animated progress ring
                            SizedBox(
                              width: ringSize,
                              height: ringSize,
                              child: CircularProgressIndicator(
                                value: value,
                                strokeWidth: 8,
                                strokeCap: StrokeCap.round,
                                backgroundColor: Colors.transparent,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            // Percentage text
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${(value * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 18.0 : 22.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  // Stats column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TweenAnimationBuilder<int>(
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeOutCubic,
                          tween: IntTween(
                            begin: 0,
                            end: stats['totalAttended'] as int,
                          ),
                          builder: (context, value, child) {
                            return _buildAnimatedStatRow(
                              icon: Icons.check_circle_rounded,
                              label: 'Attended',
                              value: '$value',
                              delay: 0,
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        TweenAnimationBuilder<int>(
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeOutCubic,
                          tween: IntTween(
                            begin: 0,
                            end: stats['totalClasses'] as int,
                          ),
                          builder: (context, value, child) {
                            return _buildAnimatedStatRow(
                              icon: Icons.calendar_today_rounded,
                              label: 'Total',
                              value: '$value',
                              delay: 100,
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        TweenAnimationBuilder<int>(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          tween: IntTween(
                            begin: 0,
                            end: stats['subjectCount'] as int,
                          ),
                          builder: (context, value, child) {
                            return _buildAnimatedStatRow(
                              icon: Icons.school_rounded,
                              label: 'Subjects',
                              value: '$value',
                              delay: 200,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOverallStatsDetails(
    BuildContext context,
    AttendanceProvider provider,
  ) {
    HapticFeedback.mediumImpact();
    final stats = provider.getOverallStats();
    final subjects = provider.subjects;
    final percentage = stats['percentage'] as double;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.analytics_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Attendance Overview',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'Detailed breakdown by subject',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Overall summary card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      '${percentage.toStringAsFixed(1)}%',
                      'Overall',
                      Icons.pie_chart_rounded,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    _buildSummaryItem(
                      '${stats['totalAttended']}/${stats['totalClasses']}',
                      'Classes',
                      Icons.calendar_today_rounded,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    _buildSummaryItem(
                      '${subjects.length}',
                      'Subjects',
                      Icons.school_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Semester info
              if (provider.semesterStartDate != null ||
                  provider.semesterEndDate != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          provider.isSemesterEnded
                              ? Icons.lock_rounded
                              : Icons.event_rounded,
                          color: AppTheme.accentColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            provider.getSemesterStatusMessage(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              // Subject list header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Text(
                      'Subject Breakdown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${subjects.length} subjects',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Subject list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    return _buildSubjectBreakdownItem(subject, provider);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _buildSubjectBreakdownItem(
    Subject subject,
    AttendanceProvider provider,
  ) {
    final percentage = subject.attendancePercentage;
    final isAtRisk = percentage < subject.overallGoalPercentage;
    final safeBunks = provider.calculateSafeBunks(subject.id);
    final weeklyAttended = provider.getWeeklyAttendedCount(subject.id);

    Color statusColor;
    if (percentage >= subject.overallGoalPercentage) {
      statusColor = AppTheme.successColor;
    } else if (percentage >= subject.overallGoalPercentage - 10) {
      statusColor = AppTheme.warningColor;
    } else {
      statusColor = AppTheme.errorColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  subject.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMiniStat(
                Icons.check_circle_outline_rounded,
                '${subject.attendedClasses}/${subject.totalClasses}',
                'Classes',
              ),
              const SizedBox(width: 16),
              _buildMiniStat(
                Icons.calendar_view_week_rounded,
                '$weeklyAttended/${subject.weeklyGoal}',
                'This Week',
              ),
              const SizedBox(width: 16),
              _buildMiniStat(
                isAtRisk
                    ? Icons.warning_amber_rounded
                    : Icons.beach_access_rounded,
                isAtRisk ? 'At Risk' : '$safeBunks left',
                isAtRisk ? 'Status' : 'Safe Bunks',
                isWarning: isAtRisk,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
    IconData icon,
    String value,
    String label, {
    bool isWarning = false,
  }) {
    final color = isWarning ? AppTheme.errorColor : AppTheme.textSecondary;
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isWarning ? color : AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedStatRow({
    required IconData icon,
    required String label,
    required String value,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOut,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, animValue, child) {
        return Transform.translate(
          offset: Offset(20 * (1 - animValue), 0),
          child: Opacity(
            opacity: animValue,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
    final isMediumScreen = screenWidth < 400;
    final iconContainerSize = isSmallScreen
        ? 44.0
        : (isMediumScreen ? 48.0 : 52.0);
    final iconSize = isSmallScreen ? 22.0 : (isMediumScreen ? 24.0 : 26.0);
    final circularProgressSize = isSmallScreen
        ? 52.0
        : (isMediumScreen ? 56.0 : 60.0);
    final circularStrokeWidth = isSmallScreen ? 4.5 : 5.0;
    final cardPadding = isSmallScreen ? 12.0 : 14.0;
    final nameFontSize = isSmallScreen ? 14.0 : 15.0;
    final statValueFontSize = isSmallScreen ? 13.0 : 14.0;
    final statLabelFontSize = isSmallScreen ? 10.0 : 11.0;

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
                        borderRadius: BorderRadius.circular(12),
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
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.errorColor,
                                AppTheme.errorColor.withOpacity(0.8),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
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
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: isSmallScreen ? 10.0 : 12.0),
                // Subject Info with flexible stats
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name row with optional action button
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
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 8 : 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: needsUpdate
                                      ? AppTheme.primaryColor
                                      : _getStatusColor(todayRecord?.status),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      needsUpdate
                                          ? Icons.add_circle_outline_rounded
                                          : _getStatusIcon(todayRecord?.status),
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                    SizedBox(width: isSmallScreen ? 2 : 4),
                                    Text(
                                      needsUpdate
                                          ? 'Mark'
                                          : _getStatusLabel(
                                              todayRecord?.status,
                                            ),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isSmallScreen ? 10 : 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 10),
                      // Flexible stats row
                      Row(
                        children: [
                          _buildFlexibleStat(
                            value: '${subject.attendedClasses}',
                            label: 'Attended',
                            color: AppTheme.successColor,
                            valueFontSize: statValueFontSize,
                            labelFontSize: statLabelFontSize,
                          ),
                          SizedBox(width: isSmallScreen ? 12 : 16),
                          _buildFlexibleStat(
                            value: '${subject.totalClasses}',
                            label: 'Total',
                            color: AppTheme.textSecondary,
                            valueFontSize: statValueFontSize,
                            labelFontSize: statLabelFontSize,
                          ),
                          SizedBox(width: isSmallScreen ? 12 : 16),
                          _buildFlexibleStat(
                            value: '$weeklyAttended/${subject.weeklyGoal}',
                            label: 'Weekly',
                            color: _getProgressColor(weeklyProgress),
                            valueFontSize: statValueFontSize,
                            labelFontSize: statLabelFontSize,
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

  Widget _buildFlexibleStat({
    required String value,
    required String label,
    required Color color,
    required double valueFontSize,
    required double labelFontSize,
  }) {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: labelFontSize,
              color: AppTheme.textTertiary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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

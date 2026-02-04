import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/providers.dart';
import '../utils/theme.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';

/// Profile screen showing user information and settings
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.getPrimaryColor(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppTheme.getPrimaryColor(context),
            ),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
      ),
      body: Consumer2<AuthProvider, AttendanceProvider>(
        builder: (context, authProvider, attendanceProvider, _) {
          final user = authProvider.user;
          final stats = attendanceProvider.getOverallStats();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              children: [
                // Profile Card
                Container(
                  decoration: AppTheme.getCardDecoration(context),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: AppTheme.getPrimaryGradient(context),
                            shape: BoxShape.circle,
                            boxShadow: AppTheme.isDark(context)
                                ? null
                                : AppTheme.primaryShadow(0.25),
                          ),
                          child: Center(
                            child: Text(
                              _getInitials(user?.displayName ?? user?.email),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Name
                        Text(
                          user?.displayName ?? 'User',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getTextPrimary(context),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Email
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.getBackgroundColor(context),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user?.email ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.getTextSecondary(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Stats Card
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmallScreen = constraints.maxWidth < 340;
                    final iconSize = isSmallScreen ? 44.0 : 56.0;
                    final valueFontSize = isSmallScreen ? 16.0 : 20.0;
                    final labelFontSize = isSmallScreen ? 10.0 : 12.0;
                    final iconIconSize = isSmallScreen ? 22.0 : 28.0;

                    return Container(
                      decoration: AppTheme.getCardDecoration(context),
                      child: Padding(
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.bar_chart_rounded,
                                    color: AppTheme.primaryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Your Statistics',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 15 : 17,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.getTextPrimary(context),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isSmallScreen ? 16 : 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItemResponsive(
                                  context: context,
                                  icon: Icons.school_rounded,
                                  value: '${stats['subjectCount']}',
                                  label: 'Subjects',
                                  color: AppTheme.getPrimaryColor(context),
                                  iconSize: iconSize,
                                  iconIconSize: iconIconSize,
                                  valueFontSize: valueFontSize,
                                  labelFontSize: labelFontSize,
                                ),
                                _buildStatItemResponsive(
                                  context: context,
                                  icon: Icons.check_circle_rounded,
                                  value: '${stats['totalAttended']}',
                                  label: 'Attended',
                                  color: AppTheme.successColor,
                                  iconSize: iconSize,
                                  iconIconSize: iconIconSize,
                                  valueFontSize: valueFontSize,
                                  labelFontSize: labelFontSize,
                                ),
                                _buildStatItemResponsive(
                                  context: context,
                                  icon: Icons.calendar_today_rounded,
                                  value: '${stats['totalClasses']}',
                                  label: 'Total',
                                  color: AppTheme.warningColor,
                                  iconSize: iconSize,
                                  iconIconSize: iconIconSize,
                                  valueFontSize: valueFontSize,
                                  labelFontSize: labelFontSize,
                                ),
                              ],
                            ),
                            SizedBox(height: isSmallScreen ? 16 : 20),
                            LabeledProgressBar(
                              label: 'Overall Attendance',
                              percentage: stats['percentage'],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Semester Settings Card
                _buildSemesterSettingsCard(context, attendanceProvider),
                const SizedBox(height: 16),

                // Weekly Summary Card
                _buildWeeklySummaryCard(context, attendanceProvider),
                const SizedBox(height: 16),

                // Settings Section
                Container(
                  decoration: AppTheme.getCardDecoration(context),
                  child: Column(
                    children: [
                      // Dark Mode Toggle
                      Consumer<ThemeProvider>(
                        builder: (context, themeProvider, _) {
                          return _buildSettingsTileWithSwitch(
                            context: context,
                            icon: themeProvider.isDarkMode
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            title: 'Dark Mode',
                            subtitle: themeProvider.isDarkMode
                                ? 'Switch to light theme'
                                : 'Switch to dark theme',
                            value: themeProvider.isDarkMode,
                            onChanged: (value) {
                              HapticFeedback.lightImpact();
                              themeProvider.toggleTheme();
                            },
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 70),
                      _buildSettingsTile(
                        context: context,
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle: 'Manage notification preferences',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showNotificationSettings(context);
                        },
                      ),
                      const Divider(height: 1, indent: 70),
                      _buildSettingsTile(
                        context: context,
                        icon: Icons.info_outline_rounded,
                        title: 'About',
                        subtitle: 'App version and info',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showAboutDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return OutlinedButton.icon(
                        onPressed: () => _handleLogout(context),
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Sign Out'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                          side: const BorderSide(color: AppTheme.errorColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'U';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Widget _buildStatItem({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
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
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.getTextSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItemResponsive({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required double iconSize,
    required double iconIconSize,
    required double valueFontSize,
    required double labelFontSize,
  }) {
    return Flexible(
      child: Column(
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: iconIconSize),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: valueFontSize,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: labelFontSize,
              color: AppTheme.getTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.getPrimaryColor(context).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.getPrimaryColor(context)),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: AppTheme.getTextPrimary(context),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.getTextSecondary(context),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppTheme.getTextSecondary(context),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSettingsTileWithSwitch({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: value
              ? AppTheme.darkPrimaryGreen.withOpacity(0.15)
              : AppTheme.getPrimaryColor(context).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: value
              ? AppTheme.darkPrimaryGreen
              : AppTheme.getPrimaryColor(context),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: AppTheme.getTextPrimary(context),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.getTextSecondary(context),
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.darkPrimaryGreen,
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.getSurfaceColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXl),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.getTextSecondary(
                        context,
                      ).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: const Icon(
                        Icons.notifications_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Notification Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getTextPrimary(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: SwitchListTile(
                    title: const Text(
                      'Daily Reminders',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      'Receive reminders on weekdays',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.getTextSecondary(context),
                      ),
                    ),
                    value: true,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      // TODO: Implement notification toggle
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: SwitchListTile(
                    title: const Text(
                      'Weekly Summary',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      'Get summary every Saturday',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.getTextSecondary(context),
                      ),
                    ),
                    value: true,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      // TODO: Implement notification toggle
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    HapticFeedback.lightImpact();
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
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'About',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: const Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Classy is a privacy-focused, offline-first app to help you track and improve your class attendance.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppTheme.getTextSecondary(context),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.getTextSecondary(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Icon(
                    Icons.code_rounded,
                    size: 16,
                    color: AppTheme.getTextSecondary(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Developed by',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.getTextTertiary(context),
                        ),
                      ),
                      Text(
                        'Jayanshu Bhardwaj',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextPrimary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                HapticFeedback.lightImpact();
                // Close the dialog first
                Navigator.of(context).pop();
                // Then launch the URL
                final url = Uri.parse('https://github.com/jb-git-code');
                try {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } catch (e) {
                  // URL launch failed
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.open_in_new_rounded,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'https://github.com/jb-git-code',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
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
                Icons.logout_rounded,
                color: AppTheme.errorColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Logout',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout? Your data will remain saved locally.',
          style: TextStyle(
            color: AppTheme.getTextSecondary(context),
            height: 1.4,
          ),
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
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final attendanceProvider = Provider.of<AttendanceProvider>(
        context,
        listen: false,
      );

      await attendanceProvider.clearAllData();
      await authProvider.signOut();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Widget _buildWeeklySummaryCard(
    BuildContext context,
    AttendanceProvider provider,
  ) {
    final summary = provider.generateWeeklySummary();
    final totalClasses = summary['totalClasses'] as int;
    final totalAttended = summary['totalAttended'] as int;
    final message = summary['message'] as String;
    final achievedSubjects = summary['achievedSubjects'] as List<String>;
    final needsAttentionSubjects =
        summary['needsAttentionSubjects'] as List<String>;

    return Container(
      decoration: AppTheme.getCardDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: AppTheme.getIconContainerDecoration(
                    context,
                    AppTheme.getPrimaryColor(context),
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: AppTheme.getPrimaryColor(context),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Weekly Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextPrimary(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stats row
            if (totalClasses > 0) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          totalAttended.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.successColor,
                          ),
                        ),
                        Text(
                          'Attended',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.getTextSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppTheme.getTextSecondary(context).withOpacity(0.2),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          (totalClasses - totalAttended).toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.errorColor,
                          ),
                        ),
                        Text(
                          'Missed',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.getTextSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppTheme.getTextSecondary(context).withOpacity(0.2),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          totalClasses.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.getTextSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // AI Message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.05),
                    AppTheme.secondaryColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                ),
              ),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppTheme.getTextPrimary(context),
                ),
              ),
            ),

            // Subject breakdown
            if (achievedSubjects.isNotEmpty ||
                needsAttentionSubjects.isNotEmpty) ...[
              const SizedBox(height: 16),
              if (achievedSubjects.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: achievedSubjects
                      .map(
                        (subject) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 14,
                                color: AppTheme.successColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                subject,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.successColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              if (needsAttentionSubjects.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: needsAttentionSubjects
                      .map(
                        (subject) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.warning_amber,
                                size: 14,
                                color: AppTheme.warningColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                subject,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.warningColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSemesterSettingsCard(
    BuildContext context,
    AttendanceProvider provider,
  ) {
    final startDate = provider.semesterStartDate;
    final endDate = provider.semesterEndDate;
    final hasEnded = provider.isSemesterEnded;
    final statusMessage = provider.getSemesterStatusMessage();

    return Container(
      decoration: AppTheme.getCardDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: AppTheme.getIconContainerDecoration(
                    context,
                    hasEnded
                        ? AppTheme.errorColor
                        : AppTheme.getPrimaryColor(context),
                  ),
                  child: Icon(
                    Icons.calendar_month,
                    color: hasEnded
                        ? AppTheme.errorColor
                        : AppTheme.getPrimaryColor(context),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Semester Schedule',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextPrimary(context),
                        ),
                      ),
                      Text(
                        statusMessage,
                        style: TextStyle(
                          fontSize: 12,
                          color: hasEnded
                              ? AppTheme.errorColor
                              : AppTheme.getTextSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date rows
            Row(
              children: [
                Expanded(
                  child: _buildDateSelector(
                    context: context,
                    label: 'Start Date',
                    date: startDate,
                    icon: Icons.play_circle_outline,
                    onTap: hasEnded
                        ? null
                        : () => _selectSemesterStartDate(context, provider),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateSelector(
                    context: context,
                    label: 'End Date',
                    date: endDate,
                    icon: Icons.stop_circle_outlined,
                    onTap: hasEnded
                        ? null
                        : () => _selectSemesterEndDate(context, provider),
                  ),
                ),
              ],
            ),

            // Remaining time indicator
            if (provider.hasSemesterDates && !hasEnded) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.hourglass_empty,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${provider.getRemainingDays()} days (${provider.getRemainingWeeks()} weeks) remaining',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Semester ended message
            if (hasEnded) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.lock_outline, color: AppTheme.errorColor),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Semester completed. Attendance is locked.',
                        style: TextStyle(
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector({
    required BuildContext context,
    required String label,
    required DateTime? date,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.getBackgroundColor(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.getTextSecondary(context).withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppTheme.getTextSecondary(context)),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.getTextSecondary(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              date != null ? dateFormat.format(date) : 'Not set',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: date != null
                    ? AppTheme.getTextPrimary(context)
                    : AppTheme.getTextSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectSemesterStartDate(
    BuildContext context,
    AttendanceProvider provider,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.semesterStartDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: provider.semesterEndDate ?? DateTime(now.year + 1),
      helpText: 'Select Semester Start Date',
    );
    if (picked != null) {
      await provider.setSemesterStartDate(picked);
    }
  }

  Future<void> _selectSemesterEndDate(
    BuildContext context,
    AttendanceProvider provider,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          provider.semesterEndDate ?? now.add(const Duration(days: 90)),
      firstDate: provider.semesterStartDate ?? now,
      lastDate: DateTime(now.year + 2),
      helpText: 'Select Semester End Date',
    );
    if (picked != null) {
      await provider.setSemesterEndDate(picked);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/widgets.dart';

/// Complete example integrating dark mode into your app's workflow
class IntegrationGuide {
  /// STEP 1: The theme provider is already integrated in main.dart
  /// No additional setup needed - it's automatically initialized!

  /// STEP 2: Add theme toggle to your home screen's AppBar
  static AppBar createAppBarWithThemeToggle({
    required String title,
    required BuildContext context,
  }) {
    return AppBar(
      title: Text(title),
      actions: [
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return IconButton(
              icon: Icon(
                themeProvider.themeMode == AppThemeMode.dark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
              ),
              tooltip: 'Toggle Theme',
              onPressed: () => themeProvider.toggleTheme(),
            );
          },
        ),
      ],
    );
  }

  /// STEP 3: Add theme selection to your settings screen
  static Widget createSettingsSection(BuildContext context) {
    return Column(
      children: [
        // Option A: Embedded directly
        const ListTile(title: Text('Theme Settings')),
        ThemeSettingsWidget(
          onThemeChanged: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Theme updated')));
          },
        ),
      ],
    );
  }

  /// STEP 4: Create theme selection buttons
  static Widget createThemeSelectionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const ThemeSelectionDialog(),
            );
          },
          child: const Text('Choose Theme (Dialog)'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (_) => const ThemeSelectionBottomSheet(),
            );
          },
          child: const Text('Choose Theme (Bottom Sheet)'),
        ),
      ],
    );
  }

  /// STEP 5: Display current theme info
  static Widget createThemeInfo(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final themeName = themeProvider.themeMode.toString().split('.').last;
        final isDark = themeProvider.isDarkMode;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme Information',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _InfoRow(label: 'Selected Theme', value: themeName),
                _InfoRow(
                  label: 'Dark Mode Active',
                  value: isDark ? 'Yes' : 'No',
                ),
                _InfoRow(
                  label: 'Brightness',
                  value: Theme.of(
                    context,
                  ).brightness.toString().split('.').last,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// STEP 6: Use theme-aware colors in your custom widgets
  static Color getAdaptiveColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey[800]! : Colors.grey[200]!;
  }

  /// STEP 7: Complete example screen combining everything
  static Widget createCompleteExample(BuildContext context) {
    return Scaffold(
      appBar: createAppBarWithThemeToggle(
        title: 'Theme Example',
        context: context,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme info section
            Text(
              'Current Theme Status',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            createThemeInfo(context),
            const SizedBox(height: 24),

            // Theme selection buttons
            Text(
              'Change Theme',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            createThemeSelectionButtons(context),
            const SizedBox(height: 24),

            // Theme settings section
            Text(
              'Theme Settings',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            ThemeSettingsWidget(
              onThemeChanged: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Theme updated')));
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper widget for displaying info rows
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// ============================================
/// IMPLEMENTATION CHECKLIST
/// ============================================
///
/// ✅ Step 1: ThemeProvider is already initialized in main.dart
///
/// Step 2: Add theme toggle to your AppBar
///   Example: IntegrationGuide.createAppBarWithThemeToggle(...)
///
/// Step 3: Create a Settings screen with theme options
///   Example: IntegrationGuide.createSettingsSection(...)
///
/// Step 4: Add theme selection UI
///   Option A: ThemeSettingsWidget() - direct widget
///   Option B: ThemeSelectionDialog() - modal dialog
///   Option C: ThemeSelectionBottomSheet() - sliding panel
///
/// Step 5: Test all three theme modes:
///   - Light: Always shows light theme
///   - Dark: Always shows dark theme
///   - System: Follows device settings
///
/// Step 6: Verify persistence
///   - Change theme
///   - Close and reopen app
///   - Theme should be preserved
///
/// ============================================
/// USAGE IN YOUR EXISTING CODE
/// ============================================
///
/// 1. In your home_screen.dart:
///    Replace existing AppBar with theme toggle
///    Use: IntegrationGuide.createAppBarWithThemeToggle(...)
///
/// 2. In your profile_screen.dart or settings_screen.dart:
///    Add theme selection widget
///    Use: ThemeSettingsWidget() or ThemeSelectionDialog()
///
/// 3. For custom colors in widgets:
///    Check Theme.of(context).brightness
///    Use: IntegrationGuide.getAdaptiveColor(...)
///
/// ============================================

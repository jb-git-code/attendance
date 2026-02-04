import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

/// Theme settings widget showing theme selection options
class ThemeSettingsWidget extends StatelessWidget {
  final Function? onThemeChanged;

  const ThemeSettingsWidget({super.key, this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Theme',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            _buildThemeOption(
              context,
              title: 'Light',
              mode: AppThemeMode.light,
              icon: Icons.light_mode_rounded,
              isSelected: themeProvider.themeMode == AppThemeMode.light,
              onTap: () async {
                await themeProvider.setThemeMode(AppThemeMode.light);
                onThemeChanged?.call();
              },
            ),
            _buildThemeOption(
              context,
              title: 'Dark',
              mode: AppThemeMode.dark,
              icon: Icons.dark_mode_rounded,
              isSelected: themeProvider.themeMode == AppThemeMode.dark,
              onTap: () async {
                await themeProvider.setThemeMode(AppThemeMode.dark);
                onThemeChanged?.call();
              },
            ),
            _buildThemeOption(
              context,
              title: 'System',
              mode: AppThemeMode.system,
              icon: Icons.brightness_auto_rounded,
              isSelected: themeProvider.themeMode == AppThemeMode.system,
              onTap: () async {
                await themeProvider.setThemeMode(AppThemeMode.system);
                onThemeChanged?.call();
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required AppThemeMode mode,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: isSelected
          ? Icon(
              Icons.check_circle_rounded,
              color: Theme.of(context).primaryColor,
            )
          : null,
      onTap: onTap,
      selected: isSelected,
    );
  }
}

/// Theme selection dialog
class ThemeSelectionDialog extends StatelessWidget {
  const ThemeSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ThemeSettingsWidget(onThemeChanged: () => Navigator.pop(context)),
    );
  }
}

/// Theme selection bottom sheet
class ThemeSelectionBottomSheet extends StatelessWidget {
  const ThemeSelectionBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: ThemeSettingsWidget(
            onThemeChanged: () => Navigator.pop(context),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/widgets.dart';

/// Example: Settings Screen with Theme Selection
class SettingsScreenExample extends StatelessWidget {
  const SettingsScreenExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Theme section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Appearance',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),

          // Option 1: Direct theme selection widget in settings
          ThemeSettingsWidget(
            onThemeChanged: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Theme updated')));
            },
          ),

          const Divider(),

          // Option 2: Show theme in a dialog
          ListTile(
            title: const Text('Change Theme (Dialog)'),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const ThemeSelectionDialog(),
              );
            },
          ),

          // Option 3: Show theme in a bottom sheet
          ListTile(
            title: const Text('Change Theme (Bottom Sheet)'),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => const ThemeSelectionBottomSheet(),
              );
            },
          ),

          // Option 4: Custom theme toggle button
          ListTile(
            title: const Text('Quick Toggle Theme'),
            trailing: Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return IconButton(
                  icon: Icon(
                    themeProvider.themeMode == AppThemeMode.dark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                  ),
                  onPressed: () => themeProvider.toggleTheme(),
                );
              },
            ),
          ),

          // Display current theme
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              final themeName = themeProvider.themeMode
                  .toString()
                  .split('.')
                  .last;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Current Theme',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          themeName.toUpperCase(),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Example: Home screen with theme toggle button in AppBar
class HomeScreenExample extends StatelessWidget {
  const HomeScreenExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
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
      ),
      body: Center(
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getThemeIcon(themeProvider.themeMode),
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Current Theme: ${themeProvider.themeMode.toString().split('.').last}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => const ThemeSelectionBottomSheet(),
                    );
                  },
                  child: const Text('Change Theme'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  IconData _getThemeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.light_mode_rounded;
      case AppThemeMode.dark:
        return Icons.dark_mode_rounded;
      case AppThemeMode.system:
        return Icons.brightness_auto_rounded;
    }
  }
}

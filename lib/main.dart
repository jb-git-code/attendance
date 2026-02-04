import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/providers.dart';
import 'services/services.dart';
import 'screens/splash_screen.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set full screen edge-to-edge mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // Initialize Firebase with platform-specific options (handle if already initialized)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase already initialized, ignore the error
  }

  // Initialize local storage
  final localStorageService = LocalStorageService();
  await localStorageService.init();

  // Initialize notifications (non-blocking to prevent freeze)
  final notificationService = NotificationService();
  try {
    await notificationService.init();
    // Schedule notifications in the background to avoid blocking app startup
    notificationService.scheduleDefaultNotifications().catchError((e) {
      debugPrint('Failed to schedule notifications: $e');
    });
  } catch (e) {
    debugPrint('Notification initialization failed: $e');
  }

  runApp(MyApp(localStorageService: localStorageService));
}

class MyApp extends StatelessWidget {
  final LocalStorageService localStorageService;

  const MyApp({super.key, required this.localStorageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => AttendanceProvider(localStorageService),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(localStorageService),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Classy',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: _getThemeMode(themeProvider.themeMode),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }

  /// Convert ThemeProvider.ThemeMode to Flutter's ThemeMode
  static ThemeMode _getThemeMode(dynamic themeModeEnum) {
    final modeString = themeModeEnum.toString();
    if (modeString.contains('dark')) {
      return ThemeMode.dark;
    } else if (modeString.contains('system')) {
      return ThemeMode.system;
    }
    return ThemeMode.light;
  }
}

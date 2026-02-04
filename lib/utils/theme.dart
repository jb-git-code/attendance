import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// App theme and color constants - Modern Academic Theme
class AppTheme {
  // Primary brand colors - Modern Academic palette
  static const Color primaryColor = Color(
    0xFF2F3E46,
  ); // Dark slate (Cards/AppBar)
  static const Color primaryLight = Color(0xFF4A5B64);
  static const Color primaryDark = Color(0xFF1B2830);

  // Secondary colors
  static const Color secondaryColor = Color(
    0xFFCAD2C5,
  ); // Light sage (Cards light)
  static const Color accentColor = Color(0xFF84A98C); // Medium sage

  // Semantic colors
  static const Color successColor = Color(
    0xFF52796F,
  ); // Progress (Good) - Teal green
  static const Color successLight = Color(0xFFE0EBE8);
  static const Color warningColor = Color(
    0xFFE9C46A,
  ); // Progress (Warning) - Golden yellow
  static const Color warningLight = Color(0xFFFDF8E8);
  static const Color errorColor = Color(0xFFBC4749); // Red for danger
  static const Color errorLight = Color(0xFFFBEBEB);
  static const Color infoColor = Color(0xFF6C8EAD); // Dusty blue

  // Neutral colors - Clean academic tones
  static const Color backgroundColor = Color(0xFFFAFAF7); // Warm off-white
  static const Color surfaceColor = Color(0xFFFFFFFF); // Pure white
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE5E8E4); // Light gray-green

  // Text colors - Dark academic
  static const Color textPrimary = Color(0xFF1B1F23); // Almost black
  static const Color textSecondary = Color(0xFF4A5568); // Medium gray
  static const Color textTertiary = Color(0xFF8A94A0); // Light gray
  static const Color textOnPrimary = Color(0xFFFFFFFFF); // White

  // Gradient presets - Modern Academic gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2F3E46), Color(0xFF4A5B64)], // Dark slate gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF52796F), Color(0xFF6B9080)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFE9C46A), Color(0xFFF0D485)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Premium accent gradients
  static const LinearGradient creamGradient = LinearGradient(
    colors: [Color(0xFFFAFAF7), Color(0xFFF0F2ED)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient luxuryGradient = LinearGradient(
    colors: [Color(0xFF2F3E46), Color(0xFF52796F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows - Cool tones
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF2F3E46).withOpacity(0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: const Color(0xFF2F3E46).withOpacity(0.03),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: const Color(0xFF2F3E46).withOpacity(0.10),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF2F3E46).withOpacity(0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> primaryShadow(double opacity) => [
    BoxShadow(
      color: primaryColor.withOpacity(opacity),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // Border radius
  static const double radiusXs = 6.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radius2Xl = 24.0;
  static const double radiusFull = 999.0; // For pill shapes

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 20.0;
  static const double spacing2Xl = 24.0;
  static const double spacing3Xl = 32.0;

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 250);
  static const Duration animSlow = Duration(milliseconds: 350);

  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: textPrimary, size: 24),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          side: const BorderSide(color: primaryColor, width: 1.5),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingLg,
          vertical: spacingLg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(color: textTertiary, fontSize: 14),
        errorStyle: const TextStyle(
          color: errorColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radius2Xl)),
        ),
        elevation: 8,
        dragHandleColor: dividerColor,
        dragHandleSize: const Size(40, 4),
        showDragHandle: true,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: backgroundColor,
        selectedColor: primaryColor.withOpacity(0.15),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: spacingLg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: dividerColor,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.2,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textTertiary,
        ),
      ),
    );
  }

  // Dark theme - Black with Green accent (from design guidelines)
  static ThemeData get darkTheme {
    // Background & Surfaces - Soft black shades (avoids pure black)
    const darkBg = Color(0xFF0B0F0E); // App Background - Soft black
    const darkSurface = Color(0xFF121917); // Primary Card / Surface
    const darkCard = Color(0xFF16201D); // Elevated Card Surface
    const darkDivider = Color(0xFF1F2933); // Divider / Border

    // Primary & Accent Colors - Green
    const darkPrimary = Color(0xFF22C55E); // Primary Green
    const darkPrimaryLight = Color(0xFF4ADE80); // Light green for good status

    // Text Colors - High contrast for readability
    const darkTextPrimary = Color(0xFFE5E7EB); // Primary Text
    const darkTextSecondary = Color(0xFF9CA3AF); // Secondary Text
    const darkTextTertiary = Color(0xFF6B7280); // Disabled / Hint Text

    // Status Colors for Progress Indicators
    const statusAtRisk = Color(0xFFEF4444); // <65%

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkPrimary,
        brightness: Brightness.dark,
        primary: darkPrimary,
        secondary: darkPrimaryLight,
        surface: darkSurface,
        error: statusAtRisk,
      ),
      scaffoldBackgroundColor: darkBg,
      appBarTheme: AppBarTheme(
        backgroundColor: darkBg,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withOpacity(0.3),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: darkTextPrimary, size: 24),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: Color(0xFF1F2E28), width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          side: const BorderSide(color: darkPrimary, width: 1.5),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingLg,
          vertical: spacingLg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: darkDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: darkDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: statusAtRisk),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: statusAtRisk, width: 2),
        ),
        labelStyle: const TextStyle(
          color: darkTextSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(color: darkTextTertiary, fontSize: 14),
        errorStyle: const TextStyle(
          color: statusAtRisk,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkCard,
        contentTextStyle: const TextStyle(
          color: darkTextPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: darkSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radius2Xl)),
        ),
        elevation: 8,
        dragHandleColor: darkDivider,
        dragHandleSize: const Size(40, 4),
        showDragHandle: true,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkCard,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurface,
        selectedColor: darkPrimary.withOpacity(0.2),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: darkTextPrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkDivider,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: spacingLg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        tileColor: Colors.transparent,
        textColor: darkTextPrimary,
        iconColor: darkTextSecondary,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkPrimary;
          }
          return darkTextTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkPrimary.withOpacity(0.4);
          }
          return darkDivider;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: darkPrimary,
        linearTrackColor: darkDivider,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
          letterSpacing: -0.3,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          letterSpacing: -0.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          letterSpacing: -0.2,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: darkTextPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: darkTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: darkTextPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: darkTextSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkTextSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: darkTextTertiary,
        ),
      ),
    );
  }

  // ============ Dark Theme Color Constants (for widget use) ============

  // Background & Surfaces
  static const Color darkBackground = Color(0xFF0B0F0E);
  static const Color darkSurface = Color(0xFF121917);
  static const Color darkCard = Color(0xFF16201D);
  static const Color darkCardActive = Color(0xFF1C2A25);
  static const Color darkDivider = Color(0xFF1F2933);

  // Primary & Accent Colors
  static const Color darkPrimaryGreen = Color(0xFF22C55E);
  static const Color darkPrimaryGreenDark = Color(0xFF16A34A);
  static const Color darkPrimaryGreenLight = Color(0xFF4ADE80);

  // Text Colors
  static const Color darkTextPrimary = Color(0xFFE5E7EB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextTertiary = Color(0xFF6B7280);

  // Status Colors for Attendance Progress
  static const Color darkStatusExcellent = Color(0xFF22C55E); // >85%
  static const Color darkStatusGood = Color(0xFF4ADE80); // 75-85%
  static const Color darkStatusWarning = Color(0xFFFACC15); // 65-75%
  static const Color darkStatusAtRisk = Color(0xFFEF4444); // <65%

  // Optional Accent Variants
  static const Color darkAccentTeal = Color(0xFF14B8A6);
  static const Color darkAccentCyan = Color(0xFF06B6D4);
  static const Color darkAccentLime = Color(0xFF84CC16);

  // Dark theme gradient with green
  static const LinearGradient darkPrimaryGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark theme success gradient
  static const LinearGradient darkSuccessGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF4ADE80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Get status color based on attendance percentage (dark theme)
  static Color getDarkStatusColor(double percentage) {
    if (percentage >= 85) return darkStatusExcellent;
    if (percentage >= 75) return darkStatusGood;
    if (percentage >= 65) return darkStatusWarning;
    return darkStatusAtRisk;
  }

  // ============ Theme-Aware Color Getters ============
  // Use these in widgets to automatically get the right color for current theme

  /// Returns true if dark mode is active
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Background color - adapts to theme
  static Color getBackgroundColor(BuildContext context) {
    return isDark(context) ? darkBackground : backgroundColor;
  }

  /// Surface/Card color - adapts to theme
  static Color getSurfaceColor(BuildContext context) {
    return isDark(context) ? darkSurface : surfaceColor;
  }

  /// Card color - adapts to theme
  static Color getCardColor(BuildContext context) {
    return isDark(context) ? darkCard : cardColor;
  }

  /// Divider color - adapts to theme
  static Color getDividerColor(BuildContext context) {
    return isDark(context) ? darkDivider : dividerColor;
  }

  /// Primary text color - adapts to theme
  static Color getTextPrimary(BuildContext context) {
    return isDark(context) ? darkTextPrimary : textPrimary;
  }

  /// Secondary text color - adapts to theme
  static Color getTextSecondary(BuildContext context) {
    return isDark(context) ? darkTextSecondary : textSecondary;
  }

  /// Tertiary text color - adapts to theme
  static Color getTextTertiary(BuildContext context) {
    return isDark(context) ? darkTextTertiary : textTertiary;
  }

  /// Primary color - adapts to theme
  static Color getPrimaryColor(BuildContext context) {
    return isDark(context) ? darkPrimaryGreen : primaryColor;
  }

  /// Primary gradient - adapts to theme
  static LinearGradient getPrimaryGradient(BuildContext context) {
    return isDark(context) ? darkPrimaryGradient : primaryGradient;
  }

  /// Success gradient - adapts to theme
  static LinearGradient getSuccessGradient(BuildContext context) {
    return isDark(context) ? darkSuccessGradient : successGradient;
  }

  /// Get card decoration - adapts to theme with proper dark mode styling
  static BoxDecoration getCardDecoration(
    BuildContext context, {
    double radius = 20,
  }) {
    if (isDark(context)) {
      return BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: const Color(0xFF1F3D2F), // Subtle green-tinted border
          width: 1,
        ),
      );
    }
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: cardShadow,
    );
  }

  /// Get elevated card decoration - for highlighted cards
  static BoxDecoration getElevatedCardDecoration(
    BuildContext context, {
    double radius = 20,
  }) {
    if (isDark(context)) {
      return BoxDecoration(
        color: darkCardActive,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: const Color(0xFF2A4D3C), // Brighter green-tinted border
          width: 1,
        ),
      );
    }
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: elevatedShadow,
    );
  }

  /// Get icon container decoration for dark mode
  static BoxDecoration getIconContainerDecoration(
    BuildContext context,
    Color color,
  ) {
    if (isDark(context)) {
      return BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      );
    }
    return BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(radiusMd),
    );
  }
}

/// Subject icons available for selection
class SubjectIcons {
  static const List<IconData> icons = [
    Icons.calculate_rounded,
    Icons.science_rounded,
    Icons.history_edu_rounded,
    Icons.translate_rounded,
    Icons.computer_rounded,
    Icons.music_note_rounded,
    Icons.palette_rounded,
    Icons.sports_soccer_rounded,
    Icons.auto_stories_rounded,
    Icons.psychology_rounded,
    Icons.public_rounded,
    Icons.architecture_rounded,
    Icons.biotech_rounded,
    Icons.code_rounded,
    Icons.engineering_rounded,
    Icons.functions_rounded,
    Icons.hub_rounded,
    Icons.memory_rounded,
    Icons.bolt_rounded,
    Icons.eco_rounded,
  ];

  static IconData getIcon(String iconName) {
    final index = int.tryParse(iconName) ?? 0;
    return icons[index % icons.length];
  }

  static String getIconName(int index) {
    return index.toString();
  }
}

/// Extension for responsive sizing
extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isSmallScreen => screenWidth < 360;
  bool get isMediumScreen => screenWidth >= 360 && screenWidth < 400;
  bool get isLargeScreen => screenWidth >= 400;

  EdgeInsets get horizontalPadding =>
      EdgeInsets.symmetric(horizontal: isSmallScreen ? 12.0 : 16.0);
}

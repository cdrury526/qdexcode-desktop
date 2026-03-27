import 'package:flutter/material.dart';

/// Application theme definitions matching the qdexcode web app color system.
///
/// Light theme uses white backgrounds with near-black text.
/// Dark theme uses near-black backgrounds with near-white text.
/// Both use a neutral (zinc-like) palette with no hue.
abstract final class AppTheme {
  // -- Semantic colors shared across themes --

  static const Color success = Color(0xFF22C55E);
  static const Color successMuted = Color(0xFF166534);
  static const Color warning = Color(0xFFFBBF24);
  static const Color warningMuted = Color(0xFF92400E);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoMuted = Color(0xFF1E40AF);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerMuted = Color(0xFF991B1B);

  // -- Light theme --

  static ThemeData get light {
    const background = Color(0xFFFFFFFF);
    const foreground = Color(0xFF0A0A0A);
    const card = Color(0xFFFFFFFF);
    const cardForeground = Color(0xFF0A0A0A);
    const primary = Color(0xFF171717);
    const primaryForeground = Color(0xFFFAFAFA);
    const muted = Color(0xFFF5F5F5);
    const mutedForeground = Color(0xFF737373);
    const accent = Color(0xFFF5F5F5);
    const accentForeground = Color(0xFF171717);
    const destructive = Color(0xFFDC2626);
    const border = Color(0xFFE5E5E5);
    const surfaceContainer = Color(0xFFF9FAFB);

    const colorScheme = ColorScheme.light(
      surface: background,
      onSurface: foreground,
      surfaceContainerHighest: card,
      primary: primary,
      onPrimary: primaryForeground,
      secondary: accent,
      onSecondary: accentForeground,
      tertiary: muted,
      onTertiary: mutedForeground,
      error: destructive,
      outline: border,
      surfaceContainer: surfaceContainer,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      cardColor: card,
      cardForeground: cardForeground,
      mutedForeground: mutedForeground,
      border: border,
      brightness: Brightness.light,
    );
  }

  // -- Dark theme --

  static ThemeData get dark {
    const background = Color(0xFF0A0A0A);
    const foreground = Color(0xFFFAFAFA);
    const card = Color(0xFF171717);
    const cardForeground = Color(0xFFFAFAFA);
    const primary = Color(0xFFE5E5E5);
    const primaryForeground = Color(0xFF171717);
    const muted = Color(0xFF262626);
    const mutedForeground = Color(0xFFA3A3A3);
    const accent = Color(0xFF262626);
    const accentForeground = Color(0xFFFAFAFA);
    const destructive = Color(0xFFEF4444);
    const border = Color(0x1AFFFFFF); // white @ 10% opacity
    const surfaceContainer = Color(0xFF141414);

    const colorScheme = ColorScheme.dark(
      surface: background,
      onSurface: foreground,
      surfaceContainerHighest: card,
      primary: primary,
      onPrimary: primaryForeground,
      secondary: accent,
      onSecondary: accentForeground,
      tertiary: muted,
      onTertiary: mutedForeground,
      error: destructive,
      outline: border,
      surfaceContainer: surfaceContainer,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      cardColor: card,
      cardForeground: cardForeground,
      mutedForeground: mutedForeground,
      border: border,
      brightness: Brightness.dark,
    );
  }

  // -- Shared builder --

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Color cardColor,
    required Color cardForeground,
    required Color mutedForeground,
    required Color border,
    required Brightness brightness,
  }) {
    final isLight = brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      fontFamily: 'Inter',
      dividerColor: border,
      dividerTheme: DividerThemeData(color: border, thickness: 1),

      // App bar
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
      ),

      // Cards
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: border),
        ),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.5,
          ),
        ),
        hintStyle: TextStyle(color: mutedForeground),
      ),

      // Elevated buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),

      // Icon buttons
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: mutedForeground,
        ),
      ),

      // Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border),
        ),
      ),

      // Tooltips
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isLight
              ? const Color(0xFF171717)
              : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: TextStyle(
          color: isLight
              ? const Color(0xFFFAFAFA)
              : const Color(0xFF171717),
          fontSize: 12,
        ),
      ),

      // Scrollbar
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(
          border.withAlpha(128),
        ),
        radius: const Radius.circular(4),
        thickness: const WidgetStatePropertyAll(6),
      ),

      // Progress indicators
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.tertiary,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isLight
            ? const Color(0xFF171717)
            : const Color(0xFFFAFAFA),
        contentTextStyle: TextStyle(
          color: isLight
              ? const Color(0xFFFAFAFA)
              : const Color(0xFF171717),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// 文本颜色管理类
class TextColors {
  static const Color primary = Color(0xFF333333);
  static const Color secondary = Color(0xFF666666);
  static const Color tertiary = Color(0xFF999999);
  static const Color disabled = Color(0xFFCCCCCC);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color error = Color(0xFFE53E3E);
  static const Color success = Color(0xFF38A169);
  static const Color warning = Color(0xFFD69E2E);
  static const Color info = Color(0xFF3182CE);

  /// 自适应颜色（根据主题）
  static Color adaptive(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? white : primary;
  }

  /// 自适应次要颜色（根据主题）
  static Color adaptiveSecondary(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? tertiary : secondary;
  }
}

/// 背景颜色管理类
class BackgroundColors {
  static const Color primary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFFF7FAFC);
  static const Color tertiary = Color(0xFFEDF2F7);
  static const Color card = Color(0xFFFFFFFF);
  static const Color overlay = Color(0x80000000);
  static const Color dark = Color(0xFF1A202C);
  static const Color darkSecondary = Color(0xFF2D3748);

  /// 自适应颜色（根据主题）
  static Color adaptive(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? dark : primary;
  }
}

/// 品牌颜色管理类
class BrandColors {
  static const Color primary = Color(0xFF3182CE);
  static const Color secondary = Color(0xFF4299E1);
  static const Color accent = Color(0xFF63B3ED);
  static const Color success = Color(0xFF38A169);
  static const Color warning = Color(0xFFD69E2E);
  static const Color error = Color(0xFFE53E3E);
  static const Color info = Color(0xFF3182CE);
}

/// 颜色方案管理器
class ColorSchemeManager {
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: BrandColors.primary,
        brightness: Brightness.light,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: TextColors.primary),
        displayMedium: TextStyle(color: TextColors.primary),
        displaySmall: TextStyle(color: TextColors.primary),
        headlineLarge: TextStyle(color: TextColors.primary),
        headlineMedium: TextStyle(color: TextColors.primary),
        headlineSmall: TextStyle(color: TextColors.primary),
        titleLarge: TextStyle(color: TextColors.primary),
        titleMedium: TextStyle(color: TextColors.primary),
        titleSmall: TextStyle(color: TextColors.primary),
        bodyLarge: TextStyle(color: TextColors.primary),
        bodyMedium: TextStyle(color: TextColors.primary),
        bodySmall: TextStyle(color: TextColors.secondary),
        labelLarge: TextStyle(color: TextColors.primary),
        labelMedium: TextStyle(color: TextColors.primary),
        labelSmall: TextStyle(color: TextColors.secondary),
      ),
      scaffoldBackgroundColor: BackgroundColors.primary,
      cardColor: BackgroundColors.card,
      appBarTheme: const AppBarTheme(
        backgroundColor: BackgroundColors.primary,
        foregroundColor: TextColors.primary,
        elevation: 0,
      ),
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: BrandColors.primary,
        brightness: Brightness.dark,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: TextColors.white),
        displayMedium: TextStyle(color: TextColors.white),
        displaySmall: TextStyle(color: TextColors.white),
        headlineLarge: TextStyle(color: TextColors.white),
        headlineMedium: TextStyle(color: TextColors.white),
        headlineSmall: TextStyle(color: TextColors.white),
        titleLarge: TextStyle(color: TextColors.white),
        titleMedium: TextStyle(color: TextColors.white),
        titleSmall: TextStyle(color: TextColors.white),
        bodyLarge: TextStyle(color: TextColors.white),
        bodyMedium: TextStyle(color: TextColors.white),
        bodySmall: TextStyle(color: TextColors.tertiary),
        labelLarge: TextStyle(color: TextColors.white),
        labelMedium: TextStyle(color: TextColors.white),
        labelSmall: TextStyle(color: TextColors.tertiary),
      ),
      scaffoldBackgroundColor: BackgroundColors.dark,
      cardColor: BackgroundColors.darkSecondary,
      appBarTheme: const AppBarTheme(
        backgroundColor: BackgroundColors.dark,
        foregroundColor: TextColors.white,
        elevation: 0,
      ),
    );
  }
}

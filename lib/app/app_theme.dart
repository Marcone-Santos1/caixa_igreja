import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Identidade visual: Cantina Padroeira (Google Stitch DESIGN.md).
/// Cores: Azul Mariano (#16437D), Dourado Festivo (#C98614), Terracota Amendoim (#8B4B27), Marfim (#FAF6EE).
/// Tipografia: Outfit (Headlines/Títulos/Labels) + Inter (Corpo/Numéricos/Moeda).
ThemeData caixaIgrejaTheme() {
  const marianBlue = Color(0xFF16437D);
  const warmGold = Color(0xFFC98614);
  const peanutTerracotta = Color(0xFF8B4B27);
  const ivoryCanvas = Color(0xFFFAF6EE);
  const espressoCoffee = Color(0xFF251F1A);

  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: marianBlue,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFDCE8FA),
    onPrimaryContainer: Color(0xFF0A264F),
    secondary: warmGold,
    onSecondary: Color(0xFF251700),
    secondaryContainer: Color(0xFFFEE7BF),
    onSecondaryContainer: Color(0xFF4A2E00),
    tertiary: peanutTerracotta,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFF8DFD2),
    onTertiaryContainer: Color(0xFF3E1805),
    error: Color(0xFFB3261E),
    onError: Colors.white,
    errorContainer: Color(0xFFFCE8E6),
    onErrorContainer: Color(0xFF601410),
    surface: ivoryCanvas,
    onSurface: espressoCoffee,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: Color(0xFFFBF8F2),
    surfaceContainer: Color(0xFFF2ECE0),
    surfaceContainerHigh: Color(0xFFEAE3D4),
    surfaceContainerHighest: Color(0xFFEDE0D8),
    onSurfaceVariant: Color(0xFF5D534A),
    outline: Color(0xFFD8CEBD),
    outlineVariant: Color(0xFFE7DFD2),
    shadow: Color(0xFF251F1A),
    scrim: Color(0xFF251F1A),
    inverseSurface: Color(0xFF362E27),
    onInverseSurface: Color(0xFFFBF4ED),
    inversePrimary: Color(0xFFA9C7FF),
  );

  final shapeLg = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
  final shapeSm = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    splashColor: scheme.primary.withValues(alpha: 0.10),
    highlightColor: scheme.primary.withValues(alpha: 0.06),
    visualDensity: VisualDensity.standard,
  );

  final textTheme = GoogleFonts.interTextTheme(base.textTheme).copyWith(
    headlineLarge: GoogleFonts.outfit(
      fontWeight: FontWeight.w700,
      fontSize: 30,
      letterSpacing: -0.5,
      color: scheme.onSurface,
    ),
    headlineMedium: GoogleFonts.outfit(
      fontWeight: FontWeight.w700,
      fontSize: 24,
      letterSpacing: -0.3,
      color: scheme.onSurface,
    ),
    headlineSmall: GoogleFonts.outfit(
      fontWeight: FontWeight.w600,
      fontSize: 20,
      letterSpacing: -0.2,
      color: scheme.onSurface,
    ),
    titleLarge: GoogleFonts.outfit(
      fontWeight: FontWeight.w700,
      fontSize: 20,
      letterSpacing: -0.3,
      color: scheme.onSurface,
    ),
    titleMedium: GoogleFonts.outfit(
      fontWeight: FontWeight.w600,
      fontSize: 16,
      letterSpacing: -0.1,
      color: scheme.onSurface,
    ),
    titleSmall: GoogleFonts.outfit(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      color: scheme.onSurface,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      height: 1.45,
      color: scheme.onSurface,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      height: 1.4,
      color: scheme.onSurface,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      height: 1.35,
      color: scheme.onSurfaceVariant,
    ),
    labelLarge: GoogleFonts.outfit(
      fontWeight: FontWeight.w700,
      fontSize: 14,
      letterSpacing: 0.2,
      color: scheme.onSurfaceVariant,
    ),
    labelMedium: GoogleFonts.outfit(
      fontWeight: FontWeight.w600,
      fontSize: 12,
      letterSpacing: 0.4,
      color: scheme.onSurfaceVariant,
    ),
    labelSmall: GoogleFonts.outfit(
      fontWeight: FontWeight.w700,
      fontSize: 11,
      letterSpacing: 0.6,
      color: scheme.onSurfaceVariant,
    ),
  );

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.transparent,
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      centerTitle: false,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: scheme.onPrimary,
      ),
      iconTheme: const IconThemeData(color: Colors.white, size: 22),
      actionsIconTheme: const IconThemeData(color: Colors.white, size: 22),
    ),
    iconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 22),
    cardTheme: CardThemeData(
      elevation: 0,
      shadowColor: scheme.shadow.withValues(alpha: 0.08),
      color: scheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      shape: shapeLg,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        shadowColor: scheme.primary.withValues(alpha: 0.35),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: shapeSm,
        textStyle: GoogleFonts.outfit(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          letterSpacing: 0.1,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: shapeSm,
        side: BorderSide(color: scheme.outline.withValues(alpha: 0.65), width: 1),
        foregroundColor: scheme.primary,
        textStyle: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        textStyle: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 2,
      focusElevation: 3,
      hoverElevation: 4,
      highlightElevation: 2,
      backgroundColor: scheme.secondary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 3,
      shadowColor: scheme.shadow.withValues(alpha: 0.08),
      height: 72,
      backgroundColor: scheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      indicatorColor: scheme.primary.withValues(alpha: 0.12),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final sel = states.contains(WidgetState.selected);
        return IconThemeData(
          color: sel ? scheme.primary : scheme.onSurfaceVariant,
          size: 24,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final sel = states.contains(WidgetState.selected);
        return GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: 0.15,
          color: sel ? scheme.primary : scheme.onSurfaceVariant,
        );
      }),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: scheme.primary,
      textColor: scheme.onSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: 0.6),
      thickness: 1,
      space: 1,
    ),
    expansionTileTheme: ExpansionTileThemeData(
      shape: const Border(),
      collapsedShape: const Border(),
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      iconColor: scheme.primary,
      collapsedIconColor: scheme.onSurfaceVariant,
      textColor: scheme.onSurface,
      collapsedTextColor: scheme.onSurface,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLowest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: GoogleFonts.inter(
        color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
        fontSize: 14,
      ),
      labelStyle: GoogleFonts.outfit(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: scheme.onSurfaceVariant,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: GoogleFonts.inter(
        color: scheme.onInverseSurface,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 4,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
      circularTrackColor: scheme.primary.withValues(alpha: 0.12),
      linearTrackColor: scheme.primary.withValues(alpha: 0.12),
    ),
    dialogTheme: DialogThemeData(
      shape: shapeLg,
      backgroundColor: scheme.surfaceContainerHigh,
      elevation: 2,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

/// Tema escuro alinhado com Cantina Padroeira (Azul Mariano e Dourado suave).
ThemeData caixaIgrejaThemeDark() {
  const marianBlueDim = Color(0xFFA9C7FF);
  const warmGoldDim = Color(0xFFFFB956);
  const terracottaDim = Color(0xFFFFB691);
  const surfaceDark = Color(0xFF1E1A17);
  const surfaceDim = Color(0xFF28231F);

  const scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: marianBlueDim,
    onPrimary: Color(0xFF002D5E),
    primaryContainer: Color(0xFF16437D),
    onPrimaryContainer: Color(0xFFDCE8FA),
    secondary: warmGoldDim,
    onSecondary: Color(0xFF4A2E00),
    secondaryContainer: Color(0xFF6E4600),
    onSecondaryContainer: Color(0xFFFEE7BF),
    tertiary: terracottaDim,
    onTertiary: Color(0xFF501E00),
    tertiaryContainer: Color(0xFF6D3311),
    onTertiaryContainer: Color(0xFFF8DFD2),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: surfaceDark,
    onSurface: Color(0xFFEFE6DF),
    surfaceContainerLowest: Color(0xFF16120F),
    surfaceContainerLow: Color(0xFF211D19),
    surfaceContainer: surfaceDim,
    surfaceContainerHigh: Color(0xFF332D28),
    surfaceContainerHighest: Color(0xFF3E3832),
    onSurfaceVariant: Color(0xFFD3C4B8),
    outline: Color(0xFF9C8E83),
    outlineVariant: Color(0xFF4F453D),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFFEFE6DF),
    onInverseSurface: Color(0xFF332D28),
    inversePrimary: Color(0xFF16437D),
  );

  final shapeLg = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
  final shapeSm = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    splashColor: scheme.primary.withValues(alpha: 0.14),
    highlightColor: scheme.primary.withValues(alpha: 0.08),
    visualDensity: VisualDensity.standard,
  );

  final textTheme = GoogleFonts.interTextTheme(base.textTheme).copyWith(
    headlineLarge: GoogleFonts.outfit(
      fontWeight: FontWeight.w700,
      fontSize: 30,
      letterSpacing: -0.5,
      color: scheme.onSurface,
    ),
    headlineMedium: GoogleFonts.outfit(
      fontWeight: FontWeight.w700,
      fontSize: 24,
      letterSpacing: -0.3,
      color: scheme.onSurface,
    ),
    headlineSmall: GoogleFonts.outfit(
      fontWeight: FontWeight.w600,
      fontSize: 20,
      letterSpacing: -0.2,
      color: scheme.onSurface,
    ),
    titleLarge: GoogleFonts.outfit(
      fontWeight: FontWeight.w700,
      fontSize: 20,
      letterSpacing: -0.3,
      color: scheme.onSurface,
    ),
    titleMedium: GoogleFonts.outfit(
      fontWeight: FontWeight.w600,
      fontSize: 16,
      letterSpacing: -0.1,
      color: scheme.onSurface,
    ),
    titleSmall: GoogleFonts.outfit(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      color: scheme.onSurface,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      height: 1.45,
      color: scheme.onSurface,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      height: 1.4,
      color: scheme.onSurface,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      height: 1.35,
      color: scheme.onSurfaceVariant,
    ),
    labelLarge: GoogleFonts.outfit(
      fontWeight: FontWeight.w700,
      fontSize: 14,
      letterSpacing: 0.2,
      color: scheme.onSurfaceVariant,
    ),
    labelMedium: GoogleFonts.outfit(
      fontWeight: FontWeight.w600,
      fontSize: 12,
      letterSpacing: 0.4,
      color: scheme.onSurfaceVariant,
    ),
    labelSmall: GoogleFonts.outfit(
      fontWeight: FontWeight.w700,
      fontSize: 11,
      letterSpacing: 0.6,
      color: scheme.onSurfaceVariant,
    ),
  );

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.transparent,
      backgroundColor: scheme.surfaceContainer,
      foregroundColor: scheme.onSurface,
      centerTitle: false,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: scheme.onSurface,
      ),
      iconTheme: IconThemeData(color: scheme.onSurface, size: 22),
    ),
    iconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 22),
    cardTheme: CardThemeData(
      elevation: 0,
      shadowColor: scheme.shadow.withValues(alpha: 0.35),
      color: scheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      shape: shapeLg,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        shadowColor: scheme.primary.withValues(alpha: 0.45),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: shapeSm,
        textStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          letterSpacing: 0.1,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: shapeSm,
        side: BorderSide(color: scheme.outline.withValues(alpha: 0.65), width: 1),
        foregroundColor: scheme.primary,
        textStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        textStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 2,
      focusElevation: 2,
      hoverElevation: 3,
      highlightElevation: 2,
      backgroundColor: scheme.tertiary,
      foregroundColor: scheme.onTertiary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 3,
      shadowColor: scheme.shadow.withValues(alpha: 0.2),
      height: 72,
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      indicatorColor: scheme.primary.withValues(alpha: 0.22),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final sel = states.contains(WidgetState.selected);
        return IconThemeData(
          color: sel ? scheme.primary : scheme.onSurfaceVariant,
          size: 24,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final sel = states.contains(WidgetState.selected);
        return GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: 0.15,
          color: sel ? scheme.primary : scheme.onSurfaceVariant,
        );
      }),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: scheme.primary.withValues(alpha: 0.95),
      textColor: scheme.onSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: 0.55),
      thickness: 1,
      space: 1,
    ),
    expansionTileTheme: ExpansionTileThemeData(
      shape: const Border(),
      collapsedShape: const Border(),
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      iconColor: scheme.primary,
      collapsedIconColor: scheme.onSurfaceVariant,
      textColor: scheme.onSurface,
      collapsedTextColor: scheme.onSurface,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.45)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: GoogleFonts.plusJakartaSans(
        color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
        fontSize: 14,
      ),
      labelStyle: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: scheme.onSurfaceVariant,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: GoogleFonts.plusJakartaSans(
        color: scheme.onInverseSurface,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 4,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
      circularTrackColor: scheme.primary.withValues(alpha: 0.18),
      linearTrackColor: scheme.primary.withValues(alpha: 0.18),
    ),
    dialogTheme: DialogThemeData(
      shape: shapeLg,
      backgroundColor: scheme.surfaceContainerHigh,
      elevation: 2,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

/// Padding horizontal padrão para corpos de lista / formulários.
const EdgeInsets kCaixaScreenPadding =
    EdgeInsets.symmetric(horizontal: 20, vertical: 12);

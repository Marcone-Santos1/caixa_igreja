import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Identidade visual: tons índigo + âmbar, tipografia Plus Jakarta Sans, M3 suave.
ThemeData caixaIgrejaTheme() {
  const indigo = Color(0xFF4338CA);
  const surface = Color(0xFFF4F4F5);
  const surfaceDim = Color(0xFFECECF0);

  final scheme = ColorScheme.fromSeed(
    seedColor: indigo,
    brightness: Brightness.light,
    surface: surface,
    surfaceContainerLow: surfaceDim,
    primary: indigo,
    onPrimary: Colors.white,
    secondary: const Color(0xFFB45309),
    onSecondary: Colors.white,
    tertiary: const Color(0xFF0D9488),
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
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

  final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).copyWith(
    titleLarge: GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w600,
      fontSize: 22,
      letterSpacing: -0.4,
      color: scheme.onSurface,
    ),
    titleMedium: GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w600,
      fontSize: 17,
      letterSpacing: -0.2,
      color: scheme.onSurface,
    ),
    bodyLarge: GoogleFonts.plusJakartaSans(
      fontSize: 16,
      height: 1.45,
      color: scheme.onSurface,
    ),
    bodyMedium: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      height: 1.4,
      color: scheme.onSurface,
    ),
    bodySmall: GoogleFonts.plusJakartaSans(
      fontSize: 12,
      height: 1.35,
      color: scheme.onSurfaceVariant,
    ),
    labelLarge: GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w600,
      fontSize: 13,
      letterSpacing: 0.2,
      color: scheme.onSurfaceVariant,
    ),
  );

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      centerTitle: false,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: scheme.onSurface,
      ),
      iconTheme: IconThemeData(color: scheme.onSurface, size: 22),
    ),
    iconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 22),
    cardTheme: CardThemeData(
      elevation: 0,
      shadowColor: scheme.shadow.withValues(alpha: 0.12),
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
        side: BorderSide(color: scheme.outline.withValues(alpha: 0.55), width: 1),
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
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 3,
      shadowColor: scheme.shadow.withValues(alpha: 0.08),
      height: 72,
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: scheme.primary.withValues(alpha: 0.14),
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
      iconColor: scheme.primary.withValues(alpha: 0.85),
      textColor: scheme.onSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: 0.45),
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
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.35)),
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
        color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
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

/// Tema escuro (mesma identidade índigo / âmbar / teal, contraste M3).
ThemeData caixaIgrejaThemeDark() {
  const indigo = Color(0xFF818CF8);
  const surface = Color(0xFF18181B);
  const surfaceDim = Color(0xFF27272A);

  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF6366F1),
    brightness: Brightness.dark,
    surface: surface,
    surfaceContainerLow: surfaceDim,
    primary: indigo,
    onPrimary: const Color(0xFF1E1B4B),
    secondary: const Color(0xFFFBBF24),
    onSecondary: const Color(0xFF422006),
    tertiary: const Color(0xFF2DD4BF),
    onTertiary: const Color(0xFF042F2E),
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
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

  final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).copyWith(
    titleLarge: GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w600,
      fontSize: 22,
      letterSpacing: -0.4,
      color: scheme.onSurface,
    ),
    titleMedium: GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w600,
      fontSize: 17,
      letterSpacing: -0.2,
      color: scheme.onSurface,
    ),
    bodyLarge: GoogleFonts.plusJakartaSans(
      fontSize: 16,
      height: 1.45,
      color: scheme.onSurface,
    ),
    bodyMedium: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      height: 1.4,
      color: scheme.onSurface,
    ),
    bodySmall: GoogleFonts.plusJakartaSans(
      fontSize: 12,
      height: 1.35,
      color: scheme.onSurfaceVariant,
    ),
    labelLarge: GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w600,
      fontSize: 13,
      letterSpacing: 0.2,
      color: scheme.onSurfaceVariant,
    ),
  );

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      centerTitle: false,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
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

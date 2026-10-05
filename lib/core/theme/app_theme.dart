import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/status_tone.dart';

/// Colours the shared screens need beyond the Material [ColorScheme]: a second surface,
/// muted text, and the status tones as container / on-container pairs.
@immutable
class MalevaColors extends ThemeExtension<MalevaColors> {
  const MalevaColors({
    required this.surface2,
    required this.outline,
    required this.muted,
    required this.faint,
    required this.primarySoft,
    required this.onPrimarySoft,
    required this.dangerSoft,
    required this.tones,
    required this.leavePending,
  });

  final Color surface2;
  final Color outline;
  final Color muted;
  final Color faint;
  final Color primarySoft;
  final Color onPrimarySoft;
  final Color dangerSoft;
  final Map<StatusTone, (Color, Color)> tones;

  /// Driver with leave pending (the web's indigo-700); approved leave uses the accent tone.
  final Color leavePending;

  Color toneBg(StatusTone t) => tones[t]!.$1;
  Color toneFg(StatusTone t) => tones[t]!.$2;

  static const light = MalevaColors(
    surface2: Color(0xFFF6F8FC),
    outline: Color(0xFFDDE3EE),
    muted: Color(0xFF535D74),
    faint: Color(0xFF7C86A2),
    primarySoft: Color(0xFFE7EDFF),
    onPrimarySoft: Color(0xFF163A9C),
    dangerSoft: Color(0xFFFDECEA),
    leavePending: Color(0xFF4338CA),
    tones: {
      StatusTone.success: (Color(0xFFE3F5EC), Color(0xFF0B6B45)),
      StatusTone.warning: (Color(0xFFFFF1D6), Color(0xFF8A4B00)),
      StatusTone.danger: (Color(0xFFFDE8E8), Color(0xFFB42318)),
      StatusTone.info: (Color(0xFFE1F1FB), Color(0xFF075985)),
      StatusTone.primary: (Color(0xFFE7EDFF), Color(0xFF163A9C)),
      StatusTone.accent: (Color(0xFFF0E9FE), Color(0xFF5B2EB0)),
      StatusTone.neutral: (Color(0xFFECEFF4), Color(0xFF475067)),
    },
  );

  static const dark = MalevaColors(
    surface2: Color(0xFF1B2339),
    outline: Color(0xFF2A3452),
    muted: Color(0xFFA6AFC4),
    faint: Color(0xFF7C86A2),
    primarySoft: Color(0xFF1C2A55),
    onPrimarySoft: Color(0xFFC2D2FF),
    dangerSoft: Color(0xFF3A1618),
    leavePending: Color(0xFFA5B4FC),
    tones: {
      StatusTone.success: (Color(0xFF0F2E22), Color(0xFF7BE3B5)),
      StatusTone.warning: (Color(0xFF36260B), Color(0xFFF9CF7E)),
      StatusTone.danger: (Color(0xFF3A1618), Color(0xFFFF9C94)),
      StatusTone.info: (Color(0xFF0C2A3D), Color(0xFF86D3FB)),
      StatusTone.primary: (Color(0xFF1C2A55), Color(0xFFB3C6FF)),
      StatusTone.accent: (Color(0xFF2B1C4A), Color(0xFFCDBDFD)),
      StatusTone.neutral: (Color(0xFF232B3F), Color(0xFFBAC2D4)),
    },
  );

  @override
  MalevaColors copyWith() => this;

  @override
  MalevaColors lerp(ThemeExtension<MalevaColors>? other, double t) => t < 0.5 ? this : (other as MalevaColors? ?? this);
}

extension MalevaColorsX on BuildContext {
  MalevaColors get mc => Theme.of(this).extension<MalevaColors>() ?? MalevaColors.light;
  ColorScheme get cs => Theme.of(this).colorScheme;
}

/// The Material 3 light and dark themes of the Planning and RTI screens (one brand colour,
/// 8 dp grid, 48 dp targets). The rest of the app keeps its own theme until it is reworked.
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final dark = b == Brightness.dark;
    final mc = dark ? MalevaColors.dark : MalevaColors.light;
    final scheme = ColorScheme.fromSeed(seedColor: Palette.blue600, brightness: b).copyWith(
      primary: dark ? const Color(0xFF8AADFF) : Palette.blue600,
      onPrimary: dark ? const Color(0xFF0A1640) : Colors.white,
      surface: dark ? const Color(0xFF151C2F) : Colors.white,
      onSurface: dark ? const Color(0xFFE8ECF6) : const Color(0xFF121826),
      error: dark ? const Color(0xFFFF8F86) : const Color(0xFFB42318),
      onError: dark ? const Color(0xFF2A0606) : Colors.white,
      outline: mc.outline,
      outlineVariant: mc.outline,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: b);
    final text = GoogleFonts.interTextTheme(base.textTheme).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    return base.copyWith(
      scaffoldBackgroundColor: dark ? const Color(0xFF0B1020) : const Color(0xFFF3F5FA),
      textTheme: text,
      extensions: [mc],
      materialTapTargetSize: MaterialTapTargetSize.padded,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: mc.outline)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size(48, 52), shape: shape, textStyle: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
            minimumSize: const Size(48, 52), shape: shape, side: BorderSide(color: mc.outline), foregroundColor: scheme.onSurface,
            textStyle: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(minimumSize: const Size(48, 48))),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: mc.outline)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: mc.outline)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: scheme.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: scheme.error, width: 2)),
      ),
      chipTheme: base.chipTheme.copyWith(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: mc.outline))),
      dividerTheme: DividerThemeData(color: mc.outline, space: 1, thickness: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}

/// Wraps a Planning or RTI screen in the shared theme, following the device's light or dark mode.
class MalevaThemeScope extends StatelessWidget {
  const MalevaThemeScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    return Theme(data: dark ? AppTheme.dark() : AppTheme.light(), child: child);
  }
}

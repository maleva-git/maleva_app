import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;

class AppTypography {
  AppTypography._();

  // Colors
  static const Color primaryText = Color(0xFF1A2340);
  static const Color secondaryText = Color(0xFF8A94A6);

  // Private helper to check if tablet without BuildContext
  static bool get _isTablet {
    try {
      final view = ui.PlatformDispatcher.instance.views.first;
      final size = view.physicalSize / view.devicePixelRatio;
      return size.width >= 600;
    } catch (e) {
      return false;
    }
  }

  // ─── STRICT HIERARCHY ─────────────────────────────────────────────

  /// **Display**: Extra large numbers / Metrics (e.g. 11,01,783)
  /// Mobile: 24, Tablet: 28
  static TextStyle display({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      fontSize: _isTablet ? 28 : 24,
      fontWeight: fontWeight ?? FontWeight.w900,
      color: color ?? primaryText,
    );
  }

  /// **Heading 1**: Page Titles / Top-level headers
  /// Mobile: 16, Tablet: 18
  static TextStyle heading1({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      fontSize: _isTablet ? 18 : 16,
      fontWeight: fontWeight ?? FontWeight.w800,
      color: color ?? primaryText,
      letterSpacing: 1.2,
    );
  }

  /// **Heading 2**: Section headers / Large list titles
  /// Mobile: 15, Tablet: 16
  static TextStyle heading2({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      fontSize: _isTablet ? 16 : 15,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color ?? primaryText,
      letterSpacing: 0.5,
    );
  }

  /// **Heading 3**: Card titles / Standard list titles
  /// Mobile: 13, Tablet: 14
  static TextStyle heading3({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      fontSize: _isTablet ? 14 : 13,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color ?? primaryText,
    );
  }

  /// **Body Large**: Primary text / Form input text / Data values
  /// Mobile: 13, Tablet: 14 (Regular/Medium weight)
  static TextStyle bodyLarge({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      fontSize: _isTablet ? 14 : 13,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color ?? primaryText,
    );
  }

  /// **Body Medium**: Secondary text / Descriptions / List Subtitles
  /// Mobile: 12, Tablet: 13
  static TextStyle bodyMedium({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      fontSize: _isTablet ? 13 : 12,
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color ?? secondaryText,
    );
  }

  /// **Body Small**: Captions / Small metrics / Footnotes
  /// Mobile: 11, Tablet: 12
  static TextStyle bodySmall({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      fontSize: _isTablet ? 12 : 11,
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color ?? secondaryText,
    );
  }

  /// **Badge Text**: Tiny text inside status badges or labels
  /// Mobile: 10, Tablet: 11
  static TextStyle badgeText({Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      fontSize: _isTablet ? 11 : 10,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color ?? Colors.white,
      letterSpacing: 0.8,
    );
  }

  // ─── LEGACY GETTERS (Do not use in new code) ──────────────────────
  // Kept temporarily for backward compatibility where context is unavailable.
  // We will remove these as we refactor the app.

  static TextStyle get metricAmount => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: primaryText,
      );

  static TextStyle get metricLabel => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: secondaryText,
        letterSpacing: 0.8,
      );

  static TextStyle get metricSubAmount => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: primaryText,
      );

  static TextStyle get pageTitle => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: primaryText,
        letterSpacing: 1.2,
      );

  static TextStyle get pageTitleWhite => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.white.withValues(alpha: 0.80),
        letterSpacing: 1.2,
      );

  static TextStyle get pageTitleBigWhite => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: -0.5,
      );

  static TextStyle get listTitle => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: primaryText,
      );

  static TextStyle get listTitleLarge => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: primaryText,
      );

  static TextStyle get listSubtitle => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondaryText,
      );
}

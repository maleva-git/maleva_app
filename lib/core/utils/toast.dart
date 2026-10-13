// The names below copy the fluttertoast package's API (Toast.LENGTH_SHORT, ToastGravity.CENTER), so the
// screens that used it only changed their import.
// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:flutter/material.dart';

import 'app_globals.dart';

/// How long a toast stays: about 2 seconds or 3.5 seconds.
enum Toast { LENGTH_SHORT, LENGTH_LONG }

/// Where a toast shows.
enum ToastGravity { TOP, BOTTOM, CENTER, TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT, CENTER_LEFT, CENTER_RIGHT, SNACKBAR, NONE }

/// A short message over the screen, without a [BuildContext] (it uses the app's navigator overlay).
///
/// Replaces the fluttertoast package (owner, 2026-10-13: it applied the old Kotlin Gradle Plugin, which future
/// Flutter versions refuse). One toast at a time: a new one replaces the one showing.
class Fluttertoast {
  Fluttertoast._();

  static OverlayEntry? _entry;
  static Timer? _timer;

  static Future<bool?> showToast({
    required String msg,
    Toast? toastLength,
    ToastGravity? gravity,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
  }) async {
    final overlay = AppGlobals.navigatorKey.currentState?.overlay;
    if (overlay == null) {
      debugPrint('Toast (no screen yet): $msg');
      return false;
    }
    cancel();
    final entry = OverlayEntry(
      builder: (context) => _ToastView(
        message: msg,
        alignment: _alignment(gravity ?? ToastGravity.BOTTOM),
        background: backgroundColor ?? Colors.black87,
        foreground: textColor ?? Colors.white,
        fontSize: fontSize ?? 14,
      ),
    );
    _entry = entry;
    overlay.insert(entry);
    _timer = Timer(
      toastLength == Toast.LENGTH_LONG ? const Duration(milliseconds: 3500) : const Duration(seconds: 2),
      cancel,
    );
    return true;
  }

  /// Removes the toast showing, if any.
  static Future<bool?> cancel() async {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
    return true;
  }

  static Alignment _alignment(ToastGravity gravity) => switch (gravity) {
        ToastGravity.TOP => Alignment.topCenter,
        ToastGravity.TOP_LEFT => Alignment.topLeft,
        ToastGravity.TOP_RIGHT => Alignment.topRight,
        ToastGravity.CENTER => Alignment.center,
        ToastGravity.CENTER_LEFT => Alignment.centerLeft,
        ToastGravity.CENTER_RIGHT => Alignment.centerRight,
        ToastGravity.BOTTOM_LEFT => Alignment.bottomLeft,
        ToastGravity.BOTTOM_RIGHT => Alignment.bottomRight,
        ToastGravity.BOTTOM || ToastGravity.SNACKBAR || ToastGravity.NONE => Alignment.bottomCenter,
      };
}

class _ToastView extends StatelessWidget {
  const _ToastView({
    required this.message,
    required this.alignment,
    required this.background,
    required this.foreground,
    required this.fontSize,
  });

  final String message;
  final Alignment alignment;
  final Color background;
  final Color foreground;
  final double fontSize;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Align(
          alignment: alignment,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: IgnorePointer(
              child: Material(
                color: background,
                elevation: 4,
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: foreground, fontSize: fontSize),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

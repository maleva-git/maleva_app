import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'clsfunction.dart' as globals;

void msgshow(
    String msg,
    String value,
    Color? tcolor,
    Color? bcolor,
    Duration? dur,
    double? fsize,
    Toast? length,
    ToastGravity? gravity,
    BuildContext? context,
    int type) async {
  if (context != null) {
    await Future.delayed(const Duration(milliseconds: 300));
    // ignore: use_build_context_synchronously
    _showTopBanner(
      context: context,
      message: msg + value,
      backgroundColor: bcolor == Colors.green || bcolor == Colors.greenAccent
          ? const Color(0xFF1555F3)
          : bcolor ?? const Color(0xFF1555F3),
      textColor: tcolor ?? Colors.white,
      duration: dur ?? const Duration(seconds: 3),
    );
  } else {
    Fluttertoast.showToast(
        msg: msg,
        textColor: tcolor ?? Colors.white,
        fontSize: fsize ?? 14,
        toastLength: length ?? Toast.LENGTH_SHORT,
        backgroundColor: bcolor ?? Colors.black,
        gravity: gravity ?? ToastGravity.CENTER);
  }
}

// ─── Top Banner Implementation ─────────────────────────────────────────────────
void _showTopBanner({
  required BuildContext context,
  required String message,
  required Color backgroundColor,
  required Color textColor,
  required Duration duration,
}) {
  final overlay = Overlay.of(context);

  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _TopBannerWidget(
      message: message,
      backgroundColor: backgroundColor,
      textColor: textColor,
      duration: duration,
      onDismiss: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
}

// ─── Top Banner Widget ─────────────────────────────────────────────────────────
class _TopBannerWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final Duration duration;
  final VoidCallback onDismiss;

  const _TopBannerWidget({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_TopBannerWidget> createState() => _TopBannerWidgetState();
}

class _TopBannerWidgetState extends State<_TopBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Slide in
    _controller.forward();

    // Auto dismiss
    Future.delayed(widget.duration, () async {
      if (mounted) {
        await _controller.reverse();
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Pick icon based on background color
  IconData _getIcon() {
    final bg = widget.backgroundColor;
    if (bg == Colors.red || bg == Colors.redAccent) {
      return Icons.error_outline_rounded;
    } else if (bg == Colors.green || bg == Colors.greenAccent) {
      return Icons.check_circle_outline_rounded;
    } else if (bg == Colors.orange || bg == Colors.orangeAccent) {
      return Icons.warning_amber_rounded;
    } else {
      return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: () async {
              await _controller.reverse();
              widget.onDismiss();
            },
            child: Container(
              margin: EdgeInsets.only(
                top: topPadding + 10,
                left: 16,
                right: 16,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.backgroundColor.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(_getIcon(), color: widget.textColor, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.close_rounded,
                      color: widget.textColor.withOpacity(0.6), size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void msgshow1(
    String msg,
    String value,
    Color? tcolor,
    Color? bcolor,
    Duration? dur,
    double? fsize,
    Toast? length,
    ToastGravity? gravity,
    BuildContext? context,
    int type) async {
  if (context != null) {
    await Future.delayed(const Duration(seconds: 1));
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg + value,
        style: TextStyle(color: tcolor ?? Colors.white),
      ),
      backgroundColor: bcolor ?? Colors.black,
      duration: dur ?? const Duration(seconds: 5),
    ));
  } else {
    Fluttertoast.showToast(
        msg: msg,
        textColor: tcolor ?? Colors.white,
        fontSize: fsize ?? 14,
        toastLength: length ?? Toast.LENGTH_SHORT,
        backgroundColor: bcolor ?? Colors.black,
        gravity: gravity ?? ToastGravity.CENTER);
  }
}

Future<bool> ConfirmationMsgYesNo(BuildContext context, String msg) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      final bool isLogout = msg.toLowerCase().contains('logout');

      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.0),
            boxShadow: [
              BoxShadow(
                color: colour.cBlue.withOpacity(0.15),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Top Header with Blue Gradient and Logo ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28.0),
                    topRight: Radius.circular(28.0),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colour.cBlueDark, colour.cBlue, colour.cBlueLight],
                    stops: [0.0, 0.55, 1.0],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        image: DecorationImage(
                          image: globals.logo,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isLogout ? "Confirm Logout" : "Confirmation",
                      style: GoogleFonts.dmSans(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              // ── Body Message ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                child: Text(
                  msg,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    height: 1.5,
                    color: const Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // ── Action Buttons ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: colour.cBlue,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          isLogout ? "Logout" : "Confirm",
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ));
    },
  ).then((value) => value ?? false);
}

Future<bool> ConfirmationOK(String Msg, context) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        titlePadding: EdgeInsets.zero,
        title: Container(
          height:  globals.MalevaScreen == 1 ? 35 : 45,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0.0),
            color: colour.commonColor,
            border: Border.all(
              color: colour.commonColorLight,
            ),
          ),
          child: Text(
            "Maleva",
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                  color: colour.whiteText,
                  fontWeight: FontWeight.bold,
                  fontSize: globals.FontLarge,
                  letterSpacing: 0.3),
            ),
          ),
        ),
        content: SizedBox(
          width: globals.MalevaScreen == 1 ? 150 : 300.0,
          height: globals.MalevaScreen == 1 ? 30 : 50.0,
          child: Text(
            Msg,
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                  color: colour.commonColor,
                  fontWeight: FontWeight.bold,
                  fontSize:  globals.MalevaScreen == 1
                      ? globals.FontLow : globals.FontMedium,
                  letterSpacing: 0.3),
            ),
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colour.commonColor,
              side: const BorderSide(
                  color: colour.commonColorLight,
                  width: 1,
                  style: BorderStyle.solid),
              textStyle: const TextStyle(color: Colors.black),
              elevation: 20.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              padding: const EdgeInsets.all(4.0),
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text(
              'OK',
              style: GoogleFonts.lato(
                  fontSize:  globals.MalevaScreen == 1
                      ? globals.FontMedium - 2 : globals.FontMedium,
                  fontWeight: FontWeight.bold,
                  color: colour.commonColorLight),
            ),
          ),
        ],
      );
    },
  ).then((exit) {
    if (exit == null) return false;
    if (exit) {
      return true;
    } else {
      return false;
    }
  });
}

void toastMsg(msg, value, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(
      children: [
        Expanded(
            flex: 1,
            child: Text(
              msg + value.toString(),
              style:  GoogleFonts.lato(
                  textStyle: TextStyle(
                      fontSize:  globals.MalevaScreen == 1
                          ? globals.FontLow : globals.FontMedium,
                      fontWeight: FontWeight.bold,
                      color: colour.commonColor)),
            ))
      ],
    ),
    padding: const EdgeInsets.all(15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5.0),
    ),
    margin: const EdgeInsets.all(15),
    behavior: SnackBarBehavior.floating,
    backgroundColor: colour.commonColorLight,
    duration: const Duration(seconds: 1),
  ));
}

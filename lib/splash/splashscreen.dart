import 'package:maleva/core/network/api_legacy_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import '../core/theme/tokens.dart';
import '../core/utils/app_preferences.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;

// ─── Design tokens (splash only) ─────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Animations (new — purely visual) ──────────────────────────────────────
  late final AnimationController _entryCtrl;
  late final Animation<double>   _logoScale;
  late final Animation<double>   _logoFade;
  late final Animation<double>   _textFade;
  late final Animation<Offset>   _textSlide;
  late final AnimationController _loadCtrl;

  // ── All original fields ────────────────────────────────────────────────────
  double width = 0;
  double height = 0;
  String dtpDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  int progress = 1;
  String loginstatus = "0";
  String url = "";
  int daysscount = 0;

  @override
  void initState() {
    super.initState();

    // Entry animations
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScale = Tween<double>(begin: 0.70, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.35, 0.80, curve: Curves.easeOut),
      ),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.35, 0.80, curve: Curves.easeOutCubic),
      ),
    );

    // Pulsing loading bar
    _loadCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    _entryCtrl.forward();

    // ── Original startup logic — untouched ────────────────────────────────
    startup();
  }

  // ── STARTUP LOGIC (with error handling) ──────────────────────────────────
  Future startup() async {
    // ① Safe local storage init
    try {
      await ApiLegacyHelper.localstoragecall();
    } catch (e) {
      debugPrint('❌ SharedPreferences init failed: $e');
      if (mounted) {
        _showErrorPopup(
          'Startup Error',
          'Failed to initialize app storage.\n\n'
          'Please try clearing app data or reinstalling the app.\n\nError: $e',
        );
      }
      return;
    }

    await Future.delayed(const Duration(seconds: 3));

    // ② FCM token with timeout — prevents indefinite hang on devices
    // with missing or outdated Google Play Services
    try {
      await AppGlobals.getDeviceToken().timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('⚠️ FCM Token fetch failed: $e');
      // Continue without token — don't block app startup
    }
    AppGlobals.mobiletoken = AppPreferences.getFcmToken();

    String UserName = AppGlobals.storagenew.getString('Username') ?? "";
    String Password = AppGlobals.storagenew.getString('Password') ?? "";
    String OldUserName = AppGlobals.storagenew.getString('OldUsername') ?? "";
    AppGlobals.MalevaScreen= AppGlobals.storagenew.getInt('DeviceView') ?? 1;
    AppGlobals.DriverLogin=AppGlobals.storagenew.getInt('DriverId') ?? 0;
    if (UserName != "" && Password != "") {
      // ③ Login API call with error handling
      bool loginSuccess = false;
      try {
        if (!mounted) return;
        loginSuccess = await OnlineApi.Login(UserName, Password, OldUserName,AppGlobals.DriverLogin, context);
      } catch (e) {
        debugPrint('⚠️ Login API error: $e');
        if (mounted) {
          _showErrorPopup(
            'Connection Error',
            'Unable to connect to the server.\n\n'
            'Please check your internet connection and try again.\n\nError: $e',
          );
        }
        return;
      }

      if (loginSuccess) {
        if (!mounted) return;

        if(AppGlobals.DriverLogin == 1)
        {
          context.go('/driver_dashboard');
          return;
        }

        int roleId = AppPreferences.getRoleId();

    switch (roleId) {
      case 100: // ADMIN
        context.go('/dashboard/admin');
        break;
      case 200: // ADMIN2
        context.go('/dashboard/admin');
        break;
      case 300: // SALES
        context.go('/dashboard/sales');
        break;
      case 400: // OPERATIONADMIN
        context.go('/dashboard/admin');
        break;
      case 500: // BOARDING
      case 600: // BOARDINGOFFICERADMIN
        context.go('/dashboard/boarding');
        break;
      case 800: // HRADMIN
        context.go('/dashboard/admin');
        break;
      case 900: // ACCOUNTS
        context.go('/dashboard/payable');
        break;
      case 1000: // TRANSPORTATION
        context.go('/dashboard/transport');
        break;
      case 1200: // RECEIVABLE
        context.go('/dashboard/receivable');
        break;
      case 1300: // MAINTENANCE
        context.go('/dashboard/maintenance');
        break;
      case 1400: // FORWARDING
        context.go('/dashboard/forwarding');
        break;
      case 1500: // AIR FREIGHT
        context.go('/dashboard/air_freight');
        break;
      default:
        context.go('/dashboard/admin');
        break;
    }
      }
      else {
        _navigateToLogin();
      }
    } else {
      _navigateToLogin();
    }
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _loadCtrl.dispose();
    super.dispose();
  }

  // ── Error & Navigation Helpers ─────────────────────────────────────────────

  void _navigateToLogin() {
    if (!mounted) return;
    context.go('/login');
  }

  void _showErrorPopup(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            message,
            style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _navigateToLogin();
            },
            child: Text(
              'Go to Login',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1555F3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              startup();
            },
            child: Text(
              'Retry',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── BUILD — only this section is redesigned ────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.brandGradientStart,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background: subtle grid ────────────────────────────────────
          CustomPaint(painter: _GridPainter()),

          // ── Decorative circles ─────────────────────────────────────────
          Positioned(
            top: -160, left: -100,
            child: _glowCircle(420, 0.07),
          ),
          Positioned(
            bottom: -80, right: -80,
            child: _glowCircle(280, 0.05),
          ),

          // ── Corner accents ─────────────────────────────────────────────
          const Positioned(
            top: 0, left: 0,
            child: _CornerAccent(topLeft: true),
          ),
          const Positioned(
            bottom: 0, right: 0,
            child: _CornerAccent(topLeft: false),
          ),

          // ── Version badge (top right) ──────────────────────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 24, 0),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18), width: 1),
                  ),
                  child: Text(
                    AppGlobals.appversion,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.75),
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Center: logo + brand ───────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo card
                ScaleTransition(
                  scale: _logoScale,
                  child: FadeTransition(
                    opacity: _logoFade,
                    child: Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(34),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.20), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(33),
                        child: Image(
                          image: AppGlobals.splashlogo,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Brand name + tagline
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textFade,
                    child: Column(
                      children: [
                        Text(
                          'Maleva',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            color: colour.kWhite,
                            letterSpacing: -1.0,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 28, height: 1,
                              color: Colors.white.withValues(alpha: 0.30),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'LOGISTICS SUITE',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.50),
                                letterSpacing: 2.8,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 28, height: 1,
                              color: Colors.white.withValues(alpha: 0.30),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom: loading indicator ──────────────────────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(36, 0, 36, 44),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) => _AnimatedDot(i * 200)),
                    ),
                    const SizedBox(height: 16),

                    // Progress bar
                    AnimatedBuilder(
                      animation: _loadCtrl,
                      builder: (_, __) {
                        final v = _loadCtrl.value;
                        double barW;
                        double op;
                        if (v < 0.75) {
                          barW = v / 0.75;
                          op   = 1.0;
                        } else {
                          barW = 1.0;
                          op   = 1.0 - ((v - 0.75) / 0.25);
                        }
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: Stack(
                            children: [
                              // Track
                              Container(
                                height: 2,
                                width: double.infinity,
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                              // Fill
                              FractionallySizedBox(
                                widthFactor: barW,
                                child: Container(
                                  height: 2,
                                  decoration: BoxDecoration(
                                    color:
                                    Colors.white.withValues(alpha: 0.65 * op),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // Label
                    Text(
                      'INITIALIZING',
                      style: GoogleFonts.dmSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.35),
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowCircle(double size, double opacity) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [
          Colors.white.withValues(alpha: opacity),
          Colors.transparent,
        ],
      ),
    ),
  );
}

// ─── Animated dot widget ──────────────────────────────────────────────────────

class _AnimatedDot extends StatefulWidget {
  final int delayMs;
  const _AnimatedDot(this.delayMs);

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
    _anim = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: FadeTransition(
        opacity: _anim,
        child: Container(
          width: 5, height: 5,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.70),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// ─── Corner accent painter ────────────────────────────────────────────────────

class _CornerAccent extends StatelessWidget {
  final bool topLeft;
  const _CornerAccent({required this.topLeft});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64, height: 64,
      child: CustomPaint(painter: _CornerPainter(topLeft: topLeft)),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool topLeft;
  const _CornerPainter({required this.topLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    if (topLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 16);
      path.arcToPoint(const Offset(16, 0),
          radius: const Radius.circular(16), clockwise: true);
      path.lineTo(size.width, 0);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height - 16);
      path.arcToPoint(Offset(size.width - 16, size.height),
          radius: const Radius.circular(16), clockwise: true);
      path.lineTo(0, size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Subtle grid background ───────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 0.8;

    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
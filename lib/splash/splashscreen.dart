import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/DashBoard/OperationAdmin/OperationAdminDashboard.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import '../DashBoard/AirFrieght/AirFrieghtDashboard.dart';
import '../DashBoard/Boarding/BoardingDashboard.dart';
import '../DashBoard/CustomerService/CustDashboard.dart';
import '../DashBoard/Driver/DriverDashboard.dart';
import '../DashBoard/Forwarding/ForwardingDashboard.dart';
import '../DashBoard/HR/HrDashboard.dart';
import '../DashBoard/Maintenance/MaintenanceDashboard.dart';
import '../DashBoard/Payable/PayableDashbord.dart';
import '../DashBoard/Receivable/ReceivableDashboard.dart';
import '../DashBoard/TransportDB/TransportDashboard.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/pages/login_page.dart.dart';
import '../DashBoard/User/UserDashboard.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import '../features/dashboard/admin_dashboard/bloc/admin_tab_bloc.dart';
import '../features/dashboard/admin_dashboard/view/admin_dashboard.dart';
import '../features/dashboard/airfrieght_dashboard/view/airfrieght_dashboard.dart';
import '../features/dashboard/subadmin_dashboard/bloc/subadmin_dashboard_bloc.dart';
import '../features/dashboard/subadmin_dashboard/view/subadmin_dashboard.dart';

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

  // ── ORIGINAL LOGIC — NOT MODIFIED ─────────────────────────────────────────
  Future startup() async {
    await objfun.localstoragecall();
    await Future.delayed(const Duration(seconds: 3));
    await objfun.getDeviceToken();
    String UserName = objfun.storagenew.getString('Username') ?? "";
    String Password = objfun.storagenew.getString('Password') ?? "";
    String OldUserName = objfun.storagenew.getString('OldUsername') ?? "";
    objfun.MalevaScreen= objfun.storagenew.getInt('DeviceView') ?? 1;
    objfun.DriverLogin=objfun.storagenew.getInt('DriverId') ?? 0;
    if (UserName != "" && Password != "") {
      if (await OnlineApi.Login(UserName, Password, OldUserName,objfun.DriverLogin, context) ==
          true) {

        if(objfun.DriverLogin == 1)
        {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const DriverDashboard()));
        }
        else if(objfun.storagenew.getString('RulesType') == "ADMIN")
        {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => AdminTabBloc(),
                child: const NewAdminDashboard(),
              ),
            ),
          );
        }
        else if(objfun.storagenew.getString('RulesType') == "ADMIN2")
        {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => SubAdminTabBloc(),
                child: const SubAdminDashboard(),
              ),
            ),
          );
        }
        else if(objfun.storagenew.getString('RulesType') == "SALES")
        {
        //  Navigator.push(context, MaterialPageRoute(builder: (context) => const CustDashboard()));
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SalesDashboard()));
        }
        else if(objfun.storagenew.getString('RulesType') == "TRANSPORTATION")
        {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TransportDashboard()));
        }
        else if(objfun.storagenew.getString('RulesType') == "OPERATIONADMIN")
        {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const OperationAdminDashboard()));
        }
        else if(objfun.storagenew.getString('RulesType') == "AIR FRIEGHT")
        {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AirFrieghtDashboard()));
        }
        else if(objfun.storagenew.getString('RulesType') == "BOARDING" || objfun.storagenew.getString('RulesType') == "OPERATION")
        {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const BoardingDashboard()));
        }
        else if( objfun.storagenew.getString('RulesType') == "FORWARDING" )
        {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ForwardingDashboard()));
        }
        else if( objfun.storagenew.getString('RulesType') == "HRADMIN")
        {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const HrDashboard()));
        }
        else if(objfun.storagenew.getString('RulesType') == "HR")
        {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MaintenanceDashboard()));
        }
        else if( objfun.storagenew.getString('RulesType') == "RECEIVABLE" )
        {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ReceivableDashboard()));
        }
        else if( objfun.storagenew.getString('RulesType') == "ACCOUNTS")
        {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PayableDashbord()));
        }
        else
        {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const Homemobile()));
        }
      }
      else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => LoginBloc(),
              child: const Appuserloginmobile(),
            ),
          ),
        );
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => LoginBloc(),
            child: const Appuserloginmobile(),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _loadCtrl.dispose();
    super.dispose();
  }

  // ── BUILD — only this section is redesigned ────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colour.kPrimary,
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
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.18), width: 1),
                  ),
                  child: Text(
                    objfun.appversion,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.75),
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
                        color: Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(34),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.20), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(33),
                        child: Image(
                          image: objfun.splashlogo,
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
                              color: Colors.white.withOpacity(0.30),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'LOGISTICS SUITE',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.50),
                                letterSpacing: 2.8,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 28, height: 1,
                              color: Colors.white.withOpacity(0.30),
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
                                color: Colors.white.withOpacity(0.12),
                              ),
                              // Fill
                              FractionallySizedBox(
                                widthFactor: barW,
                                child: Container(
                                  height: 2,
                                  decoration: BoxDecoration(
                                    color:
                                    Colors.white.withOpacity(0.65 * op),
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
                        color: Colors.white.withOpacity(0.35),
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
          Colors.white.withOpacity(opacity),
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
            color: Colors.white.withOpacity(0.70),
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
      ..color = Colors.white.withOpacity(0.15)
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
      ..color = Colors.white.withOpacity(0.03)
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
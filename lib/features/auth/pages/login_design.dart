part of 'package:maleva/features/auth/pages/login_page.dart.dart';

// ─── Design tokens ─────────────────────────────────────────────────────────────

// ─── Responsive shell ─────────────────────────────────────────────────────────
class mobiledesign extends StatelessWidget {
  const mobiledesign({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        backgroundColor: colour.kBg,
        body: BlocListener<LoginBloc, LoginState>(
          listenWhen: (p, c) =>
          p.loginSuccess != c.loginSuccess ||
              p.errorMessage != c.errorMessage,
          listener: (context, state) {
            if (state.loginSuccess && state.role != null) {
              Navigator.pushReplacementNamed(context, state.role!);
            }
            if (state.errorMessage?.isNotEmpty == true) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: const Color(0xFFE11D48),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ));
            }
          },
          child: BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) => _LoginBody(
              state: state,
              isTablet: constraints.maxWidth >= 600, // ← single flag
            ),
          ),
        ),
      );
    });
  }
}

// ─── Single LoginBody — mobile & tablet both handle பண்றது ───────────────────
class _LoginBody extends StatefulWidget {
  final LoginState state;
  final bool isTablet;

  const _LoginBody({required this.state, required this.isTablet});

  @override
  State<_LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<_LoginBody>
    with SingleTickerProviderStateMixin {
  final _pwCtrl = TextEditingController();
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _pwCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _onKey(String key) {
    final bloc = context.read<LoginBloc>();
    final cur = _pwCtrl.text;
    if (key == 'CLEAR') {
      _pwCtrl.clear();
      bloc.add(PasswordChanged(''));
    } else if (key == 'C') {
      if (cur.isNotEmpty) {
        final v = cur.substring(0, cur.length - 1);
        _pwCtrl.value = TextEditingValue(
            text: v,
            selection: TextSelection.collapsed(offset: v.length));
        bloc.add(PasswordChanged(v));
      }
    } else {
      final v = cur + key;
      _pwCtrl.value = TextEditingValue(
          text: v,
          selection: TextSelection.collapsed(offset: v.length));
      bloc.add(PasswordChanged(v));
    }
  }

  // ── Shorthand getters ──────────────────────────────────────────────────
  bool get _isTablet => widget.isTablet;
  LoginState get _s => widget.state;

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final compact = !_isTablet && screenH < 700;

    return Stack(children: [
      // Background
      Positioned.fill(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE8EBF8), Color(0xFFECEEF4), Color(0xFFDFE4F5)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: CustomPaint(painter: _DotPatternPainter()),
        ),
      ),

      // Content
      AbsorbPointer(
        absorbing: _s.loading,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: _isTablet ? 32 : 20,
                vertical:   _isTablet ? 28 : (compact ? 14 : 22),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: _isTablet ? 860 : 420,
                  ),
                  child: Column(children: [
                    // Brand strip
                    _buildBrandStrip(compact),
                    SizedBox(height: _isTablet ? 28 : (compact ? 14 : 20)),

                    // Card — tablet=two-col, mobile=single-col
                    _isTablet
                        ? _buildTabletCard()
                        : _buildMobileCard(compact),

                    SizedBox(height: _isTablet ? 20 : 12),
                    _buildDots(),
                    const SizedBox(height: 8),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),

      if (_s.loading) _buildLoadingOverlay(),
    ]);
  }

  // ══════════════════════════════════════════════════════════════════════
  // BRAND STRIP
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildBrandStrip(bool compact) {
    final logoSize      = _isTablet ? 84.0 : (compact ? 62.0 : 72.0);
    final titleFontSize = _isTablet ? 30.0 : (compact ? 24.0 : 27.0);

    return Column(children: [
      Stack(alignment: Alignment.center, children: [
        // Glow ring
        Container(
          width:  logoSize + 22,
          height: logoSize + 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              AppTokens.brandGradientStart.withOpacity(0.18),
              AppTokens.brandGradientStart.withOpacity(0.0),
            ]),
          ),
        ),
        // Logo box
        Container(
          width:  logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(logoSize * 0.32),
            border: Border.all(color: AppTokens.brandGradientStart.withOpacity(0.14), width: 1.5),
            boxShadow: [
              BoxShadow(color: AppTokens.brandGradientStart.withOpacity(0.26), blurRadius: 24, offset: const Offset(0, 8)),
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(logoSize * 0.30),
            child: Padding(
              padding: EdgeInsets.all(_isTablet ? 14 : 11),
              child: Image(image: objfun.splashlogo, fit: BoxFit.contain),
            ),
          ),
        ),
      ]),

      SizedBox(height: _isTablet ? 14 : 10),

      ShaderMask(
        shaderCallback: (b) =>
            const LinearGradient(colors: [AppTokens.brandDark, AppTokens.brandGradientStart]).createShader(b),
        child: Text('Maleva',
            style: GoogleFonts.playfairDisplay(
              fontSize:   titleFontSize,
              fontWeight: FontWeight.w700,
              color:      Colors.white,
              letterSpacing: -0.5,
            )),
      ),

      const SizedBox(height: 5),

      Row(mainAxisSize: MainAxisSize.min, children: [
        _lineDivider(),
        const SizedBox(width: 10),
        Text('LOGISTICS SUITE',
            style: GoogleFonts.dmSans(
                fontSize: 9, fontWeight: FontWeight.w600,
                color: colour.kSubText, letterSpacing: 3.0)),
        const SizedBox(width: 10),
        _lineDivider(),
      ]),
    ]);
  }

  // ══════════════════════════════════════════════════════════════════════
  // MOBILE CARD — single column
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildMobileCard(bool compact) {
    final sp = compact ? 11.0 : 15.0;
    return _cardShell(
      padH: 20,
      padV: compact ? 18 : 24,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardHeader(headingSize: compact ? 18 : 20, subSize: 12),
        SizedBox(height: sp * 0.5),
        _headerDivider(),
        SizedBox(height: sp),

        _fieldLabel('Username', fs: 9.5),
        SizedBox(height: sp * 0.4),
        _textField(hint: 'Enter your username',
            icon: Icons.person_outline_rounded,
            fs: 13, radius: 11,
            onChanged: (v) => context.read<LoginBloc>().add(UsernameChanged(v))),
        SizedBox(height: sp * 0.85),

        _fieldLabel('Password', fs: 9.5),
        SizedBox(height: sp * 0.4),
        _textField(hint: '• • • • • •',
            obscure: _s.obscurePassword,
            ctrl: _pwCtrl, readOnly: true,
            fs: 13, radius: 11,
            icon: _s.obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            onIconTap: () =>
                context.read<LoginBloc>().add(TogglePasswordVisibility()),
            onChanged: (_) {}),
        SizedBox(height: sp * 0.85),

        _driverToggle(toggleSize: 13),
        SizedBox(height: sp),

        _pinLabel(),
        SizedBox(height: sp * 0.6),

        _keypad(btnH: compact ? 46 : 50, btnFs: compact ? 15 : 16,
            radius: 11, rowSp: compact ? 7 : 9, colSp: 7),
        SizedBox(height: sp * 0.7),

        _loginButton(h: compact ? 48 : 52, fs: 13, radius: 13),
        SizedBox(height: sp * 0.5),

        _footer(),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // TABLET CARD — two columns
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildTabletCard() {
    return _cardShell(
      padH: 0, padV: 0,
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

          // ── LEFT: fields
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.fromLTRB(32, 32, 28, 32),
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: Color(0xFFECEEF5), width: 1)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _cardHeader(headingSize: 22, subSize: 13),
                const SizedBox(height: 6),
                _headerDivider(),
                const SizedBox(height: 22),

                _fieldLabel('Username', fs: 10),
                const SizedBox(height: 7),
                _textField(hint: 'Enter your username',
                    icon: Icons.person_outline_rounded,
                    fs: 15, radius: 13,
                    onChanged: (v) =>
                        context.read<LoginBloc>().add(UsernameChanged(v))),
                const SizedBox(height: 18),

                _fieldLabel('Password', fs: 10),
                const SizedBox(height: 7),
                _textField(hint: '• • • • • •',
                    obscure: _s.obscurePassword,
                    ctrl: _pwCtrl, readOnly: true,
                    fs: 15, radius: 13,
                    icon: _s.obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    onIconTap: () =>
                        context.read<LoginBloc>().add(TogglePasswordVisibility()),
                    onChanged: (_) {}),
                const SizedBox(height: 18),

                _driverToggle(toggleSize: 15),

                const Spacer(),
                _footer(),
              ]),
            ),
          ),

          // ── RIGHT: keypad
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.fromLTRB(28, 32, 32, 32),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FE),
                borderRadius: const BorderRadius.only(
                  topRight:    Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _pinLabel(),
                const SizedBox(height: 16),
                _keypad(btnH: 58, btnFs: 20, radius: 14, rowSp: 12, colSp: 10),
                const SizedBox(height: 14),
                Flexible(
                  child: _loginButton(h: 50, fs: 16, radius: 8),
                )
              ]),
            ),
          ),

        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // SHARED BUILDER HELPERS  (private methods — no extra classes needed)
  // ══════════════════════════════════════════════════════════════════════

  Widget _cardShell({required double padH, required double padV, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.93),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.5),
        boxShadow: [
          BoxShadow(color: AppTokens.brandGradientStart.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 2)),
          BoxShadow(color: AppTokens.brandGradientStart.withOpacity(0.11), blurRadius: 55, offset: const Offset(0, 22)),
        ],
      ),
      padding: padH > 0
          ? EdgeInsets.symmetric(horizontal: padH, vertical: padV)
          : EdgeInsets.zero,
      child: child,
    );
  }

  Widget _cardHeader({required double headingSize, required double subSize}) {
    return Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Welcome back',
            style: GoogleFonts.dmSans(
                fontSize: headingSize, fontWeight: FontWeight.w700,
                color: colour.kText, letterSpacing: -0.4)),
        const SizedBox(height: 3),
        Text('Sign in to continue',
            style: GoogleFonts.dmSans(
                fontSize: subSize, fontWeight: FontWeight.w400,
                color: colour.kSubText)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTokens.brandGradientStart.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTokens.brandGradientStart.withOpacity(0.15), width: 1),
        ),
        child: Text('v2.0',
            style: GoogleFonts.dmSans(
                fontSize: 10, fontWeight: FontWeight.w600,
                color: AppTokens.brandGradientStart, letterSpacing: 0.5)),
      ),
    ]);
  }

  Widget _fieldLabel(String text, {required double fs}) => Text(
    text.toUpperCase(),
    style: GoogleFonts.dmSans(
        fontSize: fs, fontWeight: FontWeight.w600,
        color: colour.kFieldText, letterSpacing: 1.0),
  );

  Widget _textField({
    required String hint,
    required double fs,
    required double radius,
    required ValueChanged<String> onChanged,
    bool obscure            = false,
    IconData? icon,
    VoidCallback? onIconTap,
    TextEditingController? ctrl,
    bool readOnly           = false,
  }) {
    return TextField(
      controller:  ctrl,
      readOnly:    readOnly,
      obscureText: obscure,
      onChanged:   onChanged,
      style: GoogleFonts.dmSans(fontSize: fs, color: colour.kText),
      decoration: InputDecoration(
        hintText:  hint,
        hintStyle: GoogleFonts.dmSans(fontSize: fs, color: colour.kSubText),
        filled:    true,
        fillColor: colour.kSurface,
        contentPadding: EdgeInsets.symmetric(horizontal: radius + 4, vertical: radius),
        border:        OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: const BorderSide(color: Color(0xFFECEEF5), width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: const BorderSide(color: Color(0xFFECEEF5), width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: const BorderSide(color: AppTokens.brandGradientStart, width: 1.5)),
        suffixIcon: icon != null
            ? GestureDetector(
            onTap: onIconTap,
            child: Icon(icon, size: fs + 5, color: colour.kSubText))
            : null,
      ),
    );
  }

  Widget _driverToggle({required double toggleSize}) {
    final on = _s.driverLogin;
    return GestureDetector(
      onTap: () => context.read<LoginBloc>().add(ToggleDriverLogin(!on)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: on ? AppTokens.brandGradientStart.withOpacity(0.07) : colour.kSurface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
              color: on ? AppTokens.brandGradientStart.withOpacity(0.30) : colour.kBorder, width: 1.5),
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width:  toggleSize * 2.7,
            height: toggleSize * 1.6,
            decoration: BoxDecoration(
              color: on ? AppTokens.brandGradientStart : const Color(0xFFDDE0EE),
              borderRadius: BorderRadius.circular(toggleSize),
              boxShadow: on
                  ? [BoxShadow(color: AppTokens.brandGradientStart.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 3))]
                  : [],
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: on ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: toggleSize * 1.3, height: toggleSize * 1.3,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: colour.cWhite, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 3, offset: const Offset(0, 1))],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Driver Login',
                style: GoogleFonts.dmSans(
                    fontSize: toggleSize, fontWeight: FontWeight.w500,
                    color: on ? AppTokens.brandGradientStart : const Color(0xFF505578))),
          ),
          if (on) Icon(Icons.check_circle_rounded, color: AppTokens.brandGradientStart, size: toggleSize * 1.35),
        ]),
      ),
    );
  }

  Widget _pinLabel() => Row(children: [
    Text('ENTER PIN',
        style: GoogleFonts.dmSans(
            fontSize: 9, fontWeight: FontWeight.w600,
            color: colour.kSubText, letterSpacing: 2.0)),
    const SizedBox(width: 10),
    Expanded(child: Container(height: 1, color: colour.kBorder)),
  ]);

  Widget _keypad({
    required double btnH,
    required double btnFs,
    required double radius,
    required double rowSp,
    required double colSp,
  }) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['CLEAR', '0', 'C'],
    ];
    return Column(
      children: rows.map((row) => Padding(
        padding: EdgeInsets.only(bottom: rowSp),
        child: Row(
          children: row.map((key) => Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: colSp * 0.5),
              child: _KeypadButton(
                label: key,
                isAction: key == 'CLEAR' || key == 'C',
                height: btnH, fontSize: btnFs, radius: radius,
                onTap: () => _onKey(key),
              ),
            ),
          )).toList(),
        ),
      )).toList(),
    );
  }

  Widget _loginButton({required double h, required double fs, required double radius}) {
    return SizedBox(
      width: double.infinity, height: h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft, end: Alignment.centerRight,
            colors: [AppTokens.brandDark, AppTokens.brandGradientStart, AppTokens.brandMid],
            stops: [0.0, 0.45, 1.0],
          ),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [BoxShadow(color: AppTokens.brandGradientStart.withOpacity(0.40), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
            elevation: 0,
          ),
          onPressed: () => context.read<LoginBloc>().add(SubmitLogin(context)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('LOGIN',
                style: GoogleFonts.dmSans(
                    fontSize: fs, fontWeight: FontWeight.w700,
                    color: Colors.white, letterSpacing: 2.5)),
            const SizedBox(width: 10),
            Container(
              width: 26, height: 26,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 15),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _footer() => Center(
    child: Text('SHIP SPARE IN TRANSIT',
        style: GoogleFonts.dmSans(
            fontSize: 9, fontWeight: FontWeight.w500,
            color: colour.kSubText.withOpacity(0.50), letterSpacing: 2.0)),
  );
  Widget _lineDivider() => Container(
    width: 28,
    height: 1,
    decoration: BoxDecoration(
      gradient: LinearGradient(
          colors: [colour.kSubText.withOpacity(0.0), colour.kSubText.withOpacity(0.4)]),
    ),
  );

  Widget _headerDivider() => Container(
    height: 1,
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [
        AppTokens.brandGradientStart.withOpacity(0.25),
        AppTokens.brandGradientStart.withOpacity(0.0),
      ]),
    ),
  );
  Widget _buildDots() => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(
      width: 18, height: 5,
      decoration: BoxDecoration(
        color: AppTokens.brandGradientStart,
        borderRadius: BorderRadius.circular(3),
        boxShadow: [BoxShadow(color: AppTokens.brandGradientStart.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 2))],
      ),
    ),
    const SizedBox(width: 5),
    Container(width: 5, height: 5,
        decoration: BoxDecoration(color: const Color(0xFFDDE4FF), borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 5),
    Container(width: 5, height: 5,
        decoration: BoxDecoration(color: const Color(0xFFDDE4FF), borderRadius: BorderRadius.circular(3))),
  ]);

  Widget _buildLoadingOverlay() => Container(
    color: Colors.black.withOpacity(0.25),
    child: Center(
      child: Container(
        width: 72, height: 72,
        decoration: BoxDecoration(
          color: colour.cWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: AppTokens.brandGradientStart.withOpacity(0.15), blurRadius: 30),
            BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 12),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppTokens.brandGradientStart, strokeWidth: 2.5),
        ),
      ),
    ),
  );
}

// ─── Keypad button ────────────────────────────────────────────────────────────
class _KeypadButton extends StatefulWidget {
  final String label; final bool isAction;
  final double height, fontSize, radius;
  final VoidCallback onTap;

  const _KeypadButton({
    required this.label, required this.isAction,
    required this.height, required this.fontSize,
    required this.radius, required this.onTap,
  });

  @override
  State<_KeypadButton> createState() => _KeypadButtonState();
}

class _KeypadButtonState extends State<_KeypadButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 75));
    _scale = Tween<double>(begin: 1.0, end: 0.90)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _down(_) => _ctrl.forward();
  void _up(_)   { _ctrl.reverse(); widget.onTap(); }
  void _cancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _down, onTapUp: _up, onTapCancel: _cancel,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            gradient: widget.isAction
                ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [AppTokens.brandDark, AppTokens.brandDark.withOpacity(0.82)])
                : const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [AppTokens.brandGradientStart, AppTokens.brandMid]),
            borderRadius: BorderRadius.circular(widget.radius),
            boxShadow: [
              BoxShadow(
                color: (widget.isAction ? AppTokens.brandDark : AppTokens.brandGradientStart).withOpacity(0.28),
                blurRadius: 10, offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.dmSans(
                fontSize:   widget.label == 'CLEAR' ? widget.fontSize * 0.68 : widget.fontSize,
                fontWeight: FontWeight.w700,
                color:      colour.cWhite,
                letterSpacing: widget.label == 'CLEAR' ? 1.0 : 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Dot pattern painter ──────────────────────────────────────────────────────
class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1555F3).withOpacity(0.04)
      ..style = PaintingStyle.fill;
    for (double x = 0; x < size.width; x += 28) {
      for (double y = 0; y < size.height; y += 28) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotPatternPainter _) => false;
}

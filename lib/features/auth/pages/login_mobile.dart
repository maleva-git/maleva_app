part of 'package:maleva/features/auth/pages/login_page.dart.dart';

// ─── Design tokens ─────────────────────────────────────────────────────────────
const _kPrimary   = Color(0xFF1555F3);
const _kPrimaryD  = Color(0xFF0D2A99);
const _kPrimaryL  = Color(0xFF3A7BFF);
const _kBg        = Color(0xFFECEEF4);
const _kWhite     = Color(0xFFFFFFFF);
const _kSurface   = Color(0xFFF5F6FA);
const _kBorder    = Color(0xFFECEEF5);
const _kText      = Color(0xFF1A1D2E);
const _kSubText   = Color(0xFFB0B4C8);
const _kFieldText = Color(0xFF6B7094);

// ─── Responsive shell — logic untouched ───────────────────────────────────────

class mobiledesign extends StatelessWidget {
  const mobiledesign({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Widget content;
        if (constraints.maxWidth < 600) {
          content = const LoginMobileView();
        } else if (constraints.maxWidth < 1300) {
          content = const LoginTabletView();
        } else {
          content = const LoginWebView();
        }

        // AppBar removed — full-bleed elite design
        return Scaffold(
          backgroundColor: _kBg,
          body: content,
        );
      },
    );
  }
}

class LoginWebView extends StatelessWidget {
  const LoginWebView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(width: 420, child: LoginMobileView()),
    );
  }
}

class LoginTabletView extends StatelessWidget {
  const LoginTabletView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(width: 500, child: LoginMobileView()),
    );
  }
}

// ─── BLoC wiring — untouched ──────────────────────────────────────────────────

class LoginMobileView extends StatelessWidget {
  const LoginMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (previous, current) =>
      previous.loginSuccess != current.loginSuccess ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.loginSuccess && state.role != null) {
          Navigator.pushReplacementNamed(context, state.role!);
        }
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: const Color(0xFFE11D48),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) => _LoginBody(state: state),
      ),
    );
  }
}

// ─── Login body — fully redesigned UI, same BLoC events ──────────────────────

class _LoginBody extends StatelessWidget {
  final LoginState state;
  const _LoginBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Scrollable form ─────────────────────────────────────────────
        AbsorbPointer(
          absorbing: state.loading,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildBrandStrip(),
                    const SizedBox(height: 28),
                    _buildCard(context),
                    const SizedBox(height: 20),
                    _buildDots(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Loading overlay ─────────────────────────────────────────────
        if (state.loading) _buildLoadingOverlay(),
      ],
    );
  }

  // ── Brand strip: logo box + name + tagline ─────────────────────────────
  Widget _buildBrandStrip() {
    return Column(
      children: [
        // Logo mark box
        Container(
          width: 76, height: 76,
          decoration: BoxDecoration(
            color: Colors.white,                          // clean white bg
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _kPrimary.withOpacity(0.12),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _kPrimary.withOpacity(0.22),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image(
                image: objfun.splashlogo,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Brand name
        Text(
          'Maleva',
          style: GoogleFonts.playfairDisplay(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: _kText,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 5),

        // Divider + tagline
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 24, height: 1,
                color: _kSubText.withOpacity(0.35)),
            const SizedBox(width: 8),
            Text(
              'LOGISTICS SUITE',
              style: GoogleFonts.dmSans(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: _kSubText,
                letterSpacing: 2.5,
              ),
            ),
            const SizedBox(width: 8),
            Container(width: 24, height: 1,
                color: _kSubText.withOpacity(0.35)),
          ],
        ),
      ],
    );
  }

  // ── Main card ──────────────────────────────────────────────────────────
  Widget _buildCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _kPrimary.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: _kPrimary.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: _kPrimary.withOpacity(0.10),
            blurRadius: 50,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Text(
            'Welcome back',
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _kText,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sign in to continue',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: _kSubText,
            ),
          ),

          const SizedBox(height: 28),

          // Username field
          _buildFieldLabel('Username'),
          const SizedBox(height: 7),
          _EliteTextField(
            hintText: 'Enter your username',
            suffixIcon: Icons.person_outline_rounded,
            onChanged: (v) =>
                context.read<LoginBloc>().add(UsernameChanged(v)),
          ),

          const SizedBox(height: 18),

          // Password field
          _buildFieldLabel('Password'),
          const SizedBox(height: 7),
          _EliteTextField(
            hintText: 'Enter your password',
            obscureText: state.obscurePassword,
            suffixIcon: state.obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            onSuffixTap: () =>
                context.read<LoginBloc>().add(TogglePasswordVisibility()),
            onChanged: (v) =>
                context.read<LoginBloc>().add(PasswordChanged(v)),
          ),

          const SizedBox(height: 14),

          // Driver login toggle
          _buildDriverToggle(context),

          const SizedBox(height: 24),

          // Login button
          _buildLoginButton(context),

          const SizedBox(height: 20),

          // Footer label
          Center(
            child: Text(
              'SHIP SPARE IN TRANSIT',
              style: GoogleFonts.dmSans(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: _kSubText.withOpacity(0.60),
                letterSpacing: 1.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Field label ────────────────────────────────────────────────────────
  Widget _buildFieldLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.dmSans(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: _kFieldText,
        letterSpacing: 1.0,
      ),
    );
  }

  // ── Driver login row ───────────────────────────────────────────────────
  Widget _buildDriverToggle(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.read<LoginBloc>().add(ToggleDriverLogin(!state.driverLogin)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: state.driverLogin
              ? _kPrimary.withOpacity(0.06)
              : _kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: state.driverLogin
                ? _kPrimary.withOpacity(0.25)
                : _kBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Custom toggle switch
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36, height: 20,
              decoration: BoxDecoration(
                color: state.driverLogin ? _kPrimary : const Color(0xFFDDE0EE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                alignment: state.driverLogin
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 16, height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: _kWhite,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Text(
              'Driver Login',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: state.driverLogin ? _kPrimary : const Color(0xFF505578),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Login button ───────────────────────────────────────────────────────
  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [_kPrimaryD, _kPrimary, _kPrimaryL],
            stops: [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _kPrimary.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          onPressed: () =>
              context.read<LoginBloc>().add(SubmitLogin(context)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SIGN IN',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step dots ──────────────────────────────────────────────────────────
  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 14, height: 5,
          decoration: BoxDecoration(
            color: _kPrimary,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Container(
          width: 5, height: 5,
          decoration: BoxDecoration(
            color: const Color(0xFFDDE4FF),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Container(
          width: 5, height: 5,
          decoration: BoxDecoration(
            color: const Color(0xFFDDE4FF),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }

  // ── Loading overlay ────────────────────────────────────────────────────
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.30),
      child: Center(
        child: Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: _kWhite,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
              ),
            ],
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: _kPrimary,
              strokeWidth: 2.5,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Elite text field widget ──────────────────────────────────────────────────

class _EliteTextField extends StatelessWidget {
  final String     hintText;
  final bool       obscureText;
  final IconData?  suffixIcon;
  final VoidCallback? onSuffixTap;
  final ValueChanged<String> onChanged;

  const _EliteTextField({
    required this.hintText,
    required this.onChanged,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      onChanged: onChanged,
      style: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF1A1D2E),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFB0B4C8),
        ),
        filled: true,
        fillColor: const Color(0xFFF5F6FA),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFECEEF5), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFECEEF5), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kPrimary, width: 1.5),
        ),
        suffixIcon: suffixIcon != null
            ? GestureDetector(
          onTap: onSuffixTap,
          child: Icon(
            suffixIcon,
            size: 20,
            color: const Color(0xFFB0B4C8),
          ),
        )
            : null,
      ),
    );
  }
}
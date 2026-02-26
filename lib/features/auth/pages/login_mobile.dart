part of 'package:maleva/features/auth/pages/login_page.dart.dart';

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

        return Scaffold(
          appBar: AppBar(
            title: const Text("SHIP SPARE IN TRANSIT"),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
            ),
          ),
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
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 420, // web / desktop card width
          child: const LoginMobileView(), // reuse mobile UI
        ),
      ),
    );
  }
}

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

        if (state.errorMessage != null &&
            state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return _LoginBody(state: state);
        },
      ),
    );
  }
}

class _LoginBody extends StatelessWidget {
  final LoginState state;
  const _LoginBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        AbsorbPointer(
          absorbing: state.loading,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          /// LOGO
                          Image(
                            image: objfun.splashlogo,
                            width: 240,
                          ),

                          const SizedBox(height: 24),

                          /// USERNAME
                          TextField(
                            onChanged: (v) => context
                                .read<LoginBloc>()
                                .add(UsernameChanged(v)),
                            decoration: const InputDecoration(
                              labelText: "Username",
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// PASSWORD
                          TextField(
                            obscureText: state.obscurePassword,
                            onChanged: (v) => context
                                .read<LoginBloc>()
                                .add(PasswordChanged(v)),
                            decoration: InputDecoration(
                              labelText: "Password",
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  state.obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () => context
                                    .read<LoginBloc>()
                                    .add(TogglePasswordVisibility()),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          /// DRIVER LOGIN
                          Row(
                            children: [
                              Checkbox(
                                value: state.driverLogin,
                                onChanged: (v) => context
                                    .read<LoginBloc>()
                                    .add(ToggleDriverLogin(v!)),
                              ),
                              const Text("Driver Login"),
                            ],
                          ),

                          const SizedBox(height: 20),

                          /// LOGIN BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: AppColors.primaryGradient, // ✅ Reused
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  context
                                      .read<LoginBloc>()
                                      .add(SubmitLogin(context));
                                },
                                child: const Text(
                                  "LOGIN",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        /// LOADING OVERLAY
        if (state.loading)
          Container(
            color: Colors.black.withOpacity(0.25),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

}
class LoginTabletView extends StatelessWidget {
  const LoginTabletView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 500,
        child: const LoginMobileView(),
      ),
    );
  }
}


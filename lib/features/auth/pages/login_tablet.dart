part of 'package:maleva/features/auth/pages/login_page.dart.dart';


class tabletdesign extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          body: Column(
            children: [
              TextField(
                onChanged: (v) =>
                    context.read<LoginBloc>().add(UsernameChanged(v)),
              ),

              TextField(
                obscureText: state.obscurePassword,
                onChanged: (v) =>
                    context.read<LoginBloc>().add(PasswordChanged(v)),
                decoration: InputDecoration(
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


              ElevatedButton(
                onPressed: () {
                  context.read<LoginBloc>().add(SubmitLogin(context));
                },
                child: const Text("LOGIN"),
              )
            ],
          ),
        );
      },
    );
  }
}



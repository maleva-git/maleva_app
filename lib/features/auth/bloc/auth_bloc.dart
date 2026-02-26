import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginState()) {

    on<UsernameChanged>((event, emit) {
      emit(state.copyWith(username: event.value));
    });

    on<PasswordChanged>((event, emit) {
      emit(state.copyWith(password: event.value));
    });

    on<TogglePasswordVisibility>((event, emit) {
      emit(state.copyWith(
        obscurePassword: !state.obscurePassword,
      ));
    });

    on<ToggleDriverLogin>((event, emit) {
      emit(state.copyWith(driverLogin: event.value));
    });

    on<DeviceViewChanged>((event, emit) {
      emit(state.copyWith(deviceView: event.value));
    });

    on<KeyPressed>((event, emit) {
      if (event.key == "CLEAR") {
        emit(state.copyWith(password: ""));
      } else if (event.key == "C") {
        if (state.password.isNotEmpty) {
          emit(state.copyWith(
              password:
              state.password.substring(0, state.password.length - 1)));
        }
      } else {
        emit(state.copyWith(
            password: state.password + event.key));
      }
    });

    /// 🔥 REAL LOGIN LOGIC HERE
    on<SubmitLogin>((event, emit) async {

      emit(state.copyWith(loading: true));

      String oldUserName= objfun.storagenew.getString('OldUsername') ?? state.username;

      bool result = await OnlineApi.Login(
          state.username,
          state.password,
          oldUserName,
          state.driverLogin ? 1 : 0,
          event.context
      );

      if (result) {
        objfun.storagenew.setString('OldUsername', state.username);
        String role =
            objfun.storagenew.getString('RulesType') ?? "";

        emit(state.copyWith(
          loading: false,
          loginSuccess: true,
          role: role,
        ));

      } else {
        emit(state.copyWith(
          loading: false,
          errorMessage: "Invalid Username or Password",
        ));
      }
    });


  }
}



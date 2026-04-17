class LoginState {
  final String username;
  final String password;
  final bool obscurePassword;
  final bool driverLogin;
  final String deviceView;
  final String JWTToken;
  final bool loading;
  final bool loginSuccess;
  final String? errorMessage;
  final String? role;   // 👈 ADD THIS

  LoginState({
    this.username = "",
    this.password = "",
    this.obscurePassword = true,
    this.driverLogin = false,
    this.deviceView = "1",
    this.JWTToken = "",
    this.loading = false,
    this.loginSuccess = false,
    this.errorMessage,
    this.role,
  });

  LoginState copyWith({
    String? username,
    String? password,
    bool? obscurePassword,
    bool? driverLogin,
    String? deviceView,
    String? JWTToken,
    bool? loading,
    bool? loginSuccess,
    String? errorMessage,
    String? role,  // 👈 ADD
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      driverLogin: driverLogin ?? this.driverLogin,
      deviceView: deviceView ?? this.deviceView,
      loading: loading ?? this.loading,
      JWTToken: JWTToken ?? this.JWTToken,
      loginSuccess: loginSuccess ?? this.loginSuccess,
      errorMessage: errorMessage,
      role: role ?? this.role,
    );
  }
}


import 'package:flutter/Material.dart';

/// EVENTS
abstract class LoginEvent {}

class UsernameChanged extends LoginEvent {
  final String value;
  UsernameChanged(this.value);
}

class PasswordChanged extends LoginEvent {
  final String value;
  PasswordChanged(this.value);
}

class TogglePasswordVisibility extends LoginEvent {}

class ToggleDriverLogin extends LoginEvent {
  final bool value;
  ToggleDriverLogin(this.value);
}

class DeviceViewChanged extends LoginEvent {
  final String value;
  DeviceViewChanged(this.value);
}

class SubmitLogin extends LoginEvent {
  final BuildContext context;   // <-- probably this

  SubmitLogin(this.context);
}



class KeyPressed extends LoginEvent {
  final String key;
  KeyPressed(this.key);
}

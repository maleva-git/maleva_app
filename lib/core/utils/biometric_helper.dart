import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricHelper {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Checks if the device supports biometric authentication.
  static Future<bool> hasBiometrics() async {
    try {
      final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Triggers the biometric prompt and returns true if authentication is successful.
  static Future<bool> authenticate() async {
    try {
      if (!await hasBiometrics()) return false;

      return await _auth.authenticate(
        localizedReason: 'Please authenticate to log in securely',
        persistAcrossBackgrounding: true,
        biometricOnly: false,
      );
    } on PlatformException catch (_) {
      return false;
    }
  }
}

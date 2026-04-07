import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setFcmToken(String token) async {
    await _prefs.setString('fcm_token', token);
  }

  static String getFcmToken() {
    return _prefs.getString('fcm_token') ?? "";
  }
}
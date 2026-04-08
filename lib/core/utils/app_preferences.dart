// core/utils/app_preferences.dart
// clsfunction.dart la irundha storagenew usage-a inga centralize pannurom
// oru oru page la storagenew.getString(...) direct call panna vendaam —
// AppPreferences.xxx() use pannunga

import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences._();

  static late SharedPreferences _prefs;

  // main.dart-la oru thadava init pannu
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ─── Getters ──────────────────────────────────────────────────────────────
  static int    getComid()       => _prefs.getInt('Comid')       ?? 0;
  static int    getMComid()      => _prefs.getInt('MComid')      ?? 0;
  static int    getDriverId()    => _prefs.getInt('DriverId')    ?? 0;
  static int    getEmpRefId()    => _prefs.getInt('EmpRefId')    ?? 0;
  static int    getDeviceView()  => _prefs.getInt('DeviceView')  ?? 1;
  static String getUsername()    => _prefs.getString('Username') ?? '';
  static String getPassword()    => _prefs.getString('Password') ?? '';
  static String getOldUsername() => _prefs.getString('OldUsername') ?? '';
  static String getTokenKey()    => _prefs.getString('Tokenkey') ?? '';
  static String getUserId()      => _prefs.getString('Userid')   ?? '';
  static String getProfile()     => _prefs.getString('Profile')  ?? '';
  static String getRulesType()   => _prefs.getString('RulesType') ?? '';
  static String getFcmToken()    => _prefs.getString('FcmToken') ?? '';
  static String getLoadMenu()    => _prefs.getString('loadmenu') ?? '';
  static String getEnquiryOpen() => _prefs.getString('EnquiryOpen') ?? 'false';

  // ─── Setters ──────────────────────────────────────────────────────────────
  static Future<void> setComid(int v)        => _prefs.setInt('Comid', v);
  static Future<void> setMComid(int v)       => _prefs.setInt('MComid', v);
  static Future<void> setDriverId(int v)     => _prefs.setInt('DriverId', v);
  static Future<void> setEmpRefId(int v)     => _prefs.setInt('EmpRefId', v);
  static Future<void> setUsername(String v)  => _prefs.setString('Username', v);
  static Future<void> setPassword(String v)  => _prefs.setString('Password', v);
  static Future<void> setOldUsername(String v) => _prefs.setString('OldUsername', v);
  static Future<void> setRulesType(String v) => _prefs.setString('RulesType', v);
  static Future<void> setFcmToken(String v)  => _prefs.setString('FcmToken', v);
  static Future<void> setLoadMenu(String v)  => _prefs.setString('loadmenu', v);
  static Future<void> setEnquiryOpen(String v) => _prefs.setString('EnquiryOpen', v);
  static Future<void> setTokenKey(String v)  => _prefs.setString('Tokenkey', v);

  // ─── Clear on logout ──────────────────────────────────────────────────────
  static Future<void> clearOnLogout() async {
    await _prefs.setString('Username', '');
    await _prefs.setString('Password', '');
    await _prefs.setString('OldUsername', '');
    await _prefs.setInt('EmpRefId', 0);
  }

  // Raw SharedPreferences access (legacy clsfunction.dart use panna vendiruntha)
  static SharedPreferences get raw => _prefs;
}
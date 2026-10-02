import 'package:maleva/core/models/shared/menu_master_model.dart';

/// The session the Java backend returns in `Data1` of sign-in and refresh
/// (`POST /api/mobile/auth/login`, `/refresh`).
///
/// The session fields have new names; the menu rows keep the legacy .NET keys
/// (`FormText`, `Id`, `ParentId`, ...) so [MenuMasterModel] parses them as before.
class MobileSession {
  const MobileSession({
    required this.token,
    required this.expiresAt,
    required this.sessionExpiresAt,
    required this.isDriver,
    required this.userId,
    required this.companyId,
    required this.mComid,
    required this.companyName,
    required this.rulesType,
    required this.roleId,
    required this.permissionId,
    required this.truckRefId,
    required this.truckName,
    required this.menu,
  });

  factory MobileSession.fromJson(Map<String, dynamic> json) {
    final token = json['token']?.toString() ?? '';
    if (token.isEmpty) {
      throw const FormatException('The session has no token');
    }
    final menu = json['menu'];
    return MobileSession(
      token: token,
      expiresAt: _time(json['expiresAt']),
      sessionExpiresAt: _time(json['sessionExpiresAt']),
      isDriver: json['principalKind']?.toString().toUpperCase() == 'DRIVER',
      userId: _int(json['userId']),
      companyId: _int(json['companyId']),
      mComid: _int(json['mComid']),
      companyName: json['companyName']?.toString() ?? '',
      rulesType: json['rulesType']?.toString() ?? '',
      roleId: _int(json['roleId']),
      permissionId: _int(json['permissionId']),
      truckRefId: _int(json['truckRefId']),
      truckName: json['truckName']?.toString() ?? '',
      menu: menu is List
          ? menu.whereType<Map>().map((m) => MenuMasterModel.fromJson(Map<String, dynamic>.from(m))).toList()
          : const [],
    );
  }

  final String token;
  final DateTime expiresAt;

  /// After this the server refuses refresh; the user signs in with the password again.
  final DateTime sessionExpiresAt;

  final bool isDriver;

  /// EmployeeMaster.Id, or DriverMaster.Id for a driver (stored in EmpRefId as before).
  final int userId;
  final int companyId;
  final int mComid;
  final String companyName;
  final String rulesType;

  /// UserRoles role id; 0 for a driver.
  final int roleId;
  final int permissionId;
  final int truckRefId;
  final String truckName;
  final List<MenuMasterModel> menu;

  static int _int(Object? value) => int.tryParse(value?.toString() ?? '') ?? 0;

  static DateTime _time(Object? millis) => DateTime.fromMillisecondsSinceEpoch(_int(millis));
}

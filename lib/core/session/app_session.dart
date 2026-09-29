import 'package:maleva/core/utils/app_preferences.dart';

/// The signed-in user, as API calls and permission checks need them.
///
/// An interface so repositories and blocs never read SharedPreferences
/// directly, and tests can hand in fixed values.
abstract interface class AppSession {
  int get companyId;

  /// EmployeeMaster.Id of the user, or 0 for a driver login.
  ///
  /// A driver login stores a DriverMaster id in EmpRefId. Any endpoint that
  /// looks that number up in EmployeeMaster would find an unrelated employee,
  /// so it is never sent as an employee id.
  int get employeeId;

  /// UserRoles role id saved at login (100 SUPERADMIN, 200 ADMIN, ...).
  int get roleId;
}

class PreferencesAppSession implements AppSession {
  const PreferencesAppSession();

  @override
  int get companyId => AppPreferences.getComid();

  @override
  int get employeeId =>
      AppPreferences.getDriverId() == 1 ? 0 : AppPreferences.getEmpRefId();

  @override
  int get roleId => AppPreferences.getRoleId();
}

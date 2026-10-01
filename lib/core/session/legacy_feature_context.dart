import '../utils/app_globals.dart';
import '../utils/app_preferences.dart';

/// Distinct legacy sources: do not apply AppSession's driver identity policy.
class LegacyFeatureContext {
  const LegacyFeatureContext();
  int get storedGlobalCompanyId => AppGlobals.storagenew.getInt('Comid') ?? 0;
  int get globalCompanyId => AppGlobals.Comid;
  int get preferenceCompanyId => AppPreferences.getComid();
  int get employeeId => AppPreferences.getEmpRefId();
  int get driverLogin => AppPreferences.getDriverLogin();
}

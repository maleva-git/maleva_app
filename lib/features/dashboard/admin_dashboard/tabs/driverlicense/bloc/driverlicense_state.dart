

import '../../../../../../core/models/model.dart';

abstract class DriverLicenseExpiryState {}

class DriverLicenseExpiryInitial extends DriverLicenseExpiryState {}

class DriverLicenseExpiryLoading extends DriverLicenseExpiryState {}

class DriverLicenseExpiryLoaded extends DriverLicenseExpiryState {
  // ── Driver license list ───────────────────────────────────────────────────
  // Each item: Map with keys: DriverName, licenseExp, GDLExp,
  // KuantanPort, NorthportPort, PkfzPort, KliaPort, PguPort,
  // TanjungPort, PenangPort, PtpPort, WestportPort
  final List<dynamic> driverExpiryList;

  // ── Truck maintenance list ────────────────────────────────────────────────
  final List<TruckDetailsModel> truckDetails;

  // ── Expiry thresholds ─────────────────────────────────────────────────────
  final String expDate;
  final String expApadBonam;
  final String expServiceAlignGreece;

   DriverLicenseExpiryLoaded({
    required this.driverExpiryList,
    required this.truckDetails,
    required this.expDate,
    required this.expApadBonam,
    required this.expServiceAlignGreece,
  });
}

class DriverLicenseExpiryError extends DriverLicenseExpiryState {
  final String message;
  DriverLicenseExpiryError(this.message);
}
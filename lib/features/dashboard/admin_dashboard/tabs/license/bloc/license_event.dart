// license_event.dart

abstract class LicenseEvent {
  const LicenseEvent();
}

// Initial load
class LoadLicenseEvent extends LicenseEvent {
  const LoadLicenseEvent();
}

// Search filter
class SearchLicenseEvent extends LicenseEvent {
  final String query;
  const SearchLicenseEvent({required this.query});
}
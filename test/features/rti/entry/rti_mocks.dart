import 'package:maleva/core/files/attachments_api.dart';
import 'package:maleva/core/fleet/driver_api.dart';
import 'package:maleva/core/fleet/truck_api.dart';
import 'package:maleva/core/rti/levi_api.dart';
import 'package:maleva/core/rti/rti_entry_api.dart';
import 'package:maleva/core/rti/rti_job_lookup_api.dart';
import 'package:maleva/core/session/app_session.dart';
import 'package:maleva/features/rti/data/rti_entry_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockRtiEntryApi extends Mock implements RtiEntryApi {}

class MockRtiJobLookupApi extends Mock implements RtiJobLookupApi {}

class MockDriverApi extends Mock implements DriverApi {}

class MockTruckApi extends Mock implements TruckApi {}

class MockLeviApi extends Mock implements LeviApi {}

class MockAttachmentsApi extends Mock implements AttachmentsApi {}

class FixedSession implements AppSession {
  const FixedSession({this.companyId = 6, this.employeeId = 3});

  @override
  final int companyId;
  @override
  final int employeeId;
  @override
  int get roleId => 100;
}

/// A repository on mocked APIs; the drivers / trucks / employees load empty.
({RtiEntryRepository repo, MockRtiEntryApi api, MockRtiJobLookupApi lookup, MockDriverApi drivers, MockTruckApi trucks}) mockRepository(
    {AppSession session = const FixedSession()}) {
  final api = MockRtiEntryApi();
  final lookup = MockRtiJobLookupApi();
  final drivers = MockDriverApi();
  final trucks = MockTruckApi();
  when(() => drivers.allDetails()).thenAnswer((_) async => []);
  when(() => trucks.allDetailCombo()).thenAnswer((_) async => []);
  when(() => lookup.employees()).thenAnswer((_) async => []);
  when(() => api.nextNumberPreview()).thenAnswer((_) async => 'RTI000000101');
  return (
    repo: RtiEntryRepository(api: api, lookup: lookup, drivers: drivers, trucks: trucks, session: session),
    api: api,
    lookup: lookup,
    drivers: drivers,
    trucks: trucks,
  );
}

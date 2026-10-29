// Screenshots of the six driver tabs at phone size, with sample data, for checking the design by eye
// (owner 2026-10-29 premium redesign). Not a pass/fail design test: it writes PNGs to test/visual/shots/ when run with
//   SHOTS=1 flutter test --no-pub --update-goldens test/visual/driver_screens_test.dart
// and also fails on any layout overflow. Runs only with SHOTS=1 and the Inter font files on this Mac; else skipped.
import 'dart:convert';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/fuel/fuel_entry_api.dart';
import 'package:maleva/core/models/shared/truck_details_model.dart';
import 'package:maleva/core/rti/rti_api.dart';
import 'package:maleva/core/ui/premium.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/bloc/leave_bloc.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/bloc/leave_event.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/bloc/leave_state.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/data/leave_request_model.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/view/driver_leave_request_tab.dart';
import 'package:maleva/features/dashboard/common_tabs/driverlicense/bloc/driverlicense_bloc.dart';
import 'package:maleva/features/dashboard/common_tabs/driverlicense/bloc/driverlicense_event.dart';
import 'package:maleva/features/dashboard/common_tabs/driverlicense/bloc/driverlicense_state.dart';
import 'package:maleva/features/dashboard/common_tabs/driverlicense/view/driverlicense_tab.dart';
import 'package:maleva/features/dashboard/common_tabs/drivermaintenance/bloc/drivermaintenance_bloc.dart';
import 'package:maleva/features/dashboard/common_tabs/drivermaintenance/bloc/drivermaintenance_event.dart';
import 'package:maleva/features/dashboard/common_tabs/drivermaintenance/bloc/drivermaintenance_state.dart';
import 'package:maleva/features/dashboard/common_tabs/drivermaintenance/view/drivermaintenance_tab.dart';
import 'package:maleva/features/dashboard/common_tabs/driversalary/bloc/driversalary_bloc.dart';
import 'package:maleva/features/dashboard/common_tabs/driversalary/bloc/driversalary_event.dart';
import 'package:maleva/features/dashboard/common_tabs/driversalary/bloc/driversalary_state.dart';
import 'package:maleva/features/dashboard/common_tabs/driversalary/view/driversalary_tab.dart';
import 'package:maleva/features/dashboard/common_tabs/fuelentry/view/driver_fuel_tab.dart';
import 'package:maleva/features/today_trips/driver_trip.dart';
import 'package:maleva/features/today_trips/today_trips_tab.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/features/dashboard/driver_dashboard/bloc/driver_bloc.dart';
import 'package:maleva/features/dashboard/driver_dashboard/view/driver_dashboard_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _interDir = '/Applications/Grammarly Desktop.app/Contents/Frameworks/ProjectLlamaContent.framework/Versions/A/Resources/Fonts';

class _MaintBloc extends MockBloc<TruckMaintDashEvent, TruckMaintDashState> implements TruckMaintDashBloc {}

class _LicenseBloc extends MockBloc<DriverLicenseExpiryEvent, DriverLicenseExpiryState> implements DriverLicenseExpiryBloc {}

class _SalaryBloc extends MockBloc<DriverSalaryEvent, DriverSalaryState> implements DriverSalaryBloc {}

class _LeaveBloc extends MockBloc<LeaveEvent, LeaveState> implements LeaveBloc {}

String _d(int days, [String f = '/']) {
  final d = DateTime.now().add(Duration(days: days));
  return '${d.year}$f${d.month.toString().padLeft(2, '0')}$f${d.day.toString().padLeft(2, '0')}';
}

class _Rti extends RtiApi {
  _Rti() : super(Dio(), companyId: () => 6);

  @override
  Future<List<Map<String, dynamic>>> trips(String fromDay, String toDay) async {
    final today = isoDay(DateTime.now());
    return [
      {
        'rtiId': 1, 'rtiNo': 'RTI000010576', 'tripDay': today, 'truckName': 'JWS 7151', 'tripOfDay': 1, 'tripsThatDay': 1,
        'stops': [
          {'kind': 'PICKUP', 'time': '${today}T23:00:00', 'place': 'SEVEN SEAS MARITIME SERVICES 12 Tuas Road, Singapore 638486',
            'jobId': 1, 'jobNo': 'MY002606287', 'customer': 'SEVEN SEAS MARITIME', 'quantity': '4 PLTS', 'pic': 'Mr Tan 9123 4567'},
          {'kind': 'PICKUP', 'time': '${today}T23:20:00', 'place': 'Marine & Offshore Integrated Logistics, 115 Airport Cargo Road',
            'jobId': 2, 'jobNo': 'MY002606290'},
          {'kind': 'STOP', 'time': '${today}T23:30:00', 'place': 'TUAS CHECKPOINT', 'activity': 'SEAL,BREAK_SEAL', 'agentName': 'AHMAD FAUZAN',
            'agentMobile': '012-3456789'},
          {'kind': 'DELIVERY', 'time': '${today}T23:50:00', 'place': 'MALEVA SOUTHPORT CABIN', 'jobId': 1, 'jobNo': 'MY002606287'},
        ],
        'jobs': [{'lineId': 1, 'jobId': 1, 'jobNo': 'MY002606287'}],
        'seenAt': null,
        'changes': [],
      },
    ];
  }
}

class _Fuel extends FuelEntryApi {
  _Fuel() : super(Dio(), companyId: () => 6);

  @override
  Future<List<Map<String, dynamic>>> list({required String fromDate, required String toDate, int truckId = 0, int driverId = 0}) async => [
        {'id': 1, 'cNumberDisplay': 'FE06301', 'saleDate': _d(-1, '-'), 'truckName': 'JWS 7151', 'aliter': 250, 'aAmount': 537.5, 'filePath': '/Upload/r.jpg'},
        {'id': 2, 'cNumberDisplay': 'FE06288', 'saleDate': _d(-4, '-'), 'truckName': 'JWS 7151', 'aliter': 181.16, 'aAmount': 400, 'remarks': 'CARD PETRA'},
        {'id': 3, 'cNumberDisplay': 'FE06270', 'saleDate': _d(-8, '-'), 'truckName': 'JWS 7151', 'aliter': 200, 'aAmount': 430, 'filePath': '/Upload/s.jpg'},
      ];

  @override
  Future<List<String>> cards() async => const ['PETRA', 'WEF'];
}

/// Serves the local Inter files as if bundled (google_fonts looks for `Inter-<Weight>.ttf` in the asset manifest);
/// every other asset comes from flutter test's own asset folder.
void _serveFonts() {
  const weights = {
    'Thin': 'Regular', 'ExtraLight': 'Regular', 'Light': 'Regular', 'Regular': 'Regular', 'Medium': 'Medium',
    'SemiBold': 'Bold', 'Bold': 'Bold', 'ExtraBold': 'Bold', 'Black': 'Bold',
  };
  final real = <String, ByteData>{};
  final manifest = <String, Object>{};
  // Poppins and Lato (older screens) are drawn with Inter here: close enough to judge the layout
  for (final family in ['Inter', 'Poppins', 'Lato']) {
    for (final w in weights.entries) {
      final key = 'google_fonts/$family-${w.key}.ttf';
      real[key] = ByteData.view(File('$_interDir/Inter-${w.value}.ttf').readAsBytesSync().buffer);
      manifest[key] = <Object>[<String, Object>{'asset': key}];
    }
  }
  final appManifest = File('build/unit_test_assets/AssetManifest.bin');
  if (appManifest.existsSync()) {
    final decoded = const StandardMessageCodec().decodeMessage(ByteData.view(appManifest.readAsBytesSync().buffer));
    if (decoded is Map) decoded.forEach((k, v) => manifest[k as String] = v as Object);
  }
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (message) async {
    final key = Uri.decodeFull(utf8.decode(message!.buffer.asUint8List(message.offsetInBytes, message.lengthInBytes)));
    if (key == 'AssetManifest.bin') return const StandardMessageCodec().encodeMessage(manifest);
    if (real.containsKey(key)) return real[key];
    final f = File('build/unit_test_assets/$key');
    return f.existsSync() ? ByteData.view(f.readAsBytesSync().buffer) : null;
  });
}

Future<void> _fonts() async {
  // flutter_tester lives in <flutter>/bin/cache/artifacts/engine/<platform>/
  final material = '${File(Platform.resolvedExecutable).parent.parent.parent.path}/material_fonts';
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      loader.addFont(Future.value(ByteData.view(File(f).readAsBytesSync().buffer)));
    }
    await loader.load();
  }

  await load('Inter', ['Regular', 'Medium', 'Bold'].map((w) => '$_interDir/Inter-$w.ttf').toList());
  await load('Roboto', ['Regular', 'Medium', 'Bold'].map((w) => '$material/Roboto-$w.ttf').toList());
  await load('MaterialIcons', ['$material/MaterialIcons-Regular.otf']);
}

Future<void> _shot(WidgetTester tester, String name, Widget tab, {double height = 1400}) async {
  final width = double.tryParse(Platform.environment['SHOTS_W'] ?? '') ?? 390; // SHOTS_W=360 for a small phone
  tester.view.physicalSize = Size(width * 2, height * 2);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: false, fontFamily: 'Roboto'),
    home: Scaffold(backgroundColor: Px.page, body: SafeArea(child: tab)),
  ));
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pumpAndSettle();
  // fonts load in the background: wait for them, then draw again
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(() => GoogleFonts.pendingFonts());
    await tester.pump(const Duration(milliseconds: 50));
  }
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: '$name: layout overflow');
  await expectLater(find.byType(MaterialApp), matchesGoldenFile('shots/$name.png'));
}

void main() {
  // only on request: SHOTS=1 flutter test --no-pub --update-goldens test/visual/driver_screens_test.dart
  final hasFonts = Platform.environment['SHOTS'] == '1' && File('$_interDir/Inter-Regular.ttf').existsSync();

  setUpAll(() async {
    if (!hasFonts) return;
    GoogleFonts.config.allowRuntimeFetching = false;
    _serveFonts();
    await _fonts();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferences.init();
  });

  void reg<T extends Object>(T value) {
    if (sl.isRegistered<T>()) sl.unregister<T>();
    sl.registerFactory<T>(() => value);
  }

  testWidgets('1 today', skip: !hasFonts, (tester) async {
    reg<RtiApi>(_Rti());
    await _shot(tester, '1-today', const TodayTripsTab());
  });

  testWidgets('2 fuel', skip: !hasFonts, (tester) async {
    reg<FuelEntryApi>(_Fuel());
    await _shot(tester, '2-fuel', const DriverFuelTab(), height: 900);
  });

  testWidgets('2b fuel form', skip: !hasFonts, (tester) async {
    reg<FuelEntryApi>(_Fuel());
    await _shot(tester, '2b-fuel-form', const SingleChildScrollView(child: DriverFuelForm()), height: 1300);
  });

  testWidgets('3 maintenance', skip: !hasFonts, (tester) async {
    final b = _MaintBloc();
    whenListen(b, const Stream<TruckMaintDashState>.empty(),
        initialState: TruckMaintDashLoaded(expDate: _d(30, '-'), expApadBonam: _d(60, '-'), expServiceAlignGreece: _d(14, '-'), truckDetails: [
          TruckDetailsModel.fromJavaExpiry({
            'id': 1, 'truckNumber': 'JWS 7151', 'truckNumber1': 'TL 2201', 'vehicleType': 'PRIME MOVER',
            'rotexMyExp': _d(-3, '-'), 'rotexSGExp': _d(120, '-'), 'puspacomExp': _d(20, '-'), 'insuranceExp': _d(200, '-'),
            'bonamExp': _d(45, '-'), 'apadExp': _d(300, '-'), 'serviceExp': _d(10, '-'), 'serviceLast': _d(-80, '-'),
            'alignmentExp': _d(90, '-'), 'greaseExp': _d(5, '-'), 'gearOilExp': _d(150, '-'), 'ptpStickerExp': _d(400, '-'),
          }),
        ]));
    reg<TruckMaintDashBloc>(b);
    await _shot(tester, '3-maintenance', const TruckMaintenanceDashboardWidget(), height: 1700);
  });

  testWidgets('4 license', skip: !hasFonts, (tester) async {
    final b = _LicenseBloc();
    whenListen(b, const Stream<DriverLicenseExpiryState>.empty(),
        initialState: DriverLicenseExpiryLoaded(driverExpiryList: [
          {'driverName': 'MOHD AZRUL BIN HASSAN', 'licenseExp': _d(12, '-'), 'gdlExp': _d(-5, '-'), 'westportPort': _d(200, '-'),
            'northportPort': _d(25, '-'), 'ptpPort': _d(400, '-'), 'kliaPort': null},
        ], truckDetails: const [], expDate: '', expApadBonam: '', expServiceAlignGreece: ''));
    reg<DriverLicenseExpiryBloc>(b);
    await _shot(tester, '4-license', const DriverLicenseExpiryWidget(), height: 1200);
  });

  testWidgets('5 salary', skip: !hasFonts, (tester) async {
    final b = _SalaryBloc();
    whenListen(b, const Stream<DriverSalaryState>.empty(),
        initialState: DriverSalaryLoaded(fromDate: _d(-28, '-'), toDate: _d(0, '-'), salaryAmount: 2486.5, salaryList: [
          for (var i = 0; i < 5; i++)
            {'rtiDate': _d(-i * 3, '/'), 'rtiNo': 'RTI0000105${70 + i}', 'jobNo': 'MY0026062${80 + i}', 'amount': (180 + i * 35.5).toStringAsFixed(2),
              'origin': 'WESTPORT', 'destination': 'SINGAPORE'},
        ]));
    reg<DriverSalaryBloc>(b);
    await _shot(tester, '5-salary', const DriverSalaryWidget(), height: 1100);
  });

  testWidgets('6 leave', skip: !hasFonts, (tester) async {
    final b = _LeaveBloc();
    LeaveRequestModel req(int id, int from, int days, String status, {String remark = '', String by = ''}) => LeaveRequestModel(
        id: id, applicantType: 2, applicantRefId: 7, applicantName: 'AZRUL', leaveTypeRefId: 1,
        fromDate: DateTime.now().add(Duration(days: from)), toDate: DateTime.now().add(Duration(days: from + days - 1)), totalDays: days,
        reason: id == 1 ? 'Family wedding in Ipoh' : 'Medical check-up', statusRefId: 1, statusName: status, reviewRemark: remark,
        reviewedBy: 0, reviewedByName: by, createdDate: DateTime.now());
    whenListen(b, const Stream<LeaveState>.empty(),
        initialState: LeaveLoaded(requests: [
          req(1, 6, 2, 'PENDING'),
          req(2, -10, 1, 'APPROVED', by: 'HR SITI'),
          req(3, -30, 1, 'REJECTED', remark: 'Peak week, please choose another day', by: 'HR SITI'),
        ], leaveTypes: const []));
    reg<LeaveBloc>(b);
    await _shot(tester, '6-leave', const DriverLeaveRequestTab(), height: 1100);
  });

  testWidgets('0 dashboard shell', skip: !hasFonts, (tester) async {
    SharedPreferences.setMockInitialValues({'Username': 'MOHD AZRUL'});
    AppGlobals.storagenew = await SharedPreferences.getInstance();
    reg<RtiApi>(_Rti());
    reg<FuelEntryApi>(_Fuel());
    final m = _MaintBloc();
    whenListen(m, const Stream<TruckMaintDashState>.empty(), initialState: TruckMaintDashInitial());
    reg<TruckMaintDashBloc>(m);
    final l = _LicenseBloc();
    whenListen(l, const Stream<DriverLicenseExpiryState>.empty(), initialState: DriverLicenseExpiryInitial());
    reg<DriverLicenseExpiryBloc>(l);
    final sa = _SalaryBloc();
    whenListen(sa, const Stream<DriverSalaryState>.empty(), initialState: DriverSalaryInitial());
    reg<DriverSalaryBloc>(sa);
    final le = _LeaveBloc();
    whenListen(le, const Stream<LeaveState>.empty(), initialState: const LeaveLoaded(requests: [], leaveTypes: []));
    reg<LeaveBloc>(le);
    final tabs = TabController(length: 6, vsync: tester);
    addTearDown(tabs.dispose);
    await _shot(
      tester,
      '0-dashboard',
      BlocProvider(create: (_) => DriverDashboardBloc(), child: DriverDashboardView(tabController: tabs, isTablet: false)),
      height: 1400,
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/features/auth/data/mobile_session.dart';
import 'package:maleva/features/auth/data/session_service.dart';
import 'package:maleva/splash/splashscreen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/local_fonts.dart';

class MockSessionService extends Mock implements SessionService {}

MobileSession session({bool driver = false, int role = 300}) => MobileSession(
      token: 't',
      expiresAt: DateTime(2027),
      sessionExpiresAt: DateTime(2027),
      isDriver: driver,
      userId: 41,
      companyId: 6,
      mComid: 1,
      companyName: 'FIXTURE CO',
      rulesType: 'SALES',
      roleId: role,
      permissionId: 1,
      truckRefId: 0,
      truckName: '',
      menu: const [],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(installLocalTestFonts);

  late MockSessionService sessions;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferences.init();
    sessions = MockSessionService();
    when(() => sessions.syncDeviceToken(any())).thenAnswer((_) async {});
    when(() => sessions.syncDeviceToken()).thenAnswer((_) async {});
    GetIt.instance.allowReassignment = true;
    GetIt.instance.registerSingleton<SessionService>(sessions);
  });

  tearDown(() => GetIt.instance.unregister<SessionService>());

  /// Shows the splash, lets its 3-second intro and startup run, and returns the
  /// route it ended on (the splash itself is '/').
  Future<String> runSplash(WidgetTester tester) async {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      for (final path in ['/login', '/dashboard/sales', '/dashboard/admin', '/driver_dashboard', '/unauthorized'])
        GoRoute(path: path, builder: (_, __) => Scaffold(body: Text('at $path'))),
    ]);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    final location = router.routerDelegate.currentConfiguration.uri.toString();
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
    return location;
  }

  testWidgets('no stored session opens login', (tester) async {
    when(() => sessions.restore()).thenAnswer((_) async => const NoSession());
    expect(await runSplash(tester), '/login');
  });

  testWidgets('a restored session opens its dashboard by the shared map', (tester) async {
    when(() => sessions.restore()).thenAnswer((_) async => Restored(session(role: 200)));
    expect(await runSplash(tester), '/dashboard/admin');
  });

  testWidgets('a restored driver session opens the driver dashboard', (tester) async {
    when(() => sessions.restore()).thenAnswer((_) async => Restored(session(driver: true, role: 0)));
    expect(await runSplash(tester), '/driver_dashboard');
  });

  testWidgets('a refused session opens login', (tester) async {
    when(() => sessions.restore()).thenAnswer((_) async => const SessionExpired());
    expect(await runSplash(tester), '/login');
  });

  testWidgets('no connection shows the retry popup and stays on the splash', (tester) async {
    when(() => sessions.restore()).thenAnswer((_) async => const RestoreUnreachable('offline'));
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const Scaffold(body: Text('at /login'))),
    ]);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }

    expect(find.text('Connection Error'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Go to Login'), findsOneWidget);
    expect(router.routerDelegate.currentConfiguration.uri.toString(), '/');
    // restore keeps the token on this path; the service is asked once until Retry
    verify(() => sessions.restore()).called(1);

    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
  });
}

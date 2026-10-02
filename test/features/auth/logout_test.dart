import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:maleva/core/utils/auth_helper.dart';
import 'package:maleva/features/auth/data/session_service.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/local_fonts.dart';

class MockSessionService extends Mock implements SessionService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(installLocalTestFonts);

  late MockSessionService sessions;
  late GoRouter router;

  setUp(() {
    sessions = MockSessionService();
    when(() => sessions.signOut()).thenAnswer((_) async {});
    GetIt.instance.allowReassignment = true;
    GetIt.instance.registerSingleton<SessionService>(sessions);
    router = GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (context, _) => Scaffold(
          body: TextButton(onPressed: () => AuthHelper.logout(context), child: const Text('Sign out')),
        ),
      ),
      GoRoute(path: '/login', builder: (_, __) => const Scaffold(body: Text('at /login'))),
    ]);
  });

  tearDown(() {
    router.dispose();
    GetIt.instance.unregister<SessionService>();
  });

  testWidgets('confirming signs out through the session service and opens login', (tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    verify(() => sessions.signOut()).called(1);
    expect(find.text('at /login'), findsOneWidget);
  });

  testWidgets('cancelling leaves the session alone', (tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => sessions.signOut());
    expect(find.text('Sign out'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:maleva/features/auth/data/repositories/auth_repository.dart';
import 'package:maleva/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:maleva/features/auth/presentation/pages/login_page.dart';
import 'package:mocktail/mocktail.dart';
import 'support/local_fonts.dart';

class FakeAuthRepository extends Mock implements AuthRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(installLocalTestFonts);
  testWidgets('login route renders and returns to previous route without login', (tester) async {
    final repository = FakeAuthRepository();
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => Scaffold(body: TextButton(
        onPressed: () => context.push('/login'), child: const Text('Open login')))),
      GoRoute(path: '/login', builder: (context, state) => BlocProvider(
        create: (_) => LoginBloc(authRepository: repository),
        child: const Appuserloginmobile())),
    ]);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Open login'));
    await tester.pumpAndSettle();
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('Driver Login'), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('Open login'), findsOneWidget);
    verifyZeroInteractions(repository);
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
  });
}

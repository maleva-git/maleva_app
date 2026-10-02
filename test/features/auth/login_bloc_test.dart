import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/features/auth/data/mobile_auth_api.dart';
import 'package:maleva/features/auth/data/mobile_session.dart';
import 'package:maleva/features/auth/data/repositories/auth_repository.dart';
import 'package:maleva/features/auth/data/session_service.dart';
import 'package:maleva/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:maleva/features/auth/presentation/bloc/auth_event.dart';
import 'package:maleva/features/auth/presentation/bloc/auth_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSessionService extends Mock implements SessionService {}

class FakeContext extends Fake implements BuildContext {}

void main() {
  late MockSessionService sessions;
  late LoginBloc bloc;

  setUp(() async {
    // a push token is already known, so sign-in does not ask Firebase
    SharedPreferences.setMockInitialValues({'FcmToken': 'fcm-1'});
    await AppPreferences.init();
    sessions = MockSessionService();
    when(() => sessions.syncDeviceToken()).thenAnswer((_) async {});
    bloc = LoginBloc(authRepository: AuthRepository(sessionService: sessions));
  });

  tearDown(() => bloc.close());

  Future<LoginState> submit({String user = 'fixture', String pass = 'p@ss', bool driver = false}) async {
    bloc
      ..add(UsernameChanged(user))
      ..add(PasswordChanged(pass))
      ..add(ToggleDriverLogin(driver))
      ..add(SubmitLogin(FakeContext()));
    return bloc.stream.firstWhere((s) => !s.loading && (s.loginSuccess || (s.errorMessage ?? '').isNotEmpty));
  }

  test('blank input reports the error and sends no request', () async {
    final state = await submit(pass: '  ');

    expect(state.errorMessage, 'Username and Password cannot be empty');
    verifyZeroInteractions(sessions);
  });

  test('success signs in through the session service with the driver flag', () async {
    when(() => sessions.signIn(userName: any(named: 'userName'), password: any(named: 'password'), driver: any(named: 'driver')))
        .thenAnswer((_) async {
      await AppPreferences.setRulesType('SALES');
      return _session;
    });

    final state = await submit(driver: true);

    expect(state.loginSuccess, isTrue);
    expect(state.role, 'SALES');
    verify(() => sessions.signIn(userName: 'fixture', password: 'p@ss', driver: true)).called(1);
  });

  test('wrong credentials show the invalid-credentials message', () async {
    when(() => sessions.signIn(userName: any(named: 'userName'), password: any(named: 'password'), driver: any(named: 'driver')))
        .thenThrow(const InvalidCredentials());

    final state = await submit();

    expect(state.loginSuccess, isFalse);
    expect(state.errorMessage, 'Invalid Username & Password');
  });

  test('no connection shows a connection message, not invalid credentials', () async {
    when(() => sessions.signIn(userName: any(named: 'userName'), password: any(named: 'password'), driver: any(named: 'driver')))
        .thenThrow(const ConnectionFailure());

    final state = await submit();

    expect(state.errorMessage, const ConnectionFailure().message);
  });
}

final _session = MobileSession(
  token: 't',
  expiresAt: DateTime(2027),
  sessionExpiresAt: DateTime(2027),
  isDriver: true,
  userId: 7,
  companyId: 6,
  mComid: 1,
  companyName: 'FIXTURE CO',
  rulesType: '',
  roleId: 0,
  permissionId: 0,
  truckRefId: 0,
  truckName: '',
  menu: const [],
);

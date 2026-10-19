import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/java_api_client.dart';
import 'package:maleva/core/session/session_token_store.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/features/auth/data/mobile_auth_api.dart';
import 'package:maleva/features/auth/data/mobile_session.dart';
import 'package:maleva/features/auth/data/session_service.dart';
import 'package:maleva/features/auth/data/session_writer.dart';
import 'package:maleva/features/auth/presentation/mode_switch_button.dart';
import 'package:maleva/features/auth/presentation/push_mode_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/session/session_token_store_test.dart' show MemoryStore;
import 'mobile_auth_api_test.dart' show Adapter, session;

/// Office mode / Driver mode (employee-extra-jobs-and-driver-mode). Synthetic data only.
void main() {
  late Adapter adapter;
  late SessionTokenStore tokens;
  late SessionService service;

  Map<String, dynamic> linked({required String kind}) {
    final body = session(kind: kind, truck: kind == 'DRIVER' ? 12 : 0);
    final data = Map<String, dynamic>.from(body['Data1'] as Map);
    if (kind == 'DRIVER') {
      data['token'] = 'driver.jwt';
      data['linkedEmployeeId'] = 41;
      data['jobs'] = <String>[];
    } else {
      data['roleId'] = 600;
      data['linkedDriverId'] = 7;
      data['jobs'] = ['BOARDINGOFFICER', 'BOARDINGOFFICERADMIN', 'FORWARDINGAGENT'];
    }
    return {...body, 'Data1': data};
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({'FcmToken': 'fcm-k'});
    await AppPreferences.init();
    adapter = Adapter();
    tokens = SessionTokenStore(MemoryStore());
    final client = JavaApiClient(tokens, dio: Dio()..httpClientAdapter = adapter, baseUrl: 'https://java.test');
    service = SessionService(api: MobileAuthApi(client), tokens: tokens, writer: SessionWriter(tokens));
  });

  test('the session reads jobs and the linked record; an older answer gives defaults', () {
    final s = MobileSession.fromJson(Map<String, dynamic>.from(linked(kind: 'EMPLOYEE')['Data1'] as Map));
    expect(s.jobs, ['BOARDINGOFFICER', 'BOARDINGOFFICERADMIN', 'FORWARDINGAGENT']);
    expect(s.linkedDriverId, 7);
    expect(s.linkedEmployeeId, 0);

    final old = MobileSession.fromJson(Map<String, dynamic>.from(session()['Data1'] as Map));
    expect(old.jobs, isEmpty);
    expect(old.linkedDriverId, 0);
  });

  test('office to driver: the new session is written and the button flips', () async {
    adapter.body = linked(kind: 'EMPLOYEE');
    await service.signIn(userName: 'fixture', password: 'p', driver: false);
    expect(AppPreferences.getJobs(), ['BOARDINGOFFICER', 'BOARDINGOFFICERADMIN', 'FORWARDINGAGENT']);
    expect(ModeSwitchButton.canSwitch(), isTrue);

    adapter.body = linked(kind: 'DRIVER');
    final s = await service.switchMode(toDriver: true);

    expect(adapter.last!.uri.path, '/api/mobile/auth/switch');
    expect(adapter.last!.headers['Authorization'], 'Bearer synthetic.jwt');
    expect(jsonDecode(adapter.lastBody!), {'to': 'DRIVER', 'deviceToken': 'fcm-k'});
    expect(s.isDriver, isTrue);
    expect(await tokens.token(), 'driver.jwt');
    expect(AppPreferences.getDriverId(), 1);
    expect(AppPreferences.getLinkedEmployeeId(), 41);
    expect(AppPreferences.getJobs(), isEmpty);
    expect(ModeSwitchButton.canSwitch(), isTrue);
  });

  test('a refusal keeps the current session', () async {
    adapter.body = linked(kind: 'EMPLOYEE');
    await service.signIn(userName: 'fixture', password: 'p', driver: false);

    adapter
      ..status = 403
      ..body = {'IsSuccess': false, 'Message': 'No linked driver'};
    await expectLater(service.switchMode(toDriver: true),
        throwsA(isA<ServerFailure>().having((e) => e.message, 'message', 'No linked driver')));
    expect(await tokens.token(), 'synthetic.jwt');
    expect(AppPreferences.getDriverId(), 0);
  });

  test('no linked record: no button', () async {
    await service.signIn(userName: 'fixture', password: 'p', driver: false);
    expect(ModeSwitchButton.canSwitch(), isFalse);
  });

  group('alerts of the other mode', () {
    test('only an alert for the other mode, for a linked person, asks to switch', () async {
      adapter.body = linked(kind: 'EMPLOYEE');
      await service.signIn(userName: 'fixture', password: 'p', driver: false);

      expect(PushModeGate.currentKind(), 'EMPLOYEE');
      expect(PushModeGate.otherModeFor('DRIVER'), 'DRIVER');
      expect(PushModeGate.otherModeFor('employee'), isNull);
      expect(PushModeGate.otherModeFor(null), isNull);
    });

    test('a person without a link opens every alert as before', () async {
      await service.signIn(userName: 'fixture', password: 'p', driver: false);
      expect(PushModeGate.otherModeFor('DRIVER'), isNull);
    });
  });
}

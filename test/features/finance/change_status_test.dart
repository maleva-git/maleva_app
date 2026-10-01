import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/change_status_page.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/network/legacy_api_repository.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:mocktail/mocktail.dart';
import '../../support/local_fonts.dart';

class MockLegacy extends Mock implements LegacyApiRepository {}
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(installLocalTestFonts);
  late MockLegacy repository;
  setUp(() async {
    await sl.reset();
    repository = MockLegacy();
    sl.registerSingleton<LegacyApiRepository>(repository);
    AppGlobals.Comid = 17;
  });
  tearDown(() => sl.reset());
  for (final id in [0, 9]) {
    testWidgets('ID $id preserves load trigger and screen', (tester) async {
      when(() => repository.apiAllinoneSelectArray(any(), any(), any(), any()))
          .thenAnswer((_) async => []);
      await tester.pumpWidget(MaterialApp(home: ChangeStatusPage(masterId: id)));
      await tester.pumpAndSettle();
      expect(find.text('Change Status'), findsOneWidget);
      expect(find.text('Selected ID: $id'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      if (id == 0) { verifyZeroInteractions(repository); }
      else {
        final calls = verify(() => repository.apiAllinoneSelectArray(
          captureAny(), captureAny(), captureAny(), any()));
        calls.called(1);
        expect(calls.captured[0], '${ApiConstants.apiGetpettycash}17');
        expect(calls.captured[1], isNull);
        expect(calls.captured[2], {'Content-Type': 'application/json; charset=UTF-8'});
      }
    });
  }
  testWidgets('missing keys retain lists and parse errors keep earlier master update', (tester) async {
    dynamic response = [{'PattycashMasterModel': [{'Id': 2, 'CompanyRefId': 17,
      'EmployeeRefId': 4, 'PettyCashDate': '2026-01-01', 'CNumber': 1, 'Status': 0}],
      'PattyCashDetailsModel': 'invalid'}];
    when(() => repository.apiAllinoneSelectArray(any(), any(), any(), any()))
        .thenAnswer((_) async => response);
    await tester.pumpWidget(const MaterialApp(home: ChangeStatusPage(masterId: 9)));
    await tester.pumpAndSettle();
    final state = tester.state<ChangeStatusPageState>(find.byType(ChangeStatusPage));
    expect(state.pettycashMaster.single.Id, 2);
    expect(state.pettycashDetails, isEmpty);
    response = [{}];
    await state.loadpettycash();
    await tester.pump();
    expect(state.pettycashMaster.single.Id, 2);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}

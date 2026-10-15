import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/forwarding_request/forwarding_request_api.dart';
import 'package:maleva/core/forwarding_request/forwarding_request_models.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/features/forwarding_requests/bloc/forwarding_requests_cubit.dart';
import 'package:maleva/features/forwarding_requests/bloc/request_forwarding_cubit.dart';
import 'package:maleva/features/forwarding_requests/push_route.dart';
import 'package:maleva/features/forwarding_requests/view/forwarding_request_edit_page.dart';
import 'package:maleva/features/forwarding_requests/view/forwarding_requests_page.dart';
import 'package:maleva/features/mail_monitor/mine/push_route.dart';
import 'package:mocktail/mocktail.dart';

import '../../core/forwarding_request/forwarding_request_api_test.dart' show javaRow;

class _Api extends Mock implements ForwardingRequestApi {}

class _Filter extends Fake implements ForwardingRequestFilter {}

void main() {
  setUpAll(() {
    registerFallbackValue(_Filter());
    registerFallbackValue(const ForwardingRequestTicks());
  });

  group('push routing', () {
    test('team notices open the planning list, requester notices open mine; mail is untouched', () {
      expect(forwardingRouteForPush({'type': 'FORWARDING_REQUESTED', 'link': '/forwarding/requests'}), forwardingRequestsPath);
      expect(forwardingRouteForPush({'type': 'FORWARDING_DRAFTED', 'link': '/forwarding/my-requests'}), myForwardingRequestsPath);
      expect(forwardingRouteForPush({'type': 'FORWARDING_OVERDUE', 'link': ''}), forwardingRequestsPath);
      expect(forwardingRouteForPush({'type': 'FORWARDING_APPROVED'}), myForwardingRequestsPath);
      expect(forwardingRouteForPush({'type': 'PLANNING'}), isNull);
      expect(forwardingRouteForType('FORWARDING_RELEASED'), myForwardingRequestsPath);
      expect(forwardingRouteForType('MAIL_UNREAD'), isNull);
      // through the app-wide router helpers
      expect(routeForPush({'type': 'MAIL_UNREAD'}), myUnreadMailPath);
      expect(routeForPush({'type': 'FORWARDING_SUBMITTED', 'link': '/forwarding/my-requests'}), myForwardingRequestsPath);
      expect(routeForPayload('FORWARDING_CANCELLED'), forwardingRequestsPath);
    });
  });

  group('ForwardingRequestsCubit', () {
    late _Api api;
    setUp(() => api = _Api());

    test('loads with the default window, counts open and overdue, and re-reads after a save', () async {
      when(() => api.search(any())).thenAnswer((_) async => [
            ForwardingRequest.fromJava(javaRow(id: 1, more: {'estimatedDate': '2020-01-01 09:00:00'})),
            ForwardingRequest.fromJava(javaRow(id: 2, status: 'RELEASED', more: {'released': true, 'draftCreated': true})),
          ]);
      final cubit = ForwardingRequestsCubit(api, mine: false, now: DateTime(2026, 10, 8));
      expect(cubit.state.filter.fromDate, '2026-10-08');
      await cubit.load();
      expect(cubit.state.rows.length, 2);
      expect(cubit.state.openCount, 1);
      expect(cubit.state.overdueCount, 1);

      when(() => api.saveTicks(1, any())).thenAnswer((_) async => ForwardingRequest.fromJava(javaRow(id: 1, status: 'DRAFT_CREATED')));
      final saved = await cubit.saveTicks(1, const ForwardingRequestTicks(documentReceived: true, draftCreated: true, cNumber: 'C1'));
      expect(saved.status, 'DRAFT_CREATED');
      expect(cubit.state.busyId, isNull);
      verify(() => api.search(any())).called(2);
    });

    test('keeps the error message when the list cannot be loaded, and clears busy after a refused save', () async {
      when(() => api.search(any())).thenThrow(const ApiFailure('Sign in again to continue', statusCode: 401));
      final cubit = ForwardingRequestsCubit(api, mine: true);
      await cubit.load();
      expect(cubit.state.error, 'Sign in again to continue');
      expect(cubit.state.filter.mine, isTrue);

      when(() => api.saveTicks(1, any())).thenThrow(const ApiFailure('Enter the C Number to save Draft created', statusCode: 400));
      await expectLater(cubit.saveTicks(1, const ForwardingRequestTicks(draftCreated: true)), throwsA(isA<ApiFailure>()));
      expect(cubit.state.busyId, isNull);
    });
  });

  group('RequestForwardingCubit', () {
    test('lists the open form types and prepends what it creates', () async {
      final api = _Api();
      when(() => api.forSaleOrder(910)).thenAnswer((_) async => [
            ForwardingRequest.fromJava(javaRow(id: 1)),
            ForwardingRequest.fromJava(javaRow(id: 2, status: 'CANCELLED', more: {'formType': 'K1'})),
          ]);
      when(() => api.create(saleOrderId: 910, items: [ForwardingRequestItem('K1', DateTime(2026, 10, 12, 9))], remarks: any(named: 'remarks')))
          .thenAnswer((_) async => [ForwardingRequest.fromJava(javaRow(id: 3, more: {'formType': 'K1'}))]);
      final cubit = RequestForwardingCubit(api, saleOrderId: 910);
      await cubit.load();
      expect(cubit.state.openTypes, {'K8'});
      final created = await cubit.create(items: [ForwardingRequestItem('K1', DateTime(2026, 10, 12, 9))]);
      expect(created.single.id, 3);
      expect(cubit.state.existing.first.id, 3);
      expect(cubit.state.saving, isFalse);
    });
  });

  group('ForwardingRequestEditPage', () {
    testWidgets('shows only Documents, Draft and C Number, and Save passes the hidden values through', (tester) async {
      ForwardingRequestTicks? sent;
      final r = ForwardingRequest.fromJava(javaRow(status: 'RELEASED', more: {
        'documentReceived': true, 'draftCreated': true, 'draftCNumber': 'C1', 'submitted': true, 'submittedRef': 'R1',
        'approved': true, 'approvedDate': '2026-10-09', 'released': true, 'releaseNo': 'K8-1', 'sealById': 31, 'sealBy': 'RAVI',
      }));
      await tester.pumpWidget(MaterialApp(
        home: ForwardingRequestEditPage(
          request: r,
          onSave: (t) async {
            sent = t;
            return r;
          },
          onCancelRequest: () async => r,
        ),
      ));
      expect(find.text('Documents received'), findsOneWidget);
      expect(find.text('Draft created'), findsOneWidget);
      expect(find.text('C Number *'), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsNWidgets(2));
      expect(find.text('Released'), findsOneWidget, reason: 'the status chip stays');
      for (final gone in ['Submitted to customs', 'Approved by customs', 'Seal by', 'Break seal by', 'Release number *', 'Registration no']) {
        expect(find.text(gone), findsNothing, reason: gone);
      }
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(sent!.toJava(), containsPair('releaseNo', 'K8-1'));
      expect(sent!.toJava(), containsPair('sealByRefId', 31));
      expect(sent!.released, isTrue);
    });
  });
}

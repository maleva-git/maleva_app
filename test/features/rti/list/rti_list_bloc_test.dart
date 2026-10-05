import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/features/rti/list/bloc/rti_list_bloc.dart';
import 'package:maleva/features/rti/list/data/rti_list_repository.dart';
import 'package:maleva/features/rti/list/models/rti_list_filter.dart';
import 'package:maleva/features/rti/list/models/rti_list_row.dart';
import 'package:mocktail/mocktail.dart';

class _Repo extends Mock implements RtiListRepository {}

void main() {
  final today = DateTime(2026, 10, 5);
  late _Repo repo;
  late List<String> opened;

  final paid = RtiListRow(
    id: 1,
    rtiNo: 'RTI000000001',
    rtiDate: today,
    truckName: 'WXY 1234',
    amount: 150,
    jobs: const [RtiListJob(jobNo: 'TR0026-0412', customerName: 'Sample')],
  );
  const unpaid = RtiListRow(id: 2, rtiNo: 'RTI000000002', amount: 0, jobs: [RtiListJob(jobNo: 'TR0026-0500')]);

  setUpAll(() => registerFallbackValue(RtiListFilter.initial(DateTime(2026))));

  setUp(() {
    repo = _Repo();
    opened = [];
    when(() => repo.companyId).thenReturn(6);
    when(() => repo.employeeId).thenReturn(42);
    when(() => repo.isDriver).thenReturn(false);
    when(() => repo.drivers()).thenAnswer((_) async => const []);
    when(() => repo.trucks()).thenAnswer((_) async => const []);
    when(() => repo.list(any())).thenAnswer((_) async => [paid, unpaid]);
  });

  RtiListBloc build({Duration slowAfter = const Duration(seconds: 30)}) =>
      RtiListBloc(repository: repo, openUrl: (u) async => opened.add(u), today: () => today, slowAfter: slowAfter);

  RtiListFilter lastRequest() => verify(() => repo.list(captureAny())).captured.last as RtiListFilter;

  group('filters', () {
    blocTest<RtiListBloc, RtiListState>(
      'first open: today–today, My RTIs OFF (K13)',
      build: build,
      act: (b) => b.add(const RtiListStarted()),
      verify: (b) {
        final f = lastRequest();
        expect(f.fromDate, today);
        expect(f.toDate, today);
        expect(f.myRtis, isFalse);
        expect(b.state.rows, hasLength(2));
      },
    );

    blocTest<RtiListBloc, RtiListState>(
      'Clear turns My RTIs ON and loads',
      build: build,
      act: (b) => b
        ..add(RtiListDraftChanged(RtiListFilter.initial(today).copyWith(driverId: 5, driverName: 'Ali', rtiNo: 'RTI9')))
        ..add(const RtiListCleared()),
      verify: (b) {
        final f = lastRequest();
        expect(f.myRtis, isTrue);
        expect(f.driverId, 0);
        expect(f.rtiNo, '');
        expect(b.state.applied.myRtis, isTrue);
      },
    );

    blocTest<RtiListBloc, RtiListState>(
      'a driver login never sends My RTIs (the server keeps drivers to their own RTIs)',
      setUp: () => when(() => repo.isDriver).thenReturn(true),
      build: build,
      act: (b) => b.add(const RtiListCleared()),
      verify: (b) {
        expect(lastRequest().myRtis, isFalse);
        expect(b.state.isDriver, isTrue);
        verifyNever(() => repo.drivers());
      },
    );

    blocTest<RtiListBloc, RtiListState>(
      'the RTI No search goes to the server (exact match there)',
      build: build,
      act: (b) => b
        ..add(RtiListDraftChanged(RtiListFilter.initial(today).copyWith(rtiNo: 'RTI000000002')))
        ..add(const RtiListApplied()),
      verify: (_) => expect(lastRequest().rtiNo, 'RTI000000002'),
    );

    blocTest<RtiListBloc, RtiListState>(
      'Not Salary Entered RTI filters the loaded rows to amount 0, without a reload',
      build: build,
      act: (b) async {
        b.add(const RtiListStarted());
        await Future<void>.delayed(Duration.zero);
        b.add(const RtiListNotSalaryToggled(true));
      },
      verify: (b) {
        expect(b.state.visible, [unpaid]);
        verify(() => repo.list(any())).called(1);
      },
    );

    blocTest<RtiListBloc, RtiListState>(
      'the search bar finds a job number among the loaded jobs only',
      build: build,
      act: (b) async {
        b.add(const RtiListStarted());
        await Future<void>.delayed(Duration.zero);
        b.add(const RtiListFindChanged('0500'));
      },
      verify: (b) {
        expect(b.state.visible, [unpaid]);
        verify(() => repo.list(any())).called(1);
      },
    );

    blocTest<RtiListBloc, RtiListState>(
      'stats: Records and Total Amount of the rows shown',
      build: build,
      act: (b) => b.add(const RtiListStarted()),
      verify: (b) {
        expect(b.state.visible.length, 2);
        expect(b.state.totalAmount, 150);
        expect(RtiListRow.rmFixed(b.state.totalAmount), 'RM 150.00');
      },
    );
  });

  group('states', () {
    blocTest<RtiListBloc, RtiListState>(
      'a failed load: "Unable to load records" state with the server message',
      setUp: () => when(() => repo.list(any())).thenThrow(const ApiFailure('Company 6 not found')),
      build: build,
      act: (b) => b.add(const RtiListApplied()),
      verify: (b) {
        expect(b.state.status, RtiListStatus.failure);
        expect(b.state.error, 'Company 6 not found');
      },
    );

    test('after the timeout the state is "still loading"; the answer still lands', () async {
      final answer = Completer<List<RtiListRow>>();
      when(() => repo.list(any())).thenAnswer((_) => answer.future);
      final b = build(slowAfter: const Duration(milliseconds: 20));
      b.add(const RtiListApplied());
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(b.state.status, RtiListStatus.loading);
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(b.state.status, RtiListStatus.slow);
      answer.complete([paid]);
      await Future<void>.delayed(Duration.zero);
      expect(b.state.status, RtiListStatus.success);
      expect(b.state.rows, [paid]);
      await b.close();
    });

    test('a quick answer never shows "still loading"', () async {
      final b = build(slowAfter: const Duration(milliseconds: 20));
      b.add(const RtiListApplied());
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(b.state.status, RtiListStatus.success);
      await b.close();
    });

    blocTest<RtiListBloc, RtiListState>(
      'no company yet: nothing loads (waiting for login)',
      setUp: () => when(() => repo.companyId).thenReturn(0),
      build: build,
      act: (b) => b.add(const RtiListApplied()),
      verify: (b) {
        expect(b.state.status, RtiListStatus.initial);
        verifyNever(() => repo.list(any()));
      },
    );
  });

  group('share', () {
    blocTest<RtiListBloc, RtiListState>(
      'sent: "{rtiNo} sent to the group of {truck}"',
      setUp: () => when(() => repo.share(1)).thenAnswer((_) async => const RtiShareResult(sent: true, rtiNo: 'RTI000000001', truck: 'WXY 1234')),
      build: build,
      act: (b) => b.add(RtiShareRequested(paid)),
      verify: (b) {
        expect(b.state.notice?.message, 'RTI000000001 sent to the group of WXY 1234');
        expect(b.state.notice?.followUp, isNull);
        expect(b.state.shareBusyId, isNull);
      },
    );

    blocTest<RtiListBloc, RtiListState>(
      'sent without a truck name, report skipped: "the truck" and the documentSkipped note (10 s)',
      setUp: () => when(() => repo.share(1)).thenAnswer(
          (_) async => const RtiShareResult(sent: true, rtiNo: 'RTI000000001', documentSkipped: 'The RTI report could not be attached')),
      build: build,
      act: (b) => b.add(RtiShareRequested(paid)),
      verify: (b) {
        expect(b.state.notice?.message, 'RTI000000001 sent to the group of the truck');
        expect(b.state.notice?.followUp?.message, 'The RTI report could not be attached');
        expect(b.state.notice?.followUp?.duration, const Duration(seconds: 10));
      },
    );

    blocTest<RtiListBloc, RtiListState>(
      'not sent: the provider\'s detail, else "The message was not sent"',
      setUp: () => when(() => repo.share(1)).thenAnswer((_) async => const RtiShareResult(sent: false)),
      build: build,
      act: (b) => b.add(RtiShareRequested(paid)),
      verify: (b) => expect(b.state.notice?.message, 'The message was not sent'),
    );

    blocTest<RtiListBloc, RtiListState>(
      'a refusal shows the server\'s reason',
      setUp: () => when(() => repo.share(1)).thenThrow(const ApiFailure('Truck WXY 1234 has no WhatsApp group yet')),
      build: build,
      act: (b) => b.add(RtiShareRequested(paid)),
      verify: (b) => expect(b.state.notice?.message, 'Truck WXY 1234 has no WhatsApp group yet'),
    );

    blocTest<RtiListBloc, RtiListState>(
      'any other error: "Could not share this RTI"',
      setUp: () => when(() => repo.share(1)).thenThrow(StateError('x')),
      build: build,
      act: (b) => b.add(RtiShareRequested(paid)),
      verify: (b) => expect(b.state.notice?.message, 'Could not share this RTI'),
    );

    test('the confirm question is React\'s', () {
      expect(RtiListBloc.shareQuestion('RTI000000001'), "Send RTI000000001 to the truck's WhatsApp group?");
    });
  });

  group('report', () {
    blocTest<RtiListBloc, RtiListState>(
      'opens the report URL',
      setUp: () => when(() => repo.reportUrl(1)).thenAnswer((_) async => 'https://x/RTI000000001.pdf'),
      build: build,
      act: (b) => b.add(RtiReportRequested(paid)),
      verify: (_) => expect(opened, ['https://x/RTI000000001.pdf']),
    );

    blocTest<RtiListBloc, RtiListState>(
      'no id: "RTI details are missing for the RTI report."',
      build: build,
      act: (b) => b.add(const RtiReportRequested(RtiListRow(id: 0, rtiNo: 'RTI1'))),
      verify: (b) => expect(b.state.notice?.message, 'RTI details are missing for the RTI report.'),
    );

    blocTest<RtiListBloc, RtiListState>(
      'failure without a reason: "Could not open the RTI report"',
      setUp: () => when(() => repo.reportUrl(1)).thenAnswer((_) async => ''),
      build: build,
      act: (b) => b.add(RtiReportRequested(paid)),
      verify: (b) => expect(b.state.notice?.message, 'Could not open the RTI report'),
    );
  });

  group('preview', () {
    blocTest<RtiListBloc, RtiListState>(
      'loads the full RTI; the same row again closes it',
      setUp: () => when(() => repo.preview(1)).thenAnswer(
          (_) async => const RtiPreviewData(destination: 'Shah Alam', remarks: 'ok', jobs: [RtiListJob(jobNo: 'TR1', customerName: 'C')])),
      build: build,
      act: (b) async {
        b.add(const RtiListStarted());
        await Future<void>.delayed(Duration.zero);
        b.add(const RtiListRowSelected(1));
        await Future<void>.delayed(Duration.zero);
      },
      verify: (b) {
        expect(b.state.preview?.data?.destination, 'Shah Alam');
        expect(b.state.selected, paid);
      },
    );

    test('reading the Java rows', () {
      final r = RtiListRow.fromJava(const {
        'id': 9,
        'rtiNoDisplay': 'RTI000000009',
        'rtiDate': '2026-10-05',
        'driverName': 'Ali',
        'truckName': 'WXY 1',
        'amount': 0,
        'jobs': [
          {'id': 1, 'jobNo': 'TR1', 'customerName': 'C'},
        ],
      });
      expect(r.rtiNo, 'RTI000000009');
      expect(r.dateText, '05/10/2026');
      expect(r.salaryMissing, isTrue);
      expect(r.amountText, 'RM 0.00');
      expect(r.jobs.single.jobNo, 'TR1');
    });
  });
}

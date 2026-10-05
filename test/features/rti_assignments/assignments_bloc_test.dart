import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/rti/employee_assignments_api.dart';
import 'package:maleva/features/rti_assignments/bloc/assignments_bloc.dart';
import 'package:maleva/features/rti_assignments/data/assignments_repository.dart';
import 'package:maleva/features/rti_assignments/models/assignments_filter.dart';
import 'package:maleva/features/rti_assignments/models/employee_assignment.dart';
import 'package:mocktail/mocktail.dart';

class _Repo extends Mock implements AssignmentsRepository {}

class _Dio extends Mock implements Dio {}

void main() {
  final today = DateTime(2026, 10, 5);
  late _Repo repo;
  late List<String> opened;

  const mine = EmployeeAssignment(id: 1, rtiMasterRefId: 11, rtiNumber: 'RTI000000011', employeeName: 'Siti');
  const asDriver = EmployeeAssignment(id: 2, rtiMasterRefId: 12, rtiNumber: 'RTI000000012', driverName: 'Siti');
  const other = EmployeeAssignment(id: 3, rtiMasterRefId: 13, employeeName: 'Ahmad');

  setUp(() {
    repo = _Repo();
    opened = [];
    when(() => repo.companyId).thenReturn(6);
    when(() => repo.employeeId).thenReturn(42);
    when(() => repo.userName).thenReturn('Siti');
    when(() => repo.employees()).thenAnswer((_) async => const []);
    when(() => repo.fetch(from: any(named: 'from'), to: any(named: 'to'), employeeId: any(named: 'employeeId')))
        .thenAnswer((_) async => const [mine, asDriver, other]);
  });

  AssignmentsBloc build() => AssignmentsBloc(repository: repo, openUrl: (u) async => opened.add(u), today: () => today);

  void verifyNoFetch() =>
      verifyNever(() => repo.fetch(from: any(named: 'from'), to: any(named: 'to'), employeeId: any(named: 'employeeId')));

  blocTest<AssignmentsBloc, AssignmentsState>(
    'nothing loads until Search (opening loads only the employees)',
    build: build,
    act: (b) => b.add(const AssignmentsStarted()),
    verify: (b) {
      expect(b.state.status, AssignmentsStatus.idle);
      expect(b.state.filter.fromDate, today);
      expect(b.state.filter.toDate, today);
      verifyNoFetch();
    },
  );

  blocTest<AssignmentsBloc, AssignmentsState>(
    'Search sends the dates and employee 0 for everyone',
    build: build,
    act: (b) => b.add(const AssignmentsSearchRequested()),
    verify: (b) {
      verify(() => repo.fetch(from: today, to: today, employeeId: 0)).called(1);
      expect(b.state.visible, hasLength(3));
    },
  );

  blocTest<AssignmentsBloc, AssignmentsState>(
    'a picked employee is sent',
    build: build,
    act: (b) => b
      ..add(AssignmentsFilterChanged(AssignmentsFilter.initial(today).copyWith(employeeId: 7, employeeName: 'Ahmad')))
      ..add(const AssignmentsSearchRequested()),
    verify: (_) => verify(() => repo.fetch(from: today, to: today, employeeId: 7)).called(1),
  );

  blocTest<AssignmentsBloc, AssignmentsState>(
    'My Job Only sends the user\'s employee id and keeps the jobs with the user\'s name',
    build: build,
    act: (b) => b
      ..add(AssignmentsFilterChanged(AssignmentsFilter.initial(today).copyWith(employeeId: 7, myJobOnly: true)))
      ..add(const AssignmentsSearchRequested()),
    verify: (b) {
      verify(() => repo.fetch(from: today, to: today, employeeId: 42)).called(1);
      expect(b.state.visible, [mine, asDriver]);
    },
  );

  blocTest<AssignmentsBloc, AssignmentsState>(
    'a missing date: "Please select both From and To dates", nothing is fetched',
    build: build,
    act: (b) => b
      ..add(AssignmentsFilterChanged(AssignmentsFilter.initial(today).copyWith(toDate: () => null)))
      ..add(const AssignmentsSearchRequested()),
    verify: (b) {
      expect(b.state.notice?.message, 'Please select both From and To dates');
      verifyNoFetch();
    },
  );

  blocTest<AssignmentsBloc, AssignmentsState>(
    'Clear resets the filters and does not search',
    build: build,
    act: (b) => b
      ..add(AssignmentsFilterChanged(AssignmentsFilter(fromDate: DateTime(2026, 9, 1), toDate: today, employeeId: 7, myJobOnly: true)))
      ..add(const AssignmentsCleared()),
    verify: (b) {
      expect(b.state.filter, AssignmentsFilter.initial(today));
      verifyNoFetch();
    },
  );

  blocTest<AssignmentsBloc, AssignmentsState>(
    'a failed search shows the server message',
    setUp: () => when(() => repo.fetch(from: any(named: 'from'), to: any(named: 'to'), employeeId: any(named: 'employeeId')))
        .thenThrow(const ApiFailure('Date range cannot exceed 90 days')),
    build: build,
    act: (b) => b.add(const AssignmentsSearchRequested()),
    verify: (b) {
      expect(b.state.status, AssignmentsStatus.failure);
      expect(b.state.error, 'Date range cannot exceed 90 days');
    },
  );

  group('report', () {
    blocTest<AssignmentsBloc, AssignmentsState>(
      'no RTI number: "RTI Number is missing"',
      build: build,
      act: (b) => b.add(const AssignmentReportRequested(other)),
      verify: (b) => expect(b.state.notice?.message, 'RTI Number is missing'),
    );

    blocTest<AssignmentsBloc, AssignmentsState>(
      'opens the RTI report of the job\'s RTI',
      setUp: () => when(() => repo.reportUrl(11)).thenAnswer((_) async => 'https://x/r.pdf'),
      build: build,
      act: (b) => b.add(const AssignmentReportRequested(mine)),
      verify: (_) => expect(opened, ['https://x/r.pdf']),
    );

    blocTest<AssignmentsBloc, AssignmentsState>(
      'an unexpected error: "Failed to open RTI report"',
      setUp: () => when(() => repo.reportUrl(11)).thenThrow(StateError('x')),
      build: build,
      act: (b) => b.add(const AssignmentReportRequested(mine)),
      verify: (b) => expect(b.state.notice?.message, 'Failed to open RTI report'),
    );
  });

  group('EmployeeAssignmentsApi', () {
    late _Dio dio;
    setUp(() => dio = _Dio());

    test('posts {fromDate, toDate, companyId, employeeId} and reads Data1', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(),
            data: {
              'IsSuccess': true,
              'Data1': [
                {'id': 1, 'rtiNumber': 'RTI1', 'pickupDateD': '2026-10-05T08:30:00'},
              ],
            },
          ));
      final rows = await EmployeeAssignmentsApi(dio, companyId: () => 6).fetch(fromDate: '2026-10-05', toDate: '2026-10-05', employeeId: 3);
      final call = verify(() => dio.post<dynamic>('/api/rti/employee-assignments', data: captureAny(named: 'data'))).captured.single;
      expect(call, {'fromDate': '2026-10-05', 'toDate': '2026-10-05', 'companyId': 6, 'employeeId': 3});
      final job = EmployeeAssignment.fromJava(rows.single);
      expect(job.rtiNumber, 'RTI1');
      expect(EmployeeAssignment.formatDateTime(job.pickupDateD), '05 Oct 2026, 08:30 AM');
    });

    test('IsSuccess false without a message: "Failed to fetch employee assignments"', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(requestOptions: RequestOptions(), data: {'IsSuccess': false}));
      expect(
        () => EmployeeAssignmentsApi(dio, companyId: () => 6).fetch(fromDate: 'a', toDate: 'b'),
        throwsA(isA<ApiFailure>().having((e) => e.message, 'message', 'Failed to fetch employee assignments')),
      );
    });
  });
}

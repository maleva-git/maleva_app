import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/widgets/ui/picker_sheet.dart';
import 'package:maleva/features/planning/plans/bloc/plans_bloc.dart';
import 'package:maleva/features/planning/plans/data/plans_repository.dart';
import 'package:maleva/features/planning/plans/models/plan_row.dart';
import 'package:maleva/features/planning/plans/models/plans_filter.dart';
import 'package:mocktail/mocktail.dart';

class _Repo extends Mock implements PlansRepository {}

void main() {
  final today = DateTime(2026, 10, 5);
  final yesterday = DateTime(2026, 10, 4);
  late _Repo repo;
  late List<String> opened;

  const plan = PlanRow(id: 7, planningNo: 'PL000000007', planningDate: '05 Oct 2026', totalOrders: 2);

  setUp(() {
    repo = _Repo();
    opened = [];
    when(() => repo.companyId).thenReturn(6);
    when(() => repo.employeeId).thenReturn(42);
    when(() => repo.employees()).thenAnswer((_) async => const [PickOption(value: 3, label: 'Siti-ADMIN')]);
    when(() => repo.list(from: any(named: 'from'), to: any(named: 'to'), search: any(named: 'search'), employeeId: any(named: 'employeeId')))
        .thenAnswer((_) async => const [plan]);
  });

  PlansBloc build() => PlansBloc(repository: repo, openUrl: (u) async => opened.add(u), today: () => today);

  group('filters → request', () {
    test('first open: From is yesterday, To today, Report Date today', () {
      final b = build();
      expect(b.state.draft.fromDate, yesterday);
      expect(b.state.draft.toDate, today);
      expect(b.state.draft.reportDate, today);
      expect(b.state.draft.loginEmployee, isFalse);
      b.close();
    });

    blocTest<PlansBloc, PlansState>(
      'opening loads the plans of yesterday–today for everyone, and the employees',
      build: build,
      act: (b) => b.add(const PlansStarted()),
      verify: (b) {
        verify(() => repo.list(from: yesterday, to: today, search: '', employeeId: 0)).called(1);
        expect(b.state.rows, [plan]);
        expect(b.state.employees.single.value, 3);
      },
    );

    blocTest<PlansBloc, PlansState>(
      'Login Employee sends the user\'s own employee id, not the picked one',
      build: build,
      act: (b) => b
        ..add(PlansDraftChanged(PlansFilter.initial(today).copyWith(employeeId: 3, employeeName: 'Siti', loginEmployee: true)))
        ..add(const PlansApplied()),
      verify: (_) => verify(() => repo.list(from: yesterday, to: today, search: '', employeeId: 42)).called(1),
    );

    blocTest<PlansBloc, PlansState>(
      'a picked employee is sent when Login Employee is off',
      build: build,
      act: (b) => b
        ..add(PlansDraftChanged(PlansFilter.initial(today).copyWith(employeeId: 3, employeeName: 'Siti')))
        ..add(const PlansApplied()),
      verify: (_) => verify(() => repo.list(from: yesterday, to: today, search: '', employeeId: 3)).called(1),
    );

    blocTest<PlansBloc, PlansState>(
      'the search bar sends the trimmed plan number',
      build: build,
      act: (b) => b.add(const PlansSearchSubmitted(' PL000000782 ')),
      verify: (b) {
        verify(() => repo.list(from: yesterday, to: today, search: 'PL000000782', employeeId: 0)).called(1);
        expect(b.state.applied.planningNo, 'PL000000782');
      },
    );

    blocTest<PlansBloc, PlansState>(
      'editing the filters does not load until View',
      build: build,
      act: (b) => b.add(PlansDraftChanged(PlansFilter.initial(today).copyWith(planningNo: 'PL1'))),
      verify: (_) => verifyNever(() => repo.list(
          from: any(named: 'from'), to: any(named: 'to'), search: any(named: 'search'), employeeId: any(named: 'employeeId'))),
    );
  });

  group('checks', () {
    blocTest<PlansBloc, PlansState>(
      'From after To: "From date cannot be greater than to date", nothing loads',
      build: build,
      act: (b) => b
        ..add(PlansDraftChanged(PlansFilter.initial(today).copyWith(fromDate: DateTime(2026, 10, 6))))
        ..add(const PlansApplied()),
      verify: (b) {
        expect(b.state.dateError, isTrue);
        expect(b.state.notice?.message, 'From date cannot be greater than to date');
        verifyNever(() => repo.list(
            from: any(named: 'from'), to: any(named: 'to'), search: any(named: 'search'), employeeId: any(named: 'employeeId')));
      },
    );

    blocTest<PlansBloc, PlansState>(
      'no company: "Company is not available yet"',
      setUp: () => when(() => repo.companyId).thenReturn(0),
      build: build,
      act: (b) => b.add(const PlansApplied()),
      verify: (b) => expect(b.state.notice?.message, 'Company is not available yet'),
    );

    blocTest<PlansBloc, PlansState>(
      'a failed load: "Failed to load planning list"',
      setUp: () => when(() => repo.list(
              from: any(named: 'from'), to: any(named: 'to'), search: any(named: 'search'), employeeId: any(named: 'employeeId')))
          .thenThrow(const ApiFailure('boom')),
      build: build,
      act: (b) => b.add(const PlansApplied()),
      verify: (b) {
        expect(b.state.status, PlansStatus.failure);
        expect(b.state.notice?.message, 'Failed to load planning list');
      },
    );

    blocTest<PlansBloc, PlansState>(
      'Clear goes back to yesterday–today and loads',
      build: build,
      act: (b) => b
        ..add(PlansDraftChanged(PlansFilter.initial(today).copyWith(fromDate: DateTime(2026, 9, 1), loginEmployee: true)))
        ..add(const PlansCleared()),
      verify: (b) {
        expect(b.state.applied.fromDate, yesterday);
        expect(b.state.applied.loginEmployee, isFalse);
        verify(() => repo.list(from: yesterday, to: today, search: '', employeeId: 0)).called(1);
      },
    );
  });

  group('report', () {
    blocTest<PlansBloc, PlansState>(
      'opens the report for the Report Date',
      setUp: () => when(() => repo.reportUrl(7, any())).thenAnswer((_) async => 'https://x/report.pdf'),
      build: build,
      act: (b) => b
        ..add(PlansReportDateChanged(DateTime(2026, 10, 3)))
        ..add(const PlanReportRequested(plan)),
      verify: (b) {
        verify(() => repo.reportUrl(7, DateTime(2026, 10, 3))).called(1);
        expect(opened, ['https://x/report.pdf']);
        expect(b.state.reportBusyId, isNull);
      },
    );

    blocTest<PlansBloc, PlansState>(
      'no id: "Planning details are missing for the Planning report."',
      build: build,
      act: (b) => b.add(const PlanReportRequested(PlanRow(id: 0, planningNo: 'PL1', planningDate: ''))),
      verify: (b) => expect(b.state.notice?.message, 'Planning details are missing for the Planning report.'),
    );

    blocTest<PlansBloc, PlansState>(
      'no URL back: "Could not open the Planning report"',
      setUp: () => when(() => repo.reportUrl(7, any())).thenAnswer((_) async => ''),
      build: build,
      act: (b) => b.add(const PlanReportRequested(plan)),
      verify: (b) => expect(b.state.notice?.message, 'Could not open the Planning report'),
    );

    blocTest<PlansBloc, PlansState>(
      'the server\'s reason is shown when it gives one',
      setUp: () => when(() => repo.reportUrl(7, any())).thenThrow(const ApiFailure('Planning not found: 7')),
      build: build,
      act: (b) => b.add(const PlanReportRequested(plan)),
      verify: (b) => expect(b.state.notice?.message, 'Planning not found: 7'),
    );
  });

  group('PlanRow.fromSelectPlanning', () {
    test('reads the .NET-named rows like planningViewMapper.ts', () {
      final rows = PlanRow.fromSelectPlanning([
        {'Id': 5, 'PLANINGNo': 5, 'PLANINGNoDisplay': 'PL000000005', 'PLANINGDate': '02/03/2026', 'EmployeeName': 'Siti', 'TotalOrders': 2, 'Remarks': 'r'},
      ], [
        {'Id': 1, 'PLANINGMasterRefId': 5, 'JobNo': 'TR1', 'TruckName': 'WXY 1', 'DriverName': 'Ali', 'JobStatus': 'Pending', 'RTINo': 'RTI1'},
        {'Id': 2, 'PLANINGMasterRefId': 9, 'JobNo': 'TR2'},
      ]);
      expect(rows.single.planningNo, 'PL000000005');
      expect(rows.single.planningDate, '02 Mar 2026');
      expect(rows.single.employeeName, 'Siti');
      expect(rows.single.totalOrders, 2);
      expect(rows.single.jobs.map((j) => j.jobNo), ['TR1']);
      expect(rows.single.jobs.single.rtiNo, 'RTI1');
    });

    test('orders fall back to the plan\'s jobs; a non-date stays as it is', () {
      final rows = PlanRow.fromSelectPlanning([
        {'Id': 5, 'PLANINGNoDisplay': 'PL5', 'PLANINGDate': 'soon'},
      ], [
        {'Id': 1, 'PLANINGMasterRefId': 5, 'JobNo': 'TR1'},
      ]);
      expect(rows.single.totalOrders, 1);
      expect(rows.single.planningDate, 'soon');
    });
  });
}

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/bloc/leave_bloc.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/bloc/leave_event.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/bloc/leave_state.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/data/leave_repository.dart';
import 'package:mocktail/mocktail.dart';

class _Repository extends Mock implements LeaveRepository {}

SubmitLeaveRequest _submit() => SubmitLeaveRequest(
      leaveTypeRefId: 3,
      fromDate: DateTime(2026, 10, 20),
      toDate: DateTime(2026, 10, 21),
      totalDays: 2,
      reason: 'FAMILY',
      applicantRefId: 15,
      applicantType: 1,
    );

/// A submit after a refused one is sent, not ignored (leave-approval-rules).
void main() {
  late _Repository repository;

  setUpAll(() => registerFallbackValue(DateTime(2026)));

  setUp(() {
    repository = _Repository();
  });

  void addAnswers(List<Object> answers) {
    var call = 0;
    when(() => repository.addLeaveRequest(
          leaveTypeRefId: any(named: 'leaveTypeRefId'),
          fromDate: any(named: 'fromDate'),
          toDate: any(named: 'toDate'),
          totalDays: any(named: 'totalDays'),
          reason: any(named: 'reason'),
          applicantRefId: any(named: 'applicantRefId'),
          applicantType: any(named: 'applicantType'),
        )).thenAnswer((_) async {
      final answer = answers[call++];
      if (answer is Exception) throw answer;
      return true;
    });
  }

  blocTest<LeaveBloc, LeaveState>(
    'a refused request shows the server reason and the next one is still sent',
    build: () {
      addAnswers([ApiFailure('There is already approved leave from 20 Oct 2026 to 21 Oct 2026 for this person'), true]);
      return LeaveBloc(repository);
    },
    act: (bloc) async {
      bloc.add(_submit());
      await Future<void>.delayed(Duration.zero);
      bloc.add(_submit());
    },
    expect: () => [
      isA<LeaveLoaded>(),
      isA<LeaveLoaded>(),
      isA<LeaveActionError>().having((s) => s.message, 'message', contains('already approved leave')),
      isA<LeaveLoaded>(),
      isA<LeaveLoaded>(),
      isA<LeaveActionSuccess>(),
    ],
  );

  blocTest<LeaveBloc, LeaveState>(
    'a submit works before the list has loaded',
    build: () {
      addAnswers([true]);
      return LeaveBloc(repository);
    },
    act: (bloc) => bloc.add(_submit()),
    expect: () => [isA<LeaveLoaded>(), isA<LeaveLoaded>(), isA<LeaveActionSuccess>()],
  );
}

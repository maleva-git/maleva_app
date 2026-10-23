import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/session/work_jobs.dart';
import 'package:maleva/features/dashboard/work_tabs/work_tabs.dart';

/// One main role plus extra jobs (employee-extra-jobs-and-driver-mode).
void main() {
  List<String> labels(WorkDashboard d, int role, Set<String> jobs) =>
      workTabsFor(d, WorkJobs(role, jobs)).map((t) => workTabLabel(t, d)).toList();

  group('no jobs in the session (older backend): the tabs of the role, Pre Alert second', () {
    test('boarding officer 500', () {
      expect(labels(WorkDashboard.boarding, 500, {}), ['VSL', 'Pre Alert', 'Salary', 'EmpLeave', 'IR Report']);
    });

    test('boarding admin 600', () {
      expect(labels(WorkDashboard.boarding, 600, {}),
          ['VSL', 'Pre Alert', 'Salary', 'SpotsSaleOrder', 'IR Report', 'InventoryReport', 'EmpLeave']);
    });

    test('forwarding agent 1400', () {
      expect(labels(WorkDashboard.forwardingAgent, 1400, {}),
          ['Emp Leave', 'Pre Alert', 'RTI Activities', 'IR Report']);
    });
  });

  test('the new backend gives the same tabs when there is no extra job', () {
    expect(labels(WorkDashboard.boarding, 600, {'BOARDINGOFFICER', 'BOARDINGOFFICERADMIN'}),
        labels(WorkDashboard.boarding, 600, {}));
    expect(labels(WorkDashboard.forwardingAgent, 1400, {'FORWARDINGAGENT'}),
        labels(WorkDashboard.forwardingAgent, 1400, {}));
  });

  test('Kabilan: boarding admin who also seals', () {
    expect(labels(WorkDashboard.boarding, 600, {'BOARDINGOFFICER', 'BOARDINGOFFICERADMIN', 'FORWARDINGAGENT'}), [
      'VSL', 'Pre Alert', 'Salary', 'SpotsSaleOrder', 'IR Report', 'InventoryReport', 'EmpLeave',
      'RTI Activities', 'Seal / Break Seal',
    ]);
  });

  test('a boarding officer with the forwarding job keeps IR Report once', () {
    final tabs = labels(WorkDashboard.boarding, 500, {'BOARDINGOFFICER', 'FORWARDINGAGENT'});
    expect(tabs, ['VSL', 'Pre Alert', 'Salary', 'EmpLeave', 'IR Report', 'RTI Activities', 'Seal / Break Seal']);
  });

  test('a forwarding agent with boarding jobs', () {
    expect(labels(WorkDashboard.forwardingAgent, 1400, {'FORWARDINGAGENT', 'BOARDINGOFFICER'}),
        ['Emp Leave', 'Pre Alert', 'RTI Activities', 'IR Report', 'VSL']);
    expect(labels(WorkDashboard.forwardingAgent, 1400, {'FORWARDINGAGENT', 'BOARDINGOFFICER', 'BOARDINGOFFICERADMIN'}),
        ['Emp Leave', 'Pre Alert', 'RTI Activities', 'IR Report', 'VSL', 'SpotsSaleOrder', 'InventoryReport']);
  });

  test('no FW Requests tab on either work dashboard', () {
    for (final d in WorkDashboard.values) {
      for (final role in [500, 600, 1400]) {
        expect(labels(d, role, {'BOARDINGOFFICER', 'BOARDINGOFFICERADMIN', 'FORWARDINGAGENT'}), isNot(contains('FW Requests')));
      }
    }
  });

  test('Pre Alert is shown once, whatever the jobs', () {
    for (final d in WorkDashboard.values) {
      final tabs = labels(d, 600, {'BOARDINGOFFICER', 'BOARDINGOFFICERADMIN', 'FORWARDINGAGENT'});
      expect(tabs.where((t) => t == 'Pre Alert').length, 1);
    }
  });

  group('boarding checks', () {
    test('follow the role when the session has no jobs', () {
      expect(const WorkJobs(500, {}).isBoardingOfficerOnly, isTrue);
      expect(const WorkJobs(600, {}).isBoardingAdmin, isTrue);
      expect(const WorkJobs(900, {}).isBoarding, isFalse);
    });

    test('a forwarding agent with only the officer job gets the 500 limits', () {
      const jobs = WorkJobs(1400, {'FORWARDINGAGENT', 'BOARDINGOFFICER'});
      expect(jobs.isBoarding, isTrue);
      expect(jobs.isBoardingOfficerOnly, isTrue);
      expect(jobs.isForwardingAgent, isTrue);
    });
  });
}

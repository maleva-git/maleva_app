import 'package:maleva/core/utils/app_preferences.dart';

/// One main role plus extra jobs (openspec change employee-extra-jobs-and-driver-mode).
///
/// The main role still picks the home dashboard. Jobs say which work a person
/// does: a boarding admin who also seals has `BOARDINGOFFICERADMIN` and
/// `FORWARDINGAGENT`. With no jobs in the session (an older backend) the jobs
/// come from the role alone, so every screen behaves as before.
class WorkJobs {
  const WorkJobs(this.roleId, this.jobs);

  /// The signed-in user's jobs, read from the saved session.
  factory WorkJobs.current() =>
      WorkJobs(AppPreferences.getRoleId(), AppPreferences.getJobs().toSet());

  static const boardingOfficer = 'BOARDINGOFFICER';
  static const boardingOfficerAdmin = 'BOARDINGOFFICERADMIN';
  static const forwardingAgent = 'FORWARDINGAGENT';

  final int roleId;
  final Set<String> jobs;

  /// The jobs in force: the session's, or the role's when the session has none.
  Set<String> get effective {
    if (jobs.isNotEmpty) return jobs;
    switch (roleId) {
      case 500:
        return const {boardingOfficer};
      case 600:
        return const {boardingOfficer, boardingOfficerAdmin};
      case 1400:
        return const {forwardingAgent};
      default:
        return const {};
    }
  }

  bool has(String job) => effective.contains(job);

  /// Boarding work at either level (own ports, vessel report).
  bool get isBoarding => has(boardingOfficer) || has(boardingOfficerAdmin);

  bool get isBoardingAdmin => has(boardingOfficerAdmin);

  /// Boarding officer without the admin job: the role-500 limits apply.
  bool get isBoardingOfficerOnly => isBoarding && !isBoardingAdmin;

  bool get isForwardingAgent => has(forwardingAgent);
}

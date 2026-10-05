import 'package:maleva/features/operations/models/job_all_status_model.dart';
import 'package:maleva/features/operations/models/job_type_details_model.dart';

/// A job type's steps and status order, from the shared Java
/// `/api/job-type-master/select-all-data` (was .NET JobTypeApp/SelectJobAllData).
class JobSteps {
  const JobSteps(this.details, this.statuses);

  static const empty = JobSteps([], []);

  /// The steps (`Description`, `Mandatory`, `Status`): which fields a job of this type shows.
  final List<JobTypeDetailsModel> details;

  /// The status order (`Status`, `StatusName`, `MinStatus`, `Sort`).
  final List<JobAllStatusModel> statuses;

  /// The name of [status] in this job type's order, or ''.
  String statusName(int status) {
    for (final s in statuses) {
      if (s.Status == status) return s.StatusName;
    }
    return '';
  }
}

/// Reading the job-steps answer (`JobTypeApp/SelectJobAllData`): one element,
/// `[{JobTypeDetails: [...], JobStatusDetails: [...]}]`. Four screens read it
/// as a flat list, so their status lookups never matched.
class JobSteps {
  JobSteps._();

  /// The job type's status order (`Status`, `StatusName`, `MinStatus`, `Sort`).
  static List<dynamic> statuses(dynamic response) => _part(response, 'JobStatusDetails');

  /// The job type's steps (`Description`, `Mandatory`, `Status`).
  static List<dynamic> details(dynamic response) => _part(response, 'JobTypeDetails');

  static List<dynamic> _part(dynamic response, String key) {
    if (response is List && response.isNotEmpty && response.first is Map) {
      final part = (response.first as Map)[key];
      return part is List ? part : const [];
    }
    return const [];
  }
}

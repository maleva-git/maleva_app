import 'package:dio/dio.dart';
import 'package:maleva/core/lookups/job_steps.dart';
import 'package:maleva/core/lookups/master_response.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';
import 'package:maleva/features/operations/models/job_all_status_model.dart';
import 'package:maleva/features/operations/models/job_type_details_model.dart';

/// Job statuses, from the shared Java job type / status masters (change
/// `job-status-lookups-on-shared-java-api`):
/// - the company's statuses, `GET /api/job-status-master/select/{companyId}/`
///   (was .NET JobStatusApp/SelectJobStatus): `{id, name, svalue, dFlag, active}`;
/// - a job type's steps and status order,
///   `POST /api/job-type-master/select-all-data` (was .NET
///   JobTypeApp/SelectJobAllData).
/// "None" (a 404 there) is an empty list.
class JobStatusApi {
  JobStatusApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  /// The company's job statuses (the trailing slash is part of the web API's path).
  Future<List<Map<String, dynamic>>> statuses() async => JsonRead.listOfMaps(await MasterResponse.data(
      () => _dio.get<dynamic>('/api/job-status-master/select/${_companyId()}/'),
      emptyOn404: true));

  /// The steps and status order of job type [jobTypeId]; none for 0.
  Future<JobSteps> steps(int jobTypeId) async {
    if (jobTypeId <= 0) return JobSteps.empty;
    final dynamic data;
    try {
      data = JavaResponse.data((await _dio.post<dynamic>('/api/job-type-master/select-all-data',
              queryParameters: {'companyId': _companyId(), 'jobId': jobTypeId}))
          .data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return JobSteps.empty;
      throw JavaResponse.fromDio(e);
    }
    final first = JsonRead.listOfMaps(data).firstOrNull ?? const <String, dynamic>{};
    return JobSteps(
      JsonRead.listOfMaps(first['jobTypeDetails']).map(JobTypeDetailsModel.fromJava).toList(),
      JsonRead.listOfMaps(first['jobStatusDetails']).map(JobAllStatusModel.fromJava).toList(),
    );
  }
}

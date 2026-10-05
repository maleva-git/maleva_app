import 'package:dio/dio.dart';
import 'package:maleva/core/lookups/master_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// Job type pickers, from the shared Java
/// `GET /api/job-type-master/jobtypes/{companyId}` (the port of .NET
/// JobTypeApp/SelectJobType; change `lookups-on-shared-java-api`):
/// `{id, name, dFlag, active}`. A company with none answers 404 there; that is
/// an empty list here.
class JobTypeApi {
  JobTypeApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  Future<List<Map<String, dynamic>>> jobTypes() async => JsonRead.listOfMaps(await MasterResponse.data(
      () => _dio.get<dynamic>('/api/job-type-master/jobtypes/${_companyId()}'),
      emptyOn404: true));
}

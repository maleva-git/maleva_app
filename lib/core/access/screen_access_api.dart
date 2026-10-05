import 'package:dio/dio.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// The caller's actions on a controlled screen (`GET /api/screen-access/{screen}/me`):
/// VIEW, CREATE, EDIT, DELETE as the Super Admin set them for the role.
class ScreenAccess {
  const ScreenAccess(this.actions, {this.roleId});

  factory ScreenAccess.fromJava(Map<String, dynamic> m) => ScreenAccess(
        (m['actions'] is List ? m['actions'] as List : const []).map((a) => '$a'.toUpperCase()).toSet(),
        roleId: JsonRead.intOrNull(m['roleId']),
      );

  /// While loading, the web assumes VIEW only (`planningAccess.ts`).
  static const viewOnly = ScreenAccess({'VIEW'});

  final Set<String> actions;
  final int? roleId;

  bool has(String action) => actions.contains(action);
}

class ScreenAccessApi {
  ScreenAccessApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  Future<ScreenAccess> mine(String screen) async {
    try {
      final r = await _dio.get<dynamic>('/api/screen-access/$screen/me', queryParameters: {'companyRefId': _companyId()});
      return ScreenAccess.fromJava(JsonRead.map(JavaResponse.data(r.data)));
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}

import 'package:dio/dio.dart';
import 'package:maleva/core/employee_notifications/employee_notifications_models.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// The signed-in employee's bell on the shared Java API React uses (`/api/employee-notifications`,
/// employee tokens only, scoped by the server to the token's employee). A refusal is an `ApiFailure`
/// with the server's message.
class EmployeeNotificationsApi {
  EmployeeNotificationsApi(this._dio);

  final Dio _dio;

  /// `GET /api/employee-notifications/mine`: unread count and the newest 50 notices; with [group]
  /// (`?group=vessel|other`) only that group's notices and unread count, without it all of them.
  Future<NotificationInbox> mine({NoticeGroup? group}) async => NotificationInbox.fromJava(JsonRead.map(
      await _send(() => _dio.get<dynamic>('/api/employee-notifications/mine', queryParameters: _groupQuery(group)))));

  /// `PUT /api/employee-notifications/{id}/read`: answers the notice.
  Future<EmployeeNotification> markRead(int id) async => EmployeeNotification.fromJava(
      JsonRead.map(await _send(() => _dio.put<dynamic>('/api/employee-notifications/$id/read'))));

  /// `PUT /api/employee-notifications/mine/read-all`: answers how many were marked; with [group] only
  /// that group's notices are marked.
  Future<int> markAllRead({NoticeGroup? group}) async => JsonRead.integer(await _send(
      () => _dio.put<dynamic>('/api/employee-notifications/mine/read-all', queryParameters: _groupQuery(group))));

  static Map<String, dynamic>? _groupQuery(NoticeGroup? group) => group == null ? null : {'group': group.wire};

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    try {
      return JavaResponse.data((await call()).data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}

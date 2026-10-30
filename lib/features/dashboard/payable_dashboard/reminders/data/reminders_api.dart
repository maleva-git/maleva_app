import 'package:dio/dio.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

import '../../records/data/payable_record.dart';
import 'reminder_models.dart';

/// The shared Java `/api/payable-reminders` (change `payable-reminders`). The company is the signed-in one (nothing
/// is sent); answers are `ApiResponse` `{IsSuccess, Data1}`; a refusal is an `ApiFailure` with the server's words.
class RemindersApi {
  RemindersApi(this._dio);

  final Dio _dio;
  static const _base = '/api/payable-reminders';

  Future<List<ReminderItem>> list() async => [
        for (final m in JsonRead.listOfMaps(await _send(() => _dio.get<dynamic>(_base)))) ReminderItem.fromJava(m),
      ];

  /// [month] "yyyy-MM".
  Future<ReminderMonth> calendar(String month) async =>
      ReminderMonth.fromJava(JsonRead.map(await _send(() => _dio.get<dynamic>('$_base/calendar', queryParameters: {'month': month}))));

  Future<ReminderToday> today() async => ReminderToday.fromJava(JsonRead.map(await _send(() => _dio.get<dynamic>('$_base/today'))));

  /// The next three due days of what is typed (the form's "Next:" line).
  Future<List<ReminderDay>> preview(ReminderForm f) async => [
        for (final m in JsonRead.listOfMaps(JsonRead.field(
            JsonRead.map(await _send(() => _dio.post<dynamic>('$_base/preview', data: f.toJson()))), 'next')))
          ReminderDay.fromJava(m),
      ];

  Future<ReminderItem> create(ReminderForm f) async =>
      ReminderItem.fromJava(JsonRead.map(await _send(() => _dio.post<dynamic>(_base, data: f.toJson()))));

  Future<ReminderItem> update(int id, ReminderForm f) async =>
      ReminderItem.fromJava(JsonRead.map(await _send(() => _dio.put<dynamic>('$_base/$id', data: f.toJson()))));

  Future<void> delete(int id) async => _send(() => _dio.delete<dynamic>('$_base/$id'));

  Future<ReminderDay> done(int id, DateTime dueOn, {String? note}) async => ReminderDay.fromJava(JsonRead.map(await _send(() =>
      _dio.post<dynamic>('$_base/$id/done', queryParameters: {'dueOn': _ymd(dueOn), if (note != null && note.isNotEmpty) 'note': note}))));

  Future<void> undo(int id, DateTime dueOn) async =>
      _send(() => _dio.delete<dynamic>('$_base/$id/done', queryParameters: {'dueOn': _ymd(dueOn)}));

  Future<List<ReminderPerson>> people() async => [
        for (final m in JsonRead.listOfMaps(await _send(() => _dio.get<dynamic>('$_base/people'))))
          ReminderPerson(JsonRead.integer(JsonRead.field(m, 'id')), pick(m, const ['name']), JsonRead.integer(JsonRead.field(m, 'roleId'))),
      ];

  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    try {
      return JavaResponse.data((await call()).data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}

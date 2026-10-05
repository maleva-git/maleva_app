import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/files/attachments_api.dart';
import 'package:maleva/features/troubleshoot/data/applog_api.dart';

/// Answers each upload as the server does: the files it was sent, as stored
/// (or [status] with an error body).
class EchoUploadAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  int status = 200;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream, Future<void>? cancelFuture) async {
    requests.add(options);
    final body = status == 200
        ? {'IsSuccess': true, 'StatusCode': 200, 'Message': 'Attachments saved', 'Data1': {'attachments': [
            for (final f in (options.data as FormData).files) {'fileName': f.value.filename},
          ]}}
        : {'IsSuccess': false, 'StatusCode': status, 'Message': 'A driver may only send their own troubleshoot log'};
    return ResponseBody.fromString(jsonEncode(body), status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

/// "Report a Problem" off .NET CommonApp/UploadFile2 (troubleshoot-on-shared-java-api).
void main() {
  late EchoUploadAdapter adapter;
  late AttachmentsApi api;
  late Directory pending;

  setUp(() async {
    adapter = EchoUploadAdapter();
    api = AttachmentsApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter, companyId: () => 6);
    pending = await Directory.systemTemp.createTemp('pending_troubleshoot_test');
  });

  tearDown(() async {
    if (await pending.exists()) await pending.delete(recursive: true);
  });

  String sentFile(RequestOptions request) {
    expect(request.uri.path, '/api/attachments');
    expect(request.queryParameters['folderName'], 'Troubleshoot');
    expect(request.queryParameters['mode'], 'MIXED');
    return (request.data as FormData).files.single.value.filename!;
  }

  test("a report goes to the user's Troubleshoot folder on the shared upload", () async {
    final name = await AppLogApi.insertAppLog(empRefId: 15, empName: 'ANNA', comid: 6, appVersion: '2.0',
        screenHistory: 'Home', errorLog: '', userNote: 'slow', api: api, pendingDir: pending);

    final request = adapter.requests.single;
    expect(request.queryParameters['recordId'], 15);
    expect(request.queryParameters['companyRefId'], 6);
    expect(sentFile(request), name);
    expect(name, startsWith('troubleshoot_log_15_'));
  });

  test('a crash before sign-in is kept, then sent once someone is signed in', () async {
    await AppLogApi.savePendingCrash(appVersion: '2.0', screenHistory: 'Main', errorLog: 'Boom', pendingDir: pending);
    expect(pending.listSync().whereType<File>(), hasLength(1));
    expect(adapter.requests, isEmpty);

    expect(await AppLogApi.sendPending(recordId: 15, api: api, pendingDir: pending), 1);

    expect(adapter.requests.single.queryParameters['recordId'], 15);
    expect(sentFile(adapter.requests.single), startsWith('crash_'));
    expect(pending.listSync(), isEmpty);
  });

  test('a report also sends what was kept', () async {
    await AppLogApi.savePendingCrash(appVersion: '2.0', screenHistory: 'Main', errorLog: 'Boom', pendingDir: pending);

    await AppLogApi.insertAppLog(empRefId: 15, empName: 'ANNA', comid: 6, appVersion: '2.0',
        screenHistory: 'Home', errorLog: '', api: api, pendingDir: pending);

    expect(adapter.requests, hasLength(2));
    expect(pending.listSync(), isEmpty);
  });

  test('a refused pending log stays for next time', () async {
    await AppLogApi.savePendingCrash(appVersion: '2.0', screenHistory: 'Main', errorLog: 'Boom', pendingDir: pending);
    adapter.status = 403;

    expect(await AppLogApi.sendPending(recordId: 15, api: api, pendingDir: pending), 0);
    expect(pending.listSync().whereType<File>(), hasLength(1));
  });
}

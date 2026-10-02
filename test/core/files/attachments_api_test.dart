import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/files/attachments_api.dart';
import 'package:maleva/core/network/api_failure.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

Map<String, dynamic> ok(Object? data) => {'IsSuccess': true, 'StatusCode': 200, 'Message': 'ok', 'Data1': data};

Map<String, dynamic> file(String name, {String sub = 'Boarding'}) =>
    {'fileName': name, 'path': '/Upload/6/SalesOrder/40/$sub/$name', 'contentType': 'image/jpeg', 'sizeBytes': 10};

/// The shared Java /api/attachments, as the app uses it (change files-on-shared-attachments-api).
void main() {
  late QueueAdapter adapter;
  late AttachmentsApi api;
  late Directory tmp;

  setUp(() async {
    adapter = QueueAdapter();
    api = AttachmentsApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter, companyId: () => 6);
    tmp = await Directory.systemTemp.createTemp('attach');
  });

  tearDown(() => tmp.delete(recursive: true));

  String uri() => adapter.requests.last.uri.toString();

  test('the stored name follows the server rule', () {
    expect(AttachmentsApi.storedName('IMG_2024 10 02.JPG'), 'IMG_2024_10_02.jpg');
    expect(AttachmentsApi.storedName('photo.jpeg'), 'photo.jpeg');
    expect(AttachmentsApi.storedName('..hidden.png'), 'hidden.png');
  });

  test('upload keeps the phone name, compresses, and answers the stored name', () async {
    final photo = File('${tmp.path}/IMG 1.JPG')..writeAsBytesSync([1, 2, 3]);
    adapter.replies.add((200, jsonEncode(ok({'attachments': [file('IMG_1.jpg')], 'paths': [], 'storedCount': 1}))));

    final names = await api.upload([photo], folder: 'SalesOrder', recordId: 40, subFolder: 'Boarding');

    expect(names, ['IMG_1.jpg']);
    final req = adapter.requests.single;
    expect(req.method, 'POST');
    expect(req.uri.path, '/api/attachments');
    expect(req.uri.queryParameters, {
      'companyRefId': '6', 'recordId': '40', 'folderName': 'SalesOrder', 'subFolderName': 'Boarding',
      'mode': 'IMAGES_ONLY', 'keepOriginalName': 'true',
    });
    expect((req.data as FormData).files.single.key, 'files');
  });

  test('an upload the server did not store is a failure', () async {
    final photo = File('${tmp.path}/a.jpg')..writeAsBytesSync([1]);
    adapter.replies.add((200, jsonEncode(ok({'attachments': [], 'paths': []}))));

    expect(() => api.upload([photo], folder: 'SalesOrder', recordId: 40), throwsA(isA<ApiFailure>()));
  });

  test('image names are the png/jpg/jpeg files, as .NET FetchFiles', () async {
    adapter.replies.add((200, jsonEncode(ok([file('a.jpg'), file('b.pdf'), file('c.PNG'), file('d.jpeg')]))));

    expect(await api.imageNames(folder: 'SalesOrder', recordId: 40, subFolder: 'Boarding'), ['a.jpg', 'c.PNG', 'd.jpeg']);
    expect(uri(), 'https://java.test/api/attachments?companyRefId=6&recordId=40&folderName=SalesOrder&subFolderName=Boarding');
  });

  test('delete sends the names; a blank sub folder is left out', () async {
    adapter.replies.add((200, jsonEncode(ok({'attachments': [], 'paths': [], 'deletedCount': 1}))));

    await api.delete(['a.jpg'], folder: 'jobs order', recordId: 12, subFolder: '');

    final req = adapter.requests.single;
    expect(req.method, 'DELETE');
    expect(req.uri.queryParameters['folderName'], 'jobs order');
    expect(req.uri.queryParameters.containsKey('subFolderName'), isFalse);
    expect(req.uri.queryParametersAll['paths'], ['a.jpg']);
  });

  test('add stores under new names (PDF pages) and answers the record files', () async {
    final pdf = File('${tmp.path}/quote.pdf')..writeAsBytesSync([1]);
    adapter.replies.add((200, jsonEncode(ok({'attachments': [file('x-1.jpg', sub: '')], 'paths': []}))));

    final files = await api.add([pdf], folder: 'jobs order', recordId: 12, mode: AttachmentMode.pdfAsImages);

    expect(files.single['fileName'], 'x-1.jpg');
    expect(adapter.requests.single.uri.queryParameters['mode'], 'PDF_AS_IMAGES');
    expect(adapter.requests.single.uri.queryParameters['keepOriginalName'], 'false');
  });

  test('a refusal carries the server message', () async {
    adapter.replies.add((400, jsonEncode({'status': 400, 'message': 'folderName is invalid'})));

    expect(() => api.list(folder: 'Sales Order!', recordId: 1),
        throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'folderName is invalid')));
  });
}

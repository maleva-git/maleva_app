import 'dart:io';

import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// How the server stores an upload (Java `AttachmentUploadMode`).
enum AttachmentMode {
  /// Every file is compressed as an image (.NET `UploadFile`).
  imagesOnly('IMAGES_ONLY'),

  /// Images compressed, other files kept as they are (.NET `UploadFile2/3`).
  mixed('MIXED'),

  /// Like [mixed], and a PDF becomes one image per page (.NET `UploadFile5`).
  pdfAsImages('PDF_AS_IMAGES');

  const AttachmentMode(this.wire);
  final String wire;
}

/// The files of a record, from the shared Java `/api/attachments` the web uses
/// (it replaced .NET `CommonApp/UploadFile*`, `FetchFiles`, `DeleteFile` and the
/// web `Common/FetchFile2` / `UploadFile5`). Files live where .NET put them:
/// `/Upload/<company>/<folder>/<record>/<sub folder>/<file>`.
class AttachmentsApi {
  AttachmentsApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  static const _imageExtensions = {'.png', '.jpg', '.jpeg'};

  /// Stores [files] for the record and answers the file names as stored, in the
  /// order given. The phone's file name is kept (as .NET UploadFile did),
  /// cleaned for the disk; a file of the same name is replaced.
  Future<List<String>> upload(List<File> files,
      {required String folder,
      required int recordId,
      String? subFolder,
      AttachmentMode mode = AttachmentMode.imagesOnly}) async {
    final data = await _store(files, folder, recordId, subFolder, mode, keepOriginalName: true);
    final stored = {for (final a in JsonRead.listOfMaps(data['attachments'])) JsonRead.string(a['fileName'])};
    final names = [for (final f in files) storedName(_baseName(f.path))];
    final missing = names.where((n) => !stored.contains(n)).toList();
    if (missing.isNotEmpty) {
      throw ApiFailure('The server did not store ${missing.join(', ')}');
    }
    return names;
  }

  /// Stores [files] under new unique names (as .NET UploadFile5 did) and answers
  /// every file of the record afterwards (`fileName`, `path`, ...).
  Future<List<Map<String, dynamic>>> add(List<File> files,
          {required String folder, required int recordId, String? subFolder, AttachmentMode mode = AttachmentMode.mixed}) async =>
      JsonRead.listOfMaps((await _store(files, folder, recordId, subFolder, mode, keepOriginalName: false))['attachments']);

  Future<Map<String, dynamic>> _store(List<File> files, String folder, int recordId, String? subFolder,
      AttachmentMode mode, {required bool keepOriginalName}) async {
    final form = FormData();
    for (final f in files) {
      form.files.add(MapEntry('files', await MultipartFile.fromFile(f.path, filename: _baseName(f.path))));
    }
    return JsonRead.map(await _send(() => _dio.post<dynamic>('/api/attachments',
        queryParameters: _scope(folder, recordId, subFolder)
          ..['mode'] = mode.wire
          ..['keepOriginalName'] = keepOriginalName,
        data: form)));
  }

  /// Every file of the record: `fileName`, `path` (`/Upload/...`), `contentType`, `sizeBytes`.
  Future<List<Map<String, dynamic>>> list({required String folder, required int recordId, String? subFolder}) async =>
      JsonRead.listOfMaps(await _send(() => _dio.get<dynamic>('/api/attachments',
          queryParameters: _scope(folder, recordId, subFolder))));

  /// The record's image file names (png, jpg, jpeg), as .NET `FetchFiles` listed them.
  Future<List<String>> imageNames({required String folder, required int recordId, String? subFolder}) async => [
        for (final a in await list(folder: folder, recordId: recordId, subFolder: subFolder))
          if (_imageExtensions.contains(_extension(JsonRead.string(a['fileName'])))) JsonRead.string(a['fileName'])
      ];

  /// Deletes files by name or `/Upload/...` path; answers the record's files left.
  Future<List<Map<String, dynamic>>> delete(List<String> namesOrPaths,
      {required String folder, required int recordId, String? subFolder}) async {
    final data = JsonRead.map(await _send(() => _dio.delete<dynamic>('/api/attachments',
        queryParameters: _scope(folder, recordId, subFolder)..['paths'] = namesOrPaths)));
    return JsonRead.listOfMaps(data['attachments']);
  }

  /// The name the server stores a file under when it keeps the original name:
  /// the base name with anything but letters, digits, `.`, `_` and `-` turned
  /// into `_` (leading dots and underscores dropped, at most 100 characters),
  /// and the extension in lower case.
  static String storedName(String fileName) {
    final dot = fileName.lastIndexOf('.');
    final base = dot > 0 ? fileName.substring(0, dot) : fileName;
    final ext = _extension(fileName);
    var clean = base.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_').replaceFirst(RegExp(r'^[._]+'), '');
    if (clean.length > 100) clean = clean.substring(0, 100);
    return '$clean$ext';
  }

  Map<String, dynamic> _scope(String folder, int recordId, String? subFolder) => {
        'companyRefId': _companyId(),
        'recordId': recordId,
        'folderName': folder,
        if (subFolder != null && subFolder.trim().isNotEmpty) 'subFolderName': subFolder.trim(),
      };

  static String _baseName(String path) => path.split(RegExp(r'[\\/]')).last;

  static String _extension(String name) {
    final dot = name.lastIndexOf('.');
    if (dot <= 0) return '';
    final ext = name.substring(dot).toLowerCase();
    return RegExp(r'^\.[a-z0-9]{1,10}$').hasMatch(ext) ? ext : '';
  }

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    try {
      return JavaResponse.data((await call()).data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}

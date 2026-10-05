import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/files/attachments_api.dart';
import 'package:path_provider/path_provider.dart';

/// "Report a Problem" logs, stored on the server under
/// `/Upload/<company>/Troubleshoot/<user id>/` by the shared Java
/// `/api/attachments` (was .NET CommonApp/UploadFile2, change
/// `troubleshoot-on-shared-java-api`). The upload needs a signed-in session: a
/// crash before sign-in is kept on the phone ([savePendingCrash]) and sent by
/// [sendPending] once someone is signed in. A driver may upload only to their
/// own Troubleshoot folder; the server enforces it.
class AppLogApi {
  AppLogApi._();

  static const String folder = 'Troubleshoot';
  static const String _pendingFolder = 'pending_troubleshoot';

  /// Builds the log text the server keeps.
  @visibleForTesting
  static String buildLog({
    required int empRefId,
    required String empName,
    required int comid,
    required String appVersion,
    required String screenHistory,
    required String errorLog,
    String? userNote,
  }) {
    final log = StringBuffer();
    log.writeln("==============================================");
    log.writeln("            MALEVA TROUBLESHOOT LOG           ");
    log.writeln("==============================================");
    log.writeln("Employee ID   : $empRefId");
    log.writeln("Employee Name : $empName");
    log.writeln("Company ID    : ${comid == 0 ? 'unknown' : comid}");
    log.writeln("App Version   : $appVersion");
    log.writeln("Platform      : ${Platform.isAndroid ? 'Android' : (Platform.isIOS ? 'iOS' : 'Other')}");
    log.writeln("Generated At  : ${DateTime.now().toString()}");
    log.writeln("==============================================");
    log.writeln("\n[USER NOTE]");
    log.writeln(userNote != null && userNote.isNotEmpty ? userNote : "No notes provided by user.");
    log.writeln("\n[SCREEN / NAVIGATION HISTORY]");
    log.writeln(screenHistory.isNotEmpty ? screenHistory : "No history recorded.");
    log.writeln("\n[ERROR LOG]");
    log.writeln(errorLog.isNotEmpty ? errorLog : "No error log.");
    log.writeln("==============================================");
    return log.toString();
  }

  /// Sends a signed-in user's report (and any crash log kept from before
  /// sign-in). Answers the stored file name; a refusal throws an ApiFailure.
  static Future<String> insertAppLog({
    required int empRefId,
    required String empName,
    required int comid,
    required String appVersion,
    required String screenHistory,
    required String errorLog,
    String? userNote,
    AttachmentsApi? api,
    Directory? pendingDir,
  }) async {
    final attachments = api ?? sl<AttachmentsApi>();
    final fileName = "troubleshoot_log_${empRefId}_${DateTime.now().millisecondsSinceEpoch}.txt";
    final file = File("${Directory.systemTemp.path}/$fileName");
    await file.writeAsString(buildLog(
      empRefId: empRefId,
      empName: empName,
      comid: comid,
      appVersion: appVersion,
      screenHistory: screenHistory,
      errorLog: errorLog,
      userNote: userNote,
    ));
    try {
      final stored = await attachments.upload([file], folder: folder, recordId: empRefId, mode: AttachmentMode.mixed);
      await sendPending(recordId: empRefId, api: attachments, pendingDir: pendingDir);
      return stored.single;
    } finally {
      if (await file.exists()) await file.delete();
    }
  }

  /// Keeps a crash log from before sign-in on the phone (the app support
  /// folder, which the temporary-file clean-up leaves alone). Never throws.
  static Future<void> savePendingCrash({
    required String screenHistory,
    required String errorLog,
    required String appVersion,
    String? userNote,
    Directory? pendingDir,
  }) async {
    try {
      final dir = await _pending(pendingDir);
      await File("${dir.path}/crash_${DateTime.now().millisecondsSinceEpoch}.txt").writeAsString(buildLog(
        empRefId: 0,
        empName: 'Startup crash (before sign-in)',
        comid: 0,
        appVersion: appVersion,
        screenHistory: screenHistory,
        errorLog: errorLog,
        userNote: userNote,
      ));
    } catch (e) {
      debugPrint('Could not keep the crash log: $e');
    }
  }

  /// Uploads the crash logs kept on the phone to the signed-in user's
  /// Troubleshoot folder ([recordId]), deleting each once stored. Answers how
  /// many were sent; never throws (what is left is tried again next time).
  static Future<int> sendPending({required int recordId, AttachmentsApi? api, Directory? pendingDir}) async {
    var sent = 0;
    try {
      final dir = await _pending(pendingDir);
      final files = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.txt')).toList();
      if (files.isEmpty) return 0;
      final attachments = api ?? sl<AttachmentsApi>();
      for (final file in files) {
        try {
          await attachments.upload([file], folder: folder, recordId: recordId, mode: AttachmentMode.mixed);
          await file.delete();
          sent++;
        } catch (e) {
          debugPrint('Crash log not sent yet: $e');
          break;
        }
      }
    } catch (e) {
      debugPrint('Crash logs not sent: $e');
    }
    return sent;
  }

  static Future<Directory> _pending(Directory? given) async {
    final dir = given ?? Directory("${(await getApplicationSupportDirectory()).path}/$_pendingFolder");
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }
}

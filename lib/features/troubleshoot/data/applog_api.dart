import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:maleva/core/network/api_constants.dart';

/// Sends a "Report a Problem" log file to the server.
class AppLogApi {
  AppLogApi._();

  static Future<dynamic> insertAppLog({
    required int empRefId,
    required String empName,
    required int comid,
    required String appVersion,
    required String screenHistory, // human-readable text block
    required String errorLog,      // human-readable text block
    String? userNote,              // optional — what the user typed
  }) async {
    // 1. Construct the log text content
    final logContent = StringBuffer();
    logContent.writeln("==============================================");
    logContent.writeln("            MALEVA TROUBLESHOOT LOG           ");
    logContent.writeln("==============================================");
    logContent.writeln("Employee ID   : $empRefId");
    logContent.writeln("Employee Name : $empName");
    logContent.writeln("Company ID    : $comid");
    logContent.writeln("App Version   : $appVersion");
    logContent.writeln("Platform      : ${Platform.isAndroid ? 'Android' : (Platform.isIOS ? 'iOS' : 'Other')}");
    logContent.writeln("Generated At  : ${DateTime.now().toString()}");
    logContent.writeln("==============================================");
    logContent.writeln("\n[USER NOTE]");
    logContent.writeln(userNote != null && userNote.isNotEmpty ? userNote : "No notes provided by user.");
    logContent.writeln("\n[SCREEN / NAVIGATION HISTORY]");
    logContent.writeln(screenHistory.isNotEmpty ? screenHistory : "No history recorded.");
    logContent.writeln("\n[ERROR LOG]");
    logContent.writeln(errorLog.isNotEmpty ? errorLog : "No error log.");
    logContent.writeln("==============================================");

    // 2. Write content to a local temporary .txt file
    final tempDir = Directory.systemTemp;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = "troubleshoot_log_${empRefId}_$timestamp.txt";
    final file = File("${tempDir.path}/$fileName");
    await file.writeAsString(logContent.toString());

    try {
      // 3. Prepare the multipart request to UploadFile2 endpoint
      final uploadUrl = ApiConstants.apiPostFile; // "$port/api/CommonApp/UploadFile2/"
      final uri = Uri.parse(uploadUrl);
      final request = http.MultipartRequest("POST", uri);

      final stream = http.ByteStream(file.openRead());
      stream.cast();
      final length = await file.length();

      final multipartFile = http.MultipartFile(
        'MyImages0', // key must match "MyImages0" as required by server API
        stream,
        length,
        filename: fileName,
        contentType: MediaType('image', 'jpeg'), // Use image/jpeg to ensure IIS/WAF parses it as a file upload
      );

      request.files.add(multipartFile);

      // Add required headers for folder/file path construction on the server
      request.headers.addAll({
        'Comid': comid.toString(),
        'Id': empRefId.toString(), // Saves under employee ID folder
        'FolderName': 'Troubleshoot', // Main category folder
        'FileName': fileName,
        'SubFolderName': '', // Can be left empty
      });

      // Send the request exactly as done in objfun.upload
      final response = await http.Response.fromStream(await request.send());

      // 4. Delete the temporary file
      if (await file.exists()) {
        await file.delete();
      }

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception("Server responded with status code ${response.statusCode}");
      }
    } catch (e) {
      // Make sure file is deleted even on failure
      if (await file.exists()) {
        await file.delete();
      }
      rethrow;
    }
  }
}

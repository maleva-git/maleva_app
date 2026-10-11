import 'dart:io';

import 'package:maleva/core/mailmonitor/mail_monitor_api.dart';
import 'package:maleva/core/mailmonitor/response_report_models.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// View or share the server's PDF of the report (change `mail-response-report-tab`). The file goes to
/// the app's temp folder only.
class ResponsePdf {
  const ResponsePdf(this._api);

  final MailMonitorApi _api;

  static String fileName(ReportRange r) => 'Mail-Response-Report-${r.from}-to-${r.to}.pdf';

  Future<File> _save(ReportRange range) async {
    final bytes = await _api.responsePdf(range);
    if (bytes.isEmpty) throw Exception('The server sent an empty PDF');
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${fileName(range)}');
    return file.writeAsBytes(bytes, flush: true);
  }

  /// Opens the PDF in the device's PDF viewer.
  Future<void> view(ReportRange range) async {
    final file = await _save(range);
    final result = await OpenFile.open(file.path, type: 'application/pdf');
    if (result.type != ResultType.done) throw Exception(result.message);
  }

  /// The device's share sheet (WhatsApp, email, ...).
  Future<void> share(ReportRange range) async {
    final file = await _save(range);
    await Share.shareXFiles([XFile(file.path, mimeType: 'application/pdf')], text: 'Mail response report');
  }
}

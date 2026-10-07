import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_api.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_models.dart';
import 'package:maleva/core/mailmonitor/mail_text.dart';

class MailMessageState {
  const MailMessageState({this.message, this.body = '', this.loading = false, this.error});

  final MailMessage? message;

  /// The body as plain text: the text part, or the HTML converted to text.
  final String body;
  final bool loading;
  final String? error;
}

/// One opened mail (it stays unread in the mailbox). Lives only while the mail page is open.
class MailMessageCubit extends Cubit<MailMessageState> {
  MailMessageCubit(this._api) : super(const MailMessageState(loading: true));

  final MailMonitorApi _api;

  Future<void> open(int mailboxId, int uid) async {
    emit(const MailMessageState(loading: true));
    try {
      final m = await _api.message(mailboxId, uid);
      if (isClosed) return;
      emit(MailMessageState(message: m, body: bodyText(m)));
    } catch (e) {
      if (!isClosed) emit(MailMessageState(error: '$e'));
    }
  }

  static String bodyText(MailMessage m) {
    final text = m.text?.trim() ?? '';
    if (text.isNotEmpty) return text;
    final html = m.html ?? '';
    return html.isEmpty ? '' : htmlToText(html);
  }
}

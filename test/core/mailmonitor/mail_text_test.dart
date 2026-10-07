import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_models.dart';
import 'package:maleva/core/mailmonitor/mail_text.dart';
import 'package:maleva/features/mail_monitor/bloc/mail_message_cubit.dart';

/// Mail bodies are shown as text in the app; nothing inside them is loaded or run.
void main() {
  test('scripts, styles and images are dropped and the text stays readable', () {
    const html = '<html><head><title>T</title><style>p{color:red}</style></head><body>'
        '<p>Dear team,</p><p>Please confirm the <b>ETA</b>.</p>'
        '<script>alert(1)</script><img src="https://tracker.example/p.gif">'
        '<ul><li>Vessel A</li><li>Vessel B</li></ul>Regards,<br>Ops</body></html>';

    final text = htmlToText(html);

    expect(text, contains('Dear team,'));
    expect(text, contains('Please confirm the ETA.'));
    expect(text, contains('• Vessel A'));
    expect(text, contains('Regards,\nOps'));
    expect(text, isNot(contains('alert')));
    expect(text, isNot(contains('color:red')));
    expect(text, isNot(contains('tracker')));
    expect(text, isNot(contains('<')));
  });

  test('entities are decoded once', () {
    expect(htmlToText('A &amp; B &lt;ok&gt; &quot;x&quot; &#39;y&#39; &#8364;5 &amp;lt;'), 'A & B <ok> "x" \'y\' €5 &lt;');
  });

  test('blank lines collapse and table cells stay apart', () {
    expect(htmlToText('<table><tr><td>Job</td><td>TR001</td></tr></table><p></p><p></p><p>End</p>'), 'Job TR001\n\nEnd');
  });

  test('the text part wins; HTML is converted only when there is no text', () {
    MailMessage mail({String? text, String? html}) => MailMessage(uid: 1, from: '', to: '', cc: '', subject: '', sentAt: null,
        receivedAt: null, html: html, text: text, truncated: false, attachments: const []);

    expect(MailMessageCubit.bodyText(mail(text: 'Plain', html: '<p>Rich</p>')), 'Plain');
    expect(MailMessageCubit.bodyText(mail(html: '<p>Rich</p>')), 'Rich');
    expect(MailMessageCubit.bodyText(mail()), '');
  });
}

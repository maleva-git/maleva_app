/// A mail's HTML body as readable plain text (owner's decision 2026-10-07: the app shows mail
/// as text). Nothing in the mail is loaded or run: scripts, styles and images are dropped, and
/// the result is shown as text only.
String htmlToText(String html) {
  var s = html;
  s = s.replaceAll(RegExp(r'<(script|style|head|title)\b[^>]*>[\s\S]*?</\1\s*>', caseSensitive: false), '');
  s = s.replaceAll(RegExp(r'<!--[\s\S]*?-->'), '');
  s = s.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
  s = s.replaceAll(RegExp(r'<li\b[^>]*>', caseSensitive: false), '\n• ');
  s = s.replaceAll(RegExp(r'</(p|div|tr|h[1-6]|li|table|blockquote)\s*>', caseSensitive: false), '\n');
  s = s.replaceAll(RegExp(r'</t[dh]\s*>', caseSensitive: false), '\t');
  s = s.replaceAll(RegExp(r'<[^>]+>'), '');
  s = _decodeEntities(s);
  s = s.replaceAll('\r', '');
  s = s.split('\n').map((line) => line.replaceAll(RegExp(r'[ \t\u00A0]+'), ' ').trim()).join('\n');
  s = s.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  return s.trim();
}

const _named = {
  '&nbsp;': ' ',
  '&lt;': '<',
  '&gt;': '>',
  '&quot;': '"',
  '&#39;': "'",
  '&apos;': "'",
  '&ndash;': '–',
  '&mdash;': '—',
  '&hellip;': '…',
  '&copy;': '©',
  '&rsquo;': '’',
  '&lsquo;': '‘',
  '&rdquo;': '”',
  '&ldquo;': '“',
};

String _decodeEntities(String s) {
  var out = s.replaceAllMapped(RegExp(r'&#(x?)([0-9a-fA-F]+);'), (m) {
    final code = int.tryParse(m[2]!, radix: m[1]!.isEmpty ? 10 : 16);
    return code == null || code > 0x10FFFF ? '' : String.fromCharCode(code);
  });
  _named.forEach((entity, char) => out = out.replaceAll(entity, char));
  // last, so "&amp;lt;" stays the text "&lt;"
  return out.replaceAll('&amp;', '&');
}

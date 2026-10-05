import 'package:maleva/core/config/app_config.dart';

/// The link of a stored file (`/Upload/<company>/<folder>/<record>/...`) on the
/// Java server, which serves the Upload tree publicly (`/Upload/**`, the same
/// tree the .NET site served; change `file-links-on-java`). A path that is
/// already a full URL is left as it is.
String fileUrl(String? path) {
  final p = (path ?? '').trim();
  if (p.isEmpty) return '';
  if (p.startsWith('http://') || p.startsWith('https://')) return p;
  return '${AppConfig.javaBaseUrl}${p.startsWith('/') ? p : '/$p'}';
}

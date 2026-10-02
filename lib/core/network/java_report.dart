import 'package:maleva/core/config/app_config.dart';

/// The full link of a report path a Java print-ticket endpoint answers
/// (`/api/.../print/{ticket}/{file}.pdf`): public, no sign-in, a few minutes.
String javaReportUrl(String path) => path.startsWith('http') ? path : '${AppConfig.javaBaseUrl}$path';

import 'package:maleva/core/config/app_config.dart';

/// Whether a TLS certificate that failed validation is accepted anyway.
///
/// The .NET hosts keep the app's historic accept-all behavior (clarification
/// Q12, unchanged here). The Java host never does: it receives the password at
/// sign-in and the session token on every call.
bool acceptInvalidCertificate(String host) => host != Uri.parse(AppConfig.javaBaseUrl).host;

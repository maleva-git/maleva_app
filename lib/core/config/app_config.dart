class AppConfig {
  AppConfig._();

  /// The Java (Spring) backend: every API call and every file link
  /// (`/Upload/...`, see `fileUrl`). Requests carry the session token, and every
  /// host must present a valid TLS certificate.
  //static const String javaBaseUrl = "http://192.168.1.100:8082"; // Local
  static const String javaBaseUrl = "https://maleva.mydriverszone.com"; // Live
}

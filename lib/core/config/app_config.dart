
class AppConfig {
  AppConfig._();
  //static const String baseUrl = "http://192.168.1.100:8085"; // Local
  //static const String baseUrl = "http://103.215.139.121:9001"; // Demo
//static const String baseUrl = "http://103.215.139.8:8001"; // Demo Latest
  static const String baseUrl = "https://mydriverszone.com"; // Live

  /// The Java (Spring) backend. Mobile sign-in, session refresh, and sign-out
  /// Use it; every other call still goes to [baseUrl] (.NET) until its module
  /// is moved. Requests to this host carry the session token and require a
  /// valid TLS certificate.
  //static const String javaBaseUrl = "http://192.168.1.100:8082"; // Local
  static const String javaBaseUrl = "https://maleva.mydriverszone.com"; // Live
}

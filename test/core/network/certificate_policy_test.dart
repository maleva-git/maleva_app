import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/config/app_config.dart';
import 'package:maleva/core/network/certificate_policy.dart';

void main() {
  test('the Java host requires a valid certificate', () {
    expect(acceptInvalidCertificate(Uri.parse(AppConfig.javaBaseUrl).host), isFalse);
  });

  test('the .NET host keeps its current behavior', () {
    expect(acceptInvalidCertificate(Uri.parse(AppConfig.baseUrl).host), isTrue);
  });
}

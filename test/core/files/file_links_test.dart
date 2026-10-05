import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/config/app_config.dart';
import 'package:maleva/core/files/file_links.dart';
import 'package:maleva/core/utils/app_globals.dart';

/// File links point at the Java server, which serves the Upload tree (file-links-on-java).
void main() {
  test('a stored path is a link on the Java server', () {
    expect(fileUrl('/Upload/6/SpareParts/12/a.jpg'), '${AppConfig.javaBaseUrl}/Upload/6/SpareParts/12/a.jpg');
    expect(fileUrl('Upload/6/x.pdf'), '${AppConfig.javaBaseUrl}/Upload/6/x.pdf');
  });

  test('a full URL is left alone; nothing is empty', () {
    expect(fileUrl('https://cdn.example/a.jpg'), 'https://cdn.example/a.jpg');
    expect(fileUrl(null), '');
    expect(fileUrl('  '), '');
  });

  test("the company's Upload folder follows the signed-in company", () {
    final before = AppGlobals.Comid;
    AppGlobals.Comid = 6;
    expect(AppGlobals.imagepath, '${AppConfig.javaBaseUrl}/Upload/6/');
    AppGlobals.Comid = 9;
    expect(AppGlobals.imagepath, '${AppConfig.javaBaseUrl}/Upload/9/');
    AppGlobals.Comid = before;
  });
}

import 'dart:convert';
import 'dart:io';
void main() async {
  var url = 'http://103.215.139.121:9001/api/VesselPlanningApp/MaxVESSELPLANINGNo?Comid=6';
  var request = await HttpClient().postUrl(Uri.parse(url));
  var response = await request.close();
  var responseBody = await response.transform(utf8.decoder).join();
  print('Status: ' + response.statusCode.toString());
  print('Body: ' + responseBody);
}

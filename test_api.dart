import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final res = await http.post(Uri.parse('https://maleva.my/api/AddressApp/SelectAddress?Comid=121&KeyWord='));
  print(res.body.length);
  if (res.body.length > 2) {
    print(res.body.substring(0, 500));
  }
}

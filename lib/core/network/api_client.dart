import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../utils/clsfunction.dart';


class ApiClient {

  static Future<dynamic> postRequest(String url, dynamic bodyData, {Map<String, String>? headers}) async {
    try {
      headers ??= {
        'Content-Type': 'application/json; charset=UTF-8',
      };
      String body = json.encode(bodyData);
      final response = await http.post(Uri.parse(url), headers: headers, body: body);
      if (response.statusCode == 200) {

        if (response.body.isEmpty) return [];

        return jsonDecode(response.body);

      }
      else if (response.statusCode == 401) {
        throw Exception("Authentication Failed !!! Please ReLogin.");
      }
      else if (response.statusCode == 406) {
        throw Exception("Already Logged in Another Device. ReLogin or Change Password !!!");
      }
      else if (response.statusCode == 404 || response.statusCode == 500) {
        var value = jsonDecode(response.body);
        throw Exception(value['Message'] ?? 'Server Error Occurred');
      }
      else {
        throw Exception('${response.statusCode} Unknown Error Occurred');
      }
    } on SocketException catch (_) {
      throw Exception('Check Your Network Connection. No Internet.');
    } catch (error) {
      throw Exception('API Error: $error');
    }
  }

  getDeviceToken() async {
    await Firebase.initializeApp();
    FirebaseMessaging fcm = FirebaseMessaging.instance;
    String? fcmToken = await fcm.getToken();
    if (fcmToken != null) {
      mobiletoken = fcmToken;
      print_(mobiletoken);
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {});
    // fcm.subscribeToTopic('puppies');
    // fcm.unsubscribeFromTopic('puppies');
  }

}
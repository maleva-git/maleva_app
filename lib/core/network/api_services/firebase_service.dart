import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../utils/app_preferences.dart';


class FirebaseService {


  static Future<void> getDeviceToken() async {
    try {
      await Firebase.initializeApp();
      FirebaseMessaging fcm = FirebaseMessaging.instance;

      String? fcmToken = await fcm.getToken();

      if (fcmToken != null) {
        await AppPreferences.setFcmToken(fcmToken);
        debugPrint("FCM Token Generated & Saved: $fcmToken");
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint("Message received in foreground: ${message.notification?.title}");
      });

    } catch (e) {
      debugPrint("Firebase Initialization Error: $e");
    }
  }
}
import 'dart:io';
import 'package:rxdart/subjects.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:maleva/core/utils/clsfunction.dart';
import 'dart:io' show File, Platform;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';


FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String?> selectNotificationSubject = BehaviorSubject<String?>();

const MethodChannel platform = MethodChannel('dexterx.dev/flutter_local_notifications_example');

class LocalNotificationService {

  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initialize(BuildContext context) {
    _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    if (Platform.isIOS) {
      // ignore: unused_element
      requestIOSPermission() {
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()!.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
          // onDidReceiveLocalNotification: (
          //     int id,
          //     String? title,
          //     String? body,
          //     String? payload,
          //     ) async {
          //   didReceiveLocalNotificationSubject.add(
          //     ReceivedNotification(
          //       id: id,
          //       title: title,
          //       body: body,
          //       payload: payload,
          //     ),
          //   );
          // }
          );
      final InitializationSettings initializationSettings = InitializationSettings(iOS: initializationSettingsIOS, macOS: null);

      _notificationsPlugin.initialize(
        initializationSettings,
      );
    } else {
      const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings("@mipmap/launcher_icon");
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );
      _notificationsPlugin.initialize(
        initializationSettings,
      );
    }
  }

  static _downloadAndSaveFile(String url, String fileName) async {
    var directory = await  getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$fileName';
    var response = await http.get(Uri.parse(url));
    var file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  static void display(RemoteMessage message) async {
    try {
      if (Platform.isIOS) {
        dynamic largeIconPath;
        String? imgurl = message.notification!.apple!.imageUrl;
        if (imgurl != "" && imgurl != null) {
          try {
            largeIconPath = await _downloadAndSaveFile(imgurl, 'largeIcon.jpg');
          } on PlatformException {
            largeIconPath = null;
          }
        } else {
          largeIconPath = null;
        }

          print_(largeIconPath);


        DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
          attachments: (largeIconPath != null && largeIconPath != "")
              ? [
            DarwinNotificationAttachment(
              largeIconPath,
            )
          ]
              : null,
          presentAlert: true, // Present an alert when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
          presentBadge: true, // Present the badge number when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
          presentSound: true, // Play a sound when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
          // sound: String?,  // Specifics the file path to play (only from iOS 10 onwards)
          badgeNumber: 1,
          // The application's icon badge number
          // attachments: List<IOSNotificationAttachment>?, (only from iOS 10 onwards)
          // subtitle: String?, //Secondary description  (only from iOS 10 onwards)
          // threadIdentifier: String? (only from iOS 10 onwards)
        );
        final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        final NotificationDetails notificationDetails = NotificationDetails(
          android: null,
          iOS: iOSPlatformChannelSpecifics,
          linux: null,
          macOS: null,
        );

        await _notificationsPlugin.show(
          id,
          message.notification!.title,
          message.notification!.body,
          notificationDetails,
          payload: '',
        );
      } else {
        dynamic largeIconPath;
        String? imgurl = message.notification!.android!.imageUrl;
        if (imgurl != "" && imgurl != null) {
          try {
            largeIconPath = await _downloadAndSaveFile(imgurl, 'largeIcon.jpg');
          } on PlatformException {
            largeIconPath = null;
          }
        } else {
          largeIconPath = null;
        }
        BigPictureStyleInformation bigPictureStyleInformation;
        if (largeIconPath != null) {
          bigPictureStyleInformation = BigPictureStyleInformation(
            FilePathAndroidBitmap(largeIconPath),
            largeIcon: FilePathAndroidBitmap(largeIconPath),
            contentTitle: message.notification!.title,
            summaryText: message.notification!.body,
          );
        } else {
          bigPictureStyleInformation = BigPictureStyleInformation(
            const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
            largeIcon: const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
            contentTitle: message.notification!.title,
            summaryText: message.notification!.body,
          );
        }
        AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(channelId, channelName,
            // objfun.channelDescription,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            styleInformation: bigPictureStyleInformation);
        final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        final NotificationDetails notificationDetails = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: null,
          linux: null,
          macOS: null,
        );

        await _notificationsPlugin.show(
          id,
          message.notification!.title,
          message.notification!.body,
          notificationDetails,
          payload: '',
        );
      }
    } on Exception catch (e) {

        print_(e);

    }
  }
}

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

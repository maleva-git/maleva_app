import 'dart:typed_data';
import 'dart:io';
import 'package:rxdart/subjects.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/features/vessel_changes/push_route.dart' show isVesselPushType, localPayloadForPush;
import 'dart:io' show File, Platform;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';


FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String?> selectNotificationSubject = BehaviorSubject<String?>();

const MethodChannel platform = MethodChannel('dexterx.dev/flutter_local_notifications_example');

class LocalNotificationService {

  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Creates the high-importance alert channel. Firebase shows a push that arrives while the app is in
  /// the background or closed on the manifest's default channel; when that channel does not exist the
  /// phone files it under a silent "Miscellaneous" channel and nothing pops up. Run at start-up, before
  /// any push can arrive; creating an existing channel again changes nothing.
  static Future<void> createAlertChannel() async {
    if (!Platform.isAndroid) return;
    final android = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(AndroidNotificationChannel(
      AppGlobals.channelId,
      AppGlobals.channelName,
      description: AppGlobals.channelDescription,
      importance: Importance.max,
      playSound: true,
      showBadge: false,
    ));
    // Vessel alerts: on Android 8+ the channel decides sound and vibration, and a channel cannot be changed
    // once made, so this one has its own id: the long vibration, no sound.
    await android?.createNotificationChannel(vesselChannel);
    // the earlier vessel channels (normal sound, then the alarm tone) are replaced by this one
    for (final old in AppGlobals.oldVesselChannelIds) {
      await android?.deleteNotificationChannel(old);
    }
  }

  /// A long vibration: 1 s, pause, 1 s, pause, 1.5 s, pause, 2 s.
  static final Int64List vesselVibration = Int64List.fromList([0, 1000, 500, 1000, 500, 1500, 500, 2000]);

  static final AndroidNotificationChannel vesselChannel = AndroidNotificationChannel(
    AppGlobals.vesselChannelId,
    AppGlobals.vesselChannelName,
    description: AppGlobals.vesselChannelDescription,
    importance: Importance.max,
    playSound: false,
    enableVibration: true,
    vibrationPattern: vesselVibration,
    enableLights: true,
    ledColor: const Color(0xFFFF6D00),
    showBadge: true,
  );

  /// How a vessel notice is shown while the app is open: the vessel channel, no sound, and insistent (the
  /// vibration repeats until the notice is opened or swiped away), so it is not missed.
  static AndroidNotificationDetails vesselDetails({StyleInformation? style}) => AndroidNotificationDetails(
        AppGlobals.vesselChannelId,
        AppGlobals.vesselChannelName,
        channelDescription: AppGlobals.vesselChannelDescription,
        importance: Importance.max,
        priority: Priority.max,
        playSound: false,
        enableVibration: true,
        vibrationPattern: vesselVibration,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        ticker: 'Vessel ETA changed',
        additionalFlags: Int32List.fromList([insistentFlag]),
        styleInformation: style,
      );

  /// A push of one of the vessel types (`VESSEL_ETA_CHANGED`, `VESSEL_LINK_NEEDED`, `PTP_SCHEDULE_STALE`,
  /// `PHONE_PUSH_DOWN`, `VESSEL_OMITTED`, `WESTPORTS_UPLOAD_DUE`, `MMSW_SCHEDULE_STALE`, by `data['type']`) is
  /// shown on the vessel channel with the long vibration; every other on the normal one.
  static bool usesVesselChannel(Map<String, dynamic> data) => isVesselPushType(data['type']?.toString());

  /// Android's Notification.FLAG_INSISTENT.
  static const int insistentFlag = 4;

  /// [onTap] gets the tapped notification's payload (the push type, e.g. MAIL_UNREAD; see localPayloadForPush).
  static void initialize(BuildContext context, {void Function(String? payload)? onTap}) {
    _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    if (Platform.isIOS) {
      requestIOSPermission() {
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()!.requestPermissions(
          alert: true,
          badge: false, // Disabled badge
          sound: true,
        );
      }

      const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: false, // Disabled badge
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
      const InitializationSettings initializationSettings = InitializationSettings(iOS: initializationSettingsIOS, macOS: null);

      _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (response) => onTap?.call(response.payload),
      );
    } else {
      const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings("@mipmap/launcher_icon");
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );
      _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (response) => onTap?.call(response.payload),
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

          AppGlobals.print_(largeIconPath);


        DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
          attachments: (largeIconPath != null && largeIconPath != "")
              ? [
            DarwinNotificationAttachment(
              largeIconPath,
            )
          ]
              : null,
          presentAlert: true, // Present an alert when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
          presentBadge: false, // DO NOT present the badge number when the notification is displayed
          presentSound: true, // Play a sound when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
          // vessel alerts: the iPhone's default notification sound (iOS vibrates only together with a sound;
          // with the ringer switch on silent it is vibration only)
          badgeNumber: 0, // Set badge to 0
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
          payload: localPayloadForPush(message.data),
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
        final bool vessel = usesVesselChannel(message.data);
        AndroidNotificationDetails androidPlatformChannelSpecifics = vessel
            ? vesselDetails(style: BigTextStyleInformation(message.notification!.body ?? ''))
            : AndroidNotificationDetails(AppGlobals.channelId, AppGlobals.channelName,
            // AppGlobals.channelDescription,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            channelShowBadge: false, // Disable app icon badge for this channel
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
          payload: localPayloadForPush(message.data),
        );
      }
    } on Exception catch (e) {

        AppGlobals.print_(e);

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

import 'dart:io';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maleva/core/theme/my_behaviour.dart';
import 'package:maleva/core/firebase/local_notification_service.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/firebase/firebase_options.dart';
import 'package:maleva/splash/splashscreen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:maleva/features/troubleshoot/data/applog_api.dart';

import 'core/di/injection.dart';
import 'core/utils/app_preferences.dart';
import 'package:maleva/core/logging/app_navigator_observer.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> backgroundHandler(RemoteMessage message) async {
  AppGlobals.print_(message.data.toString());
  AppGlobals.print_(message.notification!.title);
}

Future cleanTemporaryfiles() async {
  try {
    final dir = await getTemporaryDirectory();

    dir.deleteSync();
  } catch (e) {
    debugPrint(e.toString());
  }
}

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on FirebaseException catch (e) {
      print(e);
      if (e.code == 'duplicate-app') {
        Firebase.initializeApp();
      } else {
        rethrow; // Re-throw unexpected errors
      }
    }
    await AppPreferences.init();
    // ── DI setup — ONE call wires everything ──────────────────
    await setupDependencies();

    FirebaseMessaging.onBackgroundMessage(backgroundHandler);
    if (Platform.isIOS) {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: false, // Disable a icon badge
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: false, // Disable app icon badge in foreground
        sound: true,
      );
      AppGlobals.print_('User granted permission: ${settings.authorizationStatus}');
    }

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    HttpOverrides.global = MyHttpOverrides();
    cleanTemporaryfiles();
  } catch (e, stack) {
    debugPrint("Error during main initialization: $e\n$stack");
    try {
      await AppLogApi.insertAppLog(
        empRefId: 0,
        empName: 'Splash Screen Crash',
        comid: 6,
        appVersion: 'Unknown (Startup)',
        screenHistory: 'Main Initialization',
        errorLog: "$e\n$stack",
        userNote: 'Automatic Crash Report from Splash Screen',
      ).timeout(const Duration(seconds: 3));
    } catch (_) {}
  } finally {
    FlutterNativeSplash.remove();
  }

  runApp(
    SafeArea(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  hexColor(String colorhexcode) {
    // FIX: int.parse crashes if colorhexcode is null/malformed → use tryParse with fallback
    String colornew = '0xff${colorhexcode.replaceAll('#', '')}';
    return int.tryParse(colornew) ?? 0xFF022B50;
  }

  final Map<int, Color> _yellow700Map = {
    50: const Color(0xff022b50),
    100: const Color(0xff022b50),
    200: const Color(0xff022b50),
    300: const Color(0xff022b50),
    400: const Color(0xff022b50),
    500: const Color(0xff022b50),
    600: const Color(0xff022b50),
    700: const Color(0xff022b50),
    800: const Color(0xff022b50),
    900: const Color(0xff022b50),
  };
  @override
  Widget build(BuildContext context) {
    final MaterialColor blue900Swatch =
        MaterialColor(_yellow700Map[400]!.value, _yellow700Map);
    return MaterialApp(
      title: 'MALEVA',
      navigatorKey: AppGlobals.navigatorKey,
      navigatorObservers: [
        AppNavigatorObserver(),
      ],
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: MyBehavior(), //Design class page
          child: child ?? Container(),
        );
      },
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: blue900Swatch,
        primaryColor: blue900Swatch,
        primaryColorLight: blue900Swatch,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    //#region------FireBase-------
    LocalNotificationService.initialize(context);
    _getFCMToken();

    ///gives you the message on which user taps
    ///and it opened the app from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        // Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
        // AppGlobals.getLocation().then((value) => {
        //       Navigator.pushNamed(context, '/MapPicker'),
        //       // Navigator.pushNamedAndRemoveUntil(context, 'MapPicker', (route) => false)
        //       // Navigator.of(context).push(
        //       //     MaterialPageRoute(builder: (context) => PlacePicker(AppGlobals.googleapikey,displayLocation: AppGlobals.kInitialPosition, ))),
        //     });
        // Navigator.of(context).push(
        //     MaterialPageRoute(builder: (context) => MobileNo()));
      }
    });

    ///forground work
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        AppGlobals.print_(message.notification!.body);
        AppGlobals.print_(message.notification!.title);
        // final snackbar = SnackBar(
        //   content: Text(message.notification!.title!),
        //   action: SnackBarAction(
        //     label: 'Go',
        //     onPressed: () => null,
        //   ),
        // );
        // ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
      LocalNotificationService.display(message);
    });

    ///When the app is in background but opened and user taps
    ///on the notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    });
    // Navigator.of(context).push(
    //     MaterialPageRoute(builder: (context) => MobileNo()));
    //#endregion
    //#region=====Bluetooth=====
    // bpp.BluetoothPrintPlus.scanResults.listen((event) {});
    //
    // /// listen isScanning
    // bpp.BluetoothPrintPlus.isScanning.listen((event) {
    //   print('********** isScanning: $event **********');
    // });
    //
    // /// listen blue state
    // bpp.BluetoothPrintPlus.blueState.listen((event) {
    //   print('********** blueState change: $event **********');
    // });

    /// listen connect state
    // bpp.BluetoothPrintPlus.connectState.listen((event) {
    //   print('********** connectState change: $event **********');
    //   switch (event) {
    //     case bpp.ConnectState.connected:
    //       AppGlobals.currentconnectionstate = true;
    //       msgshow('Connected Successfully ', "", Colors.white, Colors.red, null,
    //           18.00 - AppGlobals.reducesize, AppGlobals.tll, AppGlobals.tgc, context, 2);
    //       break;
    //     case bpp.ConnectState.disconnected:
    //       AppGlobals.currentconnectionstate = false;
    //       break;
    //   }
    // });

    // /// listen received data
    // bpp.BluetoothPrintPlus.receivedData.listen((data) {
    //   print('********** received data: $data **********');
    //
    //   /// do something...
    // });
    //#endregion
  }

  _getFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    AppGlobals.print_("🔥 FCM Token: $token");
    print("🔥 FCM Token: $token");
    // TODO: send this token to your ASP.NET server
    // await http.post("https://yourserver.com/api/saveToken", body: {"token": token});
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      body: SplashScreen(),
    );
  }
}

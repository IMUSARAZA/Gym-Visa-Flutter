import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/firebase_options.dart';
import 'package:gymvisa/models/SubscriptionsModel.dart';
import 'package:gymvisa/screens/adminSide/GymInfoScreen1.dart';
import 'package:gymvisa/screens/adminSide/ManageSubscriptions.dart';
import 'package:gymvisa/screens/adminSide/SendNotification.dart';
import 'package:gymvisa/screens/adminSide/SendNotificationGymSpecific.dart';
import 'package:gymvisa/screens/adminSide/SpecificUserNotify.dart';
import 'package:gymvisa/screens/adminSide/SubsperMonth.dart';
import 'package:gymvisa/screens/adminSide/AdminHome.dart';
import 'package:gymvisa/screens/adminSide/GymInfo.dart';
import 'package:gymvisa/screens/adminSide/ManageGyms.dart';
import 'package:gymvisa/screens/clientSide/BMICalculated.dart';
import 'package:gymvisa/screens/clientSide/ExcerciseScreen.dart';
import 'package:gymvisa/screens/clientSide/ForgotPassword.dart';
import 'package:gymvisa/screens/clientSide/InfoScreen.dart';
import 'package:gymvisa/screens/clientSide/Memberships.dart';
import 'package:gymvisa/screens/clientSide/Notifications.dart';
import 'package:gymvisa/screens/clientSide/ResetEmailVerification.dart';
import 'package:gymvisa/screens/clientSide/BMI.dart';
import 'package:gymvisa/screens/clientSide/EmailVerification.dart';
import 'package:gymvisa/screens/clientSide/GetStarted.dart';
import 'package:gymvisa/screens/clientSide/LoginScreen.dart';
import 'package:gymvisa/screens/clientSide/Onboarding.dart';
import 'package:gymvisa/screens/clientSide/SignUp.dart';
import 'package:gymvisa/screens/clientSide/Subscriptions.dart';
import 'package:gymvisa/screens/clientSide/gymInform.dart';
import 'package:gymvisa/screens/clientSide/NavLoader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'models/Notifications.dart';
import 'package:gymvisa/models/GymModel.dart' as gymModel;
import 'package:gymvisa/screens/adminSide/QRs.dart' as qrScreen;
import 'package:get/get.dart';


final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    runApp(MyApp());
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? user;
  String userSubscription = "";

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: AppColors.appBackground, 
      statusBarColor: AppColors.appBackground,
    ));

    return GetMaterialApp(
    theme: ThemeData.dark().copyWith(
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  ),
      debugShowCheckedModeBanner: false,
      initialRoute: _getInitialRoute(),
      getPages: AppRoutes.routes,
    );
  }

  String _getInitialRoute() {
    if (user != null) {
      if (user!.email == "fa21-bcs-082@cuilahore.edu.pk") {
        return '/adminHome';
      } else {
        return '/home';
      }
    } else {
      return '/onboarding';
    }
  }
}

class AppRoutes {
  static final routes = [
    GetPage(name: '/adminHome', page: () => AdminHome()),
    GetPage(name: '/home', page: () => Home()),
    GetPage(name: '/onboarding', page: () => const Onboarding()),
    GetPage(name: '/getStarted', page: () => GetStarted()),
    GetPage(name: '/login', page: () => const LoginScreen()),
    GetPage(name: '/BMI', page: () => BMI()),
    GetPage(name: '/ManageGyms', page: () => ManageGyms()),
    GetPage(name: '/ManageSubs', page: () => ManageSubscriptions()),
    GetPage(name: '/TotalUsers', page: () => SpecificUserNotify()),
    GetPage(
      name: '/GymInfo',
      page: () => GymInfo(gym: Get.arguments as gymModel.Gym),
    ),
    GetPage(
      name: '/gymInformation',
      page: () => GymInform(gym: Get.arguments as gymModel.Gym),
    ),
    GetPage(name: '/ExcerciseScreen', page: () => const ExcerciseScreen()),
    GetPage(name: '/AddGym', page: () => const GymInfoScreen1()),
    GetPage(name: '/subscriptions', page: () => Subscriptions()),
    GetPage(name: '/verifyEmail', page: () => const EmailVerification()),
    GetPage(name: '/NotificationScreen', page: () {
      final Future<List<Notifications>>? receivedNotif =
          Get.arguments as Future<List<Notifications>>?;
      if (receivedNotif != null) {
        return NotificationScreen(notifs: receivedNotif);
      } else {
        return Container();
      }
    }),
    GetPage(
      name: '/sendNotification',
      page: () {
        final data = Get.arguments as Map<String, dynamic>;
        final fcmToken = data['fcmToken'] as List<UserWithToken>;
        final userIds = data['userIds'] as List;
        return SendNotification(fcmToken: fcmToken, userIds: userIds);
      },
    ),
    GetPage(name: '/forgotPassword', page: () => const ForgotPassword()),
    GetPage(name: '/barChart', page: () => SubscriptionChart()),
    GetPage(name: '/verifyResetEmail', page: () => const ResetEmailVerification()),
    GetPage(name: '/BMICal', page: () => BMICalculated()),
    GetPage(
      name: '/Memberships',
      page: () => Memberships(
        userSubscription: Get.arguments['userSubscription'],
        subscriptions: Subscription.fromJson({}),
        description: "Unlock elite fitness with Premium membership",
      ),
    ),
    GetPage(name: '/SendNotificationGymSpecific', page: () => const SendNotificationGymSpecific()),
    GetPage(name: '/QRs', page: () => qrScreen.QRs()),
    GetPage(name: '/signUp', page: () => const SignUp()),
    GetPage(name: '/infoScreen', page: () => InfoScreen()),
  ];
}

Future<void> setupFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
    return; // Stop further execution if permission is not granted
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    onDidReceiveLocalNotification: (id, title, body, payload) async {
      // Notification tapped logic
    },
  );

  const AndroidNotificationChannel callChannel = AndroidNotificationChannel(
    'your_channel_id',
    'Gym Visa',
    description: 'Incoming call notifications',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(callChannel);

  print('Notification channel created');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received a message while in the foreground: ${message.messageId}');
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'your_channel_id',
            'your_channel_name',
            channelDescription: 'Incoming call notifications',
            importance: Importance.high,
            priority: Priority.high,
            ticker: 'ticker',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('App opened from a notification: ${message.messageId}');
    // Handle background
  });

  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      print('App opened from a terminated state via notification: ${message.messageId}');
      // Handle terminated state
    }
  });
}



Future<bool> requestStoragePermission() async {
  PermissionStatus status;

  if (Platform.isAndroid && (await _getSdkInt()) >= 33) {
    PermissionStatus photoStatus = await Permission.photos.request();
    PermissionStatus videoStatus = await Permission.videos.request();
    PermissionStatus audioStatus = await Permission.audio.request();

    if (photoStatus.isGranted || videoStatus.isGranted || audioStatus.isGranted) {
      print('Media access permission granted');
      return true;
    } else if (photoStatus.isDenied || videoStatus.isDenied || audioStatus.isDenied) {
      print('Media access permission denied');
      return false;
    } else if (photoStatus.isPermanentlyDenied || videoStatus.isPermanentlyDenied || audioStatus.isPermanentlyDenied) {
      print('Media access permission permanently denied. Please enable it in settings.');
      openAppSettings();
      return false;
    }
    else if(await Permission.manageExternalStorage.request().isGranted){
      print('Storage permission granted');
      return true;
    }
    else if(await Permission.manageExternalStorage.request().isDenied){
      print('Storage permission denied');
      return false;
    }
    else if(await Permission.manageExternalStorage.request().isPermanentlyDenied){
      print('Storage permission permanently denied. Please enable it in settings.');
      openAppSettings();
      return false;
    }
  } else {
    status = await Permission.storage.request();
    
    if (status.isGranted) {
      print('Storage permission granted');
      return true;
    } else if (status.isDenied) {
      print('Storage permission denied');
      return false;
    } else if (status.isPermanentlyDenied) {
      print('Storage permission permanently denied. Please enable it in settings.');
      openAppSettings();
      return false;
    }
  }

  return false;
}

Future<int> _getSdkInt() async {
  if (Platform.isAndroid) {
    var sdkInt = (await Process.run('getprop', ['ro.build.version.sdk'])).stdout;
    return int.tryParse(sdkInt.toString().trim()) ?? 0;
  }
  return 0;
}

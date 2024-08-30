import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:local_notifications_demo/second_screen.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => const MyHomePage(title: 'Flutter Demo Home Page'),
        '/second_screen': (context) => const SecondScreen(),
      },
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String message = "";

  @override
  void initState() {
    super.initState();

    message = "No message.";

    bool? permission;

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        //check permission
        if (Platform.isAndroid) {
          permission = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()!
              .requestNotificationsPermission();
        } else if (Platform.isIOS) {
          permission = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              );
        }

        if (permission == true) {
          //icon noti android
          const initializationSettingsAndroid =
              AndroidInitializationSettings('flutter');

          final DarwinInitializationSettings initializationSettingsDarwin =
              DarwinInitializationSettings(
            onDidReceiveLocalNotification: (int? id, String? title,
                String? body, String? payload) async {},
          );

          final initializationSettings = InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
          );

          flutterLocalNotificationsPlugin.initialize(
            initializationSettings,
            onDidReceiveNotificationResponse: (NotificationResponse details) {
              // setState(() {
              //   message = details.payload!;
              // });

              Navigator.pushNamed(context, details.payload!);
            },
          );
        }
      },
    );
  }

  sendNotification() async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '10000',
      'FLUTTER_NOTIFICATION_CHANNEL',
      channelDescription: "FLUTTER_NOTIFICATION_CHANNEL_DETAIL",
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'test',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      111,
      "Hello",
      "This is a your notifications work.",
      notificationDetails,
      payload: "/second_screen",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Main Screen \n $message',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: sendNotification,
        tooltip: 'Increment',
        child: const Icon(Icons.send),
      ),
    );
  }
}

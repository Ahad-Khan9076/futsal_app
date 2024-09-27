import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:futsal_app/screens/login_screen.dart';
import 'package:futsal_app/screens/splash_screen.dart';
import 'model/local_notification_services.dart';
// Import the new service
import 'package:timezone/data/latest.dart' as tz;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocalNotificationService.initializeNotifications();
  // Initialize local notifications
  tz.initializeTimeZones();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Futsal Booking App',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

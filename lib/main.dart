import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'Reminder/reminder_screen.dart';
import 'Reminder/services.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService notificationService = NotificationService();
  await notificationService.initReminder();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ReminderScreen(),
  ));
}

// class MyApp extends StatelessWidget {
//   //final Future<FirebaseApp> _initialization = Firebase.initializeApp();

//   MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ReminderScreen();
//     // FutureBuilder(
//     //   future: _initialization,
//     //   builder: (context, snapshot) {
//     //     if (snapshot.hasError) {
//     //       debugPrint("something went wrong");
//     //       Fluttertoast.showToast(msg: "something went wrong");
//     //     }
//     //     if (snapshot.connectionState == ConnectionState.done) {
//     //       return MaterialApp(
//     //         debugShowCheckedModeBanner: false,
//     //         title: 'Reminder app',

//     //         ///HOME
//     //         home: ReminderScreen(),
//     //       );
//     //     }
//     //     return const Center(child: CircularProgressIndicator());
//     //   },
//     // );
//   }
// }

// import 'package:flutter/material.dart';
// import 'Reminder/reminder_screen.dart';



// void main() {
//   runApp(
//     MaterialApp(
//       home: ReminderScreen(),
//     )
//   );
// }

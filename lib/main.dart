import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'habit_provider.dart';
import 'notification.dart';
import 'habit_list.dart';

void main() {
  // Ensure that Flutter's binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the notification service
  final NotificationService notificationService = NotificationService();
  notificationService.init();

  runApp(MyApp(notificationService: notificationService));
}

class MyApp extends StatelessWidget {
  final NotificationService notificationService;

  MyApp({required this.notificationService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HabitProvider(),
      child: MaterialApp(
        title: 'Good Habit Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HabitListScreen(notificationService: notificationService),
      ),
    );
  }
}

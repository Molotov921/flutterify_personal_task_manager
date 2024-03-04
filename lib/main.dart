import 'package:flutter/material.dart';
import 'package:flutterify_personal_task_manager/screens/add_task_screen.dart';
import 'package:flutterify_personal_task_manager/screens/history_screen.dart';
import 'package:flutterify_personal_task_manager/screens/home_screen.dart';
import 'package:flutterify_personal_task_manager/screens/settings_screen.dart';
import 'package:flutterify_personal_task_manager/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      initialRoute: 'splash_screen',
      routes: {
        'splash_screen': (context) => const SplashScreen(),
        '/': (context) => const HomeScreen(),
        'add_task_screen': (context) =>
            AddTaskScreen(updateTaskList: () {}, task: null),
        'history_screen': (context) => const HistoryScreen(),
        'settings_screen': (context) => const SettingsScreen(),
      },
    );
  }
}

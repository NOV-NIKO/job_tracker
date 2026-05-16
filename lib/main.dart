import 'package:flutter/material.dart';
import 'package:job_tracker/screens/home_screen.dart';
import 'package:job_tracker/screens/auth_screen.dart';
import 'package:job_tracker/services/auth_service.dart';
import 'package:job_tracker/services/firebase_service.dart';
import 'package:job_tracker/theme/app_theme.dart';
import 'package:job_tracker/config/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Config.initialize();
  await FirebaseService.initialize();
  runApp(JobTrackerApp());
}

class JobTrackerApp extends StatelessWidget {
  const JobTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JobTracker',
      theme: AppTheme.theme,
      home: StreamBuilder(
        stream: AuthService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return HomeScreen();
          } else {
            return AuthScreen();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
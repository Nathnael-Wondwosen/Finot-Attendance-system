import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/class_selection_screen.dart';
import 'presentation/screens/attendance_screen.dart';
import 'presentation/screens/attendance_summary_screen.dart';
import 'presentation/screens/sync_status_screen.dart';
import 'presentation/screens/attendance_history_screen.dart';
import 'presentation/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finot Attendance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      initialRoute: Routes.splash,
      routes: {
        Routes.splash: (context) => SplashScreen(),
        Routes.login: (context) => LoginScreen(),
        Routes.dashboard: (context) => DashboardScreen(),
        Routes.classSelection: (context) => ClassSelectionScreen(),
        Routes.attendance: (context) => AttendanceScreen(),
        Routes.attendanceSummary: (context) => AttendanceSummaryScreen(),
        Routes.syncStatus: (context) => SyncStatusScreen(),
        Routes.attendanceHistory: (context) => AttendanceHistoryScreen(),
        Routes.settings: (context) => SettingsScreen(),
      },
    );
  }
}


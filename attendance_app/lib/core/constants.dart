import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Finot Attendance';
  static const String version = '1.0.0';
  static const int maxLoginAttempts = 3;
  static const Duration sessionTimeout = Duration(hours: 2);

  // API Configuration
  static const String baseUrl = 'https://your-api-url.com/api';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String isLoggedInKey = 'is_logged_in';
  static const String userKey = 'user_data';

  // Attendance Status
  static const String present = 'present';
  static const String absent = 'absent';
  static const String late = 'late';

  // Table Names
  static const String studentsTable = 'students';
  static const String classesTable = 'classes';
  static const String sectionsTable = 'sections';
  static const String attendanceLocalTable = 'attendance_local';
  static const String syncQueueTable = 'sync_queue';

  // Status Codes
  static const int notSynced = 0;
  static const int synced = 1;

  // Actions
  static const String insertAction = 'insert';
  static const String updateAction = 'update';
  static const String deleteAction = 'delete';
}

class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String mainNavigation = '/main-navigation';
  static const String attendance = '/attendance';
  static const String attendanceSummary = '/attendance-summary';
  static const String attendanceHistory = '/attendance-history';
  static const String themeSettings = '/theme-settings';
}

// Responsive Breakpoints
class Breakpoints {
  static const double small = 600;
  static const double medium = 1100;
  static const double large = 1400;
}

// Responsive Spacing
class Spacing {
  static const EdgeInsets paddingAll = EdgeInsets.all(16.0);
  static const EdgeInsets paddingHorizontal = EdgeInsets.symmetric(
    horizontal: 16.0,
  );
  static const EdgeInsets paddingVertical = EdgeInsets.symmetric(
    vertical: 16.0,
  );
  static const EdgeInsets paddingOnlyTop = EdgeInsets.only(top: 16.0);
  static const EdgeInsets paddingOnlyBottom = EdgeInsets.only(bottom: 16.0);
  static const EdgeInsets paddingOnlyLeft = EdgeInsets.only(left: 16.0);
  static const EdgeInsets paddingOnlyRight = EdgeInsets.only(right: 16.0);
  static const EdgeInsets paddingSymmetric = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 16.0,
  );
}

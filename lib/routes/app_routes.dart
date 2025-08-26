import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/dashboard/dashboard.dart';
import '../presentation/real_time_monitoring/real_time_monitoring.dart';
import '../presentation/alerts_notifications/alerts_notifications.dart';
import '../presentation/reports_analytics/reports_analytics.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String login = '/login-screen';
  static const String dashboard = '/dashboard';
  static const String realTimeMonitoring = '/real-time-monitoring';
  static const String alertsNotifications = '/alerts-notifications';
  static const String reportsAnalytics = '/reports-analytics';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    dashboard: (context) => const Dashboard(),
    realTimeMonitoring: (context) => RealTimeMonitoring(),
    alertsNotifications: (context) => const AlertsNotifications(),
    reportsAnalytics: (context) => const ReportsAnalytics(),
    // TODO: Add your other routes here
  };
}

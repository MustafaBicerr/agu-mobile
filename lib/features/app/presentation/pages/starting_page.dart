import 'package:flutter/material.dart';
import 'package:agu_mobile/core/theme/app_theme.dart';
import 'package:agu_mobile/features/app/presentation/pages/app_bootstrap.dart';
import 'package:agu_mobile/features/home/presentation/pages/home_page.dart';
import 'package:agu_mobile/shared/services/notification_service.dart';

class MyRootApp extends StatelessWidget {
  final NotificationService notificationService;
  const MyRootApp({
    super.key,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('[AGU_BOOT] MyRootApp.build → MaterialApp');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      themeMode: ThemeMode.light,
      onGenerateRoute: (settings) {
        if (settings.name == '/login') {
          return MaterialPageRoute(
            builder: (_) => MyApp(notificationService: notificationService),
          );
        }
        return MaterialPageRoute(
          builder: (_) =>
              AppBootstrap(notificationService: notificationService),
        );
      },
    );
  }
}

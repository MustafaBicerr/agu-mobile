import 'dart:async';
import 'dart:io';

import 'package:agu_mobile/shared/services/app_services.dart';
import 'package:agu_mobile/shared/services/current_user_profile_store.dart';
import 'package:agu_mobile/shared/services/notification_service.dart';
import 'package:agu_mobile/features/app/presentation/pages/starting_page.dart';
import 'package:agu_mobile/features/events/data/models/store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';

import 'package:agu_mobile/shared/config/firebase_options.dart';

void _aguBoot(String step) => debugPrint('[AGU_BOOT] $step');

Future<void> requestPermissions() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    _aguBoot('1 WidgetsFlutterBinding OK');

    await initializeDateFormatting('tr_TR');

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint('[AGU_BOOT][FlutterError] ${details.exceptionAsString()}');
      debugPrint('[AGU_BOOT][FlutterError] ${details.stack}');
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('[AGU_BOOT][PlatformDispatcher] $error');
      debugPrint('[AGU_BOOT][PlatformDispatcher] $stack');
      return false;
    };

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _aguBoot('2 Firebase.initializeApp OK');

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      if (prefs.getBool('remember_me') == false) {
        await FirebaseAuth.instance.signOut();
        CurrentUserProfileStore.instance.clear();
      }
    } catch (e, st) {
      debugPrint('[main] remember_me / signOut: $e\n$st');
    }

    if (!Platform.isAndroid && !Platform.isIOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _aguBoot('3 sqflite factory (desktop only if applicable) OK');

    tz.initializeTimeZones();
    _aguBoot('4 tz.initializeTimeZones OK');

    final NotificationService notificationService = NotificationService();
    AppServices.notification = notificationService;
    await notificationService.initNotification();
    _aguBoot('5 notificationService.initNotification OK');

    await requestPermissions();
    _aguBoot('6 requestPermissions OK');

    EventsStore.instance.setup();
    _aguBoot('7 EventsStore.setup OK');

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _aguBoot('8 SystemChrome OK — calling runApp');

    runApp(
      MyRootApp(
        notificationService: notificationService,
      ),
    );
    _aguBoot('9 runApp returned (tree scheduled)');
  }, (error, stack) {
    debugPrint('[AGU_BOOT][zone] $error');
    debugPrint('[AGU_BOOT][zone] $stack');
  });
}

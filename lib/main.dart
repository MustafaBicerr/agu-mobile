import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home_page/screens/lesson_add_page.dart';
import 'package:home_page/screens/auth_screen.dart';
import 'package:home_page/buttons/buttons.dart';
import 'package:home_page/data/database_service.dart';
import 'package:home_page/profileMenuWidget.dart';
import 'package:home_page/screens/TimeTableDetail.dart';
import 'package:home_page/screens/attendance.dart';
import 'package:home_page/bottom.dart';
import 'package:home_page/screens/events/eventsCard.dart';
import 'package:home_page/screens/main_page.dart';
import 'package:home_page/screens/notification_screen.dart';
import 'package:home_page/screens/refectory.dart';
import 'package:home_page/screens/starting_animation.dart';
import 'package:home_page/services/events_service.dart';
import 'package:home_page/starting.dart';
import 'package:home_page/state/lesson_cubit.dart';
import 'package:home_page/state/user_cubit.dart';
import 'package:home_page/utilts/constants/constants.dart';
import 'package:home_page/models/Store.dart';
import 'package:home_page/services/apiService.dart';
import 'package:home_page/services/database_matching_service.dart';
import 'package:home_page/services/dbHelper.dart';
import 'package:home_page/models/lesson.dart';
import 'package:home_page/screens/lesson_detail_screen.dart';
import 'package:home_page/screens/menu_page.dart';
import 'package:home_page/methods.dart';
import 'package:home_page/services/notification_service.dart';
import 'package:home_page/upcomingLesson.dart';
import 'package:home_page/utilts/constants/image_constants.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:sqflite/sqflite.dart';
import 'firebase_options.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';

final Dbhelper dbHelper = Dbhelper();
final NotificationService notificationService = NotificationService();
final EventsService eventsService = EventsService(baseUrlEvents);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> requestPermissions() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter bağlamını başlat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!Platform.isAndroid && !Platform.isIOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  tz.initializeTimeZones();

  final NotificationService notificationService =
      NotificationService(); // Global olarak tanımla
  await notificationService.initNotification();
  await requestPermissions();
  // DatabaseService.I.debugPrintDbInfo();
  Future<void> requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      print("Depolama izni verildi.");
    } else {
      print("Depolama izni reddedildi.");
    }
  }

  // Tek URL (Apps Script web app): tüm veriyi döndürür.
  EventsStore.instance.setup(baseUrl: baseUrlEvents);

  // AÇILIŞTA: hızlı + güncel (hibrit)
  // await EventsStore.instance.load(force: false); // cache + meta kontrol

  // Uygulamanın tam ekran modunda çalışması
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Yalnızca dikey mod
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyRootApp(notificationService: notificationService));

  WidgetsBinding.instance.addPostFrameCallback((_) async {});
}

class MyApp extends StatefulWidget {
  final NotificationService notificationService;

  // ignore: use_super_parameters
  const MyApp({Key? key, required this.notificationService}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Methods methods = Methods();

  DailyAttendanceScreenState attendance = DailyAttendanceScreenState();

  final Dbhelper dbHelper = Dbhelper();
  List<Lesson>? lessons; // Ders listesi
  MealApi mealApi = MealApi();
  String? imageUrl;
  String Name = '';
  bool isLoading = true;
  bool isDataFetched = false;

  DateTime now = DateTime.now();
  String year = DateTime.now().year.toString();
  String month = DateTime.now().month.toString();

  final eventsService = EventsService(baseUrlEvents);

  Map<String, dynamic>? userData;

  // void getAllDatas() {            //bu fonksiyonun değişmesi lazım
  //   if (isDataFetched != true) {
  //     lessons = [];
  //     getLessons();
  //     getDailyLesson();
  //     userService.loadProfileImage();
  //     userService.loadUserData();

  //     isDataFetched = true;
  //   }
  // }

  @override
  void initState() {
    //initState değişicek
    final istanbul = tz.getLocation('Europe/Istanbul');
    final now = tz.TZDateTime.now(istanbul);

    methods.printColored("Şu Anki Saat (Istanbul): $now", "31");

    super.initState();
    lessons = []; // Başlangıçta boş liste

    Future.delayed(Duration.zero, () async {
      await requestNotificationPermission(context);
    });
    // getUserData();
    //////getAllDatas();

    // _loadProfileImage();
    // loadUserData();
    // _loadDataFromSisAPI();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiBlocProvider(providers: [
        BlocProvider<LessonCubit>(
          // LessonCubit, ihtiyacı olan servisleri alarak oluşturulur
          create: (context) => LessonCubit(dbHelper, notificationService),
        ),
        BlocProvider<UserCubit>(
          create: (context) => UserCubit(),
        ),
      ], child: MainPage()),
    );
  }

  void goToDetail(Lesson lesson) async {
    // bunun için route kullanıccaz fonksiyon yazmaya gerek yok
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => LessonDetailScreen(lesson: lesson)),
    );

    // // if (result != null && result == true) {
    //    lessonService.getLessons();
    // // }
  }

  void goToLessonAdd() async {
    // bunun için route kullanıccaz fonksiyon yazmaya gerek yok
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LessonAddPage()),
    );

    // if (result != null && result == true) {
    //    lessonService.getLessons();
    // }
  }
}

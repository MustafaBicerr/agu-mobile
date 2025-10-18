import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home_page/lesson_add_page.dart';
import 'package:home_page/auth.dart';
import 'package:home_page/buttons/buttons.dart';
import 'package:home_page/data/database_service.dart';
import 'package:home_page/profileMenuWidget.dart';
import 'package:home_page/screens/TimeTableDetail.dart';
import 'package:home_page/screens/attendance.dart';
import 'package:home_page/bottom.dart';
import 'package:home_page/screens/events/eventsCard.dart';
import 'package:home_page/screens/main_page.dart';
import 'package:home_page/screens/refectory.dart';
import 'package:home_page/screens/starting_animation.dart';
import 'package:home_page/services/user_service.dart';
import 'package:home_page/starting.dart';
import 'package:home_page/utilts/constants/constants.dart';
import 'package:home_page/models/Store.dart';
import 'package:home_page/services/apiService.dart';
import 'package:home_page/services/database_matching_service.dart';
import 'package:home_page/services/dbHelper.dart';
import 'package:home_page/models/lesson.dart';
import 'package:home_page/lessonDetail.dart';
import 'package:home_page/screens/menu_page.dart';
import 'package:home_page/methods.dart';
import 'package:home_page/notifications.dart';
import 'package:home_page/upcomingLesson.dart';
import 'package:home_page/services/events_service';
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
  int _selectedIndex = 2;
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

  UserService userService = UserService();
  void getAllDatas() {
    if (isDataFetched != true) {
      lessons = []; // Başlangıçta boş liste
      // getLessons(); // Dersleri yükle
      getDailyLesson();
      userService.loadProfileImage();
      userService.loadUserData();

      isDataFetched = true;
    }
  }

  @override
  void initState() {
    final istanbul = tz.getLocation('Europe/Istanbul');
    final now = tz.TZDateTime.now(istanbul);

    methods.printColored("Şu Anki Saat (Istanbul): $now", "31");

    super.initState();
    lessons = []; // Başlangıçta boş liste

    Future.delayed(Duration.zero, () async {
      await requestNotificationPermission(context);
    });
    // getUserData();
    getAllDatas();

    // _loadProfileImage();
    // loadUserData();
    // _loadDataFromSisAPI();
  }

  @override
  Widget build(BuildContext context) {
    //aşağıdaki değişkenleri sizedbox larda her cihaza uygun olması için kullanacağız.


    return MainPage();
  }


  void goToDetail(Lesson lesson) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LessonDetail(lesson: lesson)),
    );

    // if (result != null && result == true) {
    //   getLessons();
    // }
  }

  void goToLessonAdd() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LessonAddPage()),
    );

    // if (result != null && result == true) {
    //   getLessons();
    // }
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      await Navigator.push(
          // context, MaterialPageRoute(builder: (context) => sisLessonsPage()));
          context,
          MaterialPageRoute(builder: (context) => Timetabledetail()));
    } else if (index == 3) {
      methods.navigateToPage(context, RefectoryScreen());
    } else if (index == 4) {
      await Navigator.push(context,
          MaterialPageRoute(builder: (context) => DailyAttendanceScreen()));
    }

    // Kullanıcı geri döndüğünde anasayfa seçili olacak
    setState(() {
      _selectedIndex = 2;
    });
  }

 
  Widget _buildMenuItem(
      BuildContext context, String title, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.orange[300], size: 24.0),
        const SizedBox(width: 12.0),
        Expanded(
          child: Text(
            "$title: $value",
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<List<Lesson>> getDailyLesson() async {
    String currentDay = methods.getDayName();
    List<Lesson> dailyLessons = [];
    var allLesson = await dbHelper.getLessons();

    setState(() {
      dailyLessons = allLesson
          .where(
              (lesson) => lesson.day == currentDay && lesson.isProcessed == 0)
          .toList();
    });

    return dailyLessons;
  }

  // ignore: non_constant_identifier_names
}



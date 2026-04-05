import 'dart:async';

import 'package:flutter/material.dart';
import 'package:agu_mobile/features/lessons/presentation/pages/lesson_add_page.dart';
import 'package:agu_mobile/features/home/presentation/widgets/home_buttons.dart';
import 'package:agu_mobile/features/profile/presentation/widgets/profile_menu_widget.dart';
import 'package:agu_mobile/features/attendance/presentation/pages/attendance_page.dart';
import 'package:agu_mobile/features/navigation/presentation/widgets/bottom_nav.dart';
import 'package:agu_mobile/features/events/presentation/widgets/events_card.dart';
import 'package:agu_mobile/features/refectory/presentation/pages/refectory_page.dart';
import 'package:agu_mobile/features/menu/presentation/pages/menu_page.dart';
import 'package:agu_mobile/features/lessons/data/services/db_helper.dart';
import 'package:agu_mobile/features/lessons/data/models/lesson.dart';
import 'package:agu_mobile/features/lessons/presentation/pages/lesson_detail_page.dart';
import 'package:agu_mobile/shared/utils/app_methods.dart';
import 'package:agu_mobile/shared/services/notification_service.dart';
import 'package:agu_mobile/features/lessons/presentation/widgets/upcoming_lesson_widget.dart';
import 'package:agu_mobile/shared/widgets/page_gradient_background.dart';
import 'package:agu_mobile/shared/services/current_user_profile_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class MyApp extends StatefulWidget {
  final NotificationService notificationService;

  // ignore: use_super_parameters
  const MyApp({Key? key, required this.notificationService}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Methods methods = Methods();
  final Dbhelper dbHelper = Dbhelper(); // Veritabanı yardımıcısı
  List<Lesson>? lessons; // Ders listesi
  int lessonCount = 0; // Ders sayısı
  DailyAttendanceScreenState attendance = DailyAttendanceScreenState();

  bool isDataFetched = false;

  DateTime now = DateTime.now();
  String year = DateTime.now().year.toString();
  String month = DateTime.now().month.toString();

  // 1) Firebase’den gelen ders kodlari
  final List<String> firebaseCodes = ["ECE581(01)"];

  // Future<void> runSyncWithDebug(List<String> firebaseCodes) async {
  //   Sqflite.devSetDebugModeOn(true);

  //   await SisLessonSyncService.instance.buildGlobalMapFromSisByCodes(
  //     firebaseCodes,
  //     verbose: true,
  //   );

  //   // ❌ eski: final friendDb = await openDatabase(friendPath);
  //   // ✅ yeni:
  //   final friendDb = await openFriendDbViaHelper();

  //   await SisLessonSyncService.instance.insertFromFirebase(
  //     sisLessonsByCode,
  //     friendDb,
  //     verbose: true,
  //   );

  //   await friendDb.close();
  // }

  void getAllDatas() {
    if (isDataFetched != true) {
      lessons = []; // Başlangıçta boş liste
      getLessons(); // Dersleri yükle
      getDailyLesson();
      // _fetchClasses();
      // runSyncWithDebug(firebaseCodes);
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
    // getLessons(); // Dersleri yükle
    // getDailyLesson();
    Future.delayed(Duration.zero, () async {
      await requestNotificationPermission(context);
    });
    // getUserData();
    getAllDatas();
    // Etkinlik / yemekhane / profil Firestore verisi [AppBootstrap] aşamasında yüklenir.

    // _loadProfileImage();
    // loadUserData();
    // _loadDataFromSisAPI();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //aşağıdaki değişkenleri sizedbox larda her cihaza uygun olması için kullanacağız.
    double screenHeight = MediaQuery.of(context).size.height;

    return ListenableBuilder(
      listenable: CurrentUserProfileStore.instance,
      builder: (context, _) {
        final store = CurrentUserProfileStore.instance;
        final userData = store.profileForUi;
        final imageUrl = store.imageUrl;
        final showProfileLoading = store.isLoading && userData == null;
        final userName = (userData?['name'] as String?) ?? '';
        final hasImage = imageUrl != null && imageUrl.isNotEmpty;

        return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Drawer'ı açar
              },
            );
          },
        ),
        title: Center(
          child: Image.asset(
            'assets/images/agu-logo.png',
            fit: BoxFit.contain,
            height: 42,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return const ShowProfileMenuWidget();
                      },
                    );
                  },
                  child: showProfileLoading
                      ? const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : hasImage
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(imageUrl),
                              radius: 28, // Boyutu büyüttük
                            )
                          : const Icon(
                              Icons.account_circle,
                              size: 44, // Varsayılan ikonu büyüttük
                              color: Colors.grey,
                            ),
                ),
              ],
            ),
          ),
        ],
      ),

      drawer: Drawer(
        child: MenuPage(),
      ),
      body: SingleChildScrollView(
        child: PageGradientBackground(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: screenHeight * 0.025,
                ),
                SizedBox(height: screenHeight * 0.20, child: TimeTable_Card()),
                // SizedBox(
                //   height: screenHeight * 0.025,
                // ),
                RefectoryCard(),
                SizedBox(
                  height: screenHeight * 0.025,
                ),
                EventsCard(),
                SizedBox(
                  height: screenHeight * 0.035,
                ),
                Buttons()
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: bottomBar2(context, 2), // Alt gezinme çubuğu
    );
      },
    );
  }

  Widget TimeTable_Card() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    if (lessons == null || lessons!.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.02,
          horizontal: screenWidth * 0.02,
        ),
        child: Card(
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () {
              goToLessonAdd();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                Container(
                  height: screenHeight * 0.055,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey.shade400, Colors.grey.shade600],
                    ),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  child: Row(
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        color: Colors.white,
                        size: screenWidth * 0.057,
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        "Ders Kaydı Bulunamadı",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.045,
                            ),
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Text(
                      "Ders eklemek için dokunun",
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.black54,
                      ),
                    )),
                SizedBox(height: screenWidth * 0.02),
              ],
            ),
          ),
        ),
      );
    } else {
      // Sıradaki dersi bul
      Lesson? nextLesson = findUpcomingLesson(lessons!);
      printColored("dersler: ${nextLesson.toString()}", "32");
      return ListView(
        children: [
          ShowUpcomingLesson(lesson: nextLesson),
        ],
      );
    }
  }

  void goToDetail(Lesson lesson) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LessonDetail(lesson: lesson)),
    );

    if (result != null && result == true) {
      getLessons();
    }
  }

  void goToLessonAdd() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LessonAdd()),
    );

    if (result != null && result == true) {
      getLessons();
    }
  }

  void getLessons() async {
    late int minuteBefore;

    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool isRefectoryNotification =
        preferences.getBool("isRefectoryNotification") ?? false;
    bool isLessonNotification =
        preferences.getBool("isLessonNotification") ?? false;
    bool isNotificationsEnabled =
        preferences.getBool("isNotificationsEnabled") ?? false;
    bool isAttendanceNotification =
        preferences.getBool("isAttendanceNotification") ?? false;
    String? txtMinuteString = preferences.getString("txtMinute");

    List<Lesson> dailyLesson = await getDailyLesson();
    printColored("$dailyLesson", "30");
    printColored("${dailyLesson.isEmpty}", "30");
    printColored("${dailyLesson.length}", "30");
    for (var lesson in dailyLesson) {
      printColored(
          "Lesson: ${lesson.name}, isProcessed: ${lesson.isProcessed}", "30");
    }

    if (txtMinuteString != null && !txtMinuteString.contains("f")) {
      minuteBefore = int.parse(txtMinuteString);
    } else {
      minuteBefore = 0; // Varsayılan değer
    }
    var lessonsFuture = dbHelper.getLessons();
    lessonsFuture.then((data) {
      setState(() {
        lessons = data;
      });
      if (isNotificationsEnabled) {
        // Dersler yüklendikten sonra bildirimleri planla
        if (lessons != null && lessons!.isNotEmpty && isLessonNotification) {
          widget.notificationService
              .scheduleWeeklyLessons(lessons!, minuteBefore);
        }
        //widget.notificationService.sendInstantNotification();

        if (dailyLesson.isEmpty) {
          widget.notificationService.cancelNotification(2000);
          widget.notificationService.cancelNotification(1000);
        }

        if (isRefectoryNotification && dailyLesson.isNotEmpty) {
          widget.notificationService.scheduleRefectory();
        }

        if (isAttendanceNotification && dailyLesson.isNotEmpty) {
          widget.notificationService.scheduleAttendance();
        }
      } else {
        methods.printColored(
            "Bildirimler kapalı. Bildirim gönderilmiyor.", "37");
      }
    });
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

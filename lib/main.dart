import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home_page/LessonAdd.dart';
import 'package:home_page/auth.dart';
import 'package:home_page/buttons/buttons.dart';
import 'package:home_page/data/database_service.dart';
import 'package:home_page/profileMenuWidget.dart';
import 'package:home_page/screens/TimeTableDetail.dart';
import 'package:home_page/screens/attendance.dart';
import 'package:home_page/bottom.dart';
import 'package:home_page/screens/events/eventsCard.dart';
import 'package:home_page/screens/refectory.dart';
import 'package:home_page/screens/starting_animation.dart';
import 'package:home_page/starting.dart';
import 'package:home_page/utilts/constants/constants.dart';
import 'package:home_page/utilts/models/Store.dart';
import 'package:home_page/utilts/services/apiService.dart';
import 'package:home_page/utilts/services/database_matching_service.dart';
import 'package:home_page/utilts/services/dbHelper.dart';
import 'package:home_page/utilts/models/lesson.dart';
import 'package:home_page/lessonDetail.dart';
import 'package:home_page/screens/menu.dart';
import 'package:home_page/methods.dart';
import 'package:home_page/notifications.dart';
import 'package:home_page/upcomingLesson.dart';
import 'package:home_page/utilts/services/events_service';
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

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    
  });
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
  int _selectedIndex = 2; // Varsayılan olarak Anasayfa seçili
  final Dbhelper dbHelper = Dbhelper(); // Veritabanı yardımıcısı
  List<Lesson>? lessons; // Ders listesi
  int lessonCount = 0; // Ders sayısı
  DailyAttendanceScreenState attendance = DailyAttendanceScreenState();

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

  Future<void> _loadProfileImage() async {
    try {
      Map<String, dynamic>? userData =
          await getUserData(); // Kullanıcı bilgilerini al

      if (userData != null && userData['username'] != null) {
        String username = userData['username']; // Kullanıcı adını al

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(username) // username ile belgeyi çek
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          String? fetchedImageUrl =
              userDoc['image_url']; // Profil fotoğrafını al
          print(
              "Firestore'dan gelen image_url: $fetchedImageUrl"); // Kontrol için

          setState(() {
            imageUrl = fetchedImageUrl;
          });
        }
      } else {
        print("Kullanıcı adı bulunamadı.");
      }
    } catch (e) {
      print("Hata oluştu: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadUserData() async {
    Map<String, dynamic>? data = await getUserData();

    if (data != null) {
      printColored("Firebase'den gelen kullanıcı verisi: $data",
          "32"); // Gelen veriyi kontrol et

      setState(() {
        userData = data;
      });
    } else {
      printColored("Kullanıcı verisi bulunamadı veya null döndü!", "32");
    }
  }

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
      _loadProfileImage();
      loadUserData();
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

    // _loadProfileImage();
    // loadUserData();
    // _loadDataFromSisAPI();
  }

  @override
  Widget build(BuildContext context) {
    //aşağıdaki değişkenleri sizedbox larda her cihaza uygun olması için kullanacağız.
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
                  userData != null ? userData!['name'] ?? "İsim yok" : "",
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w500),
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
                  child: isLoading
                      ? const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : imageUrl != null && imageUrl!.isNotEmpty
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(imageUrl!),
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
        child: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
            Color.fromARGB(255, 255, 255, 255),
            Color.fromARGB(255, 39, 113, 148),
            Color.fromARGB(255, 255, 255, 255),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
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

Future<Map<String, dynamic>?> getUserData() async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final String? email = auth.currentUser?.email;

  String term;
  final m = DateTime.now().month;
  if (m == 9 || m == 10 || m == 11 || m == 12 || m == 1) {
    term = "GÜZ";
  } else if (m == 2 || m == 3 || m == 4 || m == 5) {
    term = "BAHAR";
  } else {
    term = "YAZ";
  }

  if (email == null) {
    return null; // Kullanıcı giriş yapmamış
  }

  try {
    // Kullanıcıyı e-posta ile Firestore'da bul
    final QuerySnapshot userQuery = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (userQuery.docs.isNotEmpty) {
      final Map<String, dynamic> userData =
          userQuery.docs.first.data() as Map<String, dynamic>;

      return {
        'name': userData['Name'] ?? '',
        'surname': userData['Surname'] ?? '',
        'email': userData['email'] ?? '',
        'image_url': userData['image_url'] ?? '',
        'student_id': userData['student_id'] ?? '',
        'username': userData['username'] ?? '',
        // 'lessonsList': userData[DateTime.now().year.toString()][term] ?? '',
      };
    }
  } catch (e) {
    print("Firestore'dan kullanıcı bilgileri alınırken hata oluştu: $e");
  }

  return null; // Kullanıcı bulunamazsa veya hata olursa
}

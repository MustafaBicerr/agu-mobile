import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home_page/LessonAdd.dart';
import 'package:home_page/LessonsFromFirebase.dart';
import 'package:home_page/auth.dart';
import 'package:home_page/buttons/buttons.dart';
import 'package:home_page/eventsCard.dart';
import 'package:home_page/news.dart';
import 'package:home_page/profileMenuWidget.dart';
import 'package:home_page/screens/TimeTableDetail.dart';
import 'package:home_page/screens/add_class_screen.dart';
import 'package:home_page/screens/attendance.dart';
import 'package:home_page/bottom.dart';
import 'package:home_page/screens/refectory.dart';
import 'package:home_page/utilts/services/apiService.dart';
import 'package:home_page/utilts/services/dbHelper.dart';
import 'package:home_page/utilts/models/lesson.dart';
import 'package:home_page/lessonDetail.dart';
import 'package:home_page/screens/menu.dart';
import 'package:home_page/methods.dart';
import 'package:home_page/notifications.dart';
import 'package:home_page/upcomingLesson.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';
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

  Future<void> requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      print("Depolama izni verildi.");
    } else {
      print("Depolama izni reddedildi.");
    }
  }

  // Uygulamanın tam ekran modunda çalışması
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Yalnızca dikey mod
    DeviceOrientation.portraitDown,
  ]);

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false, // İsteğe bağlı: Debug yazısını kaldırır
    home: const AuthScreen(), // Başlangıç ekranı
    initialRoute: '/',
    routes: {
      '/login': (context) => MyApp(
            notificationService: NotificationService(),
          ),
      '/AddClass': (context) =>
          AddClassScreen(), // Ders ekleme sayfasını buraya ekliyoruz// Ana ekran (MyHomePage)
    }, // Ana ekran
  ));
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

  @override
  void initState() {
    final istanbul = tz.getLocation('Europe/Istanbul');
    final now = tz.TZDateTime.now(istanbul);

    methods.printColored("Şu Anki Saat (Istanbul): $now", "31");

    super.initState();
    lessons = []; // Başlangıçta boş liste
    getLessons(); // Dersleri yükle
    getDailyLesson();
    Future.delayed(Duration.zero, () async {
      await requestNotificationPermission(context);
    });

    _loadProfileImage();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Color.fromARGB(255, 255, 255, 255),
          Color.fromARGB(255, 39, 113, 148),
          Color.fromARGB(255, 255, 255, 255),
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: TimeTable_Card(),
              //child: UpcomingLessonWidget(),
            ),
            //const SizedBox(height: 50),
            RefectoryCard(fetchMeals: mealApi.fetchMeals),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: EventsCard(),
            ),
            const SizedBox(
              height: 30,
            ),
            Expanded(
              child: Buttons(),
            )
          ],
        ),
      ),
      bottomNavigationBar: bottomBar2(context, 2), // Alt gezinme çubuğu
    );
  }

  // ignore: non_constant_identifier_names
  Widget TimeTable_Card() {
    if (lessons == null || lessons!.isEmpty) {
      return ListView(
        children: [
          Container(
            // decoration: const BoxDecoration(
            //     gradient: LinearGradient(colors: [
            //   Color.fromARGB(255, 255, 255, 255),
            //   Color.fromARGB(255, 39, 113, 148),

            //   //Colors.white,
            // ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: Card(
              color: Colors.transparent,
              elevation: 0,
              child: ListTile(
                title: const Text("Ders Kaydı Bulunamadı"),
                subtitle:
                    const Text("Ders Programınızı Eklemek İçin Tıklayınız"),
                onTap: () {
                  goToLessonAdd();
                },
              ),
            ),
          ),
        ],
      );
    }

    // Sıradaki dersi bul
    Lesson? nextLesson = findUpcomingLesson(lessons!);

    return ListView(
      children: [
        ShowUpcomingLesson(lesson: nextLesson),
      ],
    );
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
          context, MaterialPageRoute(builder: (context) => Timetabledetail()));
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
      };
    }
  } catch (e) {
    print("Firestore'dan kullanıcı bilgileri alınırken hata oluştu: $e");
  }

  return null; // Kullanıcı bulunamazsa veya hata olursa
}

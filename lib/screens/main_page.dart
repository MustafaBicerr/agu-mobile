import 'package:flutter/material.dart';
import 'package:home_page/bottom.dart';
import 'package:home_page/buttons/buttons.dart';
import 'package:home_page/lesson_add_page.dart';
import 'package:home_page/methods.dart';
import 'package:home_page/models/lesson.dart';
import 'package:home_page/notifications.dart';
import 'package:home_page/profileMenuWidget.dart';
import 'package:home_page/screens/events/eventsCard.dart';
import 'package:home_page/screens/menu_page.dart' hide methods;
import 'package:home_page/screens/refectory.dart';
import 'package:home_page/services/dbHelper.dart';
import 'package:home_page/services/user_service.dart';
import 'package:home_page/upcomingLesson.dart';
import 'package:home_page/utilts/constants/image_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  
  get notificationService => null;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final int _selectedIndex = 2;
   // Varsayılan olarak Anasayfa seçili
  final Dbhelper dbHelper = Dbhelper(); // Veritabanı yardımıcısı
  List<Lesson>? lessons; // Ders listesi
  int lessonCount = 0; // Ders sayısı


  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    UserService userService = UserService();

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
            ImageConstants.aguLogo,
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
                  userService.userData != null ? userService.userData !['name'] ?? "İsim yok" : "",
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
                  child: userService.isLoading
                      ? const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : userService.imageUrl != null && userService.imageUrl!.isNotEmpty
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(userService.imageUrl!),
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
                SizedBox(height: screenHeight * 0.20, child: TimeTableCard()),
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
  /////////////////////////////////////////////////////////
    Widget TimeTableCard() {
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
  
    void goToLessonAdd() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LessonAddPage()),
    );

    if (result != null && result == true) {
        // getLessons();  
    }
  }




}


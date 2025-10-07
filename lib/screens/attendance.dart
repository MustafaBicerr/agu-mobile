import 'package:flutter/material.dart';
import 'package:home_page/bottom.dart';
import 'package:home_page/notifications.dart';
import 'package:home_page/utilts/services/dbHelper.dart';
import 'package:home_page/utilts/models/lesson.dart';
import 'package:sqflite/sqflite.dart';

class DailyAttendanceScreen extends StatefulWidget {
  @override
  DailyAttendanceScreenState createState() => DailyAttendanceScreenState();
}

class DailyAttendanceScreenState extends State<DailyAttendanceScreen> {
  final dbHelper = Dbhelper();
  List<Lesson> dailyLessons = [];
  String currentDay = "";

  void resetWeeklyAttendance() async {
    DateTime now = DateTime.now();
    if (now.weekday == DateTime.sunday) {
      // Eğer bugün Pazartesi ise
      Database db = await dbHelper.db;
      await db.rawUpdate("UPDATE lessons SET isProcessed = 0");
    }
  }

  @override
  void initState() {
    super.initState();
    resetWeeklyAttendance(); // Haftalık sıfırlamayı kontrol et
    getDailyLessons(); // Günlük dersleri yükle
  }

  // Günlük dersleri getir
  void getDailyLessons() async {
    String today = methods.getDayName();
    var allLessons = await dbHelper.getLessons();
    setState(() {
      currentDay = today;
      dailyLessons = allLessons
          .where((lesson) => lesson.day == today && lesson.isProcessed == 0)
          .toList();
    });
  }

  // Attendance güncelle ve dersi listeden kaldır
  void handleAttendance(Lesson lesson, bool attended) async {
    lesson.isProcessed = 1;
    int hourCount = 1;

    if (!attended) {
      // Saat sayısını belirle
      hourCount = 1;
      if (lesson.hour2 != null && lesson.hour2!.isNotEmpty) hourCount++;
      if (lesson.hour3 != null && lesson.hour3!.isNotEmpty) hourCount++;

      await dbHelper.incrementAttendanceByCount(lesson.name!, hourCount);

      int updatedAttendance =
          await dbHelper.getAttendanceByLessonName(lesson.name!);
      lesson.attendance = updatedAttendance;
    }

    await dbHelper.update(lesson);

    setState(() {
      dailyLessons.remove(lesson);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          attended
              ? "✅ ${lesson.name!.toUpperCase()} dersine katıldınız."
              : "❌ ${lesson.name!.toUpperCase()} dersine katılmadınız. Devamsızlık +$hourCount",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      bottomNavigationBar: bottomBar2(context, 4), // Alt gezinme çubuğu

      appBar: AppBar(
        leadingWidth: 0,
        leading: Container(),
        title: Text(
          "Günlük Devamsızlık Kontrolü",
          style: TextStyle(fontSize: screenWidth * 0.06),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Color.fromARGB(255, 255, 255, 255),
          Color.fromARGB(255, 39, 113, 148),
          Color.fromARGB(255, 255, 255, 255),
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: dailyLessons.isEmpty
            ? Center(
                child: Text(
                  "Bugün ($currentDay) için ders bulunamadı.",
                  style: const TextStyle(
                      fontSize: 18, color: Color.fromARGB(255, 255, 255, 255)),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12.0),
                itemCount: dailyLessons.length,
                itemBuilder: (context, index) {
                  final lesson = dailyLessons[index];
                  return buildLessonCard(lesson);
                },
              ),
      ),
    );
  }

  Widget buildLessonCard(Lesson lesson) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.book, color: Colors.blueAccent, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lesson.name!.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    lesson.hour1?.substring(0, 5) ?? "",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Saatler: ${lesson.hour1 ?? ""} / ${lesson.hour2 ?? ""} / ${lesson.hour3 ?? ""}",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Öğretmen: ${lesson.teacher ?? "Öğretmen bilgisi yok"}",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              "Sınıf: ${lesson.place ?? "Sınıf bilgisi yok"}",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    handleAttendance(lesson, true);
                  },
                  icon: const Icon(Icons.check, size: 18, color: Colors.white),
                  label: const Text(
                    "Katıldım",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    handleAttendance(lesson, false);
                  },
                  icon: const Icon(Icons.close, size: 18, color: Colors.white),
                  label: const Text(
                    "Katılmadım",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

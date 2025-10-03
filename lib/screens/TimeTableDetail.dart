import 'package:flutter/material.dart';

import 'package:home_page/LessonAdd.dart';
import 'package:home_page/bottom.dart';
import 'package:home_page/screens/sisAddLessonsPage.dart';

import 'package:home_page/screens/sis_webview_login.dart';

import 'package:home_page/utilts/services/dbHelper.dart';
import 'package:home_page/utilts/models/lesson.dart';
import 'package:home_page/lessonDetail.dart';
import 'package:home_page/methods.dart';

Methods methods = Methods();

// ignore: must_be_immutable
class Timetabledetail extends StatefulWidget {
  Lesson? lesson;
  Timetabledetail.full(this.lesson, {super.key});
  Timetabledetail();
  @override
  State<Timetabledetail> createState() => _TimetabledetailState();
}

class _TimetabledetailState extends State<Timetabledetail> {
  List<Lesson>? lessons;
  var dbHelper = Dbhelper();

  final List<String> days = [
    "Pazartesi",
    "Salı",
    "Çarşamba",
    "Perşembe",
    "Cuma",
    "Cumartesi",
    "Pazar"
  ];

  @override
  void initState() {
    super.initState();
    getLessons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomBar2(context, 0), // Alt gezinme çubuğu

      appBar: AppBar(
        leading: Container(),
        title: const Text(
          "Ders Programı",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            offset: const Offset(0, 40),
            shadowColor: Colors.black,
            iconColor: Colors.black,
            color: Colors.white,
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == "delete") {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Uyarı",
                          style: TextStyle(color: Colors.red)),
                      backgroundColor: Colors.blueGrey[900],
                      content: const Text(
                          "Dersleri gerçekten silmek istediğinize emin misiniz?",
                          style: TextStyle(color: Colors.white)),
                      actions: [
                        TextButton(
                            onPressed: Navigator.of(context).pop,
                            child: const Text("Hayır",
                                style: TextStyle(color: Colors.green))),
                        TextButton(
                          child: const Text("Evet",
                              style: TextStyle(color: Colors.red)),
                          onPressed: () {
                            dbHelper.deleteDatabaseFile();
                            Navigator.pop(context);

                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.blueGrey[900],
                                    title: const Text(
                                      "Bilgilendirme",
                                      style: TextStyle(color: Colors.amber),
                                    ),
                                    content: const Text(
                                        "Tüm dersler silindi. Ders eklemek için sağ alt köşedeki '+' butonuna basabilirsiniz.",
                                        style: TextStyle(color: Colors.white)),
                                    actions: [
                                      TextButton(
                                        child: const Text(
                                          "Tamam",
                                          style: TextStyle(color: Colors.green),
                                        ),
                                        onPressed: () => methods.navigateToPage(
                                            context, Timetabledetail()),
                                      ),
                                    ],
                                  );
                                });
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: "delete", child: Text("Dersleri Sil"))
            ],
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Color.fromARGB(255, 255, 255, 255),
          Color.fromARGB(255, 39, 113, 148),
          Color.fromARGB(255, 255, 255, 255),
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: lessons == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : lessons!.isEmpty
                ? const Center(
                    child: Text(
                      "Henüz ders eklenmedi.",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: days.length,
                    itemBuilder: (context, index) {
                      final day = days[index];
                      final dailyLessons = lessons!
                          .where((lesson) => lesson.day == day)
                          .toList();

                      return buildDayCard(day, dailyLessons);
                    },
                  ),
      ),
      floatingActionButton: Builder(
        builder: (fabContext) {
          return FloatingActionButton(
            onPressed: () {
              final RenderBox button =
                  fabContext.findRenderObject() as RenderBox;
              final position = button.localToGlobal(Offset(65, -135));
              _showFabMenu(fabContext, position);
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.lightBlueAccent[400],
          );
        },
      ),
    );
  }

  void _showFabMenu(BuildContext context, Offset position) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx, position.dy - 25, overlay.size.width - position.dx, 0),
      // position: RelativeRect.fromRect(
      //   Rect.fromPoints(position, position),
      //   Offset.zero & overlay.size,
      // ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      items: [
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.cloud_download, color: Colors.blue),
            title: const Text("SİS'ten Otomatik Çek",
                style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text(
              "Bölümdekiler için tavsiye edilir.",
              style: TextStyle(fontSize: 12),
            ),
            onTap: () {
              showInfoDialog(context);
            },
          ),
        ),
        // const PopupMenuItem(
        //     child: Divider(
        //   height: 0.5,
        // )),
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.edit_note, color: Colors.green),
            title: const Text(
              'Manuel Ekle',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: const Text(
              "Hazırlıktakiler için tavsiye edilir.",
              style: TextStyle(fontSize: 12),
            ),
            onTap: () {
              methods.navigateToPage(context, LessonAdd());
            },
          ),
        ),
      ],
    );
  }

  Widget buildDayCard(String day, List<Lesson> dailyLessons) {
    if (dailyLessons.isEmpty) return const SizedBox();

    dailyLessons.sort(compareLessonsByHour);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.black),
                  const SizedBox(width: 8),
                  Text(
                    day,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dailyLessons.length,
                itemBuilder: (context, index) {
                  final lesson = dailyLessons[index];
                  return buildLessonCard(lesson);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLessonCard(Lesson lesson) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: () {
          goToDetail(lesson);
        },
        child: Card(
          color: const Color.fromARGB(175, 0, 174, 254),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            width: 250,
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.menu_book, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lesson.name ?? "Ders Adı Yok",
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lesson.teacher ?? "Öğretmen adı yok",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      lesson.place ?? "Yer Yok",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.access_time, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson.hour1 ?? "Saat Yok",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          if (lesson.hour2 != null && lesson.hour2!.isNotEmpty)
                            Text(
                              lesson.hour2!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.remove, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      "Devamsızlık = ${lesson.attendance}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void goToLessonAdd() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LessonAdd()),
    );
    if (!mounted) return;
    if (result == true) {
      getLessons();
    }
  }

  void getLessons() async {
    var data = await dbHelper.getLessons();
    if (!mounted) return;
    setState(() {
      lessons = data;
    });
  }

  void goToDetail(Lesson lesson) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LessonDetail(lesson: lesson)),
    );
    if (!mounted) return;

    if (result != null && result == true) {
      getLessons();
    }
  }

  int compareLessonsByHour(Lesson a, Lesson b) {
    String hourA = a.hour1 ?? "00:00";
    String hourB = b.hour1 ?? "00:00";

    return hourA.compareTo(hourB);
  }
}

void showInfoDialog(BuildContext context) {
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.blueGrey[900],
        title:
            const Text("Bilgilendirme", style: TextStyle(color: Colors.amber)),
        content: const Text(
          "Sis e giriş yaptıktan sonra, 'Genel İşlemler' menüsünden 'Ders Programı' sekmesine gitmeniz gerekmektedir.\n\nDers Programı sekmesine gittiğinizde sağ üstteki kaydet butonuna basınız.",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            child: const Text(
              "Vazgeç",
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text(
              "Sis'e Git",
              style: TextStyle(color: Colors.green),
            ),
            onPressed: () =>
                methods.navigateToPage(context, SisWebViewFullscreen()),
          ),
        ],
      );
    },
  );
}

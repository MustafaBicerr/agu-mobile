import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home_page/notifications.dart';
import 'package:home_page/models/lesson.dart';

class sisWeeklyProgram extends StatefulWidget {
  const sisWeeklyProgram({super.key});

  @override
  State<sisWeeklyProgram> createState() => _sisWeeklyProgramState();
}

class _sisWeeklyProgramState extends State<sisWeeklyProgram> {
  String? username;
  String email = FirebaseAuth.instance.currentUser?.email ?? "";
  DateTime now = DateTime.now();
  String year = DateTime.now().year.toString();
  String month = DateTime.now().month.toString();
  String term = "";

  // Haftalık dersleri Firestore'dan çekme
  Future<void> _fetchClasses() async {
    switch (DateTime.now().month) {
      case (9 || 10 || 11 || 12 || 1):
        term = "GÜZ";
      case (2 || 3 || 4 || 5):
        term = "BAHAR";
      case (6 || 7 || 8):
        term = "YAZ";
    }

    if (email.isNotEmpty) {
      var userDoc = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: email)
          .get();

      if (userDoc.docs.isNotEmpty) {
        setState(() {
          username = userDoc.docs.first.id;
        });
      }
    }
    if (username == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(username)
        .collection("classes")
        .doc(year)
        .get();

    final data = snapshot.data() as Map<String, dynamic>?;

// term altındaki map (ör: "YAZ")
    final Map<String, dynamic> termMap =
        (data?[term] as Map<String, dynamic>?) ?? {};

// Her ders kodu için dön (ör: "ARCG303(01)")
    for (final MapEntry<String, dynamic> e in termMap.entries) {
      final String code = e.key; // "ARCG303(01)"
      final Map<String, dynamic> lesson = (e.value as Map<String, dynamic>);

      // Alan adlarını Firestore’daki ile EŞLEŞTİR
      final int absenceFromUser = (lesson['absence_from_user'] ?? 0) as int;
      final int totalAbsence = (lesson['total_absence'] ?? 0) as int;

      // attendance_list: Map<String, bool>
      final Map<String, bool> attendanceList =
          ((lesson['attendance_list'] as Map<String, dynamic>?) ?? {})
              .map((k, v) => MapEntry(k, v as bool));

      printColored(
        'code: $code  total_absence: $totalAbsence  absence_from_user: $absenceFromUser  attendance_count: ${attendanceList.length}',
        '32',
      );
    }

    // for (var entry in schedule) {
    //   String day = entry["day"];
    //   tempGroupedClasses.putIfAbsent(day, () => []).add({
    //     "name": data["name"],
    //     "location": data["location"],
    //     "start": entry["start"],
    //     "end": entry["end"],
    //     "total_absence": data["total_absence"] ?? 0, // Devamsızlık bilgisi
    //     "id": doc.id, // Dersin ID'si
    //   });
    // }

    setState(() {
      // groupedClasses = tempGroupedClasses; // Haftalık dersleri alıyoruz
      // isLoading = false; // Veriler yüklendiğinde loading'i kapatıyoruz
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchClasses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text("Firebase den alınan veriler: "),
      ),
    );
  }
}

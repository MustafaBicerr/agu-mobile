import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home_page/bottom.dart'; // Örnek BottomBar

class ClassScheduleScreen extends StatefulWidget {
  @override
  _ClassScheduleScreenState createState() => _ClassScheduleScreenState();
}

class _ClassScheduleScreenState extends State<ClassScheduleScreen> {
  String? username;
  bool isLoading = true;
  Map<String, List<Map<String, dynamic>>> groupedClasses =
      {}; // Haftalık dersler

  bool isMerged =
      false; // Derslerin bir kez merge edilip edilmediğini kontrol etmek için
  Map<String, bool> isMergedPerDay =
      {}; // Her gün için merge durumunu tutacak bir harita

  final List<String> daysOfWeek = [
    "Pazartesi",
    "Salı",
    "Çarşamba",
    "Perşembe",
    "Cuma",
    "Cumartesi",
    "Pazar"
  ]; // Günlerin sıralandığı liste

  // Bugünün hangi gün olduğunu hesaplıyoruz
  String get today => daysOfWeek[DateTime.now().weekday - 1];

  @override
  void initState() {
    super.initState();
    _getUsername();
  }

  // Kullanıcının adını almak için email üzerinden Firestore'dan çekme
  Future<void> _getUsername() async {
    String email = FirebaseAuth.instance.currentUser?.email ?? "";
    if (email.isNotEmpty) {
      var userDoc = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: email)
          .get();

      if (userDoc.docs.isNotEmpty) {
        setState(() {
          username = userDoc.docs.first.id;
        });
        _fetchClasses();
      }
    }
  }

  // Haftalık dersleri Firestore'dan çekme
  Future<void> _fetchClasses() async {
    if (username == null) return;

    var snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(username)
        .collection("classes")
        .get();

    Map<String, List<Map<String, dynamic>>> tempGroupedClasses = {};

    for (var doc in snapshot.docs) {
      var data = doc.data();
      List<dynamic> schedule = data["schedule"] ?? [];

      for (var entry in schedule) {
        String day = entry["day"];
        tempGroupedClasses.putIfAbsent(day, () => []).add({
          "name": data["name"],
          "location": data["location"],
          "start": entry["start"],
          "end": entry["end"],
          "total_absence": data["total_absence"] ?? 0, // Devamsızlık bilgisi
          "id": doc.id, // Dersin ID'si
        });
      }
    }

    setState(() {
      groupedClasses = tempGroupedClasses; // Haftalık dersleri alıyoruz
      isLoading = false; // Veriler yüklendiğinde loading'i kapatıyoruz
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomBar2(context, 1),
      appBar: AppBar(
        title: Text("Haftalık Ders Programı"),
        backgroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 39, 113, 148),
              Color.fromARGB(255, 255, 255, 255),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: daysOfWeek.length,
                itemBuilder: (context, index) {
                  String day = daysOfWeek[index];
                  var dayClasses = groupedClasses[day] ?? [];
                  dayClasses.sort((a, b) => a["start"].compareTo(b["start"]));

                  // Group by subject name
                  Map<String, List<Map<String, dynamic>>> subjectGroups = {};
                  for (var classData in dayClasses) {
                    String subject = classData["name"];
                    subjectGroups.putIfAbsent(subject, () => []).add(classData);
                  }

                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: day == today ? Colors.white : Colors.white,
                            borderRadius: BorderRadius.circular(17),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_today),
                                  const SizedBox(width: 12),
                                  Text(
                                    day,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: day == today
                                          ? Colors.black
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              dayClasses.isEmpty
                                  ? Center(
                                      child: Text(
                                        "$day günü için dersiniz yok",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    )
                                  : Container(
                                      height: 200,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: subjectGroups.length,
                                        itemBuilder: (context, subjectIndex) {
                                          String subject = subjectGroups.keys
                                              .elementAt(subjectIndex);
                                          var classes =
                                              subjectGroups[subject] ?? [];

                                          return Card(
                                            color: const Color.fromARGB(
                                                175, 0, 174, 254),
                                            elevation: 4,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                          Icons.menu_book,
                                                          color: Colors.white),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        subject,
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  // Display only times
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      ...classes
                                                          .map((classData) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 5.0),
                                                          child: Row(
                                                            children: [
                                                              const Icon(
                                                                  Icons
                                                                      .access_time_outlined,
                                                                  color: Colors
                                                                      .white),
                                                              const SizedBox(
                                                                  width: 8),
                                                              Text(
                                                                "${classData["start"]} - ${classData["end"]}",
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            14),
                                                              ),
                                                              const SizedBox(
                                                                width: 65,
                                                              )
                                                            ],
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                          Icons
                                                              .person_remove_alt_1_rounded,
                                                          color: Colors.white),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        "Devamsızlık: ${classes[0]["total_absence"]}",
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.pushNamed(context, '/AddClass');
        },
        child: const Icon(Icons.add, color: Colors.blue),
      ),
    );
  }
}

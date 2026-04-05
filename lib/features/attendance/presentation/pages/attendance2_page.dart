import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatefulWidget {
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String? username;
  bool isLoading = true;
  Map<String, List<Map<String, dynamic>>> groupedClasses =
      {}; // Haftalık dersler

  final List<String> daysOfWeek = [
    "Pazartesi",
    "Salı",
    "Çarşamba",
    "Perşembe",
    "Cuma",
    "Cumartesi",
    "Pazar"
  ]; // Günlerin sıralandığı liste

  String? today; // Bugünün adı (Pazartesi, Salı, vb.)

  @override
  void initState() {
    super.initState();
    _getUsername();
    _getToday(); // Bugün hangi gün olduğunu belirliyoruz
  }

  // Bugünün hangi gün olduğunu alıyoruz
  void _getToday() {
    DateTime now = DateTime.now();
    today = _getDayOfWeek(now.weekday);
    print(
        "Today: $today"); // Debugging: 'today' değişkeninin doğru olduğunu kontrol et
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
        _fetchClasses(); // Veri çekmek için _fetchClasses() fonksiyonunu çağırıyoruz.
      }
    }
  }

  // Bugünün derslerini Firestore'dan çekme
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

      print("Schedule: $schedule"); // Debugging: 'schedule' verisini kontrol et

      for (var entry in schedule) {
        String day = entry["day"];
        print(
            "Day from Firestore: $day"); // Debugging: 'day' değerini kontrol et

        // Bugünün tarihi
        String currentDate = DateFormat('dd.MM.yyyy').format(DateTime.now());
        print(
            "Current Date: $currentDate"); // Debugging: 'currentDate' değerini kontrol et

        // isSelect kontrolü ve günün dersini kontrol et
        if (entry["isSelect"] != null) {
          if (entry["isSelect"].containsKey(currentDate)) {
            print(
                "isSelect[$currentDate]: ${entry["isSelect"][currentDate]}"); // Debugging: isSelect[currentDate] değerini kontrol et

            if (entry["isSelect"][currentDate] == false && day == today) {
              tempGroupedClasses.putIfAbsent(day, () => []).add({
                "name": data["name"],
                "location": data["location"],
                "start": entry["start"],
                "end": entry["end"],
                "total_absence":
                    data["total_absence"] ?? 0, // Devamsızlık bilgisi
                "id": doc.id, // Dersin ID'si
                "start_time": entry[
                    "start"], // Her saatin bağımsız işlenmesi için start_time ekliyoruz
              });
            }
          } else {
            print(
                "isSelect does not contain currentDate: $currentDate, skipping this entry");
          }
        } else {
          print("isSelect is null for this entry, skipping...");
        }
      }
    }

    print(
        "Grouped Classes: $tempGroupedClasses"); // Debugging: groupedClasses'in içeriğini kontrol et

    setState(() {
      groupedClasses = tempGroupedClasses; // Verileri güncelle
      isLoading = false; // Veriler yüklendiğinde loading'i kapatıyoruz
    });
  }

  // Haftanın gününe göre ismi döndüren yardımcı fonksiyon
  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return "Pazartesi";
      case 2:
        return "Salı";
      case 3:
        return "Çarşamba";
      case 4:
        return "Perşembe";
      case 5:
        return "Cuma";
      case 6:
        return "Cumartesi";
      case 7:
        return "Pazar";
      default:
        return "";
    }
  }

  // Katılım bilgisi güncellenirken, dersin görünmemesini sağlamak
  Future<void> _markAttendance(String classId, String startTime) async {
    var classDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(username)
        .collection("classes")
        .doc(classId)
        .get();

    List<dynamic> schedule = classDoc["schedule"] ?? [];

    // Bugünün tarihi ile isSelect değerini güncellemek için
    String currentDate = DateFormat('dd.MM.yyyy').format(DateTime.now());

    // Bu dersin schedule'ındaki her entry için isSelect'i güncelliyoruz
    for (var entry in schedule) {
      if (entry["start"] == startTime) {
        // isSelect map'inde ilgili tarihi bulup güncelliyoruz
        entry["isSelect"][currentDate] = true;

        // 7 gün sonraki tarihi hesaplıyoruz
        DateTime nextWeek = DateTime.now().add(Duration(days: 7));
        String nextDate = DateFormat('dd.MM.yyyy').format(nextWeek);

        // 7 gün sonraki tarihe ait yeni bir boolean ekliyoruz
        entry["isSelect"][nextDate] = false;

        // Firestore'da güncellemeyi yapıyoruz
        await FirebaseFirestore.instance
            .collection("users")
            .doc(username)
            .collection("classes")
            .doc(classId)
            .update({
          "schedule": schedule, // schedule'ı doğrudan güncelliyoruz
        });

        // Bu dersi listeden kaldırıyoruz
        setState(() {
          groupedClasses[today]
              ?.removeWhere((element) => element['start_time'] == startTime);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Katıldınız!")),
        );
      }
    }
  }

// Devamsızlık sayısını artırma
  Future<void> _markAbsence(String classId, String startTime) async {
    var classDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(username)
        .collection("classes")
        .doc(classId)
        .get();

    List<dynamic> schedule = classDoc["schedule"] ?? [];

    // Bugünün tarihi ile isSelect değerini güncellemek için
    String currentDate = DateFormat('dd.MM.yyyy').format(DateTime.now());

    // Bu dersin schedule'ındaki her entry için isSelect'i güncelliyoruz
    for (var entry in schedule) {
      if (entry["start"] == startTime) {
        // isSelect map'inde ilgili tarihi bulup güncelliyoruz
        entry["isSelect"][currentDate] = true;

        // 7 gün sonraki tarihi hesaplıyoruz
        DateTime nextWeek = DateTime.now().add(Duration(days: 7));
        String nextDate = DateFormat('dd.MM.yyyy').format(nextWeek);

        // 7 gün sonraki tarihe ait yeni bir boolean ekliyoruz
        entry["isSelect"][nextDate] = false;

        // Devamsızlık sayısını artırıyoruz
        int currentAbsence = classDoc["total_absence"] ?? 0;
        await FirebaseFirestore.instance
            .collection("users")
            .doc(username)
            .collection("classes")
            .doc(classId)
            .update({
          "total_absence":
              currentAbsence + 1, // Devamsızlık sayısını 1 arttırıyoruz
          "schedule": schedule, // schedule'ı güncelliyoruz
        });

        // Bu dersi listeden kaldırıyoruz
        setState(() {
          groupedClasses[today]
              ?.removeWhere((element) => element['start_time'] == startTime);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Devamsızlık sayınız 1 arttırıldı!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Günlük Devamsızlık Kontrolü")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : groupedClasses[today] == null || groupedClasses[today]!.isEmpty
              ? Center(child: Text("Bugün için ders bulunamadı"))
              : ListView.builder(
                  itemCount: groupedClasses[today]!.length,
                  itemBuilder: (context, index) {
                    var classData = groupedClasses[today]![index];

                    String currentDate =
                        DateFormat('dd.MM.yyyy').format(DateTime.now());

                    bool isListed = true;

                    // schedule null değilse, içindeki her entry'yi kontrol et
                    if (classData["schedule"] != null) {
                      for (var entry in classData["schedule"]) {
                        if (entry["isSelect"] != null &&
                            entry["isSelect"].containsKey(currentDate) &&
                            entry["isSelect"][currentDate] == true) {
                          isListed = false;
                          break;
                        }
                      }
                    }

                    if (!isListed) {
                      return Container();
                    }

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              classData["name"],
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              classData["location"],
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "${classData["start"]} - ${classData["end"]}",
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Devamsızlık: ${classData["total_absence"]}",
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _markAbsence(
                                      classData["id"], classData["start_time"]),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.red),
                                  ),
                                  child: const Text("Katılmadım"),
                                ),
                                ElevatedButton(
                                  onPressed: () => _markAttendance(
                                      classData["id"], classData["start_time"]),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.green),
                                  ),
                                  child: const Text("Katıldım"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

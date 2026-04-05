import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AddClassScreen extends StatefulWidget {
  @override
  _AddClassScreenState createState() => _AddClassScreenState();
}
//yunu
class _AddClassScreenState extends State<AddClassScreen> {
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? username;
  bool isLoading = true;
  Map<String, List<Map<String, dynamic>>> groupedClasses =
      {}; // Haftalık dersler

  List<Map<String, dynamic>> scheduleList = []; // Seçilen gün ve saatler
  String? selectedDay; // Kullanıcının seçtiği gün
  List<String> selectedHours = [];

  final List<String> days = [
    "Pazartesi",
    "Salı",
    "Çarşamba",
    "Perşembe",
    "Cuma",
    "Cumartesi",
    "Pazar"
  ];

  final List<String> hours = [
    "08.00 - 08.45",
    "09.00 - 09.45",
    "10.00 - 10.45",
    "11.00 - 11.45",
    "12.00 - 12.45",
    "13.00 - 13.45",
    "14.00 - 14.45",
    "15.00 - 15.45",
    "16.00 - 16.45",
    "17.00 - 17.45",
    "18.00 - 18.45",
    "19.00 - 19.45"
  ];

// Ders ekleme sırasında selectedDay değerinin boş olmaması gerektiğini kontrol ediyoruz
  void _addDayToSchedule() {
    if (selectedDay != null && selectedHours.isNotEmpty) {
      setState(() {
        scheduleList.add({
          "day": selectedDay!, // Seçilen gün
          "hours": List<String>.from(selectedHours), // Seçilen saatler
        });
        //selectedDay = null; // Seçilen günü sıfırlıyoruz
        selectedHours = []; // Seçilen saatleri sıfırlıyoruz
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lütfen bir gün ve saat seçin")));
    }
  }

  // Kullanıcının seçtiği günü ve bugünü karşılaştırarak doğru tarihi hesaplamak
  String _getDateForSelectedDay(String selectedDay) {
    DateTime now = DateTime.now();

    // Günün sırasını almak
    int weekday = now.weekday; // Bugünün günü (1=Monday, 7=Sunday)

    // Seçilen günün sırasını almak (Pazartesi = 1, Salı = 2, ...)
    int targetDay = _getWeekdayNumber(selectedDay);

    // Eğer seçilen gün bugünün tarihiyle aynıysa, o zaman direkt bugünün tarihini kullanıyoruz
    if (targetDay == weekday) {
      return DateFormat('dd.MM.yyyy').format(now); // Bugünün tarihi
    }

    // Eğer seçilen gün bugünden sonra bir günse, o zaman bu haftadaki o günü kullanacağız
    int difference = targetDay - weekday;
    if (difference <= 0) {
      difference += 7; // Eğer seçilen gün geçtiyse, bir hafta ekliyoruz
    }

    // Hedef tarihimizi hesaplıyoruz
    DateTime targetDate = now.add(Duration(days: difference));
    return DateFormat('dd.MM.yyyy')
        .format(targetDate); // Tarihi formatlayarak döndürüyoruz
  }

  // Haftanın gününü sayı ile döndüren fonksiyon
  int _getWeekdayNumber(String day) {
    switch (day) {
      case 'Pazartesi':
        return 1;
      case 'Salı':
        return 2;
      case 'Çarşamba':
        return 3;
      case 'Perşembe':
        return 4;
      case 'Cuma':
        return 5;
      case 'Cumartesi':
        return 6;
      case 'Pazar':
        return 7;
      default:
        return 1;
    }
  }

  Future<void> _saveClassToFirestore() async {
    String email = FirebaseAuth.instance.currentUser?.email ?? "";
    if (email.isEmpty || scheduleList.isEmpty) return;

    var userDoc = await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: email)
        .get();

    if (userDoc.docs.isNotEmpty) {
      String username = userDoc.docs.first.id;

      List<Map<String, dynamic>> schedule = []; // schedule içerisindeki dersler

      // Kullanıcının seçtiği günü alıyoruz
      if (selectedDay == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Gün seçilmedi")));
        return;
      }

      // Kullanıcıdan alınan bu günü dinamik olarak tarih formatına çeviriyoruz
      String startDate =
          _getDateForSelectedDay(selectedDay!); // Hesapladığımız tarih

      // **Düzeltme:**
      Map<String, dynamic> isSelect = {};
      isSelect[startDate] = false; // Başlangıçta false

      // Schedule'a dersleri ekliyoruz
      for (var entry in scheduleList) {
        String day = entry["day"];
        for (String hour in entry["hours"]) {
          List<String> times = hour.split(" - ");
          schedule.add({
            "day": day,
            "start": times[0],
            "end": times[1],
            "isSelect": isSelect, // schedule'a isSelect ekliyoruz
          });
        }
      }

      // Firestore'a veriyi kaydediyoruz
      await FirebaseFirestore.instance
          .collection("users")
          .doc(username)
          .collection("classes")
          .doc(_classNameController.text)
          .set({
        "name": _classNameController.text,
        "location": _locationController.text,
        "schedule": schedule, // schedule listesine dersleri ekliyoruz
        "total_absence": 0,
      });

      // Veriler kaydedildikten sonra schedule sayfasına git ve yeniden veri al
      Navigator.pop(context); // schedule sayfasına git
      _fetchClasses(); // Veriyi tekrar al ve UI'yı güncelle
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
      appBar: AppBar(title: Text("Ders Ekle")),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Color.fromARGB(255, 255, 255, 255),
          Color.fromARGB(255, 39, 113, 148),
          Color.fromARGB(255, 255, 255, 255),
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _classNameController,
                decoration: InputDecoration(labelText: "Ders Adı"),
              ),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(labelText: "Sınıf"),
              ),
              SizedBox(height: 20),
              Text("Ders Günü ve Saatleri",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              // Seçilen günleri gösteren dinamik alan
              Column(
                children: scheduleList.map((entry) {
                  return Card(
                    color: Colors.blue[100],
                    child: ListTile(
                      title: Text(entry["day"],
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(entry["hours"].join(", ")),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            scheduleList.remove(entry);
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Gün Seçme Menüsü
              DropdownButton<String>(
                hint: Text("Gün Seç"),
                value: selectedDay,
                onChanged: (newValue) {
                  setState(() {
                    selectedDay = newValue;
                    selectedHours = [];
                  });
                },
                items: days.map((day) {
                  return DropdownMenuItem<String>(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
              ),

              SizedBox(height: 10),
              Text("Ders Saatleri Seç",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

              // Ders saatleri için seçim alanı
              Wrap(
                spacing: 8.0,
                children: hours.map((hour) {
                  return ChoiceChip(
                    label: Text(hour),
                    selected: selectedHours.contains(hour),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedHours.add(hour);
                        } else {
                          selectedHours.remove(hour);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              SizedBox(height: 10),
              // Seçimi Onaylama Butonu (Günü ekler)
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _addDayToSchedule,
                    child: Text(
                      "Seçimi Onayla",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(
                    width: 50,
                  ),
                  ElevatedButton(
                    onPressed: _saveClassToFirestore,
                    child: Text("Dersi Kaydet",
                        style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

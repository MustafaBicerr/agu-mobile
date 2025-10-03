import 'package:flutter/material.dart';
import 'package:home_page/utilts/services/dbHelper.dart';
import 'package:home_page/utilts/models/lesson.dart';

class LessonAdd extends StatefulWidget {
  @override
  State<LessonAdd> createState() => _LessonAdd();
}

class _LessonAdd extends State<LessonAdd> {
  String? selectedHour1;
  String? selectedHour2;
  String? selectedDay;
  var dbHelper = Dbhelper();

  TextEditingController txtName = TextEditingController();
  TextEditingController txtClass = TextEditingController();
  TextEditingController txtTeacher = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ders Ekleme"),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          // height: double.infinity,
          decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
            Color.fromARGB(255, 255, 255, 255),
            Color.fromARGB(255, 39, 113, 148),
            Color.fromARGB(255, 255, 255, 255),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    // color: Colors.white70,
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Ders Bilgileri",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                        buildNameField(),
                        buildClassField(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: const Text(
                            "Öğretmen Bilgileri",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                        buildTeacherField(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: const Text(
                            "Ders Günü ve Saatleri",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        buildDayField(),
                        buildHour1Field(),
                        buildHour2Field(),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    buildSaveButton(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNameField() {
    return Padding(
      padding:
          const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0, top: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: "Ders Adı",
          labelStyle: const TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          prefixIcon: const Icon(Icons.book),
        ),
        controller: txtName,
      ),
    );
  }

  Widget buildClassField() {
    return Padding(
      padding: const EdgeInsets.only(
          left: 16.0, right: 16.0, bottom: 16.0, top: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: "Sınıf",
          labelStyle: const TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          prefixIcon: const Icon(Icons.place),
        ),
        controller: txtClass,
      ),
    );
  }

  Widget buildTeacherField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: "Öğretmen Adı",
          labelStyle: const TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          prefixIcon: const Icon(Icons.person),
        ),
        controller: txtTeacher,
      ),
    );
  }

  Widget buildDayField() {
    final List<String> days = [
      "Pazartesi",
      "Salı",
      "Çarşamba",
      "Perşembe",
      "Cuma",
      "Cumartesi",
      "Pazar"
    ];

    return Padding(
      padding:
          const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0, top: 8.0),
      child: DropdownButtonFormField<String>(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        value: selectedDay,
        decoration: InputDecoration(
          labelText: "Gün Seç",
          labelStyle: const TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        items: days
            .map((day) => DropdownMenuItem(
                  value: day,
                  child: Text(day),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            selectedDay = value;
          });
        },
      ),
    );
  }

  Widget buildHourField(
      String label, String? selectedHour, void Function(String?) onChanged) {
    final List<String> hours = [
      "08:00-08:45",
      "09:00-09:45",
      "10:00-10:45",
      "11:00-11:45",
      "12:00-12:45",
      "13:00-13:45",
      "14:00-14:45",
      "15:00-15:45",
      "16:00-16:45",
      "17:00-17:45",
      "18:00-18:45",
      "19:00-19:45",
    ];

    return Padding(
      padding:
          const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0, top: 8.0),
      child: DropdownButtonFormField<String>(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        value: selectedHour,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          prefixIcon: const Icon(Icons.access_time),
        ),
        items: hours
            .map((hour) => DropdownMenuItem(
                  value: hour,
                  child: Text(hour),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget buildHour1Field() {
    return buildHourField("İlk Ders Saatinizi Giriniz", selectedHour1, (value) {
      setState(() {
        selectedHour1 = value;
      });
    });
  }

  Widget buildHour2Field() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: buildHourField("İkinci Ders Saatinizi Giriniz", selectedHour2,
          (value) {
        setState(() {
          selectedHour2 = value;
        });
      }),
    );
  }

  Widget buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton.icon(
          onPressed: addLesson,
          icon: const Icon(
            Icons.save,
            size: 24,
            color: Colors.white,
          ),
          label: const Text("KAYDET",
              style: TextStyle(fontSize: 18, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            // padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
    );
  }

  void addLesson() async {
    if (txtName.text.isEmpty ||
        txtClass.text.isEmpty ||
        selectedDay == null ||
        selectedHour1 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun!")),
      );
      return;
    }

    await dbHelper.insert(
      Lesson(txtName.text, txtClass.text, selectedDay, selectedHour1,
          selectedHour2, txtTeacher.text),
    );
    Navigator.pop(
        context, true); // Ders başarıyla eklendiğinde önceki sayfaya dön
  }
}

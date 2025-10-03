import 'package:flutter/material.dart';
import 'package:home_page/bottom.dart';
import 'package:home_page/screens/TimeTableDetail.dart';
import 'package:home_page/utilts/services/dbHelper.dart';
import 'package:home_page/utilts/models/lesson.dart';

class LessonDetail extends StatefulWidget {
  final Lesson lesson; // Seçilen ders

  LessonDetail({required this.lesson});

  @override
  State<LessonDetail> createState() => _LessonDetailState();
}

class _LessonDetailState extends State<LessonDetail> {
  var dbHelper = Dbhelper();
  TextEditingController txtName = TextEditingController();
  TextEditingController txtClass = TextEditingController();
  TextEditingController txtTeacher = TextEditingController();
  String? selectedDay;
  String? selectedHour1;
  String? selectedHour2;

  @override
  void initState() {
    super.initState();
    // Mevcut ders bilgilerini forma doldur
    txtName.text = widget.lesson.name ?? '';
    txtClass.text = widget.lesson.place ?? '';
    selectedDay = widget.lesson.day ?? "";
    selectedHour1 = widget.lesson.hour1;
    selectedHour2 = widget.lesson.hour2;
    txtTeacher.text = widget.lesson.teacher ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomBar2(context, 0),
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => methods.navigateToPage(context, Timetabledetail()),
            icon: Icon(Icons.arrow_back)),
        title: const Text("Ders Detayı"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => showWarningDialog(context),
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            tooltip: "Dersi Sil",
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
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // buildSectionTitle("Ders Bilgileri"),
            const SizedBox(height: 15),
            buildInfoCard("Ders Adı", buildNameField()),
            const SizedBox(height: 10),
            buildInfoCard("Sınıf", buildClassField()),
            const SizedBox(height: 20),
            // buildSectionTitle("Öğretmen Bilgileri"),
            const SizedBox(
              height: 10,
            ),
            buildInfoCard("Öğretmen Adı", buildTeacherField()),
            // buildSectionTitle("Ders Günü"),
            const SizedBox(height: 15),
            buildInfoCard("Gün Seçimi", buildDayField()),
            const SizedBox(height: 10),
            // buildSectionTitle("Ders Saatleri"),
            const SizedBox(
              height: 15,
            ),
            buildInfoCard("Birinci Ders Saati", buildHour1Field()),
            buildInfoCard("İkinci Ders Saati", buildHour2Field()),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildSaveButton(),
                buildDeleteButton(),
              ],
            )
          ],
        ),
      ),
    );
  }

  buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey[800],
      ),
    );
  }

  buildInfoCard(String title, Widget content) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            content,
          ],
        ),
      ),
    );
  }

  buildNameField() {
    return TextField(
      decoration: InputDecoration(
          hintText: "Ders Adını Giriniz",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
      controller: txtName,
    );
  }

  buildClassField() {
    return TextField(
      decoration: InputDecoration(
          hintText: "Sınıf",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
      controller: txtClass,
    );
  }

  buildTeacherField() {
    return TextField(
      decoration: InputDecoration(
          hintText: "Öğretmen",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
      controller: txtTeacher,
    );
  }

  buildDayField() {
    final List<String> days = [
      "Pazartesi",
      "Salı",
      "Çarşamba",
      "Perşembe",
      "Cuma",
      "Cumartesi",
      "Pazar"
    ];
    return DropdownButtonFormField<String>(
      // initialValue: selectedDay,
      decoration: InputDecoration(
          hintText: selectedDay ?? "Ders Gününü Seçiniz",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
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
    );
  }

  buildHour1Field() {
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
      "20:00-20:45",
    ];

    return DropdownButtonFormField<String>(
      // initialValue: selectedHour1,
      decoration: InputDecoration(
          hintText: selectedHour1 ?? "İlk Ders Saatinizi Giriniz",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
      items: hours
          .map((hour) => DropdownMenuItem(
                value: hour,
                child: Text(hour),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedHour1 = value;
        });
      },
    );
  }

  buildHour2Field() {
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

    return SingleChildScrollView(
      child: DropdownButtonFormField<String>(
          // initialValue: selectedHour2,
          decoration: InputDecoration(
              hintText: selectedHour2 ?? "İkinci Ders Saatinizi Giriniz",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          items: hours
              .map((hour) => DropdownMenuItem(
                    value: hour,
                    child: Text(hour),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedHour2 = value;
            });
          }),
    );
  }

  buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: () => showStateUpdateDialog(context),
      icon: const Icon(
        Icons.save,
        size: 20,
        color: Colors.white,
      ),
      label: const Text(
        "Dersi Güncelle",
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          backgroundColor: Colors.blue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    );
  }

  buildDeleteButton() {
    return ElevatedButton.icon(
      onPressed: () => showWarningDialog(context),
      icon: const Icon(
        Icons.delete,
        size: 20,
        color: Colors.white,
      ),
      label: const Text(
        "Dersi Sil",
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          backgroundColor: Colors.red,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    );
  }

  void updateLesson() async {
    List<Lesson>? updatedLessons;
    if (txtName.text.isEmpty ||
        txtClass.text.isEmpty ||
        selectedDay == null ||
        selectedHour1 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun!")),
      );
      return;
    }
    methods.printColored("${widget.lesson.id} - ${widget.lesson.name}", "32");
    await dbHelper.update(
      Lesson.withID(
        widget.lesson.id,
        txtName.text,
        txtClass.text,
        selectedDay,
        selectedHour1,
        selectedHour2,
        txtTeacher.text,
      ),
    );
    var data = await dbHelper.getLessons();
    if (!mounted) return;
    setState(() {
      updatedLessons = data;
    });
    methods.navigateToPage(
        context,
        LessonDetail(
            lesson: updatedLessons!
                .firstWhere((lesson) => lesson.id == widget.lesson.id)));
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.blueGrey[900],
            title: const Text(
              "Bilgilendirme",
              style: TextStyle(color: Colors.amber),
            ),
            content: const Text("Ders başarıyla güncellendi.",
                style: TextStyle(color: Colors.white)),
            actions: [
              TextButton(
                child: const Text(
                  "Tamam",
                  style: TextStyle(color: Colors.green),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
    Navigator.pop(context, true);
  }

  void deleteLesson() async {
    await dbHelper.delete(widget.lesson.id!);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ders başarıyla silindi!")),
    );
    methods.navigateToPage(context, Timetabledetail());
  }

  void showWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text("Uyarı", style: TextStyle(color: Colors.red)),
          content: const Text("Bu dersi silmek istediğinize emin misiniz?",
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              child:
                  const Text("vazgeç", style: TextStyle(color: Colors.green)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
                onPressed: deleteLesson,
                child: const Text("Sil", style: TextStyle(color: Colors.red)))
          ],
        );
      },
    );
  }

  showStateUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text("Uyarı", style: TextStyle(color: Colors.red)),
          content: const Text("Dersi güncellemek istediğinize emin misiniz?",
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              child: const Text("vazgeç", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
                onPressed: updateLesson,
                child: const Text("Güncelle",
                    style: TextStyle(color: Colors.green)))
          ],
        );
      },
    );
  }
}

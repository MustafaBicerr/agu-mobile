import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:home_page/lessonDetail.dart';
import 'package:home_page/notifications.dart';

import 'package:home_page/utilts/services/dbHelper.dart';

import 'utilts/models/lesson.dart';

class Methods {
  final dbHelper = Dbhelper();
  void printColored(String message, String colorCode) {
    print("\x1B[${colorCode}m$message\x1B[0m");
  }

  void navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  int daysNumber(String day) {
    const daysOfWeek = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];

    DateTime firstDay = DateTime(now.year, now.month, 1);
    int firstDayIndex = firstDay.weekday - 1; // Pazartesi = 0, Pazar = 6

    // Ayın toplam gün sayısını buluyoruz.

    int previousMonthDays = DateTime(now.year, now.month, 0).day;

    // Günleri numaralandırma
    List<int> numberedDays = List<int>.filled(daysOfWeek.length, 0);
    for (int i = 0; i < daysOfWeek.length; i++) {
      if (i >= firstDayIndex) {
        numberedDays[i] = (i - firstDayIndex + 1);
      } else {
        // Önceki ayın günlerini Pazartesi'ye kadar yazdırma
        numberedDays[i] = (previousMonthDays - (firstDayIndex - i - 1));
      }
    }

    switch (day) {
      case 'Pazartesi':
        return numberedDays[0];
      case 'Salı':
        return numberedDays[1];
      case 'Çarşamba':
        return numberedDays[2];
      case 'Perşembe':
        return numberedDays[3];
      case 'Cuma':
        return numberedDays[4];
      case 'Cumartesi':
        return numberedDays[5];
      case 'Pazar':
        return numberedDays[6];
      default:
        return -1;
    }
  }

  TextField buildTextField(
      String title, Icon icon, TextEditingController control) {
    return TextField(
      decoration: InputDecoration(
        labelText: title,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        prefixIcon: icon,
      ),
      controller: control,
    );
  }

  Widget buildPasswordField(
      String title, Icon icon, TextEditingController control) {
    bool isObscured = true;
    return StatefulBuilder(
      builder: (context, setState) {
        return TextField(
          controller: control,
          obscureText: isObscured,
          decoration: InputDecoration(
              labelText: title,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              prefixIcon: icon,
              suffixIcon: IconButton(
                  onPressed: () {
                    setState(
                      () {
                        isObscured = !isObscured;
                      },
                    );
                  },
                  icon: Icon(
                      isObscured ? Icons.visibility_off : Icons.visibility))),
        );
      },
    );
  }

  int getDayNumber(String? day) {
    switch (day) {
      case "Pazartesi":
        return 1;
      case "Salı":
        return 2;
      case "Çarşamba":
        return 3;
      case "Perşembe":
        return 4;
      case "Cuma":
        return 5;
      case "Cumartesi":
        return 6;
      case "Pazar":
        return 7;
      default:
        return 0; // Geçersiz gün
    }
  }

  String getDayName() {
    final now = DateTime.now();
    const days = [
      "",
      "Pazartesi",
      "Salı",
      "Çarşamba",
      "Perşembe",
      "Cuma",
      "Cumartesi",
      "Pazar"
    ];
    return days[now.weekday]; // Hafta içi günlerini döndür
  }
}

class ShowUpcomingLesson extends StatelessWidget {
  final Lesson? lesson;

  const ShowUpcomingLesson({
    Key? key,
    required this.lesson,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // MediaQuery ile ekran genişliği ve yüksekliğini alma
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.005,
        horizontal: screenWidth * 0.02,
      ),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: lesson != null
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LessonDetail(lesson: lesson!),
                    ),
                  );
                }
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: lesson != null
                        ? [Colors.indigo, Colors.blue]
                        : [Colors.grey.shade400, Colors.grey.shade600],
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
                      lesson != null ? "Yaklaşan Ders" : "Ders Bulunamadı",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.045,
                          ),
                    ),
                    if (lesson != null) const Spacer(),
                    if (lesson != null)
                      Container(
                        decoration: BoxDecoration(
                          // color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Row(
                            children: [
                              Text(
                                lesson != null ? (lesson?.day ?? "") : "",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.04,
                                    ),
                              ),
                              // SizedBox(width: screenWidth * 0.015),
                              // Text(
                              //   lesson!.hour1?.substring(0, 5) ?? "",
                              //   style: TextStyle(
                              //       fontSize: screenWidth * 0.027,
                              //       fontWeight: FontWeight.bold,
                              //       color: Colors.white),
                              // )
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // İçerik
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: lesson == null
                    ? _buildNoLessonContent(context, screenWidth)
                    : _buildLessonContentHorizontal(context, screenWidth),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoLessonContent(BuildContext context, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Bugün veya haftanın geri kalanında ders bulunamadı.",
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: screenWidth * 0.02),
      ],
    );
  }

  Widget _buildLessonContentHorizontal(
      BuildContext context, double screenWidth) {
    return Stack(
      alignment: Alignment(1, -1.13),
      children: [
        Table(
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
          },
          children: [
            TableRow(children: [
              _buildLessonDetail("Ders", lesson!.name!.toUpperCase(),
                  "Dersin ismi bulunamadı", screenWidth,
                  maxLines: 2),
              _buildLessonDetail("Öğretmen", lesson!.teacher,
                  "Dersin öğretmeni bulunamadı", screenWidth,
                  maxLines: 2),
              _buildLessonDetail("Sınıf", lesson!.place,
                  "Dersin sınıfı bulunamadı", screenWidth,
                  maxLines: 1),
              // _buildLessonDetail("Gün", lesson!.day, "Gün bilgisi yok", screenWidth,
              //     maxLines: 1),
            ]),
          ],
        ),
        Container(
          width: 50,
          // color: Colors.amber,
          alignment: Alignment.topRight,
          child: Column(
            children: [
              Text("Saat:",
                  style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo)),
              SizedBox(height: screenWidth * 0.0005),
              Text(
                lesson!.hour1?.substring(0, 5) ?? "",
                style: TextStyle(
                    fontSize: screenWidth * 0.028,
                    // fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLessonDetail(
      String label, String? value, String fallback, double screenWidth,
      {int maxLines = 3}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label:",
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.indigo,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value ?? fallback,
            maxLines: 3,
            overflow: TextOverflow.ellipsis, // taşmayı engeller
            style: TextStyle(
              fontSize: screenWidth * 0.028,
              // fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

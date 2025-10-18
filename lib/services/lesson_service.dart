// import 'package:home_page/models/lesson.dart';
// import 'package:home_page/services/dbHelper.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/material.dart';

// class LessonService {

// Dbhelper dbHelper = Dbhelper();

//    void getLessons() async {
//     late int minuteBefore;

//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     bool isRefectoryNotification =
//         preferences.getBool("isRefectoryNotification") ?? false;
//     bool isLessonNotification =
//         preferences.getBool("isLessonNotification") ?? false;
//     bool isNotificationsEnabled =
//         preferences.getBool("isNotificationsEnabled") ?? false;
//     bool isAttendanceNotification =
//         preferences.getBool("isAttendanceNotification") ?? false;
//     String? txtMinuteString = preferences.getString("txtMinute");

//     List<Lesson> dailyLesson = await getDailyLesson();
//     printColored("$dailyLesson", "30");
//     printColored("${dailyLesson.isEmpty}", "30");
//     printColored("${dailyLesson.length}", "30");
//     for (var lesson in dailyLesson) {
//       printColored(
//           "Lesson: ${lesson.name}, isProcessed: ${lesson.isProcessed}", "30");
//     }

//     if (txtMinuteString != null && !txtMinuteString.contains("f")) {
//       minuteBefore = int.parse(txtMinuteString);
//     } else {
//       minuteBefore = 0; // Varsayılan değer
//     }
//     var lessonsFuture = dbHelper.getLessons();
//     lessonsFuture.then((data) {
//       setState(() {
//         lessons = data;
//       });
//       if (isNotificationsEnabled) {
//         // Dersler yüklendikten sonra bildirimleri planla
//         if (lessons != null && lessons!.isNotEmpty && isLessonNotification) {
//           widget.notificationService
//               .scheduleWeeklyLessons(lessons!, minuteBefore);
//         }
//         //widget.notificationService.sendInstantNotification();

//         if (dailyLesson.isEmpty) {
//           widget.notificationService.cancelNotification(2000);
//           widget.notificationService.cancelNotification(1000);
//         }

//         if (isRefectoryNotification && dailyLesson.isNotEmpty) {
//           widget.notificationService.scheduleRefectory();
//         }

//         if (isAttendanceNotification && dailyLesson.isNotEmpty) {
//           widget.notificationService.scheduleAttendance();
//         }
//       } else {
//         methods.printColored(
//             "Bildirimler kapalı. Bildirim gönderilmiyor.", "37");
//       }
//     });
//   }

 
  
// }


//şimdilik yoruma aldım
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home_page/main.dart' show flutterLocalNotificationsPlugin;
import 'package:home_page/models/lesson.dart';
import 'package:home_page/methods.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

final istanbul = tz.getLocation('Europe/Istanbul');
final now = tz.TZDateTime.now(istanbul);
Methods methods = Methods();

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    if (Platform.isAndroid) {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings(
              "@mipmap/ic_launcher"); // Bildirim simgesi gerekiyor
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await notificationsPlugin.initialize(initializationSettings,
          onDidReceiveNotificationResponse: onSelectNotification);
    } else {
      // Test veya simgesiz bir çalışma için burayı atlayabilirsiniz
      printColored("Notification initialization skipped for testing.", "36");
    }

    tz.initializeTimeZones();
  }

  NotificationDetails lessonNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        "lesson_channel_id",
        "Ders Hatırlatma Kanalı",
        channelDescription: "Ders hatırlatma bildirimleri için kanal",
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
  }

  NotificationDetails refectoryNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
          "refectory_channel_id", "Yemekhane Hatırlatma Kanalı",
          channelDescription: "Yemekhane bildirimleri için kanal",
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority),
    );
  }

  NotificationDetails attendanceNotificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails(
      "attendance_channel_id",
      "Devamsızlık Hatırlatman Kanalı",
      channelDescription: "Devamsızlık bildirimleri için kanal",
      importance: Importance.max,
      priority: Priority.max,
    ));
  }

  Future<void> scheduleWeeklyNotification(int id, String title, String body,
      int day, String time, int minuteBefore) async {
    // Saat aralığını ayrıştır
    final startTime = time.split("-")[0]; // Başlangıç saati: "20.20"
    late int newDay;

    if (day > 7) {
      int previousMonthDays = DateTime(now.year, now.month, 0).day;

      if (previousMonthDays == 28) {
        newDay = day - 21;
      }
      if (previousMonthDays == 30) {
        newDay = day - 23;
      } else if (previousMonthDays == 31) {
        newDay = day - 24;
      }
    } else {
      newDay = day;
    }

    // Başlangıç saatini saat ve dakika olarak ayır
    final hourAndMinute = startTime.split(":");
    if (hourAndMinute.length != 2) {
      throw FormatException("Invalid time format: $time");
    }

    final hour = int.parse(hourAndMinute[0]); // Saat: 20
    final minute = int.parse(hourAndMinute[1]); // Dakika: 20

    // Zamanlama için güncel zamanı ve hedef zamanı belirle

    tz.TZDateTime scheduledDate =
        tz.TZDateTime(istanbul, now.year, now.month, newDay, hour, minute)
            .subtract(Duration(minutes: minuteBefore)); // 30 dakika önce

    // Eğer planlanan zaman geçmişteyse, bir hafta ekle

    while (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    printColored("Ders Bildirimleri --> $scheduledDate", "31");

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      lessonNotificationDetails(),
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exact,
    );
  }

  Future<void> scheduleWeeklyLessons(
      List<Lesson> lessons, int minuteBefore) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? txtMinute = preferences.getString("txtMinute");

    int id = 0; // Benzersiz ID
    for (var lesson in lessons) {
      if (lesson.hour1 != null && lesson.day != null) {
        await scheduleWeeklyNotification(
          id++,
          "Yaklaşan Ders: ${lesson.name}",
          "$txtMinute dakika sonra ders var",
          methods.daysNumber(lesson.day!),
          lesson.hour1!,
          minuteBefore,
        );
      }
    }
  }

  Future<void> scheduleRefectoryNotification(
      int id, String title, String body, int hour, int minute) async {
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(istanbul, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await notificationsPlugin.zonedSchedule(
        id, title, body, scheduledDate, refectoryNotificationDetails(),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exact);

    printColored("Yemekhane bildirimi zamanlandı --> $scheduledDate", "31");
  }

  Future<void> scheduleRefectory() async {
    await scheduleRefectoryNotification(1000, "Yemekhane Bildirimi",
        "Yemek servisi başladı. Bugünün menüsünü görmek için tıkla.", 11, 00);
  }

  Future<void> scheduleAttendanceNotification(
      int id, String title, String body, int hour, int minute) async {
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(istanbul, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await notificationsPlugin.zonedSchedule(
        id, title, body, scheduledDate, attendanceNotificationDetails(),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exact);

    printColored("Devamsızlık bildirimi zamanlandı --> $scheduledDate", "31");
  }

  Future<void> scheduleAttendance() async {
    await scheduleAttendanceNotification(2000, "Devamsızlık Bildirimi",
        "Günlük devamsızlık kaydınızı girmeyi unutmayın.", 21, 00);
  }

  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
    printColored("Bildirim ID: $id iptal edildi.", "33");
  }

  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
    printColored("Tüm bildirimler iptal edildi.", "33");
  }

  void onSelectNotification(NotificationResponse response) {
    printColored("Notification clicked: ${response.payload}", "33");
  }

  void sendInstantNotification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isNotificationsEnabled =
        prefs.getBool('isNotificationsEnabled') ?? false;

    if (isNotificationsEnabled) {
      printColored("Bildirim gönderiliyor...", "32");
      await notificationsPlugin.show(
        0, // Bildirim ID'si
        "Anlık Bildirim", // Başlık
        "Bu bir test bildirimidir.", // Mesaj
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel', // Kanal ID'si
            'Test Kanalı', // Kanal adı
            channelDescription: 'Bu bir test kanalıdır.', // Kanal açıklaması
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  }
}

void printColored(String message, String colorCode) {
  print("\x1B[${colorCode}m$message\x1B[0m");
}

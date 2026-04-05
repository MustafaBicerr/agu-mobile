import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

class UpcomingLessonWidget extends StatefulWidget {
  @override
  _UpcomingLessonWidgetState createState() => _UpcomingLessonWidgetState();
}

class _UpcomingLessonWidgetState extends State<UpcomingLessonWidget> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String username = ''; // Kullanıcı adı (e-posta üzerinden alınacak)

  @override
  void initState() {
    super.initState();
    initializeNotifications();
    _getUsername(); // Kullanıcı adı almak için fonksiyonu çağırıyoruz
  }

  // Bildirimleri başlatma metodu
  void initializeNotifications() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: null);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Kullanıcı adını aktif kullanıcıdan almak için metod
  Future<void> _getUsername() async {
    String email = FirebaseAuth.instance.currentUser?.email ?? "";
    if (email.isNotEmpty) {
      var userDoc = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: email)
          .get();

      if (userDoc.docs.isNotEmpty) {
        setState(() {
          username = userDoc.docs.first.id; // Kullanıcı adını ayarlıyoruz
        });
        _fetchClasses(); // Veri çekmek için _fetchClasses() fonksiyonunu çağırıyoruz.
      }
    }
  }

  // Firebase'den ders bilgilerini çekmek için metod
  Future<void> _fetchClasses() async {
    if (username.isEmpty) {
      return; // Eğer username boşsa, dersleri çekmeye gerek yok
    }

    final now = DateTime.now();

    // Kullanıcıya ait dersleri almak için 'users' -> 'username' -> 'classes' koleksiyonundan dersleri çekiyoruz
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users') // 'users' koleksiyonu
        .doc(username) // 'username' (Kullanıcının ID'si)
        .collection('classes') // 'classes' koleksiyonu
        .orderBy('start_time') // Başlangıç saatine göre sıralama
        .get();

    if (snapshot.docs.isEmpty) {
      return; // Eğer ders yoksa, işlem yapma
    }

    // Tüm dersleri alıp sıralıyoruz
    List<Map<String, dynamic>> lessons = snapshot.docs.map((doc) {
      var lesson = doc.data() as Map<String, dynamic>;
      DateTime lessonStartTime = (lesson['start_time'] as Timestamp).toDate();
      return {
        'title': lesson['title'],
        'classroom': lesson['classroom'],
        'start_time': lessonStartTime,
        'day': DateFormat('EEEE').format(lessonStartTime),
      };
    }).toList();

    // Şu anki zamandan sonra ders arıyoruz
    lessons = lessons.where((lesson) {
      DateTime lessonStartTime = lesson['start_time'];
      // Eğer ders şu anki saatten sonra ve aynı gün veya sonraki günse
      return lessonStartTime.isAfter(now) || (lessonStartTime.day > now.day);
    }).toList();

    if (lessons.isEmpty) {
      // Eğer bu hafta ders yoksa, bir sonraki hafta dersini gösteriyoruz
      DateTime nextWeek = now.add(Duration(days: 7)); // 1 hafta sonrası
      lessons = snapshot.docs.map((doc) {
        var lesson = doc.data() as Map<String, dynamic>;
        DateTime lessonStartTime = (lesson['start_time'] as Timestamp).toDate();
        return {
          'title': lesson['title'],
          'classroom': lesson['classroom'],
          'start_time': lessonStartTime
              .add(Duration(days: 7)), // Bir hafta sonrasına alıyoruz
          'day':
              DateFormat('EEEE').format(lessonStartTime.add(Duration(days: 7))),
        };
      }).toList();
    }

    // İlk dersi alıyoruz
    var upcomingLesson = lessons.first;
    DateTime lessonStartTime = upcomingLesson['start_time'];

    // Bildirim gönderme kısmı
    //DateTime now = DateTime.now();
    Duration difference = lessonStartTime.difference(now);
    if (difference.inMinutes > 0 && difference.inMinutes <= 30) {
      sendNotification('Upcoming Lesson', 'Your class is starting soon!');
    }

    // State güncelleme ve ders bilgisini ekranda gösterme
    setState(() {
      // Bu kısımları widget üzerinden gösterebilirsiniz
    });
  }

  // Bildirim gönderme metodu
  void sendNotification(String title, String body) async {
    var androidDetails = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.high,
      priority: Priority.high,
    );
    var notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _fetchClasses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong!'));
        }

        return Center(child: Text('No upcoming lessons.'));
      },
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:home_page/data/lesson.dart';
import 'package:home_page/methods.dart';
import 'package:home_page/services/dbHelper.dart';
import 'package:home_page/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool isNotificationsEnabled = false; // Varsayılan değer
  bool isLessonNotification = false;
  bool isRefectoryNotification = false;
  bool isAttendanceNotification = false;
  TextEditingController txtMinute = TextEditingController();

  NotificationService notificationService = NotificationService();
  Methods methods = Methods();
  @override
  void initState() {
    super.initState();
    loadNotificationPreference(); // Kullanıcının tercihini yükle
    loadMinute();
  }

  // Kullanıcının tercih ettiği bildirim durumunu yükle
  Future<void> loadNotificationPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isNotificationsEnabled =
          prefs.getBool('isNotificationsEnabled') ?? false; // Varsayılan: false
      isLessonNotification = prefs.getBool("isLessonNotification") ?? false;
      isRefectoryNotification =
          prefs.getBool("isRefectoryNotification") ?? false;
      isAttendanceNotification =
          prefs.getBool("isAttendanceNotification") ?? false;
    });
  }

  // Kullanıcının tercih ettiği bildirim durumunu kaydet
  Future<void> SavePreference(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  Future<void> SaveMinute(String minute) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("txtMinute", minute);
  }

  Future<void> loadMinute() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedMinute = prefs.getString("txtMinute");

    if (savedMinute != null && savedMinute.isNotEmpty) {
      txtMinute.text = savedMinute;
    }
  }

  void toggleNotification(bool value) async {
    setState(() {
      isNotificationsEnabled = value;
      requestNotificationPermission(context);
    });

    SavePreference("isNotificationsEnabled", value);

    if (!value) {
      methods.printColored(
          "Kullanıcı bildirimleri kapattı. Tüm bildirimler iptal ediliyor...",
          "32");
      await notificationService.cancelAllNotifications();
    } else {
      methods.printColored("Kullanıcı bildirimleri açtı.", "32");
    }
  }

  void toggleRefectoryNotification(bool value) async {
    setState(() {
      isRefectoryNotification = value;
    });
    SavePreference("isRefectoryNotification", value);

    if (!value) {
      methods.printColored(
          "Kullanıcı yemekhane bildirimlerini kapattı. Yemekhane bildirimleri iptal ediliyor.",
          "32");
      await notificationService.cancelNotification(1000);
    } else {
      methods.printColored(
          "Yemek bildirimleri açıldı. Yeniden zamanlanıyor...", "32");
      await notificationService.scheduleRefectoryNotification(
          1000,
          "Yemekhane Bildirimi",
          "Yemek servisi başladı. Bugünün menüsünü görmek için tıkla.",
          11,
          0);
    }
  }

  void toggleLessonNotification(bool value) async {
    Dbhelper dbhelper = Dbhelper();
    List<Lesson>? lessons;
    var recordLessons = dbhelper.getLessons();
    recordLessons.then((data) {
      setState(() {
        lessons = data.cast<Lesson>();
        isLessonNotification = value;

        if (!value) {
          methods.printColored(
              "Kullanıcı ders bildirimlerini kapattı. Ders bildirimleri iptal ediliyor. ${lessons!.length}",
              "32");
          for (int i = 1; i <= lessons!.length; i++) {
            notificationService.cancelNotification(i);
          }
        } else {
          methods.printColored(
              "Ders bildirimleri açıldı. Yeniden zamanlanıyor...", "32");
        }
      });
    });

    SavePreference("isLessonNotification", value);
  }

  void toggleAttendanceNotification(bool value) async {
    setState(() {
      isAttendanceNotification = value;
    });

    SavePreference("isAttendanceNotification", value);

    if (!value) {
      methods.printColored(
          "Kullanıcı devamsızlık bildirimlerini kapattı. Devamsızlık bilidirimleri iptal ediliyor...",
          "32");
      await notificationService.cancelNotification(2000);
    } else {
      methods.printColored(
          "Kullancı devamsızlık bildirimlerini açtı. Yendiden zamanlanıyor...",
          "32");
      await notificationService.scheduleAttendanceNotification(
          2000,
          "Devamsızlık Bildirimi",
          "Günlük devamsızlık kaydınızı girmeyi unutmayın.",
          21,
          0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Bildirim Ayarları"),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Color.fromARGB(255, 255, 255, 255),
          Color.fromARGB(255, 39, 113, 148),
          Color.fromARGB(255, 255, 255, 255),
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: ListView(
          padding:
              const EdgeInsets.all(10.0), // Listeye kenarlardan boşluk ekledim
          children: [
            // const Text(
            //   "Genel Bildirimler",
            //   style: TextStyle(
            //     fontSize: 20,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.indigo,
            //   ),
            // ),
            const SizedBox(height: 10), // Bildirim başlığından sonra boşluk
            Card(
              elevation: 2, // Hafif gölge efekti
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: const Icon(
                  Icons.notifications,
                  size: 30,
                  color: Colors.indigo,
                ),
                title: const Text(
                  "Bildirimler",
                  style: TextStyle(fontSize: 18),
                ),
                subtitle: Text(
                  isNotificationsEnabled
                      ? "Bildirimler açık. Alt bildirimleri düzenleyebilirsiniz."
                      : "Bildirimler kapalı.",
                  style: TextStyle(
                    fontSize: 14,
                    color: isNotificationsEnabled ? Colors.green : Colors.red,
                  ),
                ),
                trailing: Switch(
                  value: isNotificationsEnabled,
                  onChanged: toggleNotification,
                  activeColor: Colors.green,
                ),
              ),
            ),
            const Divider(),

            // Yemekhane Bildirimi
            // const Text(
            //   "Yemekhane Bildirimleri",
            //   style: TextStyle(
            //     fontSize: 20,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.indigo,
            //   ),
            // ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: const Icon(
                  Icons.restaurant,
                  size: 30,
                  color: Colors.indigo,
                ),
                title: const Text(
                  "Yemekhane Bildirimi",
                  style: TextStyle(fontSize: 18),
                ),
                subtitle: Text(
                  isRefectoryNotification
                      ? "Yemekhane bildirimleri açık."
                      : "Yemekhane bildirimleri kapalı.",
                  style: TextStyle(
                    fontSize: 14,
                    color: isRefectoryNotification ? Colors.green : Colors.red,
                  ),
                ),
                trailing: Switch(
                  value: isRefectoryNotification,
                  onChanged: isNotificationsEnabled
                      ? (value) => toggleRefectoryNotification(value)
                      : null,
                  activeColor: Colors.green,
                ),
              ),
            ),
            const Divider(),

            // const Text(
            //   "Devamsızlık Bildirimleri",
            //   style: TextStyle(
            //     fontSize: 20,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.indigo,
            //   ),
            // ),
            const SizedBox(
              height: 10,
            ),
            Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: const Icon(
                  Icons.person_remove,
                  size: 30,
                  color: Colors.indigo,
                ),
                title: const Text(
                  "Devamsızlık Bildirimleri",
                  style: TextStyle(fontSize: 18),
                ),
                subtitle: Text(
                  isAttendanceNotification
                      ? "Devamsızlık bildirimleri açık"
                      : "Devamsızlık bildirimleri kapalı",
                  style: TextStyle(
                      fontSize: 14,
                      color:
                          isAttendanceNotification ? Colors.green : Colors.red),
                ),
                trailing: Switch(
                  value: isAttendanceNotification,
                  onChanged: isNotificationsEnabled
                      ? (value) => toggleAttendanceNotification(value)
                      : null,
                  activeColor: Colors.green,
                ),
              ),
            ),
            const Divider(),
            // Ders Bildirimi
            // const Text(
            //   "Ders Bildirimleri",
            //   style: TextStyle(
            //     fontSize: 20,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.indigo,
            //   ),
            // ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: const Icon(
                  Icons.school,
                  size: 30,
                  color: Colors.indigo,
                ),
                title: const Text(
                  "Ders Bildirimleri",
                  style: TextStyle(fontSize: 18),
                ),
                subtitle: Text(
                  isLessonNotification
                      ? "Ders bildirimleri açık. Bildirim ayarlarını düzenleyebilirsiniz."
                      : "Ders bildirimleri kapalı.",
                  style: TextStyle(
                    fontSize: 14,
                    color: isLessonNotification ? Colors.green : Colors.red,
                  ),
                ),
                trailing: Switch(
                  value: isLessonNotification,
                  onChanged: isNotificationsEnabled
                      ? (value) => toggleLessonNotification(value)
                      : null,
                  activeColor: Colors.green,
                ),
              ),
            ),
            const Divider(),

            // Ders Bildirimleri İçin Kaydetme Alanı
            if (isLessonNotification) ...[
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.notifications_active_rounded,
                                color: Colors.indigo,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Ders Bildirim Ayarları",
                                style: TextStyle(
                                  fontSize: 18,
                                  // fontWeight: FontWeight.bold,
                                  // color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          TextField(
                            decoration: InputDecoration(
                              labelText: "Bildirim Süresi (dk)",
                              hintText:
                                  "Örneğin: 10 dakika önce (Sadece sayı giriniz.)",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            controller: txtMinute,
                            onChanged: (value) {
                              // Girilen değer değiştiğinde kullanıcıya bilgi verebiliriz
                            },
                          ),
                          // const SizedBox(height: 10),
                        ],
                      ),
                    ), /////////////////////
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(right: 16.0, bottom: 16.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              String minute = txtMinute.text;
                              final isNumeric =
                                  RegExp(r'^\d+$').hasMatch(minute);

                              if (minute.isNotEmpty && isNumeric) {
                                await SaveMinute(minute); // Kaydet

                                showNotificationDiolog(int.parse(minute));

                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   SnackBar(
                                //       content:
                                //           Text("Değer kaydedildi: $minute dakika önce")),
                                // );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Lütfen geçerli bir değer giriniz")),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Kaydet"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    txtMinute.dispose(); // Bellek sızıntısını önlemek için controller'ı temizle
    super.dispose();
  }

  void showNotificationDiolog(int minute) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[900],
          title: const Text(
            "Bildirim İzni",
            style: TextStyle(color: Colors.amber),
          ),
          content: Text(
            "Her ders için ders başlamadan '$minute' dakika önce bildirim alacaksınız.",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              child: const Text("Tamam", style: TextStyle(color: Colors.green)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

// Bildirim izni isteme fonksiyonu
Future<bool> requestNotificationPermission(BuildContext context) async {
  if (Platform.isAndroid) {
    var status = await Permission.notification.status;

    if (status.isDenied || status.isPermanentlyDenied) {
      var result = await Permission.notification.request();
      if (result.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        // Kullanıcıya "Evet/Hayır" soralım
        bool? goToSettings = await showPermissionDialog(context);
        if (goToSettings == true) {
          openAppSettings(); // Ayarlar sayfasına yönlendir
        }
        return false;
      }
    } else {
      return true; // İzin zaten verilmiş
    }
  }
  return false;
}

Future<bool?> showPermissionDialog(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Icon(
          Icons.notifications_active,
          size: 40,
          color: Colors.indigo,
        ),
        content: const Text(
          "AGU Mobile uygulamasının size bildirim göndermesini ister misiniz?",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // "Hayır" seçildi
            },
            child: const Text("Hayır"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // "Evet" seçildi
            },
            child: const Text("Evet"),
          ),
        ],
      );
    },
  );
}

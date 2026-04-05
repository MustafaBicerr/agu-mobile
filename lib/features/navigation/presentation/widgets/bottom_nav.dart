import 'package:flutter/material.dart';
import 'package:agu_mobile/features/home/presentation/pages/home_page.dart';
import 'package:agu_mobile/features/news/presentation/pages/news_page.dart';
import 'package:agu_mobile/shared/services/notification_service.dart';
import 'package:agu_mobile/features/lessons/presentation/pages/timetable_detail_page.dart';
import 'package:agu_mobile/features/attendance/presentation/pages/attendance_page.dart';
import 'package:agu_mobile/features/lessons/presentation/pages/class_schedule_page.dart';
import 'package:agu_mobile/features/refectory/presentation/pages/refectory_page.dart';
import 'package:agu_mobile/features/refectory/presentation/pages/yemekhane_gunluk_tablo_page.dart';

Widget bottomBar2(BuildContext context, int currentIndex) {
  return BottomNavigationBar(
    backgroundColor: Colors.white,
    type: BottomNavigationBarType.fixed,
    currentIndex: currentIndex,
    onTap: (index) {
      if (index != currentIndex) {
        // Aktif olmayan bir sekmeye tıklandığında
        switch (index) {
          case 0:
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => Timetabledetail()));
            break;
          // case 1:
          //   Navigator.pushReplacement(context,
          //       MaterialPageRoute(builder: (context) => ClassScheduleScreen()));
          //   break;

          case 1:
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const NewsPage(url: "https://agunews.agu.edu.tr/")));
            break;
          case 2:
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        MyApp(notificationService: NotificationService())));
            break;

          case 3:
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => RefectoryScreen()));
            break;
          case 4:
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => DailyAttendanceScreen()));
            break;
        }
      }
    },
    items: [
      const BottomNavigationBarItem(
        icon: Icon(Icons.school),
        label: 'Dersler',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.class_),
        label: 'Haberler',
      ),
      BottomNavigationBarItem(
        icon: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo_b9P6R8CU.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        label: 'Anasayfa',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.restaurant),
        label: 'Yemekhane',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_remove),
        label: 'Devamsızlık',
      ),
    ],
  );
}

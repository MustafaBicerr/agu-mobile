import 'package:flutter/material.dart';
import 'package:home_page/core/notification/notification_service.dart';
import 'package:home_page/featuers/course/presentation/pages/TimeTableDetail.dart';
import 'package:home_page/featuers/course/presentation/pages/attendance.dart';
import 'package:home_page/featuers/home/presentation/pages/news_page.dart';
import 'package:home_page/featuers/refectory/presentation/pages/refectory.dart';
import 'package:home_page/main.dart';




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

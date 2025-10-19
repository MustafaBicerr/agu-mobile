import 'package:flutter/material.dart';
import 'package:home_page/core/notification/notification_screen.dart';
import 'package:home_page/featuers/academic_calendar/presentation/pages/academic_schedule_screen.dart';
import 'package:home_page/featuers/menu/presentation/pages/developers_screen.dart';
import 'package:home_page/featuers/menu/presentation/pages/feedbacks_screen.dart';
import 'package:home_page/featuers/menu/presentation/pages/guide_page.dart';
import 'package:home_page/featuers/menu/presentation/pages/password_screen.dart';
import 'package:home_page/featuers/menu/presentation/pages/wifi_page.dart';
import 'package:home_page/methods.dart';

Methods methods = Methods();

class MenuItem {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget page;

  MenuItem(
      {required this.title,
      required this.icon,
      required this.iconColor,
      required this.page});
}

class MenuPage extends StatelessWidget {
  final List<MenuItem> menuItems = [
    MenuItem(
        title: "Bildirim Tercihleri",
        icon: Icons.notifications,
        iconColor: Colors.orange,
        page: NotificationScreen()),
    MenuItem(
        title: "Şifreler ve Giriş",
        icon: Icons.key,
        iconColor: Colors.grey,
        page: PasswordScreen()),
    MenuItem(
        title: "Akademik Takvim",
        icon: Icons.calendar_month,
        iconColor: Colors.indigo,
        page: AcademicCalendarScreen()),
    MenuItem(
        title: "Geri Bildirim Gönder",
        icon: Icons.feedback,
        iconColor: Colors.red,
        page: FeedbackScreen()),
    MenuItem(
        title: "Geliştiriciler",
        icon: Icons.people,
        iconColor: Colors.black,
        page: GelistiricilerScreen()),
    MenuItem(
        title: "Rehber",
        icon: Icons.menu_book_outlined,
        iconColor: Colors.brown,
        page: const GuidePage()),
    MenuItem(
        title: "Wi-Fi Bilgileri",
        icon: Icons.wifi,
        iconColor: Colors.black,
        page: const WifiPage()),
  ];

  MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Menü"),
          centerTitle: true,
        ),
        body: ListView.builder(
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final menuItem = menuItems[index];
              return ListTile(
                leading: Icon(
                  menuItem.icon,
                  size: screenWidth * 0.07,
                  color: menuItem.iconColor,
                  // color: Colors.indigo,
                ),
                title: Text(menuItem.title,
                    style: TextStyle(fontSize: screenWidth * 0.045)),
                onTap: () => methods.navigateToPage(context, menuItem.page),
              );
            }));
  }
}

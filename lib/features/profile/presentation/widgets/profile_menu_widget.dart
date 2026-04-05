import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth import edildi
import 'package:agu_mobile/features/profile/presentation/pages/profile_settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agu_mobile/shared/services/current_user_profile_store.dart';

class ShowProfileMenuWidget extends StatelessWidget {
  const ShowProfileMenuWidget({
    super.key,
  });

  void _logout(BuildContext context) async {
    Navigator.of(context).pop();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', false);
    await FirebaseAuth.instance.signOut();
    CurrentUserProfileStore.instance.clear();
    // AppBootstrap authStateChanges ile AuthScreen’e döner
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // ListTile(
          //   leading: const Icon(Icons.info),
          //   title: const Text('Hakkımda'),
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => const AboutPage(),
          //       ),
          //     );
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Profil Ayarları'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileSettingsPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("Çıkış Yap"),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}

void _showProfileMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return const ShowProfileMenuWidget();
    },
  );
}

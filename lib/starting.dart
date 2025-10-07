import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home_page/auth.dart';
import 'package:home_page/main.dart';
import 'package:home_page/notifications.dart';
import 'package:home_page/screens/starting_animation.dart';
import 'package:home_page/utilts/models/Store.dart';

class MyRootApp extends StatelessWidget {
  final NotificationService notificationService;
  const MyRootApp({super.key, required this.notificationService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Route'larda yeni NotificationService oluşturma! aynı instance'ı taşıyalım.
      onGenerateRoute: (settings) {
        if (settings.name == '/login') {
          return MaterialPageRoute(
            builder: (_) => MyApp(notificationService: notificationService),
          );
        }
        return MaterialPageRoute(
          builder: (_) => SplashGate(notificationService: notificationService),
        );
      },
    );
  }
}

class SplashGate extends StatefulWidget {
  final NotificationService notificationService;
  const SplashGate({super.key, required this.notificationService});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  late final Future<void> _boot;

  @override
  void initState() {
    super.initState();

    final minSplash = Future.delayed(const Duration(milliseconds: 1200));
    final loadData = EventsStore.instance.load(force: false).catchError((_) {});
    _boot = Future.wait([minSplash, loadData])
        .timeout(const Duration(seconds: 8), onTimeout: () => [])
        .then((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _boot,
      builder: (_, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const startingAnimation();
        }
        // Splash bitti → AuthGate'e geç
        return AuthGate(notificationService: widget.notificationService);
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  final NotificationService notificationService;
  const AuthGate({super.key, required this.notificationService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (_, snapshot) {
        // Hâlâ auth state belirlenmediyse minik bir “loading”
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const startingAnimation(); // ya da küçük bir loader
        }

        final user = snapshot.data;
        if (user == null) {
          // Giriş YOK → AuthScreen (login/register)
          return const AuthScreen();
        }

        // Giriş VAR → ana uygulama
        return MyApp(notificationService: notificationService);
      },
    );
  }
}

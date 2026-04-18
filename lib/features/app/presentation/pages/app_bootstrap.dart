import 'dart:async';

import 'package:agu_mobile/features/app/presentation/pages/starting_animation_page.dart';
import 'package:agu_mobile/features/auth/presentation/pages/auth_page.dart';
import 'package:agu_mobile/features/events/data/models/store.dart';
import 'package:agu_mobile/features/home/presentation/pages/home_page.dart';
import 'package:agu_mobile/shared/services/app_services.dart';
import 'package:agu_mobile/shared/services/current_user_profile_store.dart';
import 'package:agu_mobile/shared/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// - Oturum yok: auth çözülene kadar boş beyaz ekran (yükleniyor animasyonu yok) → login.
/// - Oturum var (beni hatırla): yalnızca etkinlik/yemekhane + profil çekilirken [startingAnimation].
/// - Giriş sonrası: ağ/önbellek işi ~180 ms’den uzun sürerse yükleniyor; aksi halde doğrudan ana sayfa.
class AppBootstrap extends StatefulWidget {
  final NotificationService notificationService;

  /// true: çıkış / hesap silme sonrası — doğrudan giriş ekranı.
  final bool resumeAtAuth;

  const AppBootstrap({
    super.key,
    required this.notificationService,
    this.resumeAtAuth = false,
  });

  static void restartAtAuth(BuildContext context) {
    final ns = AppServices.notification;
    if (ns == null) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => AppBootstrap(
          notificationService: ns,
          resumeAtAuth: true,
        ),
      ),
      (_) => false,
    );
  }

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  /// false iken: auth henüz çözülmedi (boş beyaz, animasyon yok).
  bool _authResolved = false;

  /// Soğuk açılışta oturum varken Firestore ön yükleme sürüyor.
  bool _coldPrefetchActive = false;

  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();
    if (widget.resumeAtAuth) {
      _authResolved = true;
    } else {
      _runColdStart();
    }
    _authSub = FirebaseAuth.instance.authStateChanges().listen((_) {
      if (mounted && _authResolved) setState(() {});
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _runColdStart() async {
    await _waitForAuthReady();

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _authResolved = true;
      _coldPrefetchActive = user != null;
    });

    if (user != null) {
      try {
        await Future.wait<void>([
          EventsStore.instance.load(force: false),
          CurrentUserProfileStore.instance.refreshFromRemote(),
        ]).timeout(const Duration(seconds: 45));
      } catch (e, st) {
        debugPrint('[AppBootstrap] cold prefetch: $e\n$st');
      }
      if (mounted) {
        setState(() => _coldPrefetchActive = false);
      }
    }
  }

  Future<void> _waitForAuthReady() async {
    try {
      // Gerçek cihazda kalıcı oturumun geri yüklenmesi emülatöre göre daha geç
      // gelebilir. İlk auth event'ini beklemek, erken "login" göstermeyi engeller.
      await FirebaseAuth.instance.authStateChanges().first.timeout(
        const Duration(seconds: 20),
      );
    } on TimeoutException catch (_) {
      debugPrint('[AppBootstrap] auth resolve timeout; continuing with currentUser');
    } catch (e, st) {
      debugPrint('[AppBootstrap] auth resolve error: $e\n$st');
    }
  }

  Future<void> _afterLoginPrefetch() async {
    if (!mounted) return;

    try {
      await Future.wait<void>([
        EventsStore.instance.load(force: false),
        CurrentUserProfileStore.instance.refreshFromRemote(),
      ]).timeout(const Duration(seconds: 45));
    } catch (e, st) {
      debugPrint('[AppBootstrap] post-login prefetch: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_authResolved) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox.expand(),
      );
    }

    if (_coldPrefetchActive) {
      return const startingAnimation();
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return AuthScreen(
        onSignedIn: _afterLoginPrefetch,
      );
    }

    return MyApp(notificationService: widget.notificationService);
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:agu_mobile/features/profile/data/user_data_source.dart';
import 'package:agu_mobile/shared/services/profile_refresh_notifier.dart';

/// Oturum açık kullanıcının Firestore `users` kaydının tek kopyasını tutar.
/// Alt sekmeler `pushReplacement` ile `MyApp` yenilense bile bellekte kalır.
class CurrentUserProfileStore extends ChangeNotifier {
  CurrentUserProfileStore._() {
    ProfileRefreshNotifier.tick.addListener(_onRefreshSignal);
  }

  static final CurrentUserProfileStore instance = CurrentUserProfileStore._();

  final UserDataSource _dataSource = UserDataSource();

  Map<String, dynamic>? _profile;
  bool _loading = false;
  bool _backgroundRefreshing = false;
  Future<void>? _inFlight;

  /// UI için `_firestore` ham alanını çıkarılmış kopya.
  Map<String, dynamic>? get profileForUi {
    if (_profile == null) return null;
    final m = Map<String, dynamic>.from(_profile!);
    m.remove('_firestore');
    return m;
  }

  Map<String, dynamic>? get profileSnapshot => _profile;

  bool get isLoading => _loading;
  bool get isBackgroundRefreshing => _backgroundRefreshing;

  String? get imageUrl {
    final u = _profile?['image_url'];
    if (u is String && u.isNotEmpty) return u;
    return null;
  }

  void _onRefreshSignal() {
    refreshFromRemote();
  }

  /// Sunucudan çek; önbellek varken arka planda yenile (AppBar’da sürekli spinner olmasın).
  Future<void> refreshFromRemote() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      clear();
      return;
    }

    if (_inFlight != null) {
      await _inFlight;
      return;
    }

    final hadCache = _profile != null;
    if (!hadCache) {
      _loading = true;
      notifyListeners();
    } else {
      _backgroundRefreshing = true;
      notifyListeners();
    }

    _inFlight = _loadRemote().whenComplete(() {
      _inFlight = null;
    });
    await _inFlight;
  }

  Future<void> _loadRemote() async {
    try {
      final data = await _dataSource
          .fetchCurrentUserData(includeRawDoc: true)
          .timeout(const Duration(seconds: 15));
      _profile = data;
    } catch (_) {
      // Ağ hatasında mevcut önbelleği koru
    } finally {
      _loading = false;
      _backgroundRefreshing = false;
      notifyListeners();
    }
  }

  /// Profil ekranı vb. doğrudan güncel veriyi çektiğinde önbelleği tek seferde hizala.
  void replaceProfile(Map<String, dynamic>? data) {
    _profile = data;
    _loading = false;
    _backgroundRefreshing = false;
    notifyListeners();
  }

  void clear() {
    _profile = null;
    _loading = false;
    _backgroundRefreshing = false;
    notifyListeners();
  }
}

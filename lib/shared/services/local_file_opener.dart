import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Uygulama alanındaki indirilen dosyayı platform görünümüyle açar.
///
/// Android: `FileProvider` + `ACTION_VIEW` (READ_MEDIA_* gerektirmez).
/// iOS: Quick Look önizleme (kullanıcı paylaş / “Başka uygulamada aç”).
class LocalFileOpener {
  LocalFileOpener._();

  static const MethodChannel _channel =
      MethodChannel('com.agu.agumobile/downloads');

  static Future<bool> open(String path) async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    try {
      final ok = await _channel.invokeMethod<bool>('openLocalFile', path);
      return ok ?? false;
    } on PlatformException catch (e, st) {
      debugPrint('[LocalFileOpener] $e\n$st');
      return false;
    }
  }
}

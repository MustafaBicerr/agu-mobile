import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Android public Downloads klasörüne dosya kaydetme / silme
/// işlemlerini yapan platform channel wrapper.
class DownloadHelper {
  static const _channel = MethodChannel('com.agu.agumobile/downloads');

  /// Dosyayı public Downloads klasörüne kaydeder.
  /// Diğer uygulamalar (Gemini, Dosya Yöneticisi vb.) bu dosyayı görebilir.
  /// Sadece Android'de çalışır; diğer platformlarda sessizce atlanır.
  static Future<String?> saveToPublicDownloads(
    String filename,
    List<int> bytes,
  ) async {
    if (!Platform.isAndroid) return null;

    try {
      final result = await _channel.invokeMethod<String>(
        'saveToPublicDownloads',
        {
          'filename': filename,
          'bytes': Uint8List.fromList(bytes),
        },
      );
      debugPrint('[DownloadHelper] Public Downloads kaydedildi: $result');
      return result;
    } on PlatformException catch (e) {
      debugPrint('[DownloadHelper] Kayıt hatası: ${e.message}');
      return null;
    }
  }

  /// Public Downloads klasöründeki dosyayı siler.
  /// Sadece Android'de çalışır; diğer platformlarda sessizce atlanır.
  static Future<bool> deleteFromPublicDownloads(String filename) async {
    if (!Platform.isAndroid) return false;

    try {
      final result = await _channel.invokeMethod<bool>(
        'deleteFromPublicDownloads',
        {'filename': filename},
      );
      debugPrint('[DownloadHelper] Public Downloads silindi: $filename');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('[DownloadHelper] Silme hatası: ${e.message}');
      return false;
    }
  }
}

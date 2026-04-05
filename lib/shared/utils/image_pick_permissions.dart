import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

/// Galeri seçimi Android Photo Picker / iOS PHPicker ile yapılır; tüm galeriye
/// erişim (READ_MEDIA_*, depolama) izni manifeste ve Play politikasına girmez.
Future<bool> ensureGalleryPermission() async {
  if (!Platform.isAndroid && !Platform.isIOS) return true;
  return true;
}

Future<bool> ensureCameraPermission() async {
  if (!Platform.isAndroid && !Platform.isIOS) return true;
  final r = await Permission.camera.request();
  return r.isGranted;
}

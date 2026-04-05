import 'package:agu_mobile/shared/services/notification_service.dart';

/// [main] içinde atanır; çıkış / hesap silme sonrası yeniden yönlendirmede aynı [NotificationService] kullanılır.
class AppServices {
  static NotificationService? notification;
}

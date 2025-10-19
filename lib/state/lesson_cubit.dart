import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_page/models/lesson.dart';
import 'package:home_page/services/dbHelper.dart';
import 'package:home_page/services/notification_service.dart';
// State dosyasını import edin:
import 'lesson_state.dart'; 
// methods'ı uygun yerden import ettiğinizden emin olun (veya inject edin)

// BLOC/Cubit yapısında LessonService sınıfına ihtiyacınız yok, 
// içindeki mantığı Cubit'e taşıyacağız.
class LessonCubit extends Cubit<LessonState> {
  // Bağımlılıkları Cubit'e Enjekte Etme (Daha Temiz Yaklaşım)
  final Dbhelper dbHelper;
  final NotificationService notificationService;
  // final Methods methods; // Eğer kullanılıyorsa

  LessonCubit(this.dbHelper, this.notificationService) : super(LessonInitial());

  // 1. Tüm Dersleri Yükleyen Metot
  Future<void> loadLessons() async {
    try {
      emit(LessonLoading()); // Yükleme durumuna geç

      // Tüm dersleri ve günlük dersleri çek
      final allLessons = await dbHelper.getLessons();
      final dailyLessons = getDailyLessons(allLessons);
      
      // Verileri yüklenmiş durumda emit et
      emit(LessonLoaded(allLessons: allLessons, dailyLessons: dailyLessons));
      
      // Bildirim mantığını burada çağır
      await setupNotifications(allLessons, dailyLessons);

    } catch (e) {
      emit(LessonError("Dersler yüklenirken hata oluştu: $e"));
    }
  }

  // 2. Günlük Dersleri Çekme Metodu (LessonService'den taşındı)
  List<Lesson> getDailyLessons(List<Lesson> allLessons) {
    // BLOC/Cubit sınıfında setState() kullanılamaz. 
    // Durum değişikliği emit() ile yapılır.
    String currentDay = methods.getDayName(); // methods'un erişilebilir olması lazım

    return allLessons
        .where(
          (lesson) => lesson.day == currentDay && lesson.isProcessed == 0,
        )
        .toList();
  }
  
  // 3. Bildirim Kurulum Mantığı 
  Future<void> setupNotifications(List<Lesson> allLessons, List<Lesson> dailyLesson) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    
    // Preferences değerlerini oku
    final isNotificationsEnabled = preferences.getBool("isNotificationsEnabled") ?? false;
    final isLessonNotification = preferences.getBool("isLessonNotification") ?? false;
    final isRefectoryNotification = preferences.getBool("isRefectoryNotification") ?? false;
    final isAttendanceNotification = preferences.getBool("isAttendanceNotification") ?? false;
    final txtMinuteString = preferences.getString("txtMinute");
    
    // minuteBefore hesaplama
    int minuteBefore;
    if (txtMinuteString != null && !txtMinuteString.contains("f")) {
      minuteBefore = int.parse(txtMinuteString);
    } else {
      minuteBefore = 0;
    }

    if (isNotificationsEnabled) {
      if (allLessons.isNotEmpty && isLessonNotification) {
        notificationService.scheduleWeeklyLessons(allLessons, minuteBefore);
      }

      if (dailyLesson.isEmpty) {
        notificationService.cancelNotification(2000);
        notificationService.cancelNotification(1000);
      }

      if (isRefectoryNotification && dailyLesson.isNotEmpty) {
        notificationService.scheduleRefectory();
      }

      if (isAttendanceNotification && dailyLesson.isNotEmpty) {
        notificationService.scheduleAttendance();
      }
    } else {
      
       methods.printColored("Bildirimler kapalı. Bildirim gönderilmiyor.", "37");
    }
  }
}
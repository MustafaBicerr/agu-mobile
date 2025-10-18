import 'package:home_page/models/lesson.dart';
import 'package:home_page/methods.dart';

Lesson? findUpcomingLesson(List<Lesson> lessons) {
  final now = DateTime.now();
  final currentDay = now.weekday; // 1 = Pazartesi, 7 = Pazar
  final currentHour = "${now.hour}.${now.minute}"; // Şimdiki saat ve dakika
  Methods methods = Methods();
  Lesson? nextLesson;
  // printColored("$currentDay, $currentHour", "31");

  for (var lesson in lessons) {
    // Gün sayısını belirle
    int dayNumber = methods.getDayNumber(lesson.day);
    // printColored("${lesson.day}, ${lesson.hour1}, ${lesson.hour2}", "32");

    if (dayNumber == 0) continue; // Geçersiz gün atlandı

    // Yaklaşan ders için kontrol
    if (dayNumber > currentDay || // Şimdiki günden sonraki bir gün mü?
        (dayNumber == currentDay && // Şimdiki gün ve daha ileri bir saat mi?
            (isLessonUpcoming(lesson.hour1, currentHour) ||
                isLessonUpcoming(lesson.hour2, currentHour)))) {
      if (nextLesson == null) {
        nextLesson = lesson; // İlk geçerli ders
      } else {
        // Daha erken bir ders varsa onu seç
        int nextLessonDayNumber = methods.getDayNumber(nextLesson.day);

        // Gün sıralamasını kontrol et
        if (dayNumber < nextLessonDayNumber || // Daha erken bir gün mü?
            (dayNumber ==
                    nextLessonDayNumber && // Aynı gün ve daha erken saat mi?
                isEarlierLesson(lesson, nextLesson, currentHour))) {
          nextLesson = lesson;
        }
      }
    }
  }

  return nextLesson;
}

bool isLessonUpcoming(String? lessonTime, String currentHour) {
  if (lessonTime == null || currentHour.isEmpty) return false;

  // "18.00 - 18.45" -> "18.00" ve "18.45"
  final times = lessonTime.split("-");
  if (times.length != 2) return false;

  final startTime = times[0];

  // Eğer şu anki saat, dersin başlangıç saatinden sonra ve bitiş saatinden önce ise
  if (isHourAfter(startTime, currentHour) || startTime == currentHour) {
    return true;
  }
  return false;
}

bool isHourAfter(String hour, String currentHour) {
  final hourParts = hour.split(":");
  final currentHourParts = currentHour.split(".");

  final hourValue = int.tryParse(hourParts[0]); // Saat
  final minuteValue = hourParts.length > 1 ? int.tryParse(hourParts[1]) : 0;

  final currentHourValue = int.tryParse(currentHourParts[0]);
  final currentMinuteValue =
      currentHourParts.length > 1 ? int.tryParse(currentHourParts[1]) : 0;

  if (hourValue == null || currentHourValue == null) return false;

  // Saat karşılaştırması
  if (hourValue > currentHourValue) return true;
  if (hourValue == currentHourValue &&
      (minuteValue ?? 0) > currentMinuteValue!) {
    return true;
  }
  return false;
}

bool isEarlierLesson(
    Lesson newLesson, Lesson currentLesson, String currentHour) {
  // Yeni dersin saatlerini sırayla kontrol et
  final hoursNew = [newLesson.hour1, newLesson.hour2];
  final hoursCurrent = [
    currentLesson.hour1,
    currentLesson.hour2,
  ];

  for (int i = 0; i < hoursNew.length; i++) {
    if (hoursNew[i] != null &&
        isHourAfter(hoursCurrent[i] ?? '', hoursNew[i]!)) {
      return true; // Yeni dersin saati daha erken
    }
  }
  return false; // Yeni ders daha erken değil
}

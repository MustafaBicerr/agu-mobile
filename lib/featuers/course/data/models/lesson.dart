import 'package:home_page/featuers/course/domain/entities/lessonEntity.dart';

class Lesson extends LessonEntity {
  const Lesson({
    int? id,
    required String name,
    required String place,
    String? day,
    String? hour1,
    String? hour2,
    String? hour3,
    String? teacher,
    int attendance = 0,
    int isProcessed = 0,
  }) : super(
          id: id,
          name: name,
          place: place,
          day: day,
          hour1: hour1,
          hour2: hour2,
          hour3: hour3,
          teacher: teacher,
          attendance: attendance,
          isProcessed: isProcessed,
        );

  /// 🔸 SQLite / JSON için Map dönüşümü
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      "name": name,
      "place": place,
      "day": day,
      "hour1": hour1,
      "hour2": hour2,
      "hour3": hour3,
      "teacher": teacher,
      "attendance": attendance,
      "isProcessed": isProcessed,
    };
    if (id != null) map["id"] = id;
    return map;
  }

  /// 🔸 Veritabanından gelen obje -> Model
  factory Lesson.fromMap(Map<String, dynamic> map) => Lesson(
        id: map["id"] is int ? map["id"] : int.tryParse(map["id"].toString()),
        name: map["name"],
        place: map["place"],
        day: map["day"],
        hour1: map["hour1"],
        hour2: map["hour2"],
        hour3: map["hour3"],
        teacher: map["teacher"],
        attendance: map["attendance"] ?? 0,
        isProcessed: map["isProcessed"] ?? 0,
      );

  /// 🔸 Domain Entity → Model
  factory Lesson.fromEntity(LessonEntity lesson) => Lesson(
        id: lesson.id,
        name: lesson.name,
        place: lesson.place,
        day: lesson.day,
        hour1: lesson.hour1,
        hour2: lesson.hour2,
        hour3: lesson.hour3,
        teacher: lesson.teacher,
        attendance: lesson.attendance,
        isProcessed: lesson.isProcessed,
      );

  /// 🔸 Model → Domain Entity
  LessonEntity toEntity() => LessonEntity(
        id: id,
        name: name,
        place: place,
        day: day,
        hour1: hour1,
        hour2: hour2,
        hour3: hour3,
        teacher: teacher,
        attendance: attendance,
        isProcessed: isProcessed,
      );
}

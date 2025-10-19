class LessonEntity {
  final int? id;
  final String name;
  final String place;
  final String? day;
  final String? hour1;
  final String? hour2;
  final String? hour3;
  final String? teacher;
  final int attendance;
  final int isProcessed;

  const LessonEntity({
    this.id,
    required this.name,
    required this.place,
    this.day,
    this.hour1,
    this.hour2,
    this.hour3,
    this.teacher,
    this.attendance = 0,
    this.isProcessed = 0,
  });

  LessonEntity copyWith({
    int? isProcessed,
    int? attendance,
  }) {
    return LessonEntity(
      id: id,
      name: name,
      place: place,
      day: day,
      hour1: hour1,
      hour2: hour2,
      hour3: hour3,
      teacher: teacher,
      attendance: attendance ?? this.attendance,
      isProcessed: isProcessed ?? this.isProcessed,
    );
  }
}

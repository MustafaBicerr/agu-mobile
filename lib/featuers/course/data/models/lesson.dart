class Lesson {
  int? id;
  String? name;
  String? place;
  String? day;
  String? hour1;
  String? hour2;
  String? hour3;
  String? teacher;
  int? attendance; // Varsayılan devamsızlık
  int isProcessed = 0; // Varsayılan olarak işlenmemiş

  Lesson(this.name, this.place, this.day, this.hour1, this.hour2, this.hour3,
      this.teacher,
      {this.attendance = 0});
  Lesson.withID(this.id, this.name, this.place, this.day, this.hour1,
      this.hour2, this.hour3, this.teacher,
      {this.attendance, this.isProcessed = 0});

  Lesson.withAttendance(this.name, this.place, this.day, this.hour1, this.hour2,
      this.hour3, this.teacher, this.attendance,
      {this.isProcessed = 0});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map["name"] = name;
    map["place"] = place;
    map["day"] = day;
    map["hour1"] = hour1;
    map["hour2"] = hour2;
    map["hour3"] = hour3;
    map["teacher"] = teacher;
    map["attendance"] = attendance;
    map["isProcessed"] = isProcessed;

    if (id != null) {
      map["id"] = id!;
    }

    return map;
  }

  Lesson.fromObject(dynamic o) {
    id = o["id"] is int ? o["id"] : int.tryParse(o["id"].toString());
    name = o["name"];
    place = o["place"];
    day = o["day"];
    hour1 = o["hour1"];
    hour2 = o["hour2"];
    hour3 = o["hour3"];
    teacher = o["teacher"];
    attendance = o["attendance"] ?? 0;
    isProcessed = o["isProcessed"] ?? 0;
  }
}

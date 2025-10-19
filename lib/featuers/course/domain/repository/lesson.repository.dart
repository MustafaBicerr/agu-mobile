import 'package:home_page/featuers/course/domain/entities/lessonEntity.dart';

abstract class LessonRepository {
  Future<void> addLesson(LessonEntity lesson);
  // Future<List<LessonEntity>> getAllLessons();
  Future<List<LessonEntity>> getLessons();
  Future<void> deleteLesson(int id);
  Future<void> updateLesson(LessonEntity lesson);
  Future<void> incrementAttendance(String name, int count);
  Future<int> getAttendance(String name);
  Future<void> deleteAllLessons();
}

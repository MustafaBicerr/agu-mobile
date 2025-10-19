import 'package:home_page/featuers/course/data/data_sources/lesson_data_local_source.dart';
import 'package:home_page/featuers/course/data/models/lesson.dart';
import 'package:home_page/featuers/course/domain/entities/lessonEntity.dart';
import 'package:home_page/featuers/course/domain/repository/lesson.repository.dart';

class LessonRepositoryImpl implements LessonRepository {
  final LessonLocalDataSource localDataSource;

  LessonRepositoryImpl(this.localDataSource);

  /// 🔹 Yeni ders ekler (varsa atlar)
  @override
  Future<void> addLesson(LessonEntity lesson) async {
    final model = Lesson.fromEntity(lesson);
    final exists = await localDataSource.lessonExists(model);
    if (!exists) {
      await localDataSource.insertLesson(model);
    }
  }

  /// 🔹 Tüm dersleri getirir
  @override
  Future<List<LessonEntity>> getLessons() async {
    final models = await localDataSource.getLessons();
    return models.map((m) => m.toEntity()).toList();
  }

  /// 🔹 ID’ye göre dersi siler
  @override
  Future<void> deleteLesson(int id) async {
    await localDataSource.deleteLesson(id);
  }

  /// 🔹 Dersi günceller
  @override
  Future<void> updateLesson(LessonEntity lesson) async {
    final model = Lesson.fromEntity(lesson);
    await localDataSource.updateLesson(model);
  }

  /// 🔹 Devamsızlık sayısını arttırır
  @override
  Future<void> incrementAttendance(String name, int count) async {
    await localDataSource.incrementAttendanceByCount(name, count);
  }

  /// 🔹 Derse ait devamsızlık sayısını döner
  @override
  Future<int> getAttendance(String name) async {
    return await localDataSource.getAttendanceByLessonName(name);
  }

  @override
  Future<void> deleteAllLessons() async {
    await localDataSource.deleteAllLessons();
  }
}

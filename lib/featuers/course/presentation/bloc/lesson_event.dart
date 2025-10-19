import 'package:equatable/equatable.dart';
import '../../domain/entities/lessonEntity.dart';

abstract class LessonEvent extends Equatable {
  const LessonEvent();

  @override
  List<Object?> get props => [];
}

/// 🔹 Tüm dersleri getir
class GetLessonsEvent extends LessonEvent {}

/// 🔹 Yeni ders ekle
class AddLessonEvent extends LessonEvent {
  final LessonEntity lesson;

  const AddLessonEvent(this.lesson);

  @override
  List<Object?> get props => [lesson];
}

/// 🔹 Dersi güncelle
class UpdateLessonEvent extends LessonEvent {
  final LessonEntity lesson;

  const UpdateLessonEvent(this.lesson);

  @override
  List<Object?> get props => [lesson];
}

/// 🔹 Devamsızlığı güncelle
class UpdateAttendanceEvent extends LessonEvent {
  final LessonEntity lesson;
  const UpdateAttendanceEvent(this.lesson);

  @override
  List<Object?> get props => [lesson];
}

/// 🔹 Dersi sil
class DeleteLessonEvent extends LessonEvent {
  final int id;

  const DeleteLessonEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// 🔹 Devamsızlık sayısını artır
class IncrementAttendanceEvent extends LessonEvent {
  final String name;
  final int count;

  const IncrementAttendanceEvent(this.name, this.count);

  @override
  List<Object?> get props => [name, count];
}

class AddLessonBatchEvent extends LessonEvent {
  final List<LessonEntity> lessons;
  const AddLessonBatchEvent(this.lessons);

  @override
  List<Object?> get props => [lessons];
}

/// 🔹 Belirli bir güne göre dersleri getir
class GetDailyLessonsEvent extends LessonEvent {
  final String day;

  const GetDailyLessonsEvent(this.day);

  @override
  List<Object?> get props => [day];
}

/// 🔹 Devamsızlık işlemi (katıldım / katılmadım)
class MarkAttendanceEvent extends LessonEvent {
  final LessonEntity lesson;
  final bool attended;

  const MarkAttendanceEvent(this.lesson, this.attended);

  @override
  List<Object?> get props => [lesson, attended];
}

class DeleteAllLessonsEvent extends LessonEvent {}

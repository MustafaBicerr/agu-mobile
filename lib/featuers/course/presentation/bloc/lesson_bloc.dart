import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_page/featuers/course/domain/repository/lesson.repository.dart';
import '../../domain/entities/lessonEntity.dart';
import 'lesson_event.dart';
import 'lesson_state.dart';

class LessonBloc extends Bloc<LessonEvent, LessonState> {
  final LessonRepository repository;

  LessonBloc(this.repository) : super(LessonInitial()) {
    on<GetLessonsEvent>(_onGetLessons);
    on<AddLessonEvent>(_onAddLesson);
    on<UpdateLessonEvent>(_onUpdateLesson);
    on<DeleteLessonEvent>(_onDeleteLesson);
    on<IncrementAttendanceEvent>(_onIncrementAttendance);
    on<AddLessonBatchEvent>(_onAddLessonBatch);
    on<GetDailyLessonsEvent>(_onGetDailyLessons);
    on<MarkAttendanceEvent>(_onMarkAttendance);
    on<UpdateAttendanceEvent>(_onUpdateAttendance);
    on<DeleteAllLessonsEvent>(_onDeleteAllLessons);
  }

  Future<void> _onGetLessons(
      GetLessonsEvent event, Emitter<LessonState> emit) async {
    emit(LessonLoading());
    try {
      final lessons = await repository.getLessons();
      emit(LessonLoaded(lessons));
    } catch (e) {
      emit(LessonError("Dersler alınamadı: $e"));
    }
  }

  Future<void> _onAddLesson(
      AddLessonEvent event, Emitter<LessonState> emit) async {
    try {
      await repository.addLesson(event.lesson);
      emit(LessonActionSuccess("Ders başarıyla eklendi"));
      add(GetLessonsEvent()); // Listeyi güncelle
    } catch (e) {
      emit(LessonError("Ders eklenemedi: $e"));
    }
  }

  Future<void> _onUpdateLesson(
      UpdateLessonEvent event, Emitter<LessonState> emit) async {
    try {
      await repository.updateLesson(event.lesson);
      emit(LessonActionSuccess("Ders başarıyla güncellendi"));
      add(GetLessonsEvent());
    } catch (e) {
      emit(LessonError("Güncelleme hatası: $e"));
    }
  }

  Future<void> _onDeleteLesson(
      DeleteLessonEvent event, Emitter<LessonState> emit) async {
    try {
      await repository.deleteLesson(event.id);
      emit(LessonActionSuccess("Ders silindi"));
      add(GetLessonsEvent());
    } catch (e) {
      emit(LessonError("Silme hatası: $e"));
    }
  }

  Future<void> _onIncrementAttendance(
      IncrementAttendanceEvent event, Emitter<LessonState> emit) async {
    try {
      await repository.incrementAttendance(event.name, event.count);
      emit(LessonActionSuccess("Devamsızlık artırıldı"));
      add(GetLessonsEvent());
    } catch (e) {
      emit(LessonError("Devamsızlık artırılamadı: $e"));
    }
  }

  Future<void> _onAddLessonBatch(
      AddLessonBatchEvent event, Emitter<LessonState> emit) async {
    try {
      for (final l in event.lessons) {
        await repository.addLesson(l);
      }
      emit(const LessonActionSuccess("Toplu dersler başarıyla eklendi"));
      add(GetLessonsEvent()); // listeyi yenile
    } catch (e) {
      emit(LessonError("Toplu ekleme hatası: $e"));
    }
  }

  Future<void> _onGetDailyLessons(
      GetDailyLessonsEvent event, Emitter<LessonState> emit) async {
    emit(LessonLoading());
    try {
      final allLessons = await repository.getLessons();
      final dailyLessons = allLessons
          .where((l) => l.day == event.day && l.isProcessed == 0)
          .toList();
      emit(DailyLessonsLoaded(event.day, dailyLessons));
    } catch (e) {
      emit(LessonError("Günlük dersler alınamadı: $e"));
    }
  }

  Future<void> _onMarkAttendance(
      MarkAttendanceEvent event, Emitter<LessonState> emit) async {
    try {
      final lesson = event.lesson;
      int hourCount = 1;

      if (!event.attended) {
        if (lesson.hour2 != null && lesson.hour2!.isNotEmpty) hourCount++;
        if (lesson.hour3 != null && lesson.hour3!.isNotEmpty) hourCount++;
        await repository.incrementAttendance(lesson.name!, hourCount);
      }

      // İşlendi olarak işaretle
      final updatedLesson = lesson.copyWith(isProcessed: 1);
      await repository.updateLesson(updatedLesson);

      emit(LessonActionSuccess(event.attended
          ? "✅ ${lesson.name!.toUpperCase()} dersine katıldınız."
          : "❌ ${lesson.name!.toUpperCase()} dersine katılmadınız. Devamsızlık +$hourCount"));
      add(GetDailyLessonsEvent(lesson.day!)); // Listeyi yenile
    } catch (e) {
      emit(LessonError("Devamsızlık işlemi başarısız: $e"));
    }
  }

  Future<void> _onUpdateAttendance(
      UpdateAttendanceEvent event, Emitter<LessonState> emit) async {
    emit(LessonLoading());
    try {
      await repository.updateLesson(event.lesson);
      emit(const LessonActionSuccess("Devamsızlık başarıyla güncellendi."));
    } catch (e) {
      emit(LessonError("Devamsızlık güncelleme hatası: $e"));
    }
  }

  Future<void> _onDeleteAllLessons(
      DeleteAllLessonsEvent event, Emitter<LessonState> emit) async {
    emit(LessonLoading());
    try {
      await repository.deleteAllLessons();
      emit(const LessonActionSuccess("Tüm dersler silindi."));
      add(GetLessonsEvent());
    } catch (e) {
      emit(LessonError("Tüm dersler silinemedi: $e"));
    }
  }
}

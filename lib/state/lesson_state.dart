

import 'package:home_page/featuers/course/data/models/lesson.dart';

abstract class LessonState {}

class LessonInitial extends LessonState {} // Başlangıç durumu

class LessonLoading extends LessonState {} // Veri yükleniyor

class LessonLoaded extends LessonState {
  final List<Lesson> allLessons;
  final List<Lesson> dailyLessons;

  LessonLoaded({required this.allLessons, required this.dailyLessons});
}

class LessonError extends LessonState {
  final String message;

  LessonError(this.message);
}
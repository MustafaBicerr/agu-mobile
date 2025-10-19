import 'package:equatable/equatable.dart';
import '../../domain/entities/lessonEntity.dart';

abstract class LessonState extends Equatable {
  const LessonState();

  @override
  List<Object?> get props => [];
}

class LessonInitial extends LessonState {}

class LessonLoading extends LessonState {}

class LessonLoaded extends LessonState {
  final List<LessonEntity> lessons;

  const LessonLoaded(this.lessons);

  @override
  List<Object?> get props => [lessons];
}

class LessonError extends LessonState {
  final String message;

  const LessonError(this.message);

  @override
  List<Object?> get props => [message];
}

class LessonActionSuccess extends LessonState {
  final String message;

  const LessonActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// 🔹 Günlük derslerin yüklendiği state
class DailyLessonsLoaded extends LessonState {
  final String day;
  final List<LessonEntity> lessons;

  const DailyLessonsLoaded(this.day, this.lessons);

  @override
  List<Object?> get props => [day, lessons];
}

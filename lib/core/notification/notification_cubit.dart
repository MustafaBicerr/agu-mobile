import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lesson.dart';

// Abstraction over your existing notification service
abstract class INotificationService {
  Future<void> scheduleWeeklyLessons(List<Lesson> lessons, int minuteBefore);
  Future<void> scheduleRefectory();
  Future<void> scheduleAttendance();
  Future<void> cancelNotification(int id);
  Future<void> cancelAll();
}

@immutable
class NotificationState {
  final bool loading;
  final bool enabled;
  final bool lessonEnabled;
  final bool refectoryEnabled;
  final bool attendanceEnabled;
  final int minuteBefore;
  final int scheduledCount; // optional info to show in UI
  final String? error;

  const NotificationState({
    this.loading = false,
    this.enabled = false,
    this.lessonEnabled = false,
    this.refectoryEnabled = false,
    this.attendanceEnabled = false,
    this.minuteBefore = 0,
    this.scheduledCount = 0,
    this.error,
  });

  NotificationState copyWith({
    bool? loading,
    bool? enabled,
    bool? lessonEnabled,
    bool? refectoryEnabled,
    bool? attendanceEnabled,
    int? minuteBefore,
    int? scheduledCount,
    String? error,
  }) {
    return NotificationState(
      loading: loading ?? this.loading,
      enabled: enabled ?? this.enabled,
      lessonEnabled: lessonEnabled ?? this.lessonEnabled,
      refectoryEnabled: refectoryEnabled ?? this.refectoryEnabled,
      attendanceEnabled: attendanceEnabled ?? this.attendanceEnabled,
      minuteBefore: minuteBefore ?? this.minuteBefore,
      scheduledCount: scheduledCount ?? this.scheduledCount,
      error: error,
    );
  }
}

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit({
    required INotificationService notificationService,
    required Future<List<Lesson>> Function() getDailyLessons,
    required Future<List<Lesson>> Function() getAllLessons,
  })  : _service = notificationService,
        _getDailyLessons = getDailyLessons,
        _getAllLessons = getAllLessons,
        super(const NotificationState());

  final INotificationService _service;
  final Future<List<Lesson>> Function() _getDailyLessons;
  final Future<List<Lesson>> Function() _getAllLessons;

  // Reads SharedPreferences once and updates state
  Future<void> refreshPrefs() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final p = await SharedPreferences.getInstance();
      final enabled = p.getBool('isNotificationsEnabled') ?? false;
      final lesson = p.getBool('isLessonNotification') ?? false;
      final ref = p.getBool('isRefectoryNotification') ?? false;
      final att = p.getBool('isAttendanceNotification') ?? false;

      final txtMinute = p.getString('txtMinute');
      final minuteBefore = (txtMinute != null && !txtMinute.contains('f'))
          ? int.tryParse(txtMinute) ?? 0
          : 0;

      emit(state.copyWith(
        loading: false,
        enabled: enabled,
        lessonEnabled: lesson,
        refectoryEnabled: ref,
        attendanceEnabled: att,
        minuteBefore: minuteBefore,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  // eski getLessons4Notification()
  Future<void> planAllLessonNotifications() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      
      await refreshPrefs();
      if (!state.enabled) {
        emit(state.copyWith(loading: false));
        return;
      }

      final daily = await _getDailyLessons();
      final all = await _getAllLessons();

      int scheduled = 0;

      if (state.lessonEnabled && all.isNotEmpty) {
        await _service.scheduleWeeklyLessons(all, state.minuteBefore);
        scheduled += all.length;
      }

      if (daily.isEmpty) {
        // keep your existing cancellations
        await _service.cancelNotification(2000);
        await _service.cancelNotification(1000);
      } else {
        if (state.refectoryEnabled) {
          await _service.scheduleRefectory();
          scheduled++;
        }
        if (state.attendanceEnabled) {
          await _service.scheduleAttendance();
          scheduled++;
        }
      }

      emit(state.copyWith(loading: false, scheduledCount: scheduled));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> cancelAll() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await _service.cancelAll();
      emit(state.copyWith(loading: false, scheduledCount: 0));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}

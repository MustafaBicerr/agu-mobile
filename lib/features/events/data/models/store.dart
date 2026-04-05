import 'package:flutter/foundation.dart';
import 'package:agu_mobile/features/events/data/models/events.dart';
import 'package:agu_mobile/features/refectory/data/models/meal.dart';
import 'package:agu_mobile/features/events/data/services/events_service.dart';

class EventsStore {
  EventsStore._();
  static final EventsStore instance = EventsStore._();

  late final EventsService _service;
  bool _initialized = false;

  // GLOBAL listeler (ValueNotifier)
  final ValueNotifier<List<Events>> _eventList =
      ValueNotifier<List<Events>>([]);
  final ValueNotifier<List<Speaker>> _speakerList =
      ValueNotifier<List<Speaker>>([]);
  final ValueNotifier<List<Trip>> _tripList = ValueNotifier<List<Trip>>([]);
  final ValueNotifier<List<Meal>> _mealList = ValueNotifier<List<Meal>>([]);

  void setup() {
    _service = EventsService();
  }

  /// Aynı anda birden fazla [load] çağrısını tek Future’da birleştirir (splash + ana sayfa yarışını önler).
  Future<void>? _loadInFlight;

  Future<void> load({bool force = false}) async {
    if (_initialized && !force) return;

    if (!force && _loadInFlight != null) {
      await _loadInFlight!;
      return;
    }

    final op = _runLoad(force);
    _loadInFlight = op;
    try {
      await op;
    } finally {
      if (identical(_loadInFlight, op)) {
        _loadInFlight = null;
      }
    }
  }

  Future<void> _runLoad(bool force) async {
    final all = await _service.getAll(forceRefresh: force);
    _mealList.value = all.meals;
    _eventList.value = all.events;
    _speakerList.value = all.speakers;
    _tripList.value = all.trips;
    _initialized = true;
  }

  // Getter'lar (eski isimleriyle erişebil)
  List<Meal> get mealList => _mealList.value;
  List<Events> get eventList => _eventList.value;
  List<Speaker> get speakerList => _speakerList.value;
  List<Trip> get tripList => _tripList.value;

  // Dinlemeye uygun getter'lar
  ValueNotifier<List<Meal>> get mealListNotifier => _mealList;
  ValueNotifier<List<Events>> get eventListNotifier => _eventList;
  ValueNotifier<List<Speaker>> get speakerListNotifier => _speakerList;
  ValueNotifier<List<Trip>> get tripListNotifier => _tripList;
}

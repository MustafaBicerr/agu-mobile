import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agu_mobile/features/events/data/models/events.dart';
import 'package:agu_mobile/features/refectory/data/models/meal.dart';

class AllData {
  AllData({
    required this.meals,
    required this.events,
    required this.speakers,
    required this.trips,
    this.signature,
    this.lastUpdate,
  });
  final List<Meal> meals;
  final List<Events> events;
  final List<Speaker> speakers;
  final List<Trip> trips;
  final String? signature;
  final String? lastUpdate;
}

/// Firestore koleksiyonları + [app_cache_meta/sync] ile hafif meta kontrolü + SharedPreferences önbelleği.
class EventsService {
  EventsService();

  static const _kCacheData = 'firestore_bundle_cache_v1';
  static const _kCacheFingerprint = 'firestore_bundle_fp_v1';

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<AllData> getAll({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      try {
        final metaSnap = await _db.collection('app_cache_meta').doc('sync').get();
        final remoteFp = _fingerprintFromMeta(metaSnap);
        final localFp = prefs.getString(_kCacheFingerprint);

        if (remoteFp.isNotEmpty &&
            localFp != null &&
            localFp.isNotEmpty &&
            remoteFp == localFp) {
          final cached = prefs.getString(_kCacheData);
          if (cached != null) {
            return _decodeAllData(jsonDecode(cached) as Map<String, dynamic>);
          }
        }
      } catch (_) {
        final cached = prefs.getString(_kCacheData);
        if (cached != null) {
          return _decodeAllData(jsonDecode(cached) as Map<String, dynamic>);
        }
      }
    }

    try {
      final full = await _fetchAllFromFirestore();
      final metaSnap = await _db.collection('app_cache_meta').doc('sync').get();
      var fp = _fingerprintFromMeta(metaSnap);
      if (fp.isEmpty) {
        fp = _fallbackFingerprint(full);
      }
      await _persist(prefs, full, fp);
      return full;
    } catch (_) {
      final cached = prefs.getString(_kCacheData);
      if (cached != null) {
        return _decodeAllData(jsonDecode(cached) as Map<String, dynamic>);
      }
      rethrow;
    }
  }

  String _fingerprintFromMeta(DocumentSnapshot<Map<String, dynamic>> snap) {
    if (!snap.exists || snap.data() == null) return '';
    final m = snap.data()!;
    final ec = (m['eventsCount'] ?? 0).toString();
    final sc = (m['speakersCount'] ?? 0).toString();
    final tc = (m['tripsCount'] ?? 0).toString();
    final rc = (m['refectoryMenusCount'] ?? 0).toString();
    final ts = m['updatedAt'];
    var ms = 0;
    if (ts is Timestamp) ms = ts.millisecondsSinceEpoch;
    return '$ec|$sc|$tc|$rc|$ms';
  }

  String _fallbackFingerprint(AllData d) {
    return '${d.events.length}|${d.speakers.length}|${d.trips.length}|${d.meals.length}|fallback';
  }

  Future<void> _persist(
    SharedPreferences prefs,
    AllData full,
    String fp,
  ) async {
    final toStore = {
      'data': {
        'refectory': full.meals.map((e) => e.toJson()).toList(),
        'events': full.events.map((e) => e.toJson()).toList(),
        'speakers': full.speakers.map((e) => e.toJson()).toList(),
        'trips': full.trips.map((e) => e.toJson()).toList(),
      }
    };
    try {
      await prefs.setString(_kCacheData, jsonEncode(toStore));
      await prefs.setString(_kCacheFingerprint, fp);
    } catch (e, st) {
      // Çok büyük önbellek Android SharedPreferences limitinde patlayabilir; uygulama çökmesin.
      debugPrint('[EventsService] _persist failed: $e\n$st');
    }
  }

  Future<AllData> _fetchAllFromFirestore() async {
    final results = await Future.wait<QuerySnapshot<Map<String, dynamic>>>([
      _db.collection('refectory_menus').get(),
      _db.collection('events').get(),
      _db.collection('speakers').get(),
      _db.collection('trips').get(),
    ]);

    final mealsSnap = results[0];
    final eventsSnap = results[1];
    final speakersSnap = results[2];
    final tripsSnap = results[3];

    final meals = _mapMeals(mealsSnap);
    final events = eventsSnap.docs
        .map((d) => Events.fromJson(_stripSynced(d.data())))
        .toList();
    final speakers = speakersSnap.docs
        .map((d) => Speaker.fromJson(_stripSynced(d.data())))
        .toList();
    final trips = tripsSnap.docs
        .map((d) => Trip.fromJson(_stripSynced(d.data())))
        .toList();

    return AllData(
      meals: meals,
      events: events,
      speakers: speakers,
      trips: trips,
      signature: null,
      lastUpdate: DateTime.now().toUtc().toIso8601String(),
    );
  }

  Map<String, dynamic> _stripSynced(Map<String, dynamic> raw) {
    final m = Map<String, dynamic>.from(raw);
    m.remove('syncedAt');
    return m;
  }

  List<Meal> _mapMeals(QuerySnapshot<Map<String, dynamic>> qs) {
    final out = <Meal>[];
    for (final doc in qs.docs) {
      final data = Map<String, dynamic>.from(doc.data());
      data.remove('syncedAt');
      final iso = _mealDateToIso(data['date']?.toString(), doc.id);
      data['date'] = iso;
      out.add(Meal.fromJson(data));
    }
    out.sort((a, b) => (a.date ?? '').compareTo(b.date ?? ''));
    return out;
  }

  /// DateTime.parse uyumu için yyyy-MM-dd (belge ID’si veya GG.AA.YYYY dönüşümü).
  String _mealDateToIso(String? cell, String docId) {
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(docId)) {
      return docId;
    }
    final raw = (cell ?? '').trim();
    if (raw.isEmpty) return docId;
    final m = RegExp(r'^(\d{1,2})\.(\d{1,2})\.(\d{4})').firstMatch(raw);
    if (m != null) {
      final dd = m.group(1)!.padLeft(2, '0');
      final mm = m.group(2)!.padLeft(2, '0');
      final yyyy = m.group(3)!;
      return '$yyyy-$mm-$dd';
    }
    try {
      DateTime.parse(raw);
      return raw;
    } catch (_) {
      return docId;
    }
  }

  AllData _decodeAllData(Map<String, dynamic> cached) {
    final data = (cached['data'] ?? {}) as Map<String, dynamic>;
    final mealsArr = (data['refectory'] ?? []) as List<dynamic>;
    final eventsArr = (data['events'] ?? []) as List<dynamic>;
    final speakersArr = (data['speakers'] ?? []) as List<dynamic>;
    final tripsArr = (data['trips'] ?? []) as List<dynamic>;

    return AllData(
      meals: mealsArr
          .map((e) => Meal.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      events: eventsArr
          .map((e) => Events.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      speakers: speakersArr
          .map((e) => Speaker.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      trips: tripsArr
          .map((e) => Trip.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

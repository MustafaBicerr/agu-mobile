import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// MODEL IMPORTLARI — yolları kendi projene göre düzelt
import 'package:home_page/models/events.dart';
import 'package:home_page/models/meal.dart';

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

class EventsService {
  EventsService(this.baseUrl);
  final String baseUrl; // Örn: https://.../exec  (sheet parametresi YOK; hepsi aynı JSON’da)

  static const _kCacheData       = 'all_cache_data';        // tam payload data
  static const _kCacheSignature  = 'all_cache_signature';
  static const _kCacheLastUpdate = 'all_cache_last_update';

  Future<AllData> getAll({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    print('---- getAll called. forceRefresh=$forceRefresh ----');

    if (!forceRefresh) {
      try {
        final meta = await _fetchMetaOnly();
        final localSig  = prefs.getString(_kCacheSignature);
        final localLast = prefs.getString(_kCacheLastUpdate);

        print('META server => sig=${meta.signature}, last=${meta.lastUpdate}');
        print('META local  => sig=$localSig,      last=$localLast');

        final sameSig  = (meta.signature != null && meta.signature == localSig);
        final sameLast = (meta.lastUpdate != null && meta.lastUpdate == localLast);

        if (sameSig || sameLast) {
          print('META match → return CACHED');
          final cached = prefs.getString(_kCacheData);
          if (cached != null) {
            return _decodeAllData(jsonDecode(cached) as Map<String, dynamic>,
                signature: localSig, lastUpdate: localLast);
          }
        } else {
          print('META differs → full fetch.');
        }
      } catch (e) {
        print('META fetch FAILED: $e');
        final cached = prefs.getString(_kCacheData);
        if (cached != null) {
          print('Returning CACHED due to meta failure.');
          return _decodeAllData(jsonDecode(cached) as Map<String, dynamic>,
              signature: prefs.getString(_kCacheSignature),
              lastUpdate: prefs.getString(_kCacheLastUpdate));
        }
      }
    } else {
      print('forceRefresh=true, skip meta → full fetch.');
    }

    // Full fetch
    final full = await _fetchAll();
    print('FULL DONE. refectory=${full.meals.length}, events=${full.events.length}, speakers=${full.speakers.length}, trips=${full.trips.length}');

    // Cache’e yaz
    final toStore = {
      'data': {
        'refectory': full.meals.map((e) => e.toJson()).toList(),
        'events':   full.events.map((e) => e.toJson()).toList(),
        'speakers': full.speakers.map((e) => e.toJson()).toList(),
        'trips':    full.trips.map((e) => e.toJson()).toList(),
      }
    };
    await prefs.setString(_kCacheData, jsonEncode(toStore));
    if (full.signature != null) await prefs.setString(_kCacheSignature, full.signature!);
    if (full.lastUpdate != null) await prefs.setString(_kCacheLastUpdate, full.lastUpdate!);

    print('CACHE updated.');
    return full;
  }

  // ---- Internal helpers ----

  Uri _buildUri(String base, Map<String, String> extra) {
    final uri = Uri.parse(base);
    final merged = Map<String, String>.from(uri.queryParameters)..addAll(extra);
    return uri.replace(queryParameters: merged);
  }

  Future<_Meta> _fetchMetaOnly() async {
    final uri = _buildUri(baseUrl, {
      'meta': '1',
      '_': DateTime.now().millisecondsSinceEpoch.toString(),
    });
    print('META GET $uri');
    final res = await http.get(uri, headers: {'Cache-Control': 'no-cache'});
    print('META status: ${res.statusCode}');
    _ensureJsonOrOk(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final meta = (body['meta'] ?? {}) as Map<String, dynamic>;
    return _Meta(
      signature: meta['signature'] as String?,
      lastUpdate: meta['last_update'] as String?,
    );
  }

  Future<AllData> _fetchAll() async {
    final uri = _buildUri(baseUrl, {
      '_': DateTime.now().millisecondsSinceEpoch.toString(),
    });
    print('FULL GET $uri');
    final res = await http.get(uri, headers: {'Cache-Control': 'no-cache'});
    print('FULL status: ${res.statusCode}');
    _ensureJsonOrOk(res);

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final meta = (body['meta'] ?? {}) as Map<String, dynamic>;
    final data = (body['data'] ?? {}) as Map<String, dynamic>;

    final mealsArr = (data['refectory'] ?? []) as List<dynamic>;
    final eventsArr   = (data['events']   ?? []) as List<dynamic>;
    final speakersArr = (data['speakers'] ?? []) as List<dynamic>;
    final tripsArr    = (data['trips']    ?? []) as List<dynamic>;

    final meals = mealsArr.map((e) => Meal.fromJson(e as Map<String, dynamic>)).toList();
    final events = eventsArr.map((e) => Events.fromJson(e as Map<String, dynamic>)).toList();
    final speakers = speakersArr.map((e) => Speaker.fromJson(e as Map<String, dynamic>)).toList();
    final trips = tripsArr.map((e) => Trip.fromJson(e as Map<String, dynamic>)).toList();

    return AllData(
      meals: meals,
      events: events,
      speakers: speakers,
      trips: trips,
      signature: meta['signature'] as String?,
      lastUpdate: meta['last_update'] as String?,
    );
  }

  void _ensureJsonOrOk(http.Response res) {
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }
    final ct = (res.headers['content-type'] ?? '').toLowerCase();
    // Apps Script bazen JSON'u text/plain ile döndürebilir; o yüzden sadece HTML'i yakala:
    final b = res.body.trimLeft();
    if (b.startsWith('<!doctype html') || b.startsWith('<html')) {
      throw Exception('Server returned HTML (login?) — check deployment access or use googleusercontent URL.');
    }
  }

  AllData _decodeAllData(Map<String, dynamic> cached, {String? signature, String? lastUpdate}) {
    final data = (cached['data'] ?? {}) as Map<String, dynamic>;
    final mealsArr = (data['refectory'] ?? []) as List<dynamic>;
    final eventsArr   = (data['events']   ?? []) as List<dynamic>;
    final speakersArr = (data['speakers'] ?? []) as List<dynamic>;
    final tripsArr    = (data['trips']    ?? []) as List<dynamic>;

    return AllData(
      meals: mealsArr.map((e) => Meal.fromJson(e as Map<String, dynamic>)).toList(),
      events: eventsArr.map((e) => Events.fromJson(e as Map<String, dynamic>)).toList(),
      speakers: speakersArr.map((e) => Speaker.fromJson(e as Map<String, dynamic>)).toList(),
      trips: tripsArr.map((e) => Trip.fromJson(e as Map<String, dynamic>)).toList(),
      signature: signature,
      lastUpdate: lastUpdate,
    );
  }
}

class _Meta {
  final String? signature;
  final String? lastUpdate;
  _Meta({this.signature, this.lastUpdate});
}

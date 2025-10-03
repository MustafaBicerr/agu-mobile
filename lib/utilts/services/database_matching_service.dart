// import 'dart:io';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';

// /// Global map:
// /// {
// ///   "CSE101": {
// ///     "code": "CSE101",
// ///     "name": "Intro to CS",
// ///     "slots": [  // atomic 45-min slots (not paired)
// ///       {"day":"Pazartesi","slot":"10:00-10:45","startMin":600,"place":"B-203","teacher":"X"},
// ///       {"day":"Pazartesi","slot":"11:00-11:45","startMin":660,"place":"B-203","teacher":"X"},
// ///       {"day":"Sali","slot":"14:00-14:45","startMin":840,"place":"C-105","teacher":"Y"},
// ///       ...
// ///     ]
// ///   },
// ///   ...
// /// }
// Map<String, Map<String, dynamic>> sisLessonsByCode = {};

// class SisLessonSyncService {
//   SisLessonSyncService._();
//   static final SisLessonSyncService instance = SisLessonSyncService._();

//   Database? _sisDb;

//   // --- SIS DB open/copy ---

//   Future<Database> _openSisDb() async {
//     if (_sisDb != null) return _sisDb!;
//     final docsDir = await getApplicationDocumentsDirectory();
//     final dstPath = p.join(docsDir.path, 'sis_lessons.db');

//     if (!File(dstPath).existsSync()) {
//       final data =
//           await rootBundle.load('assets/db/lessons.db'); // corrected path
//       final bytes =
//           data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
//       await File(dstPath).writeAsBytes(bytes, flush: true);
//     }

//     _sisDb = await openDatabase(dstPath, readOnly: true);
//     return _sisDb!;
//   }

//   // --- Public: Build global map from SIS by course codes ---

//   Future<Map<String, Map<String, dynamic>>> buildGlobalMapFromSisByCodes(
//     List<String> courseCodes, {
//     String tableName = 'lessons', // adjust if different in SIS
//     String colCode = 'code',
//     String colName = 'name',
//     String colDay = 'day',
//     String colStart =
//         'start_time', // if SIS has start/end per row (45-min or a span)
//     String colEnd = 'end_time',
//     String colPlace = 'classroom',
//     String colTeacher = 'teacher',
//     String?
//         colHourText, // if SIS has "10:00-10:45" as a single text column, give its name
//     int slotMinutes = 45,
//     int breakMinutes = 15, // 15-min gap between slots (e.g., 10:45 -> 11:00)
//   }) async {
//     sisLessonsByCode.clear();
//     if (courseCodes.isEmpty) return sisLessonsByCode;

//     final db = await _openSisDb();
//     final placeholders = List.filled(courseCodes.length, '?').join(',');
//     final sql = '''
//       SELECT
//         $colCode   AS code,
//         $colName   AS name,
//         $colDay    AS day,
//         $colPlace  AS place,
//         $colTeacher AS teacher,
//         $colStart  AS startTxt,
//         $colEnd    AS endTxt
//         ${colHourText != null ? ', $colHourText AS hourTxt' : ''}
//       FROM $tableName
//       WHERE $colCode IN ($placeholders)
//       ORDER BY $colCode, $colDay, $colStart
//     ''';

//     final rows = await db.rawQuery(sql, courseCodes);

//     for (final r in rows) {
//       final code = (r['code'] ?? '').toString();
//       final name = (r['name'] ?? '').toString();
//       final day = (r['day'] ?? '').toString();
//       final place = (r['place'] ?? '').toString();
//       final teacher = (r['teacher'] ?? '').toString();
//       final startTxt = (r['startTxt'] ?? '').toString();
//       final endTxt = (r['endTxt'] ?? '').toString();
//       final hourTxt = (r['hourTxt'] ?? '').toString();

//       if (code.isEmpty || day.isEmpty) continue;

//       sisLessonsByCode.putIfAbsent(
//           code,
//           () => {
//                 'code': code,
//                 'name': name.isEmpty ? code : name,
//                 'slots': <Map<String, dynamic>>[],
//               });

//       // Extract atomic 45-min slots from this row
//       final slots = _extractSlotsFromRow(
//         hourTxt: hourTxt,
//         startTxt: startTxt,
//         endTxt: endTxt,
//         slotMinutes: slotMinutes,
//         breakMinutes: breakMinutes,
//       );

//       for (final s in slots) {
//         final startMin = _startMinutesOfSlot(s);
//         sisLessonsByCode[code]!['slots'].add({
//           'day': day,
//           'slot': s,
//           'startMin': startMin,
//           'place': place,
//           'teacher': teacher,
//         });
//       }
//     }

//     // Optional: sort slots per code for stable order
//     for (final entry in sisLessonsByCode.entries) {
//       final list = (entry.value['slots'] as List<dynamic>);
//       list.sort((a, b) {
//         final da = a['day'].toString();
//         final dbb = b['day'].toString();
//         if (da != dbb) return da.compareTo(dbb);
//         return (a['startMin'] as int).compareTo(b['startMin'] as int);
//       });
//     }

//     return sisLessonsByCode;
//   }

//   // --- Public: Insert to friend's DB (pair slots into hour1/hour2) ---

//   Future<void> insertFromFirebase(
//     Map<String, Map<String, dynamic>> source,
//     Database friendDb, {
//     String friendTable = 'lessons',
//   }) async {
//     await friendDb.execute('''
//       CREATE TABLE IF NOT EXISTS $friendTable (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         name TEXT,
//         place TEXT,
//         day TEXT,
//         hour1 TEXT,
//         hour2 TEXT,
//         teacher TEXT,
//         attendance INTEGER DEFAULT 0,
//         isProcessed INTEGER DEFAULT 0
//       )
//     ''');

//     await friendDb.execute('''
//       CREATE INDEX IF NOT EXISTS idx_lessons_unique
//       ON $friendTable(name, day, hour1, hour2)
//     ''');

//     // Build rows and insert within a transaction
//     await friendDb.transaction((txn) async {
//       for (final codeEntry in source.values) {
//         final courseName = (codeEntry['name'] ?? codeEntry['code']).toString();
//         final slots =
//             List<Map<String, dynamic>>.from(codeEntry['slots'] as List);

//         // Group by day
//         final Map<String, List<Map<String, dynamic>>> byDay = {};
//         for (final s in slots) {
//           final d = s['day'].toString();
//           byDay.putIfAbsent(d, () => []).add(s);
//         }
//         // Pair within each day
//         for (final day in byDay.keys) {
//           final daySlots = byDay[day]!
//             ..sort((a, b) =>
//                 (a['startMin'] as int).compareTo(b['startMin'] as int));
//           int i = 0;
//           while (i < daySlots.length) {
//             final cur = daySlots[i];
//             Map<String, dynamic>? next;
//             if (i + 1 < daySlots.length) {
//               final n = daySlots[i + 1];
//               // Strict pairing: same place+teacher and approx 60 min gap (45 + 15)
//               final sameMeta = (n['place'] == cur['place']) &&
//                   (n['teacher'] == cur['teacher']);
//               final gap = (n['startMin'] as int) - (cur['startMin'] as int);
//               final okGap = gap >= 55 && gap <= 70; // tolerant window
//               if (sameMeta && okGap) next = n;
//             }

//             final row = {
//               'name': courseName,
//               'place': cur['place'] ?? '',
//               'day': day,
//               'hour1': cur['slot'] ?? '',
//               'hour2': next != null ? (next['slot'] ?? '') : '',
//               'teacher': cur['teacher'] ?? '',
//               'attendance': 0,
//               'isProcessed': 0,
//             };

//             // Duplicate check
//             final dup = await txn.query(
//               friendTable,
//               columns: ['id'],
//               where: 'name = ? AND day = ? AND hour1 = ? AND hour2 = ?',
//               whereArgs: [row['name'], row['day'], row['hour1'], row['hour2']],
//               limit: 1,
//             );
//             if (dup.isEmpty) {
//               await txn.insert(friendTable, row,
//                   conflictAlgorithm: ConflictAlgorithm.ignore);
//             }

//             i += (next != null) ? 2 : 1;
//           }
//         }
//       }
//     });
//   }

//   // --- Helpers: slot parsing ---

//   /// Returns list of atomic slot strings "HH:mm-HH:mm"
//   List<String> _extractSlotsFromRow({
//     required String hourTxt,
//     required String startTxt,
//     required String endTxt,
//     int slotMinutes = 45,
//     int breakMinutes = 15,
//   }) {
//     final List<String> out = [];

//     String normalize(String s) => s.trim().replaceAll('.', ':');

//     // A) If hourTxt looks like "10:00-10:45" or multiple separated by ',', ';', ' '
//     if (hourTxt.isNotEmpty) {
//       final raw = normalize(hourTxt);
//       // split by separators while keeping token with '-'
//       final parts = raw
//           .split(RegExp(r'[;,]'))
//           .expand((e) => e.split(RegExp(r'\s+')))
//           .toList();
//       for (final t in parts) {
//         final tok = t.trim();
//         if (tok.contains('-') && _isValidSlot(tok)) {
//           out.add(_formatSlotString(tok));
//         }
//       }
//       if (out.isNotEmpty) return out;
//     }

//     // B) Else, if start/end present: expand into 45-min slots with 15-min breaks
//     final sTxt = normalize(startTxt);
//     final eTxt = normalize(endTxt);
//     final sMin = _parseHmToMin(sTxt);
//     final eMin = _parseHmToMin(eTxt);
//     if (sMin != null && eMin != null && eMin > sMin) {
//       int cur = sMin;
//       while (cur + slotMinutes <= eMin) {
//         final slotStart = cur;
//         final slotEnd = cur + slotMinutes;
//         out.add('${_fmt(slotStart)}-${_fmt(slotEnd)}');
//         // next start after 15-min break
//         cur = slotEnd + breakMinutes;
//       }
//       if (out.isNotEmpty) return out;
//     }

//     // C) Fallback: if startTxt contains "HH:mm-HH:mm" directly
//     if (sTxt.contains('-') && _isValidSlot(sTxt)) {
//       out.add(_formatSlotString(sTxt));
//     }

//     return out;
//   }

//   bool _isValidSlot(String s) {
//     final parts = s.split('-');
//     if (parts.length != 2) return false;
//     final a = _parseHmToMin(parts[0]);
//     final b = _parseHmToMin(parts[1]);
//     return a != null && b != null && b > a;
//   }

//   String _formatSlotString(String s) {
//     final parts = s.split('-');
//     final a = _parseHmToMin(parts[0])!;
//     final b = _parseHmToMin(parts[1])!;
//     return '${_fmt(a)}-${_fmt(b)}';
//     // normalizes to HH:mm-HH:mm
//   }

//   int _startMinutesOfSlot(String slot) {
//     final a = slot.split('-').first;
//     return _parseHmToMin(a)!;
//   }

//   int? _parseHmToMin(String txt) {
//     final t = txt.trim().replaceAll('.', ':');
//     final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(t);
//     if (m == null) return null;
//     final h = int.parse(m.group(1)!);
//     final mm = int.parse(m.group(2)!);
//     if (h < 0 || h > 23 || mm < 0 || mm > 59) return null;
//     return h * 60 + mm;
//   }

//   String _fmt(int minutes) {
//     final h = (minutes ~/ 60).toString().padLeft(2, '0');
//     final m = (minutes % 60).toString().padLeft(2, '0');
//     return '$h:$m';
//   }
// }

////////////////////////////////////////////

import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:home_page/notifications.dart';
import 'package:home_page/utilts/services/dbHelper.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

Map<String, Map<String, dynamic>> sisLessonsByCode = {};

class SisLessonSyncService {
  SisLessonSyncService._();
  static final SisLessonSyncService instance = SisLessonSyncService._();

  Database? _sisDb;

  Future<Database> _openSisDb({bool verbose = true}) async {
    printColored("Debug başlıyor", "32");
    if (_sisDb != null) return _sisDb!;
    final docsDir = await getApplicationDocumentsDirectory();
    final dstPath = p.join(docsDir.path, 'sis_lessons.db');

    if (verbose) {
      print('[SIS] target copy path: $dstPath');
    }

    if (!File(dstPath).existsSync()) {
      if (verbose)
        print('[SIS] copying asset: assets/db/lessons.db -> $dstPath');
      final data = await rootBundle.load('assets/db/lessons.db');
      final bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(dstPath).writeAsBytes(bytes, flush: true);
    } else {
      if (verbose) print('[SIS] file already exists, skipping copy');
    }

    _sisDb = await openDatabase(dstPath, readOnly: true);
    if (verbose) {
      final sizeKb = await _sqliteSizeKB(_sisDb!);
      final tables = await _listTables(_sisDb!);
      print(
          '[SIS] opened. size: ${sizeKb.toStringAsFixed(1)} KB | tables: $tables');
    }
    return _sisDb!;
  }

  Future<Map<String, Map<String, dynamic>>> buildGlobalMapFromSisByCodes(
    List<String> courseCodes, {
    String? tableName, // null ise otomatik bul
    String colCode = 'code',
    String colName = 'name',
    String colDay = 'day',
    String colStart = 'start_time',
    String colEnd = 'end_time',
    String colPlace = 'classroom',
    String colTeacher = 'teacher',
    String? colHourText,
    int slotMinutes = 45,
    int breakMinutes = 15,
    bool verbose = true,
  }) async {
    // debugSisSchema(); // uygulama açılır açılmaz çalışır
    sisLessonsByCode.clear();
    if (verbose) print('[SIS] buildGlobalMap: incoming codes: $courseCodes');
    if (courseCodes.isEmpty) return sisLessonsByCode;

    final db = await _openSisDb(verbose: verbose);

    for (final code in courseCodes) {
      // tablo sabitse direkt onu kullan; degilse otomatik bul
      Map<String, dynamic>? found;
      String effectiveTable = tableName ?? '';
      bool exact = true;

      if (effectiveTable.isEmpty) {
        found = await _findSisTableForCode(db, code, verbose: verbose);
        if (found == null) {
          print('[SIS] NOT FOUND in any SIS table for code="$code"');
          continue;
        }
        effectiveTable = found['table'] as String;
        exact = found['exact'] == true;
      }

      await _debugTableColumns(db, effectiveTable);

      final whereSql = exact ? '$colCode = ?' : "$colCode LIKE ?";
      final whereArg = exact
          ? code
          : (code.contains('(') ? code.split('(').first : code) + '%';

      final sql = '''
  SELECT 
    name,
    place,
    day,
    hour1,
    hour2,
    teacher,
    attendance,
    isProcessed
  FROM $effectiveTable
  WHERE name IN (?)
  ORDER BY name, day, hour1
''';

      if (verbose) {
        print(
            '[SIS] TABLE="$effectiveTable" exact=$exact WHERE="$whereSql" arg="$whereArg"');
        print('[SIS] query: $sql');
      }

      List<Map<String, Object?>> rows = [];
      try {
        rows = await db.rawQuery(sql, [whereArg]);
      } catch (e) {
        print('[SIS][ERROR] Query failed on $effectiveTable: $e');
        continue;
      }

      print(
          '[SIS] $effectiveTable -> fetched ${rows.length} row(s) for "$code"');

      for (final r in rows) {
        final codeVal = (r['code'] ?? '').toString();
        final nameVal = (r['name'] ?? '').toString();
        final day = (r['day'] ?? '').toString();
        final place = (r['place'] ?? '').toString();
        final teacher = (r['teacher'] ?? '').toString();
        final startTxt = (r['startTxt'] ?? '').toString();
        final endTxt = (r['endTxt'] ?? '').toString();
        final hourTxt = (r['hourTxt'] ?? '').toString();

        if (codeVal.isEmpty || day.isEmpty) {
          if (verbose) print('[SIS] skip row (missing code/day): $r');
          continue;
        }

        sisLessonsByCode.putIfAbsent(
            codeVal,
            () => {
                  'code': codeVal,
                  'name': nameVal.isEmpty ? codeVal : nameVal,
                  'slots': <Map<String, dynamic>>[],
                });

        final slots = _extractSlotsFromRow(
          hourTxt: hourTxt,
          startTxt: startTxt,
          endTxt: endTxt,
          slotMinutes: slotMinutes,
          breakMinutes: breakMinutes,
        );

        if (verbose) {
          print(
              '[SIS] $codeVal $day -> slots parsed: $slots (hourTxt="$hourTxt" start="$startTxt" end="$endTxt")');
        }

        for (final s in slots) {
          final startMin = _startMinutesOfSlot(s);
          sisLessonsByCode[codeVal]!['slots'].add({
            'day': day,
            'slot': s,
            'startMin': startMin,
            'place': place,
            'teacher': teacher,
          });
        }
      }
    }

    for (final e in sisLessonsByCode.entries) {
      final slots = (e.value['slots'] as List).length;
      print('[SIS] code=${e.key} name=${e.value['name']} slotCount=$slots');
    }

    // stabilite icin sort
    for (final entry in sisLessonsByCode.entries) {
      final list = (entry.value['slots'] as List<dynamic>);
      list.sort((a, b) {
        final da = a['day'].toString();
        final dbb = b['day'].toString();
        if (da != dbb) return da.compareTo(dbb);
        return (a['startMin'] as int).compareTo(b['startMin'] as int);
      });
    }

    return sisLessonsByCode;
  }

  Future<void> insertFromFirebase(
    Map<String, Map<String, dynamic>> source,
    Database friendDb, {
    String friendTable = 'lessons',
    bool verbose = true,
  }) async {
    if (verbose) {
      final sizeKb = await _sqliteSizeKB(friendDb);
      final tables = await _listTables(friendDb);
      print(
          '[FRIEND] opened DB. size: ${sizeKb.toStringAsFixed(1)} KB | tables: $tables');
    }

    await friendDb.execute('''
      CREATE TABLE IF NOT EXISTS $friendTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        place TEXT,
        day TEXT,
        hour1 TEXT,
        hour2 TEXT,
        teacher TEXT,
        attendance INTEGER DEFAULT 0,
        isProcessed INTEGER DEFAULT 0
      )
    ''');

    await friendDb.execute('''
      CREATE INDEX IF NOT EXISTS idx_lessons_unique
      ON $friendTable(name, day, hour1, hour2)
    ''');

    final beforeCount = Sqflite.firstIntValue(
          await friendDb.rawQuery('SELECT COUNT(*) FROM $friendTable'),
        ) ??
        0;
    if (verbose) print('[FRIEND] row count before: $beforeCount');

    int inserted = 0;
    int skippedDup = 0;

    await friendDb.transaction((txn) async {
      for (final codeEntry in source.values) {
        final courseName = (codeEntry['name'] ?? codeEntry['code']).toString();
        final slots =
            List<Map<String, dynamic>>.from(codeEntry['slots'] as List);

        if (verbose) {
          print(
              '[FRIEND] processing course="$courseName" slotCount=${slots.length}');
        }

        final Map<String, List<Map<String, dynamic>>> byDay = {};
        for (final s in slots) {
          final d = s['day'].toString();
          byDay.putIfAbsent(d, () => []).add(s);
        }

        for (final day in byDay.keys) {
          final daySlots = byDay[day]!
            ..sort((a, b) =>
                (a['startMin'] as int).compareTo(b['startMin'] as int));
          int i = 0;
          while (i < daySlots.length) {
            final cur = daySlots[i];
            Map<String, dynamic>? next;
            if (i + 1 < daySlots.length) {
              final n = daySlots[i + 1];
              final sameMeta = (n['place'] == cur['place']) &&
                  (n['teacher'] == cur['teacher']);
              final gap = (n['startMin'] as int) - (cur['startMin'] as int);
              final okGap = gap >= 55 && gap <= 70;
              if (sameMeta && okGap) next = n;
            }

            final dayTr = normalizeDayToTr(day);
            final h1 = normalizeSlot(cur['slot'] ?? '');
            final h2 = next != null ? normalizeSlot(next['slot'] ?? '') : '';

            final row = {
              'name': courseName,
              'place': cur['place'] ?? '',
              'day': dayTr,
              'hour1': h1,
              'hour2': h2,
              'teacher': cur['teacher'] ?? '',
              'attendance': 0,
              'isProcessed': 0,
            };

            if (verbose) {
              print('[FRIEND] try insert -> '
                  'name="${row['name']}" day="${row['day']}" '
                  'hour1="${row['hour1']}" hour2="${row['hour2']}" '
                  'place="${row['place']}" teacher="${row['teacher']}"');
            }

            final dup = await txn.query(
              friendTable,
              columns: ['id'],
              where: 'name = ? AND day = ? AND hour1 = ? AND hour2 = ?',
              whereArgs: [row['name'], row['day'], row['hour1'], row['hour2']],
              limit: 1,
            );
            if (dup.isEmpty) {
              final id = await txn.insert(friendTable, row,
                  conflictAlgorithm: ConflictAlgorithm.ignore);
              if (verbose) print('[FRIEND] inserted rowId=$id');
              inserted++;
            } else {
              if (verbose) print('[FRIEND] skipped (duplicate)');
              skippedDup++;
            }

            i += (next != null) ? 2 : 1;
          }
        }
      }
    });

    final afterCount = Sqflite.firstIntValue(
          await friendDb.rawQuery('SELECT COUNT(*) FROM $friendTable'),
        ) ??
        0;
    final sizeKbAfter = await _sqliteSizeKB(friendDb);

    if (verbose) {
      print(
          '[FRIEND] row count after: $afterCount (delta=${afterCount - beforeCount})');
      print('[FRIEND] inserted=$inserted skippedDuplicate=$skippedDup');
      print('[FRIEND] DB size now: ${sizeKbAfter.toStringAsFixed(1)} KB');
    }
  }

  // ---- Helpers -------------------------------------------------------------

  Future<double> _sqliteSizeKB(Database db) async {
    final pc =
        Sqflite.firstIntValue(await db.rawQuery('PRAGMA page_count')) ?? 0;
    final ps =
        Sqflite.firstIntValue(await db.rawQuery('PRAGMA page_size')) ?? 0;
    final bytes = pc * ps;
    return bytes / 1024.0;
  }

  Future<List<String>> _listTables(Database db) async {
    final rows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
    );
    return rows.map((e) => e['name'].toString()).toList();
  }

  List<String> _extractSlotsFromRow({
    required String hourTxt,
    required String startTxt,
    required String endTxt,
    int slotMinutes = 45,
    int breakMinutes = 15,
  }) {
    final List<String> out = [];
    String normalize(String s) => s.trim().replaceAll('.', ':');

    if (hourTxt.isNotEmpty) {
      final raw = normalize(hourTxt);
      final parts = raw
          .split(RegExp(r'[;,]'))
          .expand((e) => e.split(RegExp(r'\s+')))
          .toList();
      for (final t in parts) {
        final tok = t.trim();
        if (tok.contains('-') && _isValidSlot(tok)) {
          out.add(_formatSlotString(tok));
        }
      }
      if (out.isNotEmpty) return out;
    }

    final sTxt = normalize(startTxt);
    final eTxt = normalize(endTxt);
    final sMin = _parseHmToMin(sTxt);
    final eMin = _parseHmToMin(eTxt);
    if (sMin != null && eMin != null && eMin > sMin) {
      int cur = sMin;
      while (cur + slotMinutes <= eMin) {
        final slotStart = cur;
        final slotEnd = cur + slotMinutes;
        out.add('${_fmt(slotStart)}-${_fmt(slotEnd)}');
        cur = slotEnd + breakMinutes;
      }
      if (out.isNotEmpty) return out;
    }

    if (sTxt.contains('-') && _isValidSlot(sTxt)) {
      out.add(_formatSlotString(sTxt));
    }
    return out;
  }

  bool _isValidSlot(String s) {
    final parts = s.split('-');
    if (parts.length != 2) return false;
    final a = _parseHmToMin(parts[0]);
    final b = _parseHmToMin(parts[1]);
    return a != null && b != null && b > a;
  }

  String _formatSlotString(String s) {
    final parts = s.split('-');
    final a = _parseHmToMin(parts[0])!;
    final b = _parseHmToMin(parts[1])!;
    return '${_fmt(a)}-${_fmt(b)}';
  }

  int _startMinutesOfSlot(String slot) {
    final a = slot.split('-').first;
    return _parseHmToMin(a)!;
  }

  int? _parseHmToMin(String txt) {
    final t = txt.trim().replaceAll('.', ':');
    final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(t);
    if (m == null) return null;
    final h = int.parse(m.group(1)!);
    final mm = int.parse(m.group(2)!);
    if (h < 0 || h > 23 || mm < 0 || mm > 59) return null;
    return h * 60 + mm;
  }

  String _fmt(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  // database_matching_service.dart

  String normalizeDayToTr(String raw) {
    final s = raw.trim().toLowerCase();
    switch (s) {
      case 'mon':
      case 'monday':
        return 'Pazartesi';
      case 'tue':
      case 'tuesday':
        return 'Salı';
      case 'wed':
      case 'wednesday':
        return 'Çarşamba';
      case 'thu':
      case 'thursday':
        return 'Perşembe';
      case 'fri':
      case 'friday':
        return 'Cuma';
      case 'sat':
      case 'saturday':
        return 'Cumartesi';
      case 'sun':
      case 'sunday':
        return 'Pazar';
      default:
        return raw; // zaten Türkçe ise
    }
  }

  String normalizeSlot(String slot) {
    final t = slot.trim().replaceAll('.', ':');
    final m = RegExp(r'^(\d{1,2}):(\d{2})-(\d{1,2}):(\d{2})$').firstMatch(t);
    if (m == null) return t;
    String pad(String x) => x.padLeft(2, '0');
    return '${pad(m.group(1)!)}:${m.group(2)!}-${pad(m.group(3)!)}:${m.group(4)!}';
  }
}

Future<Database> openFriendDbViaHelper() async {
  final helper = Dbhelper();
  final Database db = await helper.db; // Dbhelper içinde db getter’ı var
  return db;
}

Future<Map<String, dynamic>?> _findSisTableForCode(Database db, String code,
    {bool verbose = true}) async {
  final tables = [
    'compdata',
    'eeedata',
    'iedata',
    'arcdata',
    'badata',
    'pscdata'
  ];
  // 1) exact match
  for (final t in tables) {
    final c = Sqflite.firstIntValue(await db
            .rawQuery('SELECT COUNT(*) FROM $t WHERE code = ?', [code])) ??
        0;
    if (verbose) print('[SIS/PROBE] $t exact=$c for code="$code"');
    if (c > 0) return {'table': t, 'exact': true};
  }
  // 2) LIKE base (ECE581(01) -> ECE581%)
  final base = code.contains('(') ? code.split('(').first : code;
  for (final t in tables) {
    final c = Sqflite.firstIntValue(await db.rawQuery(
            "SELECT COUNT(*) FROM $t WHERE code LIKE ?", ['$base%'])) ??
        0;
    if (verbose) print('[SIS/PROBE] $t like=$c for base="$base"');
    if (c > 0) return {'table': t, 'exact': false};
  }
  return null;
}

Future<void> _debugTableColumns(Database db, String table) async {
  final info = await db.rawQuery("PRAGMA table_info($table)");
  final cols = info.map((e) => e['name']).toList();
  print('[SIS/SCHEMA] $table columns: $cols');
}

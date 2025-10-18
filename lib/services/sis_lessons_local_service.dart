// // lib/utilts/services/sis_lessons_local_service.dart
// import 'package:home_page/data/database_service.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:home_page/utilts/models/sisLessons.dart';
// import 'package:home_page/utilts/models/sisLessons_db_adapter.dart';
// // import 'package:home_page/utilts/services/database_service.dart';

// /// Eski sisLessonsAPI.fetchAllLessonData() ile aynı dönüş:
// /// { "compData": List<sisLessons>, "ieData": List<sisLessons>, ... }
// class SisLessonsLocalService {
//   /// İstersen sadece seçili tabloları doldur (performans için)
//   Future<Map<String, List<sisLessons>>> fetchAllLessonData({
//     List<String>? includeTables, // örn: ['compdata','iedata']
//   }) async {
//     final Database db = await DatabaseService.I.db;

//     // DB’deki tabloların adlarını al
//     final tables = await db.rawQuery(
//         "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name");
//     final allNames = tables.map((e) => (e['name'] as String)).toList();

//     // JSON’daki gibi anahtar üret (compData, ieData ...) -> tablo adları genelde lowercase (compdata)
//     Map<String, String> keyToTable = {};
//     for (final t in allNames) {
//       // compdata -> compData, iedata -> ieData gibi basit dönüşüm
//       final key = _toJsonLikeKey(t);
//       keyToTable[key] = t;
//     }

//     final result = <String, List<sisLessons>>{};
//     final targets = includeTables == null
//         ? keyToTable.entries
//         : keyToTable.entries.where((e) => includeTables.contains(e.value));

//     for (final e in targets) {
//       final key = e.key; // "compData"
//       final table = e.value; // "compdata"
//       final rows = await db.rawQuery("SELECT * FROM $table");
//       final list = rows.map((m) => SisLessonsDb.fromDb(m)).toList();
//       result[key] = list;
//     }
//     return result;
//   }

//   String _toJsonLikeKey(String table) {
//     // "compdata" -> "compData", "ie" -> "ie", "elektrikelektronik" -> "elektrikelektronik"
//     if (table.endsWith("data") && table.length > 4) {
//       final stem = table.substring(0, table.length - 4);
//       return "${stem}Data";
//     }
//     // fallback: camelCase’e çok kasmadan ilk parçayı koru
//     return table;
//   }
// }

import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import '../models/lesson_data.dart';

class LessonsRepository {
  final _svc = DatabaseService.I;

  /// Tek bölüm tablosundan gün/saat sırasıyla haftalık dersleri getir
  Future<List<Lesson>> weeklyFromTable(String table,
      {List<String>? dersKodlari}) async {
    final d = await _svc.db;
    final List<Map<String, Object?>> rows;
    if (dersKodlari != null && dersKodlari.isNotEmpty) {
      final placeholders = List.filled(dersKodlari.length, '?').join(',');
      rows = await d.rawQuery(
        "SELECT * FROM $table WHERE ders_kodu IN ($placeholders) "
        "ORDER BY dow, start_min",
        dersKodlari,
      );
    } else {
      rows = await d
          .rawQuery("SELECT * FROM $table ORDER BY dow, start_min LIMIT 500");
    }
    return rows.map(Lesson.fromMap).toList();
  }

  /// Birden çok bölüm tablosunu tek listede birleştir (UNION ALL)
  Future<List<Lesson>> weeklyFromMultiTables(List<String> tables,
      {List<String>? dersKodlari}) async {
    if (tables.isEmpty) return [];
    final d = await _svc.db;

    final where = (dersKodlari != null && dersKodlari.isNotEmpty)
        ? "WHERE ders_kodu IN (${List.filled(dersKodlari.length, '?').join(',')})"
        : "";

    final unionSql =
        tables.map((t) => "SELECT * FROM $t $where").join(" UNION ALL ");
    final sql = "$unionSql ORDER BY dow, start_min";

    final rows = await d.rawQuery(sql, dersKodlari ?? const []);
    return rows.map(Lesson.fromMap).toList();
  }

  /// Basit arama (ders kodu / ders adı / hoca)
  Future<List<Lesson>> search(String table, String q, {int limit = 100}) async {
    final d = await _svc.db;
    final like = '%${q.toUpperCase()}%';
    final rows = await d.rawQuery(
      "SELECT * FROM $table WHERE "
      "UPPER(ders_kodu) LIKE ? OR UPPER(ders_adi) LIKE ? OR UPPER(ogretim_gorevlisi) LIKE ? "
      "ORDER BY dow, start_min LIMIT ?",
      [like, like, like, limit],
    );
    return rows.map(Lesson.fromMap).toList();
  }

  /// Gün filtresi
  Future<List<Lesson>> byDay(String table, int dow) async {
    final d = await _svc.db;
    final rows = await d
        .rawQuery("SELECT * FROM $table WHERE dow=? ORDER BY start_min", [dow]);
    return rows.map(Lesson.fromMap).toList();
  }
}

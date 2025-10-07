import 'dart:core';

import 'package:home_page/utilts/models/lesson.dart';
import 'package:home_page/utilts/services/database_matching_service.dart';
import 'package:path/path.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class Dbhelper {
  Database? _db;

  Future<void> incrementAttendanceByCount(String name, int count) async {
    Database db = await this.db;
    String lowerName = name.trim().toLowerCase();
    await db.rawUpdate(
      'UPDATE lessons SET attendance = attendance + ? WHERE LOWER(TRIM(name)) = ?',
      [count, lowerName],
    );
  }

  Future<int> getAttendanceByLessonName(String name) async {
    Database db = await this.db;
    String lowerName = name.trim().toLowerCase();
    var result = await db.rawQuery(
      'SELECT attendance FROM lessons WHERE LOWER(TRIM(name)) = ? LIMIT 1',
      [lowerName],
    );
    if (result.isNotEmpty) {
      return result.first['attendance'] as int;
    } else {
      return 0;
    }
  }

  Future<void> incrementAttendanceForLessonNameLowercase(String name) async {
    Database db = await this.db;
    String lowerName = name.trim().toLowerCase(); // ← güncel hali
    await db.rawUpdate(
      'UPDATE lessons SET attendance = attendance + 1 WHERE LOWER(TRIM(name)) = ?',
      [lowerName],
    );
  }

  Future<Database> get db async {
    _db ??= await initializeDb();

    return _db!;
  }

  Future<Database> initializeDb() async {
    String dbPath = join(await getDatabasesPath(), "timeTable.db");
    var timeTableDb = openDatabase(dbPath, version: 1, onCreate: createDb);
    return timeTableDb;
  }

  void createDb(Database db, int version) async {
    await db.execute(
        "Create table lessons(id integer primary key, name text, place text, day text, hour1 text, hour2 text, hour3 text, teacher text, attendance INTEGER DEFAULT 0, isProcessed INTEGER DEFAULT 0)");
  }

  Future<List<Lesson>> getLessons() async {
    Database db = await this.db;
    var result = await db.query("lessons");
    return List.generate(result.length, (i) {
      return Lesson.fromObject(result[i]);
    });
  }

  Future<int> insert(Lesson lesson) async {
    Database db = await this.db;
    var result = await db.insert("lessons", lesson.toMap());
    return result;
  }

  Future<int> delete(int id) async {
    Database db = await this.db;
    var result = await db.rawDelete("DELETE FROM lessons WHERE id = ?", [id]);
    return result;
  }

  Future<int> update(Lesson lesson) async {
    Database db = await this.db;
    var result = await db.update("lessons", lesson.toMap(),
        where: "id =?", whereArgs: [lesson.id]);
    return result;
  }

  Future<int> updateAttendance(Lesson lesson) async {
    Database db = await this.db;
    var result = await db.update(
      "lessons",
      {'attendance': lesson.attendance},
      where: "name = ?",
      whereArgs: [lesson.name],
    );
    return result;
  }

  void deleteDatabaseFile() async {
    String dbPath = join(await getDatabasesPath(), "timeTable.db");
    Database db = await openDatabase(dbPath);
    // await db.delete("timeTable");
    await db.delete("lessons");
    await db.close(); // Veritabanını tamamen sil
  }
}

// Dbhelper içine ekle (sqflite import'ları zaten var kabul ediyorum).
// Amaç: Aynı dersi (mantıksal olarak) DB'de varsa INSERT etme.

extension _StringNorm on String {
  String norm() => trim().replaceAll(RegExp(r'\s+'), ' ');
}

class DedupHelpers {
  // Bellek içi anahtar: name|day|hour1|hour2|place|teacher
  static String lessonKey({
    required String name,
    required String day,
    String? hour1,
    String? hour2,
    String? hour3,
    required String place,
    required String teacher,
  }) {
    return [
      name.norm().toUpperCase(),
      day.norm().toUpperCase(),
      (hour1 ?? '').norm().toUpperCase(),
      (hour2 ?? '').norm().toUpperCase(),
      place.norm().toUpperCase(),
      teacher.norm().toUpperCase(),
    ].join('|');
  }
}

extension DbhelperDedup on Dbhelper {
  /// DB'de bu ders zaten varsa true döner (tam eşleşme).
  Future<bool> lessonExists({
    required String name,
    required String day,
    String? hour1,
    String? hour2,
    required String place,
    required String teacher,
  }) async {
    final Database d = await db;
    final res = await d.rawQuery(
      '''
      SELECT 1 
      FROM lessons 
      WHERE name = ? AND day = ?
        AND IFNULL(hour1,'') = ?
        AND IFNULL(hour2,'') = ?
        AND place = ? AND teacher = ?
      LIMIT 1
      ''',
      [
        name.trim(),
        day.trim(),
        (hour1 ?? '').trim(),
        (hour2 ?? '').trim(),
        place.trim(),
        teacher.trim(),
      ],
    );
    return res.isNotEmpty;
  }

  /// Tek dersi: yoksa ekler, varsa atlar. attendance/isProcessed korunmuş olur.
  /// true => insert edildi, false => skip edildi.
  Future<bool> insertIfNotExistsPreserveAttendance(Lesson l) async {
    final exists = await lessonExists(
      name: l.name ?? '', // modeline göre uyarlayabilirsin
      day: l.day ?? '',
      hour1: l.hour1,
      hour2: l.hour2,
      place: l.place ?? '',
      teacher: l.teacher ?? '',
    );
    if (exists) return false;

    final Database d = await db;
    // Burada kendi insert(Lesson) metodunu da çağırabilirsin:
    // return await insert(l) > 0;
    // Eğer elle yazacaksan:
    final data = {
      'name': l.name,
      'place': l.place,
      'day': l.day,
      'hour1': l.hour1,
      'hour2': l.hour2,
      'teacher': l.teacher,
      'attendance': l.attendance ?? 0,
      'isProcessed': l.isProcessed ?? 0,
    };
    await d.insert(
        'lessons', data /*, conflictAlgorithm: ConflictAlgorithm.ignore*/);
    return true;
  }

  /// Toplu ekleme: önce RAM'de aynı dersleri ayıklar, sonra DB'de var mı bakıp ekler.
  /// Dönen değer: gerçekten eklenen kayıt sayısı.
  Future<int> insertManyIfNotExistsPreserveAttendance(
      List<Lesson> lessons) async {
    // 1) RAM dedup
    final seen = <String>{};
    final unique = <Lesson>[];
    for (final l in lessons) {
      final key = DedupHelpers.lessonKey(
        name: l.name ?? '',
        day: l.day ?? '',
        hour1: l.hour1,
        hour2: l.hour2,
        hour3: l.hour3,
        place: l.place ?? '',
        teacher: l.teacher ?? '',
      );
      if (seen.add(key)) unique.add(l);
    }

    // 2) DB dedup (transaction ile hizlandir)
    final Database d = await db;
    int inserted = 0;
    await d.transaction((txn) async {
      for (final l in unique) {
        final rows = await txn.rawQuery(
          '''
          SELECT 1 FROM lessons 
          WHERE name = ? AND day = ?
            AND IFNULL(hour1,'') = ?
            AND IFNULL(hour2,'') = ?
            AND IFNULL(hour3,'') = ?
            AND place = ? AND teacher = ?
          LIMIT 1
          ''',
          [
            (l.name ?? '').trim(),
            (l.day ?? '').trim(),
            (l.hour1 ?? '').trim(),
            (l.hour2 ?? '').trim(),
            (l.hour3 ?? '').trim(),
            (l.place ?? '').trim(),
            (l.teacher ?? '').trim(),
          ],
        );
        if (rows.isEmpty) {
          await txn.insert('lessons', {
            'name': l.name,
            'place': l.place,
            'day': l.day,
            'hour1': l.hour1,
            'hour2': l.hour2,
            'hour3': l.hour3,
            'teacher': l.teacher,
            'attendance': l.attendance ?? 0,
            'isProcessed': l.isProcessed ?? 0,
          });
          inserted++;
        }
      }
    });
    return inserted;
  }
}

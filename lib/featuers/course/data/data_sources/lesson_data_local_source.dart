import 'package:home_page/featuers/course/data/models/lesson.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// ========================
/// 🔹 ABSTRACT INTERFACE
/// ========================
abstract class LessonLocalDataSource {
  Future<Database> get database;

  Future<void> insertLesson(Lesson lesson);
  Future<void> updateLesson(Lesson lesson);
  Future<void> deleteLesson(int id);
  Future<List<Lesson>> getLessons();

  Future<void> incrementAttendanceByCount(String name, int count);
  Future<int> getAttendanceByLessonName(String name);
  Future<void> updateAttendance(Lesson lesson);

  Future<void> deleteAllLessons();
  Future<bool> lessonExists(Lesson lesson);
  Future<bool> insertIfNotExistsPreserveAttendance(Lesson lesson);
  Future<int> insertManyIfNotExistsPreserveAttendance(List<Lesson> lessons);
}

/// ========================
/// 🔸 IMPLEMENTATION
/// ========================
class LessonLocalDataSourceImpl implements LessonLocalDataSource {
  static Database? _db;

  /// 🔹 Lazy DB initializer
  @override
  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  /// 🔹 Initialize Database
  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'timeTable.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  /// 🔹 Create DB tables
  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE lessons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        place TEXT,
        day TEXT,
        hour1 TEXT,
        hour2 TEXT,
        hour3 TEXT,
        teacher TEXT,
        attendance INTEGER DEFAULT 0,
        isProcessed INTEGER DEFAULT 0
      )
    ''');
  }

  // ====================================================
  // 🔹 CRUD OPERATIONS
  // ====================================================

  @override
  Future<void> insertLesson(Lesson lesson) async {
    final db = await database;
    await db.insert("lessons", lesson.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> updateLesson(Lesson lesson) async {
    final db = await database;
    await db.update(
      "lessons",
      lesson.toMap(),
      where: "id = ?",
      whereArgs: [lesson.id],
    );
  }

  @override
  Future<void> deleteLesson(int id) async {
    final db = await database;
    await db.delete("lessons", where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<List<Lesson>> getLessons() async {
    final db = await database;
    final result = await db.query("lessons");
    return result.map((e) => Lesson.fromMap(e)).toList();
  }

  @override
  Future<void> deleteAllLessons() async {
    final db = await database;
    await db.delete("lessons");
  }

  // ====================================================
  // 🔹 ATTENDANCE (DEVAMSIZLIK) FONKSİYONLARI
  // ====================================================

  @override
  Future<void> incrementAttendanceByCount(String name, int count) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE lessons 
      SET attendance = attendance + ? 
      WHERE LOWER(TRIM(name)) = ?
      ''',
      [count, name.trim().toLowerCase()],
    );
  }

  @override
  Future<int> getAttendanceByLessonName(String name) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT attendance 
      FROM lessons 
      WHERE LOWER(TRIM(name)) = ? 
      LIMIT 1
      ''',
      [name.trim().toLowerCase()],
    );
    if (result.isNotEmpty) {
      return result.first['attendance'] as int;
    } else {
      return 0;
    }
  }

  @override
  Future<void> updateAttendance(Lesson lesson) async {
    final db = await database;
    await db.update(
      "lessons",
      {'attendance': lesson.attendance},
      where: "name = ?",
      whereArgs: [lesson.name],
    );
  }

  // ====================================================
  // 🔹 DUPLICATE (TEKRAR EDEN KAYIT) KONTROL FONKSİYONLARI
  // ====================================================

  /// Aynı ders zaten varsa TRUE döner
  @override
  Future<bool> lessonExists(Lesson lesson) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 1 
      FROM lessons 
      WHERE name = ? 
        AND day = ?
        AND IFNULL(hour1, '') = ?
        AND IFNULL(hour2, '') = ?
        AND IFNULL(hour3, '') = ?
        AND place = ? 
        AND teacher = ?
      LIMIT 1
    ''', [
      lesson.name.trim(),
      lesson.day?.trim() ?? '',
      lesson.hour1?.trim() ?? '',
      lesson.hour2?.trim() ?? '',
      lesson.hour3?.trim() ?? '',
      lesson.place.trim(),
      lesson.teacher?.trim() ?? '',
    ]);
    return result.isNotEmpty;
  }

  /// Eğer aynı kayıt yoksa insert eder, varsa atlar.
  @override
  Future<bool> insertIfNotExistsPreserveAttendance(Lesson lesson) async {
    final exists = await lessonExists(lesson);
    if (exists) return false;

    await insertLesson(lesson);
    return true;
  }

  /// RAM + DB dedup’lu toplu ekleme.
  /// Dönüş: gerçekten eklenen kayıt sayısı.
  @override
  Future<int> insertManyIfNotExistsPreserveAttendance(
      List<Lesson> lessons) async {
    final db = await database;

    // RAM'de duplicate ayıklama
    final seen = <String>{};
    final unique = <Lesson>[];
    for (final l in lessons) {
      final key = [
        (l.name).trim().toUpperCase(),
        (l.day ?? '').trim().toUpperCase(),
        (l.hour1 ?? '').trim().toUpperCase(),
        (l.hour2 ?? '').trim().toUpperCase(),
        (l.hour3 ?? '').trim().toUpperCase(),
        (l.place).trim().toUpperCase(),
        (l.teacher ?? '').trim().toUpperCase(),
      ].join('|');
      if (seen.add(key)) unique.add(l);
    }

    int inserted = 0;
    await db.transaction((txn) async {
      for (final l in unique) {
        final rows = await txn.rawQuery('''
          SELECT 1 
          FROM lessons 
          WHERE name = ? AND day = ?
            AND IFNULL(hour1, '') = ?
            AND IFNULL(hour2, '') = ?
            AND IFNULL(hour3, '') = ?
            AND place = ? AND teacher = ?
          LIMIT 1
        ''', [
          (l.name).trim(),
          (l.day ?? '').trim(),
          (l.hour1 ?? '').trim(),
          (l.hour2 ?? '').trim(),
          (l.hour3 ?? '').trim(),
          (l.place).trim(),
          (l.teacher ?? '').trim(),
        ]);

        if (rows.isEmpty) {
          await txn.insert('lessons', l.toMap());
          inserted++;
        }
      }
    });
    return inserted;
  }
}

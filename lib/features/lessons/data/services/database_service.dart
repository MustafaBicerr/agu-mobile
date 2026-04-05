import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

extension DbDebug on DatabaseService {
  Future<void> debugPrintDbInfo() async {
    final path = await _dbPath();
    final f = File(path);
    print(
        'DB PATH: $path  | exists=${await f.exists()}  | size=${await f.length()} bytes');

    final d = await db;
    final tables = await d.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name");
    print('TABLES: ${tables.map((e) => e['name']).toList()}');

    for (final t in tables) {
      final name = t['name'] as String;
      final cnt = await d.rawQuery('SELECT COUNT(*) as c FROM $name');
      print('COUNT($name) = ${cnt.first['c']}');
    }
  }
}

class DatabaseService {
  DatabaseService._();
  static final DatabaseService I = DatabaseService._();

  Database? _db;

  Future<Database> get db async {
    if (_db == null || !_db!.isOpen) {
      await ensureReady();
    }
    return _db!;
  }

  /// Tek doğrusal yol: .../databases/lessons.db
  Future<String> _dbPath() async {
    final dir = await getDatabasesPath();
    return p.join(dir, 'lessons.db');
  }

  /// Asset'ten kopyala (+ opsiyonel version karşılaştırması)
  Future<void> ensureReady() async {
    final path = await _dbPath();

    // 1) Dosya yoksa, asset'ten kopyala
    if (!await databaseExists(path)) {
      await _copyFromAsset(path);
    }

    // 2) Aç
    _db = await openDatabase(path);

    // 3) Teşhis logu
    try {
      final size = await File(path).length();
      final tables = await _db!.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name");
      debugPrint(
          'DB path: $path | size: $size bytes | tables: ${tables.map((e) => e['name']).toList()}');
      for (final t in tables) {
        final name = t['name'] as String;
        final c = Sqflite.firstIntValue(
              await _db!.rawQuery('SELECT COUNT(*) FROM $name'),
            ) ??
            0;
        debugPrint('COUNT($name) = $c');
      }
    } catch (_) {}
  }

  Future<void> _copyFromAsset(String dstPath) async {
    await Directory(p.dirname(dstPath)).create(recursive: true);
    final data =
        await rootBundle.load('assets/db/lessons.db'); // ← senin asset yolun
    final bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(dstPath).writeAsBytes(bytes, flush: true);
  }
}

import 'dart:developer';

import 'package:timerize/models/models.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseProvider {
  static final DatabaseProvider _instance = DatabaseProvider._internal();
  static Database? _database;

  factory DatabaseProvider() {
    return _instance;
  }

  DatabaseProvider._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, 'shower_sections.db');

    return await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE shower_sections (
            id TEXT PRIMARY KEY,
            sectionName TEXT,
            orderIndex INTEGER,
            seconds INTEGER,
            minutes INTEGER
          )
        ''');
      },
    );
  }

  Future<List<ShowerSection>> getShowerSections() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('shower_sections');

    return List.generate(maps.length, (i) {
      return ShowerSection(
        id: maps[i]['id'],
        sectionName: maps[i]['sectionName'],
        orderIndex: maps[i]['orderIndex'],
        seconds: maps[i]['seconds'],
        minutes: maps[i]['minutes'],
      );
    });
  }

  Future<void> saveShowerSection(ShowerSection showerSection) async {
    final db = await database;

    // Check if the record already exists
    final existingRecord = await db.query(
      'shower_sections',
      where: 'id = ?',
      whereArgs: [showerSection.id],
    );

    if (existingRecord.isNotEmpty) {
      // Update the existing record
      return await db.update(
        'shower_sections',
        showerSection.toJson(),
        where: 'id = ?',
        whereArgs: [showerSection.id],
      ).then((affectedRows) =>
          log(showerSection.toString(), name: 'Updated section'));
    } else {
      // Insert a new record
      return await db
          .insert(
            'shower_sections',
            showerSection.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          )
          .then((affectedRows) =>
              log(showerSection.toString(), name: 'Saved section'));
    }
  }

  Future<void> deleteShowerSection(String id) async {
    final db = await database;
    await db.delete(
      'shower_sections',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

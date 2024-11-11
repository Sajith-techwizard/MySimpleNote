import 'dart:async';
import 'package:sqflite/sqflite.dart';

import '../models/note.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  final String noteTable = 'note_table';
  final String colId = 'id';
  final String colTitle = 'title';
  final String colDescription = 'description';
  final String colPriority = 'priority';
  final String colDate = 'date';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  Future<Database> get database async {
    _database ??= await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    String path = '${await getDatabasesPath()}/note.db';
    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
      'CREATE TABLE $noteTable('
          '$colId INTEGER PRIMARY KEY AUTOINCREMENT, '
          '$colTitle TEXT, '
          '$colDescription TEXT, '
          '$colPriority INTEGER, '
          '$colDate TEXT'
          ')',
    );
  }

  // Fetch all notes as a list of maps
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    final db = await database;
    return await db.query(noteTable, orderBy: '$colPriority ASC');
  }

  // Insert a new note
  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert(noteTable, note.toMap());
  }

  // Update an existing note
  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      noteTable,
      note.toMap(),
      where: '$colId = ?',
      whereArgs: [note.id],
    );
  }

  // Delete a note
  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete(noteTable, where: '$colId = ?', whereArgs: [id]);
  }

  // Get the count of notes
  Future<int> getCount() async {
    final db = await database;
    final x = await db.rawQuery('SELECT COUNT(*) FROM $noteTable');
    return Sqflite.firstIntValue(x) ?? 0;
  }

  // Convert the Map List to a List of Note objects
  Future<List<Note>> getNoteList() async {
    final noteMapList = await getNoteMapList();
    return noteMapList.map((noteMap) => Note.fromMapObject(noteMap)).toList();
  }
}






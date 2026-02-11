import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/time_block.dart';

class TaskService {
  static TaskService _instance = TaskService._init();
  static TaskService get instance => _instance;
  static set instance(TaskService value) => _instance = value;
  
  static Database? _database;

  TaskService._init();
  TaskService(); // Public constructor for mocking

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ticktock.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE tracking_state (
          id INTEGER PRIMARY KEY,
          title TEXT,
          start_time TEXT
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE window_state (
          id INTEGER PRIMARY KEY,
          width REAL,
          height REAL
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE tasks ADD COLUMN tags TEXT');
    }
    if (oldVersion < 5) {
      // Procedure to make a column nullable in SQLite (re-create table)
      await db.execute('PRAGMA foreign_keys=OFF');
      await db.execute('''
        CREATE TABLE tasks_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          color INTEGER,
          tags TEXT
        )
      ''');
      await db.execute('''
        INSERT INTO tasks_new (id, title, description, color, tags)
        SELECT id, title, description, color, tags FROM tasks
      ''');
      await db.execute('DROP TABLE tasks');
      await db.execute('ALTER TABLE tasks_new RENAME TO tasks');
      await db.execute('PRAGMA foreign_keys=ON');
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        color INTEGER,
        tags TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE time_blocks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE tracking_state (
        id INTEGER PRIMARY KEY,
        title TEXT,
        start_time TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE window_state (
        id INTEGER PRIMARY KEY,
        width REAL,
        height REAL
      )
    ''');
  }

  Future<void> saveWindowSize(double width, double height) async {
    final db = await instance.database;
    await db.insert(
      'window_state',
      {
        'id': 1,
        'width': width,
        'height': height,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Size?> getWindowSize() async {
    final db = await instance.database;
    final maps = await db.query(
      'window_state',
      where: 'id = ?',
      whereArgs: [1],
    );
    if (maps.isNotEmpty) {
      return Size(maps.first['width'] as double, maps.first['height'] as double);
    }
    return null;
  }

  Future<void> saveTrackingState(String title, DateTime startTime) async {
    final db = await instance.database;
    await db.insert(
      'tracking_state',
      {
        'id': 1,
        'title': title,
        'start_time': startTime.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getTrackingState() async {
    final db = await instance.database;
    final maps = await db.query(
      'tracking_state',
      where: 'id = ?',
      whereArgs: [1],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<void> clearTrackingState() async {
    final db = await instance.database;
    await db.delete(
      'tracking_state',
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<int> createTask(Task task) async {
    final db = await instance.database;
    return await db.insert('tasks', task.toMap());
  }

  Future<int> createTimeBlock(TimeBlock block) async {
    final db = await instance.database;
    return await db.insert('time_blocks', block.toMap());
  }

  Future<List<Task>> getTasks() async {
    final db = await instance.database;
    final tasksData = await db.query('tasks');
    
    List<Task> tasks = [];
    for (var taskMap in tasksData) {
      final blocksData = await db.query(
        'time_blocks',
        where: 'task_id = ?',
        whereArgs: [taskMap['id']],
      );
      
      final blocks = blocksData.map((b) => TimeBlock.fromMap(b)).toList();
      tasks.add(Task.fromMap(taskMap, blocks));
    }
    return tasks;
  }

  Future<Set<DateTime>> getSessionDates() async {
    final db = await instance.database;
    final result = await db.query('time_blocks', columns: ['start_time']);
    
    return result.map((row) {
      final date = DateTime.parse(row['start_time'] as String);
      return DateTime(date.year, date.month, date.day);
    }).toSet();
  }

  Future<int> updateTask(Task task) async {
    final db = await instance.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> updateTimeBlock(TimeBlock block) async {
    final db = await instance.database;
    return await db.update(
      'time_blocks',
      block.toMap(),
      where: 'id = ?',
      whereArgs: [block.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTimeBlock(int id) async {
    final db = await instance.database;
    return await db.delete(
      'time_blocks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<String?> getLastActiveTaskTitle() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT t.title 
      FROM tasks t
      JOIN time_blocks b ON t.id = b.task_id
      ORDER BY b.end_time DESC
      LIMIT 1
    ''');
    
    if (result.isNotEmpty) {
      return result.first['title'] as String?;
    }
    return null;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

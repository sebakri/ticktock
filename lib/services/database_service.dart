import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';
import '../models/time_block.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

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
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        color INTEGER NOT NULL
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

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

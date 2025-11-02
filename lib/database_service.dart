import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Database? _database;

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  DatabaseService._();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'activities.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE activities(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        duration INTEGER NOT NULL,
        calories REAL NOT NULL,
        protein REAL NOT NULL,
        carbs REAL NOT NULL,
        fats REAL NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertActivity(Activity activity) async {
    Database db = await database;
    return await db.insert('activities', activity.toMap());
  }

  Future<List<Activity>> getAllActivities() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('activities');
    return List.generate(maps.length, (i) {
      return Activity.fromMap(maps[i]);
    });
  }

  Future<int> updateActivity(Activity activity) async {
    Database db = await database;
    return await db.update(
      'activities',
      activity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  Future<int> deleteActivity(int id) async {
    Database db = await database;
    return await db.delete('activities', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllActivities() async {
    Database db = await database;
    await db.delete('activities');
  }
}

class Activity {
  final int? id;
  final String name;
  final String type;
  final int duration;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  bool isCompleted;
  final DateTime createdAt;

  Activity({
    this.id,
    required this.name,
    required this.type,
    required this.duration,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.isCompleted = false,
    required this.createdAt,
  });

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      duration: map['duration'],
      calories: map['calories'],
      protein: map['protein'],
      carbs: map['carbs'],
      fats: map['fats'],
      isCompleted: map['isCompleted'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'duration': duration,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Activity copyWith({
    int? id,
    String? name,
    String? type,
    int? duration,
    double? calories,
    double? protein,
    double? carbs,
    double? fats,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Activity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

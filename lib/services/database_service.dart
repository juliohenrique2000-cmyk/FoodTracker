import '../database/drift_database.dart';
import 'package:drift/drift.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static AppDatabase? _database;

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  DatabaseService._();

  Future<AppDatabase> get database async {
    _database ??= AppDatabase();
    return _database!;
  }

  // User operations
  Future<int> insertUser(UsersCompanion user) async {
    final db = await database;
    return await db.into(db.users).insert(user);
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    return await (db.select(
      db.users,
    )..where((tbl) => tbl.email.equals(email))).getSingleOrNull();
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    return await db.select(db.users).get();
  }

  // Activity operations
  Future<int> insertActivity(ActivitiesCompanion activity) async {
    final db = await database;
    return await db.into(db.activities).insert(activity);
  }

  Future<List<Activity>> getAllActivities() async {
    final db = await database;
    return await db.select(db.activities).get();
  }

  Future<bool> updateActivity(Activity activity) async {
    final db = await database;
    return await db.update(db.activities).replace(activity);
  }

  Future<int> deleteActivity(int id) async {
    final db = await database;
    return await (db.delete(
      db.activities,
    )..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<int> deleteAllActivities() async {
    final db = await database;
    return await db.delete(db.activities).go();
  }

  // Pantry operations
  Future<int> insertPantryItem(PantryItemsCompanion item) async {
    final db = await database;
    return await db.into(db.pantryItems).insert(item);
  }

  Future<List<PantryItem>> getAllPantryItems() async {
    final db = await database;
    return await db.select(db.pantryItems).get();
  }

  Future<bool> updatePantryItem(PantryItem item) async {
    final db = await database;
    return await db.update(db.pantryItems).replace(item);
  }

  Future<int> deletePantryItem(int id) async {
    final db = await database;
    return await (db.delete(
      db.pantryItems,
    )..where((tbl) => tbl.id.equals(id))).go();
  }

  // Water intake operations
  Future<int> insertWaterIntake(WaterIntakesCompanion intake) async {
    final db = await database;
    return await db.into(db.waterIntakes).insert(intake);
  }

  Future<WaterIntake?> getWaterIntakeForToday(int userId) async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await (db.select(db.waterIntakes)
          ..where((tbl) => tbl.userId.equals(userId))
          ..where((tbl) => tbl.date.isBetweenValues(startOfDay, endOfDay)))
        .getSingleOrNull();
  }

  Future<bool> updateWaterIntake(WaterIntake intake) async {
    final db = await database;
    return await db.update(db.waterIntakes).replace(intake);
  }

  Future<int> addWaterCup(int userId) async {
    final existing = await getWaterIntakeForToday(userId);

    if (existing != null) {
      final updated = existing.copyWith(cups: existing.cups + 1);
      await updateWaterIntake(updated);
      return updated.cups;
    } else {
      final newIntake = WaterIntakesCompanion(
        userId: Value(userId),
        cups: const Value(1),
        date: Value(DateTime.now().toUtc()),
      );
      await insertWaterIntake(newIntake);
      return 1;
    }
  }
}

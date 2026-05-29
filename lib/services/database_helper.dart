import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'wikimedia.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pages (
            id INTEGER PRIMARY KEY,
            title TEXT,
            text TEXT,
            thumb TEXT,
            categories TEXT,
            links TEXT,
            all_categories TEXT
          )
        ''');
        // Index on ID is implicit for PRIMARY KEY, but let's add indices if needed.
      },
    );
  }

  Future<void> insertPagesBulk(List<Map<String, dynamic>> pageMaps) async {
    final db = await database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final pageMap in pageMaps) {
        batch.insert(
          'pages',
          pageMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<Map<String, dynamic>?> getPage(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pages',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getPagesByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final db = await database;
    final idString = ids.join(',');
    return await db.rawQuery('SELECT id, title, all_categories, thumb FROM pages WHERE id IN ($idString)');
  }

  /// Fetches a random set of candidates for the recommendation engine.
  /// Uses SQLite's RANDOM() which is efficient for datasets under 100k rows.
  Future<List<Map<String, dynamic>>> getRandomScoringCandidates(int count) async {
    final db = await database;
    return await db.query(
      'pages',
      columns: ['id', 'all_categories', 'thumb'],
      orderBy: 'RANDOM()',
      limit: count,
    );
  }

  /// Loads all category strings to build the category search index.
  Future<List<Map<String, dynamic>>> getAllCategoryStrings() async {
    final db = await database;
    return await db.query(
      'pages',
      columns: ['categories'],
    );
  }

  Future<int> getPageCount() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM pages'),
    );
    return count ?? 0;
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('pages');
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

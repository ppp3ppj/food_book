import 'package:sqlite3/sqlite3.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';

/// SQLite database manager using sqlite3 package directly
class AppDatabase {
  Database? _database;
  String? _databasePath;

  /// Get database instance
  Database get database {
    if (_database == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _database!;
  }

  /// Get database path
  String? get databasePath => _databasePath;

  /// Initialize database connection
  Future<void> initialize() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      _databasePath = p.join(dbFolder.path, 'food_book.db');

      debugPrint('📂 Database path: $_databasePath');

      _database = sqlite3.open(_databasePath!);

      // Create tables
      _createTables();

      debugPrint('✅ Database connection opened successfully!');
    } catch (e) {
      print(
        '❌ Database initialization failed: $e',
      ); // Keep in release - critical error
      rethrow;
    }
  }

  /// Create database tables
  void _createTables() {
    _database!.execute('''
      CREATE TABLE IF NOT EXISTS items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL DEFAULT 0.0,
        date TEXT NOT NULL,
        reason TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT
      )
    ''');

    // Add date column if it doesn't exist (for existing databases)
    try {
      _database!.execute(
        'ALTER TABLE items ADD COLUMN date TEXT NOT NULL DEFAULT "2025-01-01"',
      );
    } catch (e) {
      // Column already exists, ignore error
    }

    // Add reason column if it doesn't exist (for existing databases)
    try {
      _database!.execute('ALTER TABLE items ADD COLUMN reason TEXT');
    } catch (e) {
      // Column already exists, ignore error
    }

    // Create index on date column for faster queries
    try {
      _database!.execute(
        'CREATE INDEX IF NOT EXISTS idx_items_date ON items(date)',
      );
      debugPrint('📊 Database index created for date column');
    } catch (e) {
      debugPrint('⚠️ Index creation skipped: $e');
    }

    debugPrint('📋 Tables created successfully');
  }

  /// Test database connection
  Future<bool> testConnection() async {
    try {
      if (_database == null) {
        await initialize();
      }

      // Execute a simple query to test connection
      final result = _database!.select('SELECT 1 as test');

      if (result.isNotEmpty) {
        debugPrint('✅ Database connection test successful!');
        debugPrint('📊 Test query result: ${result.first['test']}');
        return true;
      }

      return false;
    } catch (e) {
      print(
        '❌ Database connection test failed: $e',
      ); // Keep in release - critical error
      return false;
    }
  }

  /// Get database version
  String getVersion() {
    return sqlite3.version.toString();
  }

  /// Execute a raw SQL query
  ResultSet query(String sql, [List<Object?> parameters = const []]) {
    return _database!.select(sql, parameters);
  }

  /// Execute a SQL statement (INSERT, UPDATE, DELETE)
  void execute(String sql, [List<Object?> parameters = const []]) {
    _database!.execute(sql, parameters);
  }

  /// Close database connection
  void close() {
    if (_database != null) {
      _database!.dispose();
      _database = null;
      print('🔒 Database connection closed');
    }
  }
}

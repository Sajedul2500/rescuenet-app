import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/models/offline_request.dart';

/// Local database for storing offline requests
class OfflineRequestDatabase {
  static final OfflineRequestDatabase _instance =
      OfflineRequestDatabase._internal();
  static Database? _database;

  factory OfflineRequestDatabase() => _instance;

  OfflineRequestDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'offline_requests.db');

      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    } catch (e) {
      print('Error initializing database: $e');
      // If there's a plugin error, throw a more specific error
      if (e.toString().contains('MissingPluginException')) {
        throw Exception('Database not ready. Please restart the app.');
      }
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE offline_requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        description TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        location_name TEXT,
        created_at TEXT NOT NULL,
        sync_status TEXT NOT NULL,
        retry_count INTEGER NOT NULL DEFAULT 0,
        error_message TEXT
      )
    ''');

    // Create index on sync_status for efficient querying
    await db.execute('''
      CREATE INDEX idx_sync_status ON offline_requests(sync_status)
    ''');
  }

  /// Insert a new offline request
  Future<int> insertRequest(OfflineRequest request) async {
    try {
      final db = await database;
      return await db.insert(
        'offline_requests',
        {
          'type': request.type,
          'description': request.description,
          'latitude': request.latitude,
          'longitude': request.longitude,
          'location_name': request.locationName,
          'created_at': request.createdAt.toIso8601String(),
          'sync_status': request.syncStatus.name,
          'retry_count': request.retryCount,
          'error_message': request.errorMessage,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error inserting request: $e');
      if (e.toString().contains('MissingPluginException')) {
        throw Exception(
            'Database plugin not initialized. Please restart the app and try again.');
      }
      throw Exception('Failed to save request: ${e.toString()}');
    }
  }

  /// Get all pending requests
  Future<List<OfflineRequest>> getPendingRequests() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'offline_requests',
      where: 'sync_status = ?',
      whereArgs: [SyncStatus.pending.name],
      orderBy: 'created_at ASC',
    );

    return maps.map((map) => OfflineRequest.fromJson(map)).toList();
  }

  /// Get all requests (for display purposes)
  Future<List<OfflineRequest>> getAllRequests() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'offline_requests',
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => OfflineRequest.fromJson(map)).toList();
  }

  /// Update request sync status
  Future<int> updateRequest(OfflineRequest request) async {
    final db = await database;
    return await db.update(
      'offline_requests',
      {
        'sync_status': request.syncStatus.name,
        'retry_count': request.retryCount,
        'error_message': request.errorMessage,
      },
      where: 'id = ?',
      whereArgs: [request.id],
    );
  }

  /// Delete synced requests older than 7 days (cleanup)
  Future<int> deleteSyncedRequests() async {
    final db = await database;
    final sevenDaysAgo =
        DateTime.now().subtract(const Duration(days: 7)).toIso8601String();

    return await db.delete(
      'offline_requests',
      where: 'sync_status = ? AND created_at < ?',
      whereArgs: [SyncStatus.synced.name, sevenDaysAgo],
    );
  }

  /// Delete all requests (for testing/debugging)
  Future<int> deleteAllRequests() async {
    final db = await database;
    return await db.delete('offline_requests');
  }

  /// Get request count by status
  Future<int> getRequestCountByStatus(SyncStatus status) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM offline_requests WHERE sync_status = ?',
      [status.name],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static final List<Map<String, dynamic>> _webHistory = [];

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('zaturre.db');
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

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        image_path TEXT NOT NULL,
        prediction TEXT NOT NULL,
        risk_percentage REAL NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER UNIQUE,
        bio TEXT,
        avatar_path TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE preferences (
        user_id INTEGER PRIMARY KEY,
        dark_mode INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  Future<int> registerUser(
      String name,
      String email,
      String password,
      ) async {
    try {
      final db = await instance.database;
      final data = {
        'name': name,
        'email': email,
        'password': password,
      };
      return await db.insert(
        'users',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('DB Error (registerUser): $e');
      return -1; // Failure
    }
  }

  Future<int> loginUser(String email, String password) async {
    if (kIsWeb) return 1; // Mock web user id
    try {
      final db = await instance.database;
      final result = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
        limit: 1,
      );
      if (result.isNotEmpty) {
        return result.first['id'] as int;
      }
      return -1; // Not found
    } catch (e) {
      print('DB Error (loginUser): $e');
      return -1;
    }
  }

  Future<int> saveImageRecord(
      int userId,
      String imagePath,
      String prediction,
      double riskPercentage,
      ) async {
    if (kIsWeb) {
      _webHistory.insert(0, {
        'id': _webHistory.length + 1,
        'user_id': userId,
        'image_path': imagePath,
        'prediction': prediction,
        'risk_percentage': riskPercentage,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return 1;
    }
    try {
      final db = await instance.database;
      final data = {
        'user_id': userId,
        'image_path': imagePath,
        'prediction': prediction,
        'risk_percentage': riskPercentage,
        'timestamp': DateTime.now().toIso8601String(),
      };
      return await db.insert('images', data);
    } catch (e) {
      print('DB Error (saveImageRecord): $e');
      return 1;
    }
  }

  Future<List<Map<String, dynamic>>> getAnalysisHistory(int userId) async {
    if (kIsWeb) {
      return _webHistory.where((item) => item['user_id'] == userId).toList();
    }
    try {
      final db = await instance.database;
      return await db.query(
        'images',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'timestamp DESC',
      );
    } catch (e) {
      print('DB Error (getAnalysisHistory): $e');
      return []; // Mock empty history
    }
  }

  Future<Map<String, dynamic>?> getProfileData(int userId) async {
    try {
      final db = await instance.database;
      final result = await db.query(
        'profiles',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );
      if (result.isNotEmpty) return result.first;
      return null;
    } catch (e) {
      print('DB Error (getProfileData): $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUser(int userId) async {
    if (kIsWeb) return null;
    try {
      final db = await instance.database;
      final result = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );
      if (result.isNotEmpty) return result.first;
      return null;
    } catch (e) {
      print('DB Error (getUser): $e');
      return null;
    }
  }

  Future<int> saveProfileData(
      int userId,
      String bio,
      String avatarPath,
      ) async {
    try {
      final db = await instance.database;
      final data = {
        'user_id': userId,
        'bio': bio,
        'avatar_path': avatarPath,
      };
      return await db.insert(
        'profiles',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('DB Error (saveProfileData): $e');
      return 1;
    }
  }

  Future<void> saveUserPreferences(
      int userId,
      bool isDarkMode,
      ) async {
    try {
      final db = await instance.database;
      await db.insert(
        'preferences',
        {
          'user_id': userId,
          'dark_mode': isDarkMode ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('DB Error (saveUserPreferences): $e');
    }
  }

  Future<bool> getUserPreferenceDarkMode(int userId) async {
    try {
      final db = await instance.database;
      final results = await db.query(
        'preferences',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );
      if (results.isNotEmpty) return results.first['dark_mode'] == 1;
      return false;
    } catch (e) {
      print('DB Error (getUserPreferenceDarkMode): $e');
      return false; // Default to false
    }
  }

  Future<bool> testConnection() async {
    try {
      final db = await instance.database;
      return db.isOpen;
    } catch (e) {
      return false;
    }
  }
}

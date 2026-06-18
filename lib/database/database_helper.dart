import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('zaturre.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
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
        timestamp TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        bio TEXT,
        avatar_path TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  Future<int> registerUser(String name, String email, String password) async {
    final db = await instance.database;
    final data = {
      'name': name,
      'email': email,
      'password': password,
    };
    return await db.insert('users', data);
  }

  Future<int> saveImageRecord(int userId, String imagePath) async {
    final db = await instance.database;
    final data = {
      'user_id': userId,
      'image_path': imagePath,
      'timestamp': DateTime.now().toIso8601String(),
    };
    return await db.insert('images', data);
  }

  Future<int> saveProfileData(int userId, String bio, String avatarPath) async {
    final db = await instance.database;
    final data = {
      'user_id': userId,
      'bio': bio,
      'avatar_path': avatarPath,
    };
    return await db.insert('profiles', data);
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

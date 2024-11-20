import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
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
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        senha TEXT NOT NULL,
        tipo TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE carona (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        motorista_id INTEGER NOT NULL,
        destino TEXT NOT NULL,
        horario TEXT NOT NULL,
        vagas INTEGER NOT NULL,
        FOREIGN KEY (motorista_id) REFERENCES users (id)
      )
    ''');
  }

  // usuários
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // CRUD caronas
  Future<int> createCarona(Map<String, dynamic> carona) async {
    final db = await instance.database;
    return await db.insert('carona', carona);
  }

  Future<List<Map<String, dynamic>>> getAllCarona() async {
    final db = await instance.database;
    return await db.query('carona');
  }

  Future<int> updateCarona(int id, Map<String, dynamic> updatedCarona) async {
    final db = await instance.database;
    return await db.update(
      'carona',
      updatedCarona,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCarona(int id) async {
    final db = await instance.database;
    return await db.delete(
      'carona',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

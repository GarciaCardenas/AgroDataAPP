import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = "AppDatabase.db";
  static final _databaseVersion = 1;

  static final table = 'usuarios';

  static final columnId = 'id';
  static final columnNombre = 'nombre';
  static final columnEmail = 'email';
  static final columnUsuario = 'usuario';
  static final columnContrasena = 'contrasena';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnNombre TEXT NOT NULL,
            $columnEmail TEXT NOT NULL,
            $columnUsuario TEXT NOT NULL,
            $columnContrasena TEXT NOT NULL
          )
          ''');
  }

  Future<int> insertarUsuario(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<Map<String, dynamic>?> validarLogin(String usuario, String contrasena) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      table,
      where: '$columnUsuario = ? AND $columnContrasena = ?',
      whereArgs: [usuario, contrasena],
    );
    return result.isNotEmpty ? result.first : null;
  }
}

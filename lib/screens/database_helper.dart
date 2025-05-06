import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = "AppDatabase.db";
  static final _databaseVersion = 2; // AUMENTADO A 2

  static final tableUsuarios = 'usuarios';
  static final tablePosts = 'posts';

  // Columnas de usuarios
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
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // <- AÑADIDO
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableUsuarios (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnNombre TEXT NOT NULL,
        $columnEmail TEXT NOT NULL,
        $columnUsuario TEXT NOT NULL,
        $columnContrasena TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablePosts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        contenido TEXT,
        imagen TEXT,
        fecha TEXT,
        FOREIGN KEY (user_id) REFERENCES $tableUsuarios($columnId)
      )
    ''');
  }

  // NUEVO: manejo de actualizaciones entre versiones
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tablePosts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER,
          contenido TEXT,
          imagen TEXT,
          fecha TEXT,
          FOREIGN KEY (user_id) REFERENCES $tableUsuarios($columnId)
        )
      ''');
    }
  }

  // ========== MÉTODOS PARA USUARIOS ==========
  Future<int> insertarUsuario(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tableUsuarios, row);
  }

  Future<Map<String, dynamic>?> validarLogin(String usuario, String contrasena) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      tableUsuarios,
      where: '$columnUsuario = ? AND $columnContrasena = ?',
      whereArgs: [usuario, contrasena],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> obtenerUsuarioPorId(int id) async {
    final db = await database;
    final result = await db.query(tableUsuarios, where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<int> actualizarUsuario(int id, Map<String, dynamic> valores) async {
    final db = await database;
    return await db.update(tableUsuarios, valores, where: 'id = ?', whereArgs: [id]);
  }

  // ========== MÉTODOS PARA POSTS ==========
  Future<int> insertarPost(Map<String, dynamic> post) async {
    Database db = await instance.database;
    return await db.insert(tablePosts, post);
  }

  Future<List<Map<String, dynamic>>> obtenerPosts() async {
    Database db = await instance.database;
    return await db.query(tablePosts, orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> obtenerPostsPorUsuario(int userId) async {
    Database db = await instance.database;
    return await db.query(
      tablePosts,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
  }
}

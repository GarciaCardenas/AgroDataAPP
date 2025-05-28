import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = "AppDatabase.db";
  static final _databaseVersion = 3; // AUMENTADO A 2

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

  static Future<void> deleteAppDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "AppDatabase.db");
    await deleteDatabase(path);
  }

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
    $columnContrasena TEXT NOT NULL,
    foto TEXT  -- Nueva columna
  )
  ''');

    await db.execute('''
CREATE TABLE $tablePosts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  contenido TEXT,
  imagen TEXT,
  fecha TEXT,
  categoria_id INTEGER,
  FOREIGN KEY (user_id) REFERENCES $tableUsuarios($columnId),
  FOREIGN KEY (categoria_id) REFERENCES categorias(id)
)
''');




    // Tabla para los likes
    await db.execute('''
    CREATE TABLE likes (
      post_id INTEGER,
      user_id INTEGER,
      FOREIGN KEY (post_id) REFERENCES $tablePosts(id),
      FOREIGN KEY (user_id) REFERENCES $tableUsuarios(id),
      PRIMARY KEY (post_id, user_id)
    )
  ''');


    await db.execute('''
      CREATE TABLE categorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT UNIQUE
      )
      ''');


    // Tabla para los comentarios
    await db.execute('''
    CREATE TABLE comentarios (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      post_id INTEGER,
      user_id INTEGER,
      comentario TEXT,
      fecha TEXT,
      FOREIGN KEY (post_id) REFERENCES $tablePosts(id),
      FOREIGN KEY (user_id) REFERENCES $tableUsuarios(id)
    )
  ''');
  }


  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Verificar si la columna 'foto' ya existe
      final columns = await db.rawQuery("PRAGMA table_info($tableUsuarios)");
      final existeFoto = columns.any((column) => column['name'] == 'foto');

      if (!existeFoto) {
        await db.execute("ALTER TABLE $tableUsuarios ADD COLUMN foto TEXT");
      }

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


  await db.execute('''
    CREATE TABLE IF NOT EXISTS categorias (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT UNIQUE
  )
  ''');
      // Verificar si columna categoria_id ya existe en posts
      final postColumns = await db.rawQuery("PRAGMA table_info($tablePosts)");
      final existeCategoriaId = postColumns.any((column) => column['name'] == 'categoria_id');

      if (!existeCategoriaId) {
        await db.execute('ALTER TABLE $tablePosts ADD COLUMN categoria_id INTEGER');
      }


      await db.execute('''
      CREATE TABLE IF NOT EXISTS likes (
        post_id INTEGER,
        user_id INTEGER,
        FOREIGN KEY (post_id) REFERENCES $tablePosts(id),
        FOREIGN KEY (user_id) REFERENCES $tableUsuarios(id),
        PRIMARY KEY (post_id, user_id)
      )
    ''');


      await db.execute('''
      CREATE TABLE IF NOT EXISTS comentarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        post_id INTEGER,
        user_id INTEGER,
        comentario TEXT,
        fecha TEXT,
        FOREIGN KEY (post_id) REFERENCES $tablePosts(id),
        FOREIGN KEY (user_id) REFERENCES $tableUsuarios(id)
      )
    ''');
    }
  }

  // contar likes
  Future<int> obtenerLikes(int postId) async {
    final db = await database;
    final res = await db.rawQuery(
        'SELECT COUNT(*) AS count FROM likes WHERE post_id = ?',
        [postId]
    );
    return Sqflite.firstIntValue(res) ?? 0;
  }

// insertar like
  Future<void> agregarLike(int postId, int userId) async {
    final db = await database;
    await db.insert('likes', {
      'post_id': postId,
      'user_id': userId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

// obtener comentarios
  Future<List<Map<String, dynamic>>> obtenerComentarios(int postId) async {
    final db = await database;
    return await db.rawQuery('''
    SELECT c.comentario, c.fecha, u.nombre 
    FROM comentarios c
    JOIN usuarios u ON c.user_id = u.id
    WHERE c.post_id = ?
    ORDER BY c.fecha ASC
  ''', [postId]);
  }

  Future<int> insertarCategoria(String nombre) async {
    final db = await database;

    // Verifica si ya existe
    final resultado = await db.query(
      'categorias',
      where: 'nombre = ?',
      whereArgs: [nombre],
    );

    if (resultado.isNotEmpty) {
      return resultado.first['id'] as int;
    }

    return await db.insert('categorias', {'nombre': nombre});
  }


  Future<List<Map<String, dynamic>>> obtenerCategorias() async {
    final db = await database;
    return await db.query('categorias');
  }


  Future<int> insertarPostConCategoria(Map<String, dynamic> post) async {
    final db = await database;
    return await db.insert(tablePosts, post);
  }


  Future<void> agregarComentario(int postId, int userId, String comentario) async {
    final db = await database;
    await db.insert(
      'comentarios',
      {
        'post_id': postId,
        'user_id': userId,
        'comentario': comentario,
        'fecha': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,  // Para evitar duplicados
    );
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

  Future<List<Map<String, dynamic>>> obtenerPosts({
    String? categoria,
    String? textoBusqueda,
  }) async {
    final db = await database;
    String where = '';
    List<dynamic> args = [];

    if (categoria != null) {
      where += 'categoria_id IN (SELECT id FROM categorias WHERE nombre = ?)';
      args.add(categoria);
    }

    if (textoBusqueda != null && textoBusqueda.isNotEmpty) {
      if (where.isNotEmpty) where += ' AND ';
      where += 'contenido LIKE ?';
      args.add('%$textoBusqueda%');
    }

    return await db.query(
      tablePosts,
      where: where.isEmpty ? null : where,
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'id DESC',
    );
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

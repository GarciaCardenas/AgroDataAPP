import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = "AppDatabase.db";
  static final _databaseVersion = 4; // AUMENTADO A 4 para incluir cultivos

  static final tableUsuarios = 'usuarios';
  static final tablePosts = 'posts';
  static final tableCultivos = 'cultivos'; // Nueva tabla

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
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Tabla de usuarios
    await db.execute('''
    CREATE TABLE $tableUsuarios (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnNombre TEXT NOT NULL,
      $columnEmail TEXT NOT NULL,
      $columnUsuario TEXT NOT NULL,
      $columnContrasena TEXT NOT NULL,
      foto TEXT
    )
    ''');

    // Tabla de posts
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

    // Tabla de cultivos - NUEVA
    await db.execute('''
    CREATE TABLE $tableCultivos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      nombre TEXT NOT NULL,
      tipo_cultivo TEXT NOT NULL,
      variedad TEXT,
      area REAL,
      estado TEXT DEFAULT 'Siembra',
      fecha_siembra TEXT NOT NULL,
      ubicacion TEXT,
      notas TEXT,
      fecha_creacion TEXT NOT NULL,
      fecha_actualizacion TEXT,
      FOREIGN KEY (user_id) REFERENCES $tableUsuarios($columnId)
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

    // Tabla de categorías
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

    // Tabla para registros/seguimiento de cultivos - NUEVA
    await db.execute('''
    CREATE TABLE registros_cultivos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      cultivo_id INTEGER NOT NULL,
      user_id INTEGER NOT NULL,
      tipo_registro TEXT NOT NULL,
      descripcion TEXT,
      valor_numerico REAL,
      unidad TEXT,
      fecha_registro TEXT NOT NULL,
      imagen TEXT,
      ubicacion_gps TEXT,
      clima TEXT,
      temperatura REAL,
      humedad REAL,
      FOREIGN KEY (cultivo_id) REFERENCES $tableCultivos(id),
      FOREIGN KEY (user_id) REFERENCES $tableUsuarios(id)
    )
    ''');

    // Insertar categorías por defecto
    await db.insert('categorias', {'nombre': 'Plagas'});
    await db.insert('categorias', {'nombre': 'Enfermedades'});
    await db.insert('categorias', {'nombre': 'Fertilización'});
    await db.insert('categorias', {'nombre': 'Riego'});
    await db.insert('categorias', {'nombre': 'General'});
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

    // Nueva migración para versión 4 - Agregar cultivos
    if (oldVersion < 4) {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableCultivos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        tipo_cultivo TEXT NOT NULL,
        variedad TEXT,
        area REAL,
        estado TEXT DEFAULT 'Siembra',
        fecha_siembra TEXT NOT NULL,
        ubicacion TEXT,
        notas TEXT,
        fecha_creacion TEXT NOT NULL,
        fecha_actualizacion TEXT,
        FOREIGN KEY (user_id) REFERENCES $tableUsuarios($columnId)
      )
      ''');

      await db.execute('''
      CREATE TABLE IF NOT EXISTS registros_cultivos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cultivo_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        tipo_registro TEXT NOT NULL,
        descripcion TEXT,
        valor_numerico REAL,
        unidad TEXT,
        fecha_registro TEXT NOT NULL,
        imagen TEXT,
        ubicacion_gps TEXT,
        clima TEXT,
        temperatura REAL,
        humedad REAL,
        FOREIGN KEY (cultivo_id) REFERENCES $tableCultivos(id),
        FOREIGN KEY (user_id) REFERENCES $tableUsuarios(id)
      )
      ''');
    }
  }

  // ========== MÉTODOS PARA CULTIVOS ==========

  Future<int> insertarCultivo(Map<String, dynamic> cultivo) async {
    final db = await database;
    return await db.insert(tableCultivos, cultivo);
  }

  Future<List<Map<String, dynamic>>> obtenerCultivosPorUsuario(int userId) async {
    final db = await database;
    return await db.query(
      tableCultivos,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'fecha_creacion DESC',
    );
  }

  Future<List<Map<String, dynamic>>> obtenerTodosLosCultivos() async {
    final db = await database;
    return await db.query(
      tableCultivos,
      orderBy: 'fecha_creacion DESC',
    );
  }

  // Método mejorado para actualizar cultivo con manejo de errores
  Future<int> actualizarCultivo(int id, Map<String, dynamic> valores) async {
    final db = await database;
    try {
      valores['fecha_actualizacion'] = DateTime.now().toIso8601String();
      final result = await db.update(
        tableCultivos,
        valores,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (result == 0) {
        throw Exception('No se encontró el cultivo con ID: $id');
      }

      return result;
    } catch (e) {
      print('Error actualizando cultivo: $e');
      throw Exception('Error al actualizar cultivo: $e');
    }
  }

  // Método mejorado para eliminar cultivo con manejo de errores
  Future<int> eliminarCultivo(int id) async {
    final db = await database;
    try {
      // Verificar que el cultivo existe
      final cultivo = await obtenerCultivoPorId(id);
      if (cultivo == null) {
        throw Exception('No se encontró el cultivo con ID: $id');
      }

      // Usar transacción para asegurar consistencia
      return await db.transaction((txn) async {
        // Eliminar primero los registros relacionados
        await txn.delete('registros_cultivos', where: 'cultivo_id = ?', whereArgs: [id]);

        // Luego eliminar el cultivo
        final result = await txn.delete(tableCultivos, where: 'id = ?', whereArgs: [id]);

        return result;
      });
    } catch (e) {
      print('Error eliminando cultivo: $e');
      throw Exception('Error al eliminar cultivo: $e');
    }
  }

  // Método mejorado para obtener cultivo por ID con manejo de errores
  Future<Map<String, dynamic>?> obtenerCultivoPorId(int id) async {
    final db = await database;
    try {
      final result = await db.query(
        tableCultivos,
        where: 'id = ?',
        whereArgs: [id],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error obteniendo cultivo: $e');
      throw Exception('Error al obtener cultivo: $e');
    }
  }

  // NUEVO: Método para verificar si un cultivo pertenece a un usuario
  Future<bool> verificarPropiedadCultivo(int cultivoId, int userId) async {
    final db = await database;
    try {
      final result = await db.query(
        tableCultivos,
        where: 'id = ? AND user_id = ?',
        whereArgs: [cultivoId, userId],
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Error verificando propiedad del cultivo: $e');
      return false;
    }
  }

  // NUEVO: Obtener cultivos por estado específico
  Future<List<Map<String, dynamic>>> obtenerCultivosPorEstado(int userId, String estado) async {
    final db = await database;
    try {
      return await db.query(
        tableCultivos,
        where: 'user_id = ? AND estado = ?',
        whereArgs: [userId, estado],
        orderBy: 'fecha_creacion DESC',
      );
    } catch (e) {
      print('Error obteniendo cultivos por estado: $e');
      throw Exception('Error al obtener cultivos por estado: $e');
    }
  }

  // NUEVO: Buscar cultivos por nombre o tipo
  Future<List<Map<String, dynamic>>> buscarCultivos(int userId, String termino) async {
    final db = await database;
    try {
      return await db.query(
        tableCultivos,
        where: 'user_id = ? AND (nombre LIKE ? OR tipo_cultivo LIKE ?)',
        whereArgs: [userId, '%$termino%', '%$termino%'],
        orderBy: 'fecha_creacion DESC',
      );
    } catch (e) {
      print('Error buscando cultivos: $e');
      throw Exception('Error al buscar cultivos: $e');
    }
  }

  // NUEVO: Obtener estadísticas detalladas por usuario
  Future<Map<String, dynamic>> obtenerEstadisticasDetalladasCultivos(int userId) async {
    final db = await database;
    try {
      // Total de cultivos
      final totalCultivos = await db.rawQuery(
          'SELECT COUNT(*) as total FROM $tableCultivos WHERE user_id = ?',
          [userId]
      );

      // Cultivos por estado
      final cultivosPorEstado = await db.rawQuery(
          'SELECT estado, COUNT(*) as cantidad FROM $tableCultivos WHERE user_id = ? GROUP BY estado',
          [userId]
      );

      // Área total cultivada
      final areaTotal = await db.rawQuery(
          'SELECT SUM(area) as total_area FROM $tableCultivos WHERE user_id = ?',
          [userId]
      );

      // Cultivo más antiguo
      final cultivoMasAntiguo = await db.query(
        tableCultivos,
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'fecha_siembra ASC',
        limit: 1,
      );

      // Tipos de cultivos únicos
      final tiposCultivos = await db.rawQuery(
          'SELECT DISTINCT tipo_cultivo FROM $tableCultivos WHERE user_id = ?',
          [userId]
      );

      // Cultivos creados en los últimos 30 días
      final treintaDiasAtras = DateTime.now().subtract(Duration(days: 30)).toIso8601String();
      final cultivosRecientes = await db.rawQuery(
          'SELECT COUNT(*) as recientes FROM $tableCultivos WHERE user_id = ? AND fecha_creacion >= ?',
          [userId, treintaDiasAtras]
      );

      return {
        'total_cultivos': (totalCultivos.first['total'] as int?) ?? 0,
        'cultivos_por_estado': cultivosPorEstado,
        'area_total': (areaTotal.first['total_area'] as double?) ?? 0.0,
        'cultivo_mas_antiguo': cultivoMasAntiguo.isNotEmpty ? cultivoMasAntiguo.first : null,
        'tipos_unicos': tiposCultivos.length,
        'cultivos_recientes': (cultivosRecientes.first['recientes'] as int?) ?? 0,
      };
    } catch (e) {
      print('Error obteniendo estadísticas detalladas: $e');
      return {
        'total_cultivos': 0,
        'cultivos_por_estado': <Map<String, dynamic >>[],
        'area_total': 0.0,
        'cultivo_mas_antiguo': null,
        'tipos_unicos': 0,
        'cultivos_recientes': 0,
      };
    }
  }

  // NUEVO: Método para obtener resumen de actividad del cultivo
  Future<Map<String, dynamic>> obtenerResumenActividadCultivo(int cultivoId) async {
    final db = await database;
    try {
      // Total de registros
      final totalRegistros = await db.rawQuery(
          'SELECT COUNT(*) as total FROM registros_cultivos WHERE cultivo_id = ?',
          [cultivoId]
      );

      // Último registro
      final ultimoRegistro = await db.query(
        'registros_cultivos',
        where: 'cultivo_id = ?',
        whereArgs: [cultivoId],
        orderBy: 'fecha_registro DESC',
        limit: 1,
      );

      // Tipos de registros
      final tiposRegistros = await db.rawQuery(
          'SELECT tipo_registro, COUNT(*) as cantidad FROM registros_cultivos WHERE cultivo_id = ? GROUP BY tipo_registro',
          [cultivoId]
      );

      return {
        'total_registros': (totalRegistros.first['total'] as int?) ?? 0,
        'ultimo_registro': ultimoRegistro.isNotEmpty ? ultimoRegistro.first : null,
        'tipos_registros': tiposRegistros,
      };
    } catch (e) {
      print('Error obteniendo resumen de actividad: $e');
      return {
        'total_registros': 0,
        'ultimo_registro': null,
        'tipos_registros': <Map<String, dynamic>>[],
      };
    }
  }

  // MEJORAR: Método existente de insertar cultivo con validaciones
  Future<int> insertarCultivoMejorado(Map<String, dynamic> cultivo) async {
    final db = await database;
    try {
      // Validaciones básicas
      if (cultivo['nombre'] == null || cultivo['nombre'].toString().trim().isEmpty) {
        throw Exception('El nombre del cultivo es obligatorio');
      }

      if (cultivo['user_id'] == null) {
        throw Exception('ID de usuario es obligatorio');
      }

      if (cultivo['tipo_cultivo'] == null || cultivo['tipo_cultivo'].toString().trim().isEmpty) {
        throw Exception('El tipo de cultivo es obligatorio');
      }

      // Asegurar campos obligatorios
      cultivo['fecha_creacion'] = cultivo['fecha_creacion'] ?? DateTime.now().toIso8601String();
      cultivo['estado'] = cultivo['estado'] ?? 'Siembra';
      cultivo['fecha_siembra'] = cultivo['fecha_siembra'] ?? DateTime.now().toIso8601String();

      return await db.insert(tableCultivos, cultivo);
    } catch (e) {
      print('Error insertando cultivo: $e');
      throw Exception('Error al crear cultivo: $e');
    }
  }

  // NUEVO: Método para backup de cultivos de un usuario
  Future<List<Map<String, dynamic>>> exportarCultivosUsuario(int userId) async {
    final db = await database;
    try {
      return await db.rawQuery('''
        SELECT 
          c.*,
          COUNT(r.id) as total_registros,
          MAX(r.fecha_registro) as ultimo_registro
        FROM $tableCultivos c
        LEFT JOIN registros_cultivos r ON c.id = r.cultivo_id
        WHERE c.user_id = ?
        GROUP BY c.id
        ORDER BY c.fecha_creacion DESC
      ''', [userId]);
    } catch (e) {
      print('Error exportando cultivos: $e');
      throw Exception('Error al exportar cultivos: $e');
    }
  }

  // NUEVO: Método para limpiar registros antiguos (mantenimiento)
  Future<int> limpiarRegistrosAntiguos(int diasAntiguedad) async {
    final db = await database;
    try {
      final fechaLimite = DateTime.now()
          .subtract(Duration(days: diasAntiguedad))
          .toIso8601String();

      return await db.delete(
        'registros_cultivos',
        where: 'fecha_registro < ?',
        whereArgs: [fechaLimite],
      );
    } catch (e) {
      print('Error limpiando registros antiguos: $e');
      throw Exception('Error en limpieza de registros: $e');
    }
  }

  // NUEVO: Verificar integridad de la base de datos (diagnóstico)
  Future<Map<String, dynamic>> verificarIntegridadCultivos() async {
    final db = await database;
    try {
      // Cultivos huérfanos (sin usuario válido)
      final cultivosHuerfanos = await db.rawQuery('''
        SELECT COUNT(*) as huerfanos 
        FROM $tableCultivos c 
        LEFT JOIN $tableUsuarios u ON c.user_id = u.id 
        WHERE u.id IS NULL
      ''');

      // Registros huérfanos (sin cultivo válido)
      final registrosHuerfanos = await db.rawQuery('''
        SELECT COUNT(*) as huerfanos 
        FROM registros_cultivos r 
        LEFT JOIN $tableCultivos c ON r.cultivo_id = c.id 
        WHERE c.id IS NULL
      ''');

      return {
        'cultivos_huerfanos': (cultivosHuerfanos.first['huerfanos'] as int?) ?? 0,
        'registros_huerfanos': (registrosHuerfanos.first['huerfanos'] as int?) ?? 0,
        'fecha_verificacion': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error verificando integridad: $e');
      return {
        'cultivos_huerfanos': -1,
        'registros_huerfanos': -1,
        'error': e.toString(),
      };
    }
  }


  // ========== MÉTODOS PARA REGISTROS DE CULTIVOS ==========

  Future<int> insertarRegistroCultivo(Map<String, dynamic> registro) async {
    final db = await database;
    return await db.insert('registros_cultivos', registro);
  }

  Future<List<Map<String, dynamic>>> obtenerRegistrosPorCultivo(int cultivoId) async {
    final db = await database;
    return await db.query(
      'registros_cultivos',
      where: 'cultivo_id = ?',
      whereArgs: [cultivoId],
      orderBy: 'fecha_registro DESC',
    );
  }

  Future<List<Map<String, dynamic>>> obtenerRegistrosPorTipo(int cultivoId, String tipoRegistro) async {
    final db = await database;
    return await db.query(
      'registros_cultivos',
      where: 'cultivo_id = ? AND tipo_registro = ?',
      whereArgs: [cultivoId, tipoRegistro],
      orderBy: 'fecha_registro DESC',
    );
  }

  // ========== MÉTODOS PARA ANÁLISIS Y ESTADÍSTICAS ==========

  Future<Map<String, dynamic>> obtenerEstadisticasCultivos(int userId) async {
    final db = await database;

    // Total de cultivos
    final totalCultivos = await db.rawQuery(
        'SELECT COUNT(*) as total FROM $tableCultivos WHERE user_id = ?',
        [userId]
    );

    // Cultivos por estado
    final cultivosPorEstado = await db.rawQuery(
        'SELECT estado, COUNT(*) as cantidad FROM $tableCultivos WHERE user_id = ? GROUP BY estado',
        [userId]
    );

    // Área total cultivada
    final areaTotal = await db.rawQuery(
        'SELECT SUM(area) as total_area FROM $tableCultivos WHERE user_id = ?',
        [userId]
    );

    return {
      'total_cultivos': (totalCultivos.first['total'] as int?) ?? 0,
      'cultivos_por_estado': cultivosPorEstado,
      'area_total': (areaTotal.first['total_area'] as double?) ?? 0.0,
    };
  }

  // ========== MÉTODOS EXISTENTES (sin cambios) ==========

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
      conflictAlgorithm: ConflictAlgorithm.replace,
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
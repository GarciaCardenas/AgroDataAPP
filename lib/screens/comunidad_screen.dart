import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'video_player_widget.dart';
import 'package:sqflite/sqflite.dart';

class ComunidadScreen extends StatefulWidget {
  @override
  _ComunidadScreenState createState() => _ComunidadScreenState();
}

class _ComunidadScreenState extends State<ComunidadScreen> {
  List<Map<String, dynamic>> posts = [];
  List<String> categorias = [];
  String categoriaSeleccionada = 'Todos';
  String textoBusqueda = '';
  Map<int, bool> _showAllComments = {};

  @override
  void initState() {
    super.initState();
    _initFiltros();
  }

  Future<void> _initFiltros() async {
    final data = await DatabaseHelper.instance.obtenerCategorias();
    setState(() {
      categorias = ['Todos'] + data.map((e) => e['nombre'].toString()).toList();
    });
    await cargarPosts();
  }

  Future<void> cargarPosts() async {
    final datos = await DatabaseHelper.instance.obtenerPosts(
      categoria: categoriaSeleccionada == 'Todos' ? null : categoriaSeleccionada,
      textoBusqueda: textoBusqueda.isEmpty ? null : textoBusqueda,
    );
    setState(() {
      posts = datos;
      _showAllComments = {for (var p in posts) p['id'] as int: false};
    });
  }

  Future<void> agregarComentario(int postId, int userId, String comentario) async {
    final db = await DatabaseHelper.instance.database;
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

  Future<String> obtenerNombreUsuario(int id) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('usuarios', where: 'id = ?', whereArgs: [id]);
    return (result.isNotEmpty && result.first['nombre'] != null)
        ? result.first['nombre'] as String
        : 'Agricultor Anónimo';
  }

  void _toggleCommentsVisibility(int postId) {
    setState(() {
      _showAllComments[postId] = !_showAllComments[postId]!;
    });
  }

  String _timeAgo(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Comunidad Agrícola",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF9C27B0),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Header con estadísticas
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF9C27B0),
                  Color(0xFFBA68C8),
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Red de Agricultores",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Comparte experiencias y aprende de otros profesionales",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Estadísticas de la comunidad
          Container(
            margin: EdgeInsets.fromLTRB(24, 16, 24, 0),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatColumn(Icons.people, "Miembros", "1.2K+"),
                ),
                Container(width: 1, height: 40, color: Colors.grey[200]),
                Expanded(
                  child: _buildStatColumn(Icons.forum, "Posts", "856"),
                ),
                Container(width: 1, height: 40, color: Colors.grey[200]),
                Expanded(
                  child: _buildStatColumn(Icons.trending_up, "Activos hoy", "127"),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Filtros y búsqueda
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Barra de búsqueda mejorada
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar en la comunidad...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) async {
                      setState(() => textoBusqueda = value.trim());
                      await cargarPosts();
                    },
                  ),
                ),

                SizedBox(height: 16),

                // Chips de categorías mejorados
                Container(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categorias.length,
                    itemBuilder: (context, index) {
                      final categoria = categorias[index];
                      final isSelected = categoria == categoriaSeleccionada;
                      return Container(
                        margin: EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            categoria,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Color(0xFF9C27B0),
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) async {
                            setState(() => categoriaSeleccionada = categoria);
                            await cargarPosts();
                          },
                          selectedColor: Color(0xFF9C27B0),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: isSelected ? Color(0xFF9C27B0) : Colors.grey[300]!,
                            width: 1,
                          ),
                          elevation: isSelected ? 2 : 0,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Lista de posts
          Expanded(
            child: posts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: posts.length,
              itemBuilder: (ctx, idx) => _buildPostCard(posts[idx]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        icon: Icon(Icons.add),
        label: Text("Nuevo Post"),
        onPressed: () =>
            Navigator.pushNamed(context, '/new_post').then((_) => cargarPosts()),
      ),
    );
  }

  Widget _buildStatColumn(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Color(0xFF9C27B0), size: 20),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.forum_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            "No hay publicaciones",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            "¡Sé el primero en compartir algo!",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final showAll = _showAllComments[post['id']] ?? false;
    final comentarioController = TextEditingController();

    return FutureBuilder<String>(
      future: obtenerNombreUsuario(post['user_id']),
      builder: (ctx, snapUser) {
        final nombreUsuario = snapUser.data ?? 'Cargando...';

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: DatabaseHelper.instance.obtenerComentarios(post['id']),
          builder: (ctx2, snapComments) {
            final comentarios = snapComments.data ?? [];

            return Container(
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header del post
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Color(0xFF9C27B0),
                          radius: 20,
                          child: Text(
                            nombreUsuario.isNotEmpty ? nombreUsuario[0].toUpperCase() : 'A',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nombreUsuario,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Text(
                                _timeAgo(post['fecha']),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.more_vert,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                      ],
                    ),
                  ),

                  // Contenido del post
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      post['contenido'],
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),

                  // Media (imagen/video)
                  if (post['imagen']?.isNotEmpty ?? false) ...[
                    SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullScreenMediaView(path: post['imagen']),
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: post['imagen'].endsWith(".mp4")
                              ? SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: VideoPlayerWidget(videoFile: File(post['imagen'])),
                          )
                              : Image.file(
                            File(post['imagen']),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 16),

                  // Acciones (likes, comentarios)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        FutureBuilder<int>(
                          future: DatabaseHelper.instance.obtenerLikes(post['id']),
                          builder: (_, snapLikes) {
                            final count = snapLikes.data ?? 0;
                            return InkWell(
                              onTap: () async {
                                final prefs = await SharedPreferences.getInstance();
                                final userId = prefs.getInt('userId');
                                if (userId != null) {
                                  await DatabaseHelper.instance.agregarLike(post['id'], userId);
                                  await cargarPosts();
                                }
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.favorite,
                                      color: count > 0 ? Colors.red : Colors.grey[400],
                                      size: 20,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '$count',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 16),
                        InkWell(
                          onTap: () => _toggleCommentsVisibility(post['id']),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.comment_outlined,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${comentarios.length}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Comentarios
                  if (comentarios.isNotEmpty) ...[
                    Divider(height: 1, color: Colors.grey[200]),
                    _buildCommentsSection(comentarios, showAll, post['id']),
                  ],

                  // Input para nuevo comentario
                  Divider(height: 1, color: Colors.grey[200]),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          radius: 16,
                          child: Icon(Icons.person, size: 18, color: Colors.grey[600]),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextField(
                              controller: comentarioController,
                              decoration: InputDecoration(
                                hintText: "Escribe un comentario...",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF9C27B0),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.send, color: Colors.white, size: 18),
                            onPressed: () async {
                              final prefs = await SharedPreferences.getInstance();
                              final userId = prefs.getInt('userId');
                              final text = comentarioController.text.trim();
                              if (userId != null && text.isNotEmpty) {
                                await agregarComentario(post['id'], userId, text);
                                comentarioController.clear();
                                setState(() => _showAllComments[post['id']] = true);
                                await cargarPosts();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCommentsSection(List<Map<String, dynamic>> comentarios, bool showAll, int postId) {
    final displayed = showAll ? comentarios : comentarios.take(2).toList();

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...displayed.map((comentario) => Container(
            margin: EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  radius: 16,
                  child: Text(
                    (comentario['nombre'] ?? 'A')[0].toUpperCase(),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comentario['nombre'] ?? 'Agricultor Anónimo',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            comentario['fecha'] != null
                                ? _timeAgo(comentario['fecha'])
                                : '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        comentario['comentario'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),

          if (comentarios.length > 2)
            TextButton(
              onPressed: () => _toggleCommentsVisibility(postId),
              child: Text(
                showAll
                    ? "Ver menos comentarios"
                    : "Ver ${comentarios.length - 2} comentarios más",
                style: TextStyle(
                  color: Color(0xFF9C27B0),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FullScreenMediaView extends StatelessWidget {
  final String path;
  const FullScreenMediaView({required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: path.endsWith(".mp4")
            ? VideoPlayerWidget(videoFile: File(path))
            : InteractiveViewer(
          child: Image.file(File(path)),
        ),
      ),
    );
  }
}
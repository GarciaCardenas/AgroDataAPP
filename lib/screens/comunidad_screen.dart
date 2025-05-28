import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'video_player_widget.dart';
import 'package:sqflite/sqflite.dart';
import 'video_player_widget.dart';
import 'dart:io';

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
    // Cargar categorías
    final data = await DatabaseHelper.instance.obtenerCategorias();
    setState(() {
      categorias = ['Todos'] + data.map((e) => e['nombre'].toString()).toList();
    });
    // Cargar posts iniciales
    await cargarPosts();
  }

  Future<void> cargarPosts() async {
    final datos = await DatabaseHelper.instance.obtenerPosts(
      categoria: categoriaSeleccionada == 'Todos' ? null : categoriaSeleccionada,
      textoBusqueda: textoBusqueda.isEmpty ? null : textoBusqueda,
    );
    setState(() {
      posts = datos;
      _showAllComments = { for (var p in posts) p['id'] as int : false };
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
        : 'Anónimo';
  }

  void _toggleCommentsVisibility(int postId) {
    setState(() {
      _showAllComments[postId] = !_showAllComments[postId]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Comunidad"), backgroundColor: Colors.green),
      body: Column(
        children: [
          // Chips de categorías
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Row(
              children: categorias.map((cat) {
                final selected = cat == categoriaSeleccionada;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (_) async {
                      setState(() => categoriaSeleccionada = cat);
                      await cargarPosts();
                    },
                    selectedColor: Colors.green[300],
                    backgroundColor: Colors.grey[200],
                  ),
                );
              }).toList(),
            ),
          ),

          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: (value) async {
                setState(() => textoBusqueda = value.trim());
                await cargarPosts();
              },
            ),
          ),

          // Lista de posts
          Expanded(
            child: posts.isEmpty
                ? Center(child: Text("No hay publicaciones"))
                : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (ctx, idx) => _buildPostCard(posts[idx]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
        onPressed: () =>
            Navigator.pushNamed(context, '/new_post').then((_) => cargarPosts()),
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
            final displayed = <Widget>[];

            if (comentarios.isNotEmpty) {
              final lista = showAll ? comentarios : [comentarios.first];
              for (var c in lista) {
                final fecha = c['fecha'] != null
                    ? DateTime.parse(c['fecha']).toLocal().toString().split('.')[0]
                    : '';
                displayed.addAll([
                  Text("${c['nombre'] ?? 'Anónimo'} - $fecha",
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(c['comentario'] ?? ''),
                  SizedBox(height: 4),
                ]);
              }
              if (comentarios.length > 1) {
                displayed.add(TextButton(
                  onPressed: () => _toggleCommentsVisibility(post['id']),
                  child: Text(showAll
                      ? "Ver menos"
                      : "Ver más (${comentarios.length - 1} más)"),
                ));
              }
            }

            return Card(
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nombreUsuario,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text(post['contenido']),
                    if (post['imagen']?.isNotEmpty ?? false) ...[
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FullScreenMediaView(path: post['imagen']),
                          ),
                        ),
                        child: post['imagen'].endsWith(".mp4")
                            ? SizedBox(
                          height: 250,
                          child: VideoPlayerWidget(
                              videoFile: File(post['imagen'])),
                        )
                            : Image.file(File(post['imagen']), height: 250),
                      ),
                    ],
                    SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.thumb_up, color: Colors.green),
                          onPressed: () async {
                            final prefs =
                            await SharedPreferences.getInstance();
                            final userId = prefs.getInt('userId');
                            if (userId != null) {
                              await DatabaseHelper.instance
                                  .agregarLike(post['id'], userId);
                              await cargarPosts();
                            }
                          },
                        ),
                        FutureBuilder<int>(
                          future:
                          DatabaseHelper.instance.obtenerLikes(post['id']),
                          builder: (_, snapLikes) {
                            final count = snapLikes.data ?? 0;
                            return Text('$count likes',
                                style: TextStyle(fontWeight: FontWeight.bold));
                          },
                        ),
                      ],
                    ),
                    Divider(),

                    // Comentarios
                    ...displayed,

                    // Nuevo comentario
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: comentarioController,
                            decoration: InputDecoration(
                              hintText: "Escribe un comentario",
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () async {
                            final prefs =
                            await SharedPreferences.getInstance();
                            final userId = prefs.getInt('userId');
                            final text = comentarioController.text.trim();
                            if (userId != null && text.isNotEmpty) {
                              await agregarComentario(
                                  post['id'], userId, text);
                              comentarioController.clear();
                              setState(() =>
                              _showAllComments[post['id']] = true);
                              await cargarPosts();
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Publicado el ${DateTime.parse(post['fecha']).toLocal().toString().split('.')[0]}",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
            : Image.file(File(path)),
      ),
    );
  }
}
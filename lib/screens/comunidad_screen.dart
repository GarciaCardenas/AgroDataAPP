import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'video_player_widget.dart'; // Asegúrate de que la ruta sea correcta


class ComunidadScreen extends StatefulWidget {
  @override
  _ComunidadScreenState createState() => _ComunidadScreenState();
}

class _ComunidadScreenState extends State<ComunidadScreen> {
  List<Map<String, dynamic>> posts = [];
  Map<int, bool> _showAllComments = {}; // Mapa para rastrear la visibilidad de los comentarios por postId

  Future<void> cargarPosts() async {
    final datos = await DatabaseHelper.instance.obtenerPosts();
    setState(() {
      posts = datos;
      // Inicializar el estado de visibilidad para cada post
      for (var post in posts) {
        _showAllComments[post['id']] = false;
      }
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

    if (result.isNotEmpty && result.first['nombre'] != null) {
      return result.first['nombre'] as String;
    } else {
      return '';
    }
  }

  void _toggleCommentsVisibility(int postId) {
    setState(() {
      _showAllComments[postId] = !_showAllComments[postId]!;
    });
  }

  @override
  void initState() {
    super.initState();
    cargarPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Comunidad"), backgroundColor: Colors.green),
      body: posts.isEmpty
          ? Center(child: Text("No hay publicaciones aún"))
          : ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            final comentarioController = TextEditingController();
            final showAll = _showAllComments[post['id']] ?? false;

            return FutureBuilder<String>(
              future: obtenerNombreUsuario(post['user_id']),
              builder: (context, snapshot) {
                final nombreUsuario = snapshot.data ?? "Cargando...";

                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: DatabaseHelper.instance.obtenerComentarios(post['id']),
                  builder: (context, comentarioSnapshot) {
                    final comentarios = comentarioSnapshot.data ?? [];
                    List<Widget> displayedComments = [];

                    if (comentarios.isNotEmpty) {
                      if (!showAll && comentarios.length > 1) {
                        final primerComentario = comentarios.first;
                        final nombre = primerComentario['nombre'] ?? "Anónimo";
                        final fecha = primerComentario['fecha'] != null
                            ? DateTime.parse(primerComentario['fecha']).toLocal().toString().split('.')[0]
                            : "";
                        final texto = primerComentario['comentario'] ?? "";
                        displayedComments.add(
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "$nombre - $fecha",
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(texto),
                              ],
                            ),
                          ),
                        );
                      } else {
                        displayedComments = comentarios.map((comentario) {
                          final nombre = comentario['nombre'] ?? "Anónimo";
                          final fecha = comentario['fecha'] != null
                              ? DateTime.parse(comentario['fecha']).toLocal().toString().split('.')[0]
                              : "";
                          final texto = comentario['comentario'] ?? "";

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "$nombre - $fecha",
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(texto),
                              ],
                            ),
                          );
                        }).toList();
                      }
                    }

                    return Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 600),
                        child: Card(
                          margin: EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 5,
                          child: Padding(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(nombreUsuario, style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 5),
                                Text(post['contenido']),
                                SizedBox(height: 10),
                                if (post['imagen'].isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => FullScreenMediaView(path: post['imagen']),
                                        ),
                                      );
                                    },
                                    child: post['imagen'].endsWith(".mp4")
                                        ? SizedBox(
                                      height: 200, // Ajusta la altura según necesites
                                      width: double.infinity,
                                      child: VideoPlayerWidget(videoFile: File(post['imagen'])),
                                    )
                                        : Image.file(File(post['imagen']), height: 200),
                                  ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.thumb_up, color: Colors.green),
                                      onPressed: () async {
                                        final prefs = await SharedPreferences.getInstance();
                                        final userId = prefs.getInt('userId');
                                        if (userId != null) {
                                          await DatabaseHelper.instance.agregarLike(post['id'], userId);
                                          await cargarPosts();
                                        }
                                      },
                                    ),
                                    FutureBuilder<int>(
                                      future: DatabaseHelper.instance.obtenerLikes(post['id']),
                                      builder: (context, snap) {
                                        final likeCount = snap.data ?? 0;
                                        return Text('$likeCount likes', style: TextStyle(fontWeight: FontWeight.bold));
                                      },
                                    ),
                                  ],
                                ),
                                Text("Comentarios:", style: TextStyle(fontWeight: FontWeight.bold)),
                                ...displayedComments,
                                if (comentarios.length > 1)
                                  TextButton(
                                    onPressed: () => _toggleCommentsVisibility(post['id']),
                                    child: Text(showAll ? "Ver menos" : "Ver más (${comentarios.length - 1} más)"),
                                  ),
                                SizedBox(height: 8),
                                TextField(
                                  controller: comentarioController,
                                  decoration: InputDecoration(
                                    labelText: "Escribe un comentario",
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.send),
                                      onPressed: () async {
                                        final prefs = await SharedPreferences.getInstance();
                                        final userId = prefs.getInt('userId');
                                        final text = comentarioController.text.trim();
                                        if (userId != null && text.isNotEmpty) {
                                          await agregarComentario(post['id'], userId, text);
                                          comentarioController.clear();
                                          // Después de agregar un comentario, por lo general querrás mostrar todos los comentarios
                                          setState(() {
                                            _showAllComments[post['id']] = true;
                                          });
                                          await cargarPosts();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Publicado el ${DateTime.parse(post['fecha']).toLocal().toString().split('.')[0]}",
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/new_post').then((_) => cargarPosts());
        },
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
            : Image.file(File(path)),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';

class ComunidadScreen extends StatefulWidget {
  @override
  _ComunidadScreenState createState() => _ComunidadScreenState();
}

class _ComunidadScreenState extends State<ComunidadScreen> {
  List<Map<String, dynamic>> posts = [];

  Future<void> cargarPosts() async {
    final datos = await DatabaseHelper.instance.obtenerPosts();
    setState(() {
      posts = datos;
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

            return FutureBuilder<String>(
              future: obtenerNombreUsuario(post['user_id']),
              builder: (context, snapshot) {
                final nombreUsuario = snapshot.data ?? "Cargando...";

                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: DatabaseHelper.instance.obtenerComentarios(post['id']),
                  builder: (context, comentarioSnapshot) {
                    final comentarios = comentarioSnapshot.data ?? [];

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
                                        ? Icon(Icons.videocam, size: 100)
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
                                ...comentarios.map((comentario) {
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
                                }).toList(),

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
            ? Text("Reproductor de video no implementado. Usa video_player.") // o usa video_player aquí
            : Image.file(File(path)),
      ),
    );
  }
}


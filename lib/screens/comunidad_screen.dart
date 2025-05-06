import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

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

  Future<String> obtenerNombreUsuario(int id) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('usuarios', where: 'id = ?', whereArgs: [id]);

    if (result.isNotEmpty && result.first['nombre'] != null) {
      return result.first['nombre'] as String;
    } else {
      return ''; // o puedes lanzar una excepción
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
          return FutureBuilder<String>(
            future: obtenerNombreUsuario(post['user_id']),
            builder: (context, snapshot) {
              final nombreUsuario = snapshot.data ?? "Cargando...";
              return Card(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.thumb_up, color: Colors.green),
                          SizedBox(width: 10),
                          Icon(Icons.comment, color: Colors.green),
                        ],
                      ),
                      SizedBox(height: 5),
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
      ),
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

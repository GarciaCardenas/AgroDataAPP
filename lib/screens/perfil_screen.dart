import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'custom_drawer.dart';

class PerfilScreen extends StatefulWidget {
  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  int? userId;

  @override
  void initState() {
    super.initState();
    cargarUsuario();
  }

  Future<void> cargarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');

    if (userId != null) {
      final db = DatabaseHelper.instance;
      final usuario = await db.obtenerUsuarioPorId(userId!);

      if (usuario != null) {
        setState(() {
          nameController.text = usuario['nombre'] ?? '';
          emailController.text = usuario['email'] ?? '';
        });
      }
    }
  }

  Future<void> actualizarPerfil() async {
    if (userId != null) {
      final db = DatabaseHelper.instance;
      await db.actualizarUsuario(userId!, {
        'nombre': nameController.text,
        'email': emailController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Perfil actualizado")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(context),
      appBar: AppBar(
        title: Text("Mi Perfil"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.green,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Nombre completo"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Correo electrónico"),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: actualizarPerfil,
              child: Text("Guardar cambios"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

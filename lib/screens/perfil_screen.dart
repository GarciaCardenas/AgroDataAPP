import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'custom_drawer.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


class PerfilScreen extends StatefulWidget {
  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  int? userId;
  bool isEditing = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    cargarUsuario();

  }

  Future<void> cargarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId != null) {
      // Carga el usuario desde la base de datos
      final usuario = await DatabaseHelper.instance.obtenerUsuarioPorId(userId);

      if (usuario != null && usuario['foto'] != null) {
        rutaFoto = usuario['foto'];
        _imagenPerfil = File(rutaFoto!);
      }
    }




    if (userId != null) {
      final db = DatabaseHelper.instance;
      final usuario = await db.obtenerUsuarioPorId(userId!);

      if (usuario != null) {
        setState(() {
          nameController.text = usuario['nombre'] ?? '';
          emailController.text = usuario['email'] ?? '';
          // Si guardas ruta de imagen en BD, podrías cargarla aquí también
        });
      }
    }
  }

  File? _imagenPerfil;
  String? rutaFoto;

  Future<void> seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagenPerfil = File(pickedFile.path);
        rutaFoto = pickedFile.path;
      });
    }
  }


  Future<void> actualizarPerfil() async {
    if (userId != null) {
      final db = DatabaseHelper.instance;
      await db.actualizarUsuario(userId!, {
        'nombre': nameController.text,
        'email': emailController.text,
        'foto': rutaFoto,
        // puedes guardar ruta de imagen si la manejas con persistencia
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Perfil actualizado")));

      setState(() {
        isEditing = false;
      });
    }
  }

  Future<void> _elegirImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        // Aquí podrías guardar la ruta en la BD
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(context),
      appBar: AppBar(
        title: Text("Mi Perfil"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: isEditing ? _elegirImagen : null,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _imagenPerfil != null
                    ? FileImage(_imagenPerfil!)
                    : (rutaFoto != null ? FileImage(File(rutaFoto!)) : null),
                child: _imagenPerfil == null && rutaFoto == null
                    ? Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
                backgroundColor: Colors.green,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Nombre completo"),
              readOnly: !isEditing,
            ),
            SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Correo electrónico"),
              readOnly: !isEditing,
            ),
            SizedBox(height: 30),
            if (isEditing)
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

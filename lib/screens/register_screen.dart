import 'package:flutter/material.dart';
import 'database_helper.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registro"), backgroundColor: Colors.green),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Nombre completo", border: OutlineInputBorder()),
            ),
            SizedBox(height: 15),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Correo electrónico", border: OutlineInputBorder()),
            ),
            SizedBox(height: 15),
            TextField(
              controller: userController,
              decoration: InputDecoration(labelText: "Nombre de usuario", border: OutlineInputBorder()),
            ),
            SizedBox(height: 15),
            TextField(
              controller: passController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Contraseña", border: OutlineInputBorder()),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                final db = DatabaseHelper.instance;
                await db.insertarUsuario({
                  'nombre': nameController.text,
                  'email': emailController.text,
                  'usuario': userController.text,
                  'contrasena': passController.text,
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Usuario registrado exitosamente")),
                );
                Navigator.pop(context);
              },
              child: Text("Registrarse"),
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

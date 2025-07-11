import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Registro"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Transform.rotate(
              angle: 3.1416,
              child: Image.asset(
                'assets/images/inicio.png',
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.55),
                colorBlendMode: BlendMode.darken,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: userController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8), // Transparencia
                      labelText: "Nombre de usuario",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: passController,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9), // Transparencia
                      labelText: "Contraseña",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      final db = DatabaseHelper.instance;

                      await db.insertarUsuario({
                        'nombre': userController.text,                      // Usa el mismo valor que el usuario
                        'email': '${userController.text}@correo.com',       // Correo ficticio automático
                        'usuario': userController.text,
                        'contrasena': passController.text,
                      });


                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('savedUsername', userController.text);
                      await prefs.setString('savedPassword', passController.text);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Usuario registrado exitosamente")),
                      );
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    child: const Text(
                      "Registrarse",
                      style: TextStyle(color: Colors.black), // 🟢 Texto en negro
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text(
                      "¿Ya tienes cuenta? Inicia sesión",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

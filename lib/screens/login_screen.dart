import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  void _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    userController.text = prefs.getString('savedUsername') ?? '';
    passController.text = prefs.getString('savedPassword') ?? '';
  }

  Future<void> _guardarCredenciales(String usuario, String contrasena) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedUsername', usuario);
    await prefs.setString('savedPassword', contrasena);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade700, Colors.green.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    Icon(Icons.agriculture, size: 80, color: Colors.green),
                    SizedBox(height: 20),
                    TextField(
                      controller: userController,
                      decoration: InputDecoration(
                        labelText: 'Usuario',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: passController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () async {
                        final db = DatabaseHelper.instance;
                        final user = await db.validarLogin(
                          userController.text,
                          passController.text,
                        );

                        if (user != null) {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setInt('userId', user['id']);
                          await prefs.setString('usuario', user['nombre']);
                          await prefs.setString('email', user['email']);

                          // Guardar credenciales para el próximo inicio automático
                          await _guardarCredenciales(
                            userController.text,
                            passController.text,
                          );

                          Navigator.pushReplacementNamed(context, '/home');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Usuario o contraseña incorrectos")),
                          );
                        }
                      },
                      child: Text("Iniciar sesión"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Aquí podrías agregar lógica para recuperación de contraseña
                      },
                      child: Text("¿Olvidaste tu contraseña?"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text("¿No tienes cuenta? Regístrate aquí"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'custom_drawer.dart';

class PerfilScreen extends StatelessWidget {
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
            Text("Nombre del Usuario", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("usuario@correo.com", style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 30),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text("Editar Perfil"),
              onTap: () {
                // Aquí puedes redirigir a otra pantalla o mostrar un formulario
              },
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text("Cambiar Contraseña"),
              onTap: () {
                // Función para cambiar contraseña
              },
            ),
          ],
        ),
      ),
    );
  }
}

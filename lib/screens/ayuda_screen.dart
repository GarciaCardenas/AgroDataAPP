import 'package:flutter/material.dart';
import 'custom_drawer.dart';

class AyudaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(context),
      appBar: AppBar(
        title: Text("Ayuda"),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Text("Preguntas Frecuentes", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          ExpansionTile(
            title: Text("¿Cómo escaneo una planta?"),
            children: [Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Ve a la pantalla principal y presiona 'Escanear planta'. Asegúrate de dar permisos a la cámara."),
            )],
          ),
          ExpansionTile(
            title: Text("¿Qué hago si olvidé mi contraseña?"),
            children: [Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("En la pantalla de inicio de sesión, presiona '¿Olvidaste tu contraseña?' para recuperarla."),
            )],
          ),
          ExpansionTile(
            title: Text("¿Cómo accedo a la comunidad?"),
            children: [Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Desde la pantalla principal, selecciona 'Ir a la comunidad'."),
            )],
          ),
        ],
      ),
    );
  }
}
